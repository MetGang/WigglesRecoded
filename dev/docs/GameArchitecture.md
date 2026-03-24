# Wiggles/Diggles Game Architecture

Technical reference for the Wiggles/Diggles engine, scripting system, and game data. This document describes how the **original game** works under the hood.

---

## Engine Overview

Wiggles/Diggles runs on a custom C++ engine with an embedded **Tcl 8.3** interpreter. The engine handles rendering, physics, audio, and I/O, while virtually all gameplay logic lives in plain-text Tcl scripts under `data/`.

### Runtime Binaries

| File | Purpose |
|------|---------|
| `Diggles.exe` / `Wiggles.exe` | Main executable |
| `DigglesPort.dll` | Core engine with Tcl bindings |
| `tcl83.dll` | Tcl 8.3 interpreter |
| `SDL2.dll` | Multimedia layer |

---

## Directory Structure

```
data/
├── 3db/            42 binary 3D model files (.3db)
├── GameScripts/    50 scenario/mission definitions (.tcl)
├── Ground/         Ground textures with detail maps
├── GUI/            UI assets (buttons/, icons/, stateicons/, deco/, Fonts/, docpix/)
├── Music/          226 MP3 tracks
├── Scripts/        482 Tcl files, 112k lines — all game logic
├── Shaders/        21 HLSL/FX shader files
├── Sound/          ~1200 WAV effects, organized by source
├── Templates/      ~2000 files for procedural level generation
├── Texture/        2656 TGA textures (m032/, m064/, m128/, m256/, ClassIcons/)
└── MESSAGES.TXT    Master localization file
```

---

## Script Organization

```
Scripts/
├── init/                   System initialization
│   ├── classinit.tcl       Main class loader — loads everything below
│   ├── LGINIT.TCL          Level generation templates
│   ├── LGTOOLS.TCL         Level generation tools
│   ├── claninit.tcl        Clan system
│   ├── TALKINIT.TCL        Dialog system
│   ├── EVENTGEN.TCL        Event generation
│   ├── soundinit.tcl       Sound system
│   ├── animinit.tcl        Animation system
│   ├── shader.tcl          Shader system
│   ├── fight.tcl           Combat system
│   ├── mpinit.tcl          Multiplayer
│   └── customcommands.tcl  Helper procedures
│
├── classes/
│   ├── characters/         NPCs and creatures (18 files)
│   │                       trolls, odin, fenris, hamster, spinne, fisch, etc.
│   ├── zwerg/              Gnome/dwarf system (19 files) — core mechanic
│   │   ├── zwerg.tcl       Main gnome class definition
│   │   ├── pzwerg.tcl      Playable gnome variant
│   │   ├── actors.tcl      Actor gnomes
│   │   ├── baby.tcl        Baby gnomes
│   │   ├── z_work_*.tcl    Work behavior (common, states, strike, prod, prodfill)
│   │   ├── z_spare_*.tcl   Spare time (main, fun, procs, reprod, talk)
│   │   ├── z_events.tcl    Event handling
│   │   ├── z_procs.tcl     Helper procedures
│   │   ├── z_anims.tcl     Animation definitions
│   │   ├── z_dignwalk.tcl  Digging and walking
│   │   └── z_faceanim.tcl  Face animations
│   ├── items/              Items and materials (20+ files)
│   │                       werkzeuge, waffen, rohstoffe, pilz, magie, etc.
│   ├── work/               Production buildings (30+ files)
│   │                       schmiede, saegewerk, farm, labor, brauerei, etc.
│   ├── sparetime/          Recreation buildings (18 files)
│   │                       bar, disco, theater, baths, bedrooms, tempel, etc.
│   ├── story/              Quests and narrative (15 files)
│   │                       story.tcl, sequencer.tcl, world triggers, etc.
│   └── deco/               Decorative objects (10 files)
│
├── ai/                     std_ai.tcl — NPC behavior
├── gameplay/               Game modes and tech tree
│   ├── techtree.tcl        Production chain definitions
│   ├── Campaign*.tcl       Campaign game modes
│   └── Sandbox*.tcl        Sandbox modes
├── misc/                   Shared utilities
│   ├── utility.tcl         Helper functions
│   ├── autodef.tcl         Simplified class definition helper
│   ├── genericprod.tcl     Generic production system (shared by all buildings)
│   ├── genericfight.tcl    Generic fight system
│   ├── genattribs.tcl      Generic attributes
│   └── ...
├── sequences/              Cinematics (organized by world)
└── text/                   Localization and dialogs
    ├── talk/               Dialog files (commontalk, worktalk, sparetalk, etc.)
    ├── info/               Info text
    └── doc/                In-game documentation (per locale: de/, en/, pl/)
```

### Class Loading Order

`classinit.tcl` loads classes in this fixed order:

1. `classes/characters/*.tcl` (files with `_` prefix are **skipped** — loaded by parent files)
2. `classes/items/*.tcl`
3. `classes/deco/*.tcl`
4. `classes/work/*.tcl`
5. `classes/sparetime/*.tcl`
6. `classes/story/*.tcl` (except `sequencer.tcl`)
7. `classes/zwerg/` — explicitly: `zwerg.tcl`, `pzwerg.tcl`, `actors.tcl`, `baby.tcl`

