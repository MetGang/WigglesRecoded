# Wiggles Re:coded Architecture

How WigglesRecoded is structured, what it changes from the original, and how to contribute.

For original game internals, see [GameArchitecture.md](GameArchitecture.md).

---

## Goals

The original codebase is badly formatted, poorly commented, and contains development leftovers. WigglesRecoded rewrites it to be:

1. **Clean** — consistent formatting, no dead code, no debug spam
2. **Documented** — comments where logic isn't self-evident
3. **Modular** — new singleton Manager system, utility libraries, data-driven databases
4. **Extensible** — config-driven behavior, achievement/cheat/stats infrastructure
5. **Compatible** — works with Steam and GOG versions, preserves save file compatibility

WigglesRecoded is a **mod**, not a new engine. It replaces Tcl script files while running on the same C++ engine (`DigglesPort.dll`). It can be installed via [DigglesModManager](https://github.com/DigglesMods/DigglesModManager) or by copying the `data/` folder.

---

## Current Status

**Version:** 0.0 RC0 (pre-release)

**Coverage:** 57 Tcl files / 21,774 lines rewritten out of the original 482 files / 112,388 lines (~12%).

| System | Status | Files |
|--------|--------|-------|
| Gnome core (`zwerg/`) | Partially rewritten | 8 / 19 |
| Items | Partially rewritten | 5 / 20+ |
| Work buildings | Minimal | 2 / 30+ (`lager`, `feuerstelle`) |
| Recreation buildings | Not started | 0 / 18 |
| AI | Rewritten | 1 / 1 |
| Gameplay/campaigns | Partially rewritten | 2 / 10 |
| Characters/NPCs | Minimal | 1 / 18 (`RAUPE`) |
| Story/quests | Minimal | 1 / 15 |
| Initialization | Rewritten | 1 / 12 (`classinit`) |
| Decoration | Not started | 0 / 10 |
| **New: Managers** | **Complete** | **5 new files** |
| **New: Libraries** | **Complete** | **5 new files** |
| **New: Databases** | **Complete** | **5 new files** |
| **New: Debug** | **Complete** | **1 new file** |
| **New: Experience** | **Complete** | **1 new file** |

---

## Directory Structure

```
data/
├── config.ini                      INI configuration (loaded by ConfigManager)
├── default.ini                     Default config shipped with the mod
├── preset                          Optional: path override for config file
│
└── Scripts/
    ├── debug.tcl                   Logging system
    ├── utility.tcl                 Global helper functions (manager accessors)
    │
    ├── init/
    │   └── classinit.tcl           Rewritten class loader (adds Manager loading)
    │
    ├── ai/
    │   └── std_ai.tcl              Rewritten AI
    │
    ├── classes/
    │   ├── characters/
    │   │   └── RAUPE.TCL
    │   ├── items/
    │   │   ├── magie.tcl
    │   │   ├── pilz.tcl
    │   │   ├── rohstoffe.tcl
    │   │   ├── tueren.tcl
    │   │   └── werkzeuge.tcl
    │   ├── managers/               ★ NEW — singleton manager classes
    │   │   ├── AchievementManager.tcl
    │   │   ├── CheatManager.tcl
    │   │   ├── ConfigManager.tcl
    │   │   ├── StatisticsManager.tcl
    │   │   └── TextWinManager.tcl
    │   ├── story/
    │   │   └── story.tcl
    │   ├── work/
    │   │   ├── feuerstelle.tcl
    │   │   └── lager.tcl
    │   └── zwerg/
    │       ├── zwerg.tcl
    │       ├── z_dignwalk.tcl
    │       ├── z_events.tcl
    │       ├── z_procs.tcl
    │       ├── z_spare_main.tcl
    │       ├── z_work_common.tcl
    │       ├── z_work_prod.tcl
    │       └── z_work_strike.tcl
    │
    ├── db/                         ★ NEW — data-driven databases
    │   ├── achievements.tcl
    │   ├── cheats.tcl
    │   ├── clans.tcl
    │   ├── gnome_skills.tcl
    │   └── statistics.tcl
    │
    ├── gameplay/
    │   ├── Campaign.tcl
    │   └── CampaignInit.tcl
    │
    ├── lib/                        ★ NEW — utility libraries
    │   ├── compare.tcl
    │   ├── lang.tcl
    │   ├── list.tcl
    │   ├── time.tcl
    │   └── ui.tcl
    │
    ├── misc/
    │   ├── genattribs.tcl
    │   ├── generic_exp.tcl         ★ NEW — experience/leveling system
    │   ├── genericprod.tcl
    │   └── onlinehelputils.tcl
    │
    └── text/doc/                   Rewritten in-game documentation
        ├── common/
        │   ├── info_achievement.tcl
        │   ├── info_assistant.tcl
        │   ├── info_details.tcl
        │   ├── info_gnomes.tcl
        │   └── info_invention.tcl
        ├── de/ en/ pl/
        │   ├── info_gnomes.tcl
        │   ├── info_prods.tcl
        │   └── info_stammbaum.tcl
```

---

## New Systems

### Manager Pattern

All new systems use a **singleton manager** pattern. Each manager:

1. Is a `def_class` with `none none 0` (no material, no type, no physics)
2. Has a `get_instance` static method that creates the singleton on first call
3. Is loaded by `classinit.tcl` after all game classes

```tcl
def_class MyManager none none 0 {} {

    method_static get_instance {} {
        set id [obj_query 0 -class MyManager -limit 1]
        if { $id == 0 } {
            set id [new MyManager]
            log INFO "Created new MyManager $id"
            call_method $id apply_config
        }
        return $id
    }

    method apply_config {} {
        # Read settings from ConfigManager
    }

    obj_init {
        # Initialize state
    }
}
```

Accessing a manager from anywhere:

```tcl
set mgr [call_method_static MyManager get_instance]
call_method $mgr some_method $args
```

Global shorthand functions in `utility.tcl` wrap common manager calls:

```tcl
# Achievement shortcuts
proc am_trigger_achv_step {key} { ... }

# Cheat shortcuts
proc chm_cheating_enabled {} { ... }
proc chm_cheat_enabled {name} { ... }

# Config shortcuts
proc cfm_get_value {key} { ... }
proc cfm_get_value_or {key fallback} { ... }

# Statistics shortcuts
proc stm_incr_stat_value {key value} { ... }

# TextWindow shortcuts
proc twm_open_window {name state} { ... }
proc twm_embed_window {name state} { ... }
```

### ConfigManager

Reads INI-style configuration from `data/config.ini` (or a path specified in `data/preset`).

```ini
# data/default.ini
[main]
Cheats = 1

[campaign]
AttrExpFactor = 1.0
; 0 Wiggles, 1 Voodoos, 2 Knockers, 3 Brains, 4 Vampire
StartingClan = 0

[skirmish]
AttrExpFactor = 2.0

[cheats]
InstantHarvest = 0
InventButtons = 0
```

Accessing config values:

```tcl
set value [cfm_get_value "campaign.AttrExpFactor"]
set value [cfm_get_value_or "cheats.InstantHarvest" 0]
```

Keys are `section.key` format (e.g., `main.Cheats`, `campaign.StartingClan`).

### AchievementManager

Tracks achievements defined in `db/achievements.tcl`:

```tcl
# Database format: key {steps rarity type time_window window_count}
array set db {
    FirstCut      {1 Common count 0 {}}
    FastChopping  {1 Uncommon time 60 3}
    Scavenger     {5 Uncommon count 0 {}}
    Enlightenment {3 Uncommon count 0 {}}
    SoMuchDigging {1 Rare count 0 {}}
    YoungAgain    {1 Epic count 0 {}}
}
```

| Field | Description |
|-------|-------------|
| steps | Number of triggers needed to unlock |
| rarity | `Common` `Uncommon` `Rare` `Epic` `Legendary` |
| type | `count` (increment per trigger) or `time` (triggers within a time window) |
| time_window | For `time` type: seconds within which triggers must occur |
| window_count | For `time` type: number of triggers to track in the sliding window |

Triggering from game code:

```tcl
am_trigger_achv_step "FirstCut"
```

Unlocking shows a newsticker notification and opens the achievement window on click.

### CheatManager

Toggle-based cheats defined in `db/cheats.tcl`:

```tcl
array set db {
    InventButtons {}
    InstantHarvest {}
}
```

Cheats are enabled globally via `main.Cheats` config, then individually via `cheats.X` config keys. Checking from game code:

```tcl
if { [chm_cheat_enabled "InstantHarvest"] } {
    # skip harvest time
}
```

### StatisticsManager

Tracks gameplay statistics defined in `db/statistics.tcl`:

```tcl
array set db {
    BooksRead {}
    MushroomsHarvested {}
    ContainersLooted {}
}
```

Incrementing from game code:

```tcl
stm_incr_stat_value "MushroomsHarvested" 1
```

### Experience & Skills System

`misc/generic_exp.tcl` adds an RPG-style experience system to gnomes:

- Gnomes earn XP from actions → level up → gain skill points
- Level-up formula: XP needed = `2^level`
- Skill database in `db/gnome_skills.tcl`:

```tcl
array set db {
    QuickHarvest {1 Axt}     ;# cost: 1 skill point, icon: Axt
    MasterChef   {2 GrillPilz}
}
```

Methods available on gnomes:

```tcl
call_method $gnome gain_exp_points $points
call_method $gnome get_exp_level
call_method $gnome get_exp_skill_points
call_method $gnome can_acquire_skill "QuickHarvest"
call_method $gnome acquire_skill "QuickHarvest"
call_method $gnome has_acquired_skill "QuickHarvest"
```

Level-up triggers a newsticker notification.

### Clan System

`db/clans.tcl` defines the five clans with experience modifiers:

| Clan | Modifiers |
|------|-----------|
| Wiggles | (none — baseline) |
| Voodoos | Food ×1.3, Wood ×1.1, Combat ×0.9 |
| Knockers | Stone ×1.2, Metal ×1.1 |
| Brains | Energy ×1.2, Service ×1.1 |
| Vampire | Combat ×1.2, Food ×0.8 |

### Debug Logging

`debug.tcl` provides a leveled logging system:

```tcl
# Setup (call once at startup)
call scripts/debug.tcl
setup_logging

# Log messages
log INFO "Something happened"
log WARN "Potential issue"
log ERROR "Something broke"
log EVENT "Event fired: $evt"
```

Active levels (can be toggled by prepending `//`):

```
INIT, INFO, WARN, ERROR, EVENT, STATE, PROCS, CLASS, AI
```

Output goes to `debug.log` with timestamps:

```
[123.45678] INFO: Something happened
[123.45700] WARN: Potential issue
```

### Utility Libraries (`lib/`)

| File | Purpose |
|------|---------|
| `compare.tcl` | Comparison helpers |
| `lang.tcl` | `lmsgp` — parameterized message formatting (`$1`, `$2` placeholders) |
| `list.tcl` | List operations |
| `time.tcl` | Time utilities |
| `ui.tcl` | UI layout helpers (button generation, window styling) |

---

## Code Style Changes

### Formatting

Original:
```tcl
if {$current_itemtype != 0  &&  $current_worker != 0} {
    if {![obj_valid $current_worker]} {
        log "WARNING: genericprod.tcl : current_worker is != 0 but object invalid!"
        set current_worker 0
        return
    }
```

Re:coded:
```tcl
if { $current_itemtype != 0 && $current_worker != 0 } {
    if { ![obj_valid $current_worker] } {
        set current_worker 0
        return
    }
```

Rules applied:
- Spaces inside braces: `{ $x != 0 }` not `{$x != 0}`
- Remove debug spam and dead comments
- Remove development leftovers (commented-out code, German debug messages)

### Simplification

Original (6 lines per slot):
```tcl
if {[get_prod_slot_cnt this _Nahrung_einlagern] != 0} {
    set store_food 1
} else {
    set store_food 0
}
```

Re:coded (1 line per slot):
```tcl
set store_food [expr {[get_prod_slot_cnt this _Nahrung_einlagern] > 0}]
```

### Loading

Original `classinit.tcl` uses `cd` + `glob` + `cd ../../../..` pattern:
```tcl
cd Data/scripts/classes/characters
set filelist [lsort [glob -nocomplain "*.tcl"]]
cd ../../../..
```

Re:coded uses `-directory` option directly:
```tcl
set files [lsort [glob -nocomplain -directory "data/scripts/classes/characters" "*.tcl"]]
```

---

## Contributing

### What Needs Work

Roughly in order of impact:

1. **Recreation buildings** (`sparetime/`) — 0/18 files rewritten. Each is a self-contained class.
2. **Work buildings** (`work/`) — 2/30+ done. Similar structure, can be done in parallel.
3. **Characters/NPCs** (`characters/`) — 1/18 done. Trolls, creatures, special NPCs.
4. **Items** (`items/`) — 5/20+ done. Many are simple `autodef` items.
5. **Gnome subsystems** (`zwerg/`) — 8/19 done. Missing: `z_anims`, `z_faceanim`, `z_work_states`, `z_work_prodfill`, `z_spare_fun`, `z_spare_procs`, `z_spare_reprod`, `z_spare_talk`, and more.
6. **Story/quests** (`story/`) — 1/15 done. World triggers and quest logic.
7. **Decoration** (`deco/`) — 0/10 done.
8. **Initialization** (`init/`) — 1/12 done. Most init files haven't been touched.
9. **Gameplay** — 2/10 done. Missing campaign variants, sandbox modes, tech tree generator.

### How to Rewrite a File

1. **Find the original** in the game's `data/Scripts/` directory
2. **Read and understand** what it does (refer to [GameArchitecture.md](GameArchitecture.md))
3. **Create the re:coded version** maintaining identical behavior:
   - Clean up formatting (spaces inside braces, consistent indentation)
   - Remove dead code, commented-out blocks, German debug messages
   - Simplify where possible (expr instead of if/else, etc.)
   - Add comments only where logic is non-obvious
4. **Integrate new systems** where applicable:
   - Add `call scripts/debug.tcl` and use `log LEVEL "message"` instead of raw `log "..."`
   - Use `cfm_get_value_or` for configurable parameters
   - Trigger achievements with `am_trigger_achv_step` at meaningful game events
   - Track statistics with `stm_incr_stat_value` for relevant actions
5. **Test** by installing the mod and verifying the rewritten system works identically

### Adding New Systems

Follow the Manager pattern:

1. Create database in `db/my_system.tcl` with `db_mysystem`, `db_mysystem_keys`, etc.
2. Create manager in `classes/managers/MyManager.tcl` with singleton `get_instance`
3. Add shorthand functions in `utility.tcl`
4. Register in `classinit.tcl` (after game classes, before startcache write)
5. Add config keys in `default.ini` if needed

### Adding New Achievements

Edit `db/achievements.tcl`:

```tcl
array set db {
    FirstCut      {1 Common count 0 {}}
    # Add yours:
    MyAchievement {3 Rare count 0 {}}
}
```

Add localization strings to `MESSAGES.TXT`:
- `AchvTitle_MyAchievement` — display name
- `AchvDesc_MyAchievement` — description

Trigger in game code:
```tcl
am_trigger_achv_step "MyAchievement"
```

---

## Developer Tools

Located in the `dev/` directory:

| Tool | Description |
|------|-------------|
| `docs/Particles.md` | Visual catalog of all 42 particle effects |
| `docs/Layout.md` | UI layout system reference |
| `docs/GameArchitecture.md` | Original game architecture reference |
| `API.json` | Documented engine API commands |
| `MESSAGES.tsv` | Translation database in spreadsheet format |
| `ttt.tsv` + `ttt.py` | Tech tree data and parser |
| `tsv2messages.py` | Convert TSV translations → `MESSAGES.TXT` format |
| `strings.txt` | All extracted game strings |
| `sort_api.py` | Sort API.json entries |
| `Changelog.md` | Version history |

---

## DigglesModManager Integration

WigglesRecoded ships with a `config.json` in the repository root:

```json
{
  "author": "MetGang",
  "name": { "de": "Wiggles Re:coded", "en": "Diggles Re:coded", "pl": "Wiggles Re:coded" },
  "version": "0.0",
  "directories": [
    { "type": "optional", "path": "dev", "condition": { "type": "mod", "id": "null" } }
  ]
}
```

The `dev/` directory is marked as optional with an impossible condition (`mod:null`) so it is never installed into the game — it stays as a developer resource only.