A **startcache** system can pre-compile definitions for faster loading.

---

## Object System

### `def_class`

Every game entity is defined through `def_class`:

```tcl
def_class ClassName ParentMaterial ObjectType PhysicsEnabled {Flags} {
    # Class body
}
```

| Parameter | Values | Description |
|-----------|--------|-------------|
| `ClassName` | Any unique name | Class identifier |
| `ParentMaterial` | `none` `wood` `stone` `metal` | Material category |
| `ObjectType` | `none` `material` `production` `energy` `service` `store` `elevator` `protection` `dummy` | Behavior type |
| `PhysicsEnabled` | `0` `1` | Physics simulation |
| `Flags` | `{}` `{reproduces}` `{lives}` `{moves}` `{reproduces lives moves}` | Special behavior |

### Class Body Structure

```tcl
def_class MyClass wood production 0 {} {
    # 1. Load shared scripts
    call scripts/misc/animclassinit.tcl
    call scripts/misc/genericprod.tcl

    # 2. Class-level settings
    class_defaultanim myclass.standard
    class_fightdist 2.0
    class_viewinfog 1
    class_flagoffset 1.6 -1.8

    # 3. Members (persistent state)
    set my_member_var 0
    member my_member_var

    # 4. Events
    def_event evt_my_event
    handle_event evt_my_event {
        # handler code
    }

    # 5. Methods
    method my_method {arg1} {
        # instance method — 'this' = current object
    }

    method_static my_static {} {
        # class method — no 'this'
    }

    # 6. Constructor
    obj_init {
        # Runs for each new instance
        set_anim this myclass.standard 0 $ANIM_STILL
        set_viewinfog this 1
        set_physic this 1
    }
}
```

### Helper Classes

Classes prefixed with `_` are service/helper classes loaded by their parent file, not by classinit:

```tcl
def_class _Nahrung_einlagern  service material 1 {} {}
def_class _Kisten_einlagern   service material 1 {} {}
```

### Attributes

```tcl
# Define an attribute type (global)
def_attrib AttributeName MinValue MaxValue DefaultValue

# Read/write on objects
get_attrib $obj AttributeName
set_attrib $obj AttributeName $value
add_attrib $obj AttributeName $delta
```

### Events

```tcl
# Define and handle
def_event evt_name
handle_event evt_name { ... }

# Fire
set_event $target evt_name -target $target

# Get event data
set source [event_get this -subject1]
```

### Timers

```tcl
timer_event this evt_timer_name -repeat 1 -interval 10 -userid 0 -attime [expr [gettime]+5]
```

---

## Tech Tree

`Scripts/gameplay/techtree.tcl` defines all production chains:

```tcl
{
Grillpilz   Food   Material   1   {}
    {Pilz}              // required materials
    {}                  // required tools
    {}                  // required blueprints
    {Feuerstelle}       // required workplace
}
```

| Field | Description |
|-------|-------------|
| name | Class name of the product |
| category | `Food`, `Weapons`, `Tools`, etc. |
| type | `Material`, `Location`, `Tool`, `Blueprint` |
| era | Technology era (1, 2, 3) |
| flags | `{reproduces}` for renewable resources |
| materials | Input material classes |
| tools | Required tool classes |
| blueprints | Required blueprint classes |
| places | Workplace building classes |

---

## Gnome State Machine

Gnomes (`zwerg`) are the core game mechanic. They operate on a state machine:

```
idle → task → work_dispatch → work_idle → work_active → work_breakable
                                  ↓
                             sparetime
```

States are managed across multiple files:
- `z_work_common.tcl` — work coordination
- `z_work_prod.tcl` — production tasks
- `z_work_states.tcl` — state transitions
- `z_work_strike.tcl` — strike behavior
- `z_spare_main.tcl` — spare time activities
- `z_spare_fun.tcl` — fun activities
- `z_spare_reprod.tcl` — reproduction
- `z_spare_talk.tcl` — conversations

---

## Template System

Levels are procedurally generated from templates:

| Extension | Content |
|-----------|---------|
| `.tcl` | Script that spawns objects and configures the area |
| `.l2m` | Layer map (2D texture/collision data) |
| `.pmp` | Polygon map (terrain geometry) |
| `.ent` | Entity placement list |

Template naming:
- `urw_` = Urwald (forest), `kris_` = Kristall (crystal), `lava_` = Lava, `swf_` = Schwefel (sulfur)
- `_gng_` = corridor, `_hol_` = cave, `_unq_` = unique location

`LGINIT.TCL` and `LGTOOLS.TCL` manage template group registration and random selection during generation.

---

## Engine API

Commands provided by the C++ engine (DigglesPort.dll). Not exhaustive.

### Object Lifecycle

| Command | Description |
|---------|-------------|
| `new ClassName` | Create instance |
| `del object` | Delete object |
| `destruct object` | Destruct (triggers cleanup) |
| `obj_valid object` | Check if reference is valid |
| `obj_query base "options"` | Query objects (see below) |

**Query options:** `-class Name`, `-type Type`, `-owner player`, `-limit N`, `-boundingbox {x1 y1 z1 x2 y2 z2}`

### Position / Physics

| Command | Description |
|---------|-------------|
| `get_pos obj` | Get position `{x y z}` |
| `set_pos obj {x y z}` | Set position |
| `vector_add {a} {b}` | Vector addition |
| `get_physic obj` / `set_physic obj 0\|1` | Physics state |
| `get_boxed obj` | Is object packed for transport |

### Properties

| Command | Description |
|---------|-------------|
| `get_objclass obj` | Class name |
| `get_objname obj` | Object name |
| `get_objtype obj` | Object type |
| `get_ref obj` | Object reference |
| `get_owner obj` / `set_owner obj val` | Owner |
| `get_lock obj` | Lock state |
| `is_contained obj` | Is inside another object |
| `set_selectable obj 0\|1` | Selectable by player |
| `set_hoverable obj 0\|1` | Mouse hover highlight |
| `set_storable obj 0\|1` | Can be stored |
| `set_viewinfog obj 0\|1` | Visible through fog of war |
| `set_fogofwar obj rx ry` | Fog of war reveal radius (-1 to disable) |

### Animations

| Command | Description |
|---------|-------------|
| `set_anim obj name set mode` | Play animation (`$ANIM_STILL`, `$ANIM_LOOP`, `$ANIM_ONCE`) |
| `class_defaultanim name` | Default animation for class |
| `set_class_anim class set name` | Map animation set |

### Visual Effects

| Command | Description |
|---------|-------------|
| `set_light obj 0\|1` | Toggle light |
| `change_light obj {r g b} intensity {r2 g2 b2}` | Configure light |
| `create_particlesource id pos dir count time` | Spawn particles (see [Particles.md](Particles.md)) |

### Inventory

| Command | Description |
|---------|-------------|
| `inv_list obj` | List contents |
| `inv_cnt obj` | Count items |
| `inv_find_obj obj item` | Find item in inventory |

### Task List

```tcl
tasklist_add $gnome "walk_pos \{ [get_pos $target] \}"
tasklist_add $gnome "play_anim animation_name"
tasklist_add $gnome "rotate_towards \{ [get_pos $target] \}"
tasklist_add $gnome "prod_turnfront"
tasklist_add $gnome "call_method $ref method_name $args"
```

### Production

| Command | Description |
|---------|-------------|
| `get_prod_slot_cnt obj class` | Production slot count |
| `get_prod_pack obj` / `set_prod_pack obj val` | Pack state |

### Misc

| Command | Description |
|---------|-------------|
| `call filepath` | Execute Tcl file |
| `call_method obj method args` | Call instance method |
| `call_method_static Class method args` | Call static method |
| `check_method class method` | Check if method exists |
| `in_class_def` | True when inside class definition context |
| `get_class_name` | Current class name (in def context) |
| `state_get obj` | Current state |
| `gettime` | Current game time |
| `random max` / `random min max` | Random number |
| `hfloor val` | Floor function |
| `minimalrun` | Check minimal run mode |
| `startcache present\|enabled\|load\|write` | Cache management |
| `map_template name` | Load map template |
| `newsticker new\|change\|delete ...` | News ticker UI |
| `set_objworkicons obj class` | Work icons |
| `get_selectedboject` / `set_selectedobject id` | Selection |
| `reset_owner_attribs` | Reset owner attribute counters |

---

## Asset Formats

| Format | Location | Tool |
|--------|----------|------|
| `.tga` (Targa) | `Texture/`, `GUI/` | GIMP, Photoshop |
| `.3db` (proprietary) | `3db/` | No public tools — reuse existing models |
| `.wav` | `Sound/` | Any audio editor |
| `.mp3` | `Music/` | Any audio editor |
| `.l2m` `.pmp` `.ent` | `Templates/` | Binary — modify existing or use game tools |
| `.tcl` | `Scripts/`, `GameScripts/`, `Templates/tcl/` | Any text editor |
| `MESSAGES.TXT` | `data/` | Text editor (tab-separated) |

---

## Localization

`MESSAGES.TXT` is a tab-separated file mapping message IDs to translations. Scripts reference messages by ID; the engine resolves them based on the active language.

Dialog files in `Scripts/text/talk/` use locale suffixes (e.g., `_pl.tcl` for Polish).

In-game documentation lives in `Scripts/text/doc/{locale}/`.

---

## Game Scenarios

`GameScripts/` contains top-level scenario definitions:

| Pattern | Description |
|---------|-------------|
| `single_Campaign*.tcl` | Story campaign levels |
| `single_Tutorial.tcl` | Tutorial |
| `sandbox_*.tcl` | Sandbox/free play modes |
| `multiplayer.tcl` / `multi_*.tcl` | Multiplayer modes |
| `oberwelt.tcl` | Overworld |

Each scenario file loads templates, initializes systems, and configures gameplay parameters.
