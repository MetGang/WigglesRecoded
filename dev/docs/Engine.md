# Engine Internals

Deep-dive into the Wiggles/Diggles C++ engine: origins, architecture, rendering, audio, binary formats, and modding boundaries.

For Tcl scripting and game object system, see [GameArchitecture.md](GameArchitecture.md).

---

## Origins

The engine is a **proprietary custom engine** built by **SEK (Spieleentwicklungskombinat)**, a Berlin-based studio founded in 1998 by Carolin Batke, Thomas Langhanki, Ingo Neumann, and Carsten Orthbandt (lead developer).

- **Original release (2001)**: DirectX 7 (Direct3D 7 + DirectDraw 7), C++, 32-bit PE32
- **Restoration (2020)**: [General Arcade](https://generalarcade.com/) ported the renderer from DirectX 7 to DirectX 11, added SDL2 for windowing, SoLoud for audio, and Steam integration. Team: 2 software engineers, 2 QA, 1 producer.
- **Source code**: Unpublished, held by Carsten Orthbandt. No indication of future release.
- **Other games on this engine**: None. SEK later made ParaWorld (2006) on a different engine (PEST). SEK dissolved in January 2007.

Build path embedded in binaries: `C:\dev\wiggles\Wiggles\`

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Diggles.exe  (3.6 MB, PE32, Intel 80386)                │
│                                                         │
│  CGameThread            Main game loop                  │
│  CGameRenderThread      Render thread                   │
│  ObjMgr                 Game object manager             │
│  CTclGlobalMethods      Tcl command registration        │
│  CTclObjMethods         Per-object Tcl commands         │
│  CTclClassDefMethods    Class definition DSL            │
│  AiGameControl          AI coordination                 │
│  AiCentral              AI central planner              │
│  TechTree               Technology tree evaluation      │
│  ProdPlanner            Production planning             │
│  ProdAllocator          Worker-to-building allocation   │
│  NetMgr                 Multiplayer network manager     │
│  KNetConnection         Network connection              │
│  StoryMgr               Story/quest progression         │
│  CFightActionMgr        Combat action system            │
│  FloorPathMap           Pathfinding                     │
│  ViWin*                 GUI widget hierarchy            │
│  ViControlMgr           Input/event dispatching         │
│  VIMapEdit              Built-in map editor             │
├─────────────────────────────────────────────────────────┤
│ DigglesPort.dll  (333 KB, PE32)                         │
│                                                         │
│  IDirect3D7Port              D3D7 → D3D11 wrapper       │
│  IDirect3DDevice7Port        Device wrapper             │
│  IDirectDraw7Port            DDraw → modern wrapper     │
│  IDirectDrawSurface7Port     Surface wrapper            │
│  IDirectDrawClipperPort      Clipper wrapper            │
│  IDirect3DVertexBuffer7Port  VB wrapper                 │
│  CSdlWindow                  SDL2 window management     │
│  SoloudAudioPlayer           SoLoud/XAudio2 audio       │
│  GroundRenderer              Terrain rendering          │
│  GroundRenderer2             Alternate terrain renderer │
│  ModelRenderer               3D model rendering         │
│  WallRenderer                Wall/cave rendering        │
│  C3DDB                       .3db model loader          │
│  CDXExecBuf                  DX execution buffers       │
│  CParticle                   Particle system            │
├─────────────────────────────────────────────────────────┤
│ tcl83.dll     (484 KB)   Tcl 8.3 interpreter            │
│ SDL2.dll      (1.2 MB)   Window, input, display mgmt    │
│ steam_api.dll (234 KB)   Steam integration              │
└─────────────────────────────────────────────────────────┘
```

### Initialization Sequence

1. `TclInit` — initialize Tcl interpreter
2. `Map` — load map/level
3. `Options` — load render options
4. SDL initialization — window system
5. Rendering initialization — graphics setup
6. `TclScript 1` — pre-load scripts
7. Display initialization
8. `TclInit2` — secondary Tcl init (user/system scripts)
9. AI initialization

### Frame Loop

```
SrvDoThink()          Game logic tick
EndBuildFrame()       Finalize frame data
RenderBegin()         Start rendering
  BeginFrame()
  Fill()              Draw scene
  EndFrame()
RenderEnd()
Flip()                Present to screen
```

---

## Rendering

### DigglesPort.dll — The D3D7→D3D11 Bridge

The original game was built against DirectX 7 APIs. General Arcade's 2020 port wraps these in COM-style adapter classes that translate calls to Direct3D 11:

| Original D3D7 Interface | Port Wrapper | Purpose |
|--------------------------|-------------|---------|
| `IDirect3D7` | `IDirect3D7Port` | D3D enumeration, device creation |
| `IDirect3DDevice7` | `IDirect3DDevice7Port` | Draw calls, state management |
| `IDirectDraw7` | `IDirectDraw7Port` | Surface management |
| `IDirectDrawSurface7` | `IDirectDrawSurface7Port` | Texture/backbuffer surfaces |
| `IDirectDrawClipper` | `IDirectDrawClipperPort` | Window clipping |
| `IDirectDrawPalette` | `IDirectDrawPalettePort` | Palette emulation |
| `IDirect3DVertexBuffer7` | `IDirect3DVertexBuffer7Port` | Vertex data |

Entry point: `DirectDrawCreateExPort()` — replaces the original `DirectDrawCreateEx`.

### Shader Pipeline

The port replaces the D3D7 fixed-function pipeline with HLSL shaders in `data/Shaders/`:

**Multi-stage texturing** (emulates D3D7 texture stage states):
- `TL1CS.fx` / `TL2CS.fx` — textured + lit (1 and 2 stages)
- `UL1CS.fx` / `UL2CS.fx` — textured, unlit
- Supports up to 8 texture stages (`MAX_STAGES_COUNT`)
- Emulates D3DTOP operations: DISABLE, SELECTARG1, SELECTARG2, MODULATE, MODULATE2X, MODULATE4X, ADD, ADDSIGNED, SUBTRACT, BLENDDIFFUSEALPHA, BLENDTEXTUREALPHA, BLENDFACTORALPHA, DOTPRODUCT3

**Post-processing chain:**
1. `SceneBrightness.fx` — dynamic scene brightness
2. `BloomBrightness.fx` — bloom extraction with threshold
3. `BlurHorizontal.fx` + `BlurVertical.fx` — separable Gaussian blur
4. `Composition.fx` — final compositing (scene + bloom)

**Utility shaders:**
- `Straight.fx` — pass-through
- `ResolveDepthBuffer_CS.hlsl` — compute shader for depth buffer
- `Gamma.fxh` — gamma correction (adjustable 0.3–2.3, brightness -0.5–0.5)
- `Common.fxh` — shared definitions

### Material System

Materials control how objects are rendered. Known material types (from binary strings):

| Material | Description |
|----------|-------------|
| `model_solid` | Opaque solid |
| `model_solid_nozwrite` | Solid, no depth write |
| `model_solid_invalpha` | Solid with inverted alpha |
| `model_blend` | Alpha blended |
| `model_blend_glow` | Alpha blended with glow |
| `model_blend_nozwrite` | Blended, no depth write |
| `model_additive` | Additive blending |
| `model_additive_glow` | Additive with glow |
| `model_blend_envmap` | Blended with environment map |
| `model_additive_envmap` | Additive with environment map |
| `alpha_light0` / `alpha_light1` | Alpha with lighting |
| `nolight_noalpha` | Unlit, no alpha |
| `particle_blend` / `particle_additive` | Particle rendering modes |
| `ground_blend` | Terrain blending |
| `shadow_blend` | Shadow rendering |

### Shadow System

- Database shadows — pre-computed shadow meshes
- `RenderShadowMeshPro` — shadow mesh rendering with Z-write control

### Display Management

- Multi-monitor support: `GetDisplayIndex`, `ValidateDisplayIndex`, `GetDisplayBounds`
- Window resize: `ResizeWindowToFit`
- SDL2-based: `CSdlWindow`, `CSdlWindowHandle`

---

## Audio

**Library**: [SoLoud](https://sol.gfxile.net/soloud/) — free, portable audio engine

**Source in build**: `C:\dev\wiggles\Wiggles\SoLoud\src\core\`

**Backend**: XAudio2 (Windows) with NoSound fallback. Media Foundation support for advanced audio rendering.

**Key classes**:
- `SoloudAudioPlayer` — main player interface
- `WavStream@SoLoud` — WAV file streaming
- `AudioSource@SoLoud` / `AudioSourceInstance@SoLoud` — source abstraction

**Player API** (from binary strings):
```
OpenFile, Play, Stop, Pause, Resume
SetVolume, SetPosition, SetLoop
GetVolume, GetPosition, GetTotalDuration
GetState (Playing/Paused/Stopped)
Tick, Close, Deinit
```

**Limits**: Up to 256 simultaneous active voices (hardcoded: `mMaxActiveVoices < 256`).

**Tcl interface**: `sound` and `adaptive_sound` commands.

---

## Tcl Integration

### How Commands Are Registered

The engine registers Tcl commands via C++ classes:

| Class | Purpose |
|-------|---------|
| `CTclGlobalMethods` | Global game commands (`new`, `del`, `gettime`, etc.) |
| `CTclObjMethods` | Per-object commands (`get_pos`, `set_anim`, etc.) |
| `CTclClassDefMethods` | Class definition DSL (`def_class`, `method`, `obj_init`, etc.) |

Registration happens at startup via `CTclGlobalMethods::Register()`. **New commands cannot be added without C++ source access.**

### Complete Command Reference

~500+ commands extracted from [wiggles.ruka.at/tipstricks/wiggles_tcl.html](https://wiggles.ruka.at/tipstricks/wiggles_tcl.html). See the sections below for categorized lists.

#### AI Commands

```
ai                        ai_getintrudergnomes      ai_getintruderprods
ai_getownerid             ai_getpossibleinventions  ai_getprodlocations
ai_gnomepop_getcount      ai_gnomepop_getlist       ai_gnomepop_getobj
ai_gnomepop_getpos        ai_gnomepopscount         ai_log
ai_nextgnomepop           ai_nextprodpop            ai_npring
ai_prodpop_getcount       ai_prodpop_getlist        ai_prodpop_getobj
ai_prodpop_getpos         ai_prodpopscount          ai_setbuildup
ai_setpack                ai_tickhandler            ai_validlocation
```

#### Attributes

```
add_attrib                add_expattrib             add_owner_attrib
def_attrib                get_attrib                get_attrib_display_name
get_attrib_names          get_bestexp               get_expattrib
get_owner_attrib          get_owner_attrib_list     set_attrib
set_owner_attrib          transfer_attribs
```

#### Class Definition

```
call_method               call_method_static        check_method
class_collosion           class_defaultanim         class_defaultmaterial
class_defaulttxtanim      class_disablescripting    class_fightdist
class_flagoffset          class_light               class_objsnapclass
class_physcategory        class_physic              class_snaptowall
class_viewinfog           def_class                 def_idiobjclass
get_class_category        get_class_era             get_class_flags
get_class_name            get_class_type            in_class_def
inherit                   member                    method
method_const              method_static             obj_exit
obj_init                  set_class_anim            set_class_animset
ClassID                   ClassInfo                 ClassList
ClassName
```

#### Events

```
clone_event               def_event                 event_generator
event_get                 evtgen_attrib             get_eventenabled
handle_event              set_event                 set_eventenabled
timer_event               timer_unset
```

#### State Machine

```
state                     state_disable             state_enable
state_enter               state_get                 state_getenablecnt
state_leave               state_reset               state_trigger
state_triggerfresh
```

#### Object Management

```
action                    auto_choose_gender        auto_choose_workingtime
change_light              check_energy              check_ghost_coll
create_doorlogic          create_elevatorlogic      create_ladderlogic
cwd                       del                       destruct
dig_resetid               dist_between              fairy_move
get_activegameplay        get_alternateanimdb       get_angle_num4
get_attack_pos            get_attackinprogress      get_autolight
get_boxed                 get_buildupstate          get_classaniminfo
get_climbability          get_cloaked               get_collision
get_diedinfight           get_escape_pos            get_forceipol
get_gnomeposition         get_hoverable             get_instore
get_invulnerable          get_light                 get_linked_to
get_linkpos               get_linkrot               get_lock
get_logactions            get_obj_logicfogskip      get_obj_logicskip
get_objclass              get_objectcollision       get_objgender
get_objinfo               get_objname               get_objownertype
get_objrace               get_objtype               get_owner
get_ownerrace             get_pathlength            get_pathrandflags
get_physic                get_placesnapmode         get_pos
get_posbottom             get_posx                  get_posy
get_posz                  get_processactions        get_prodalloclock
get_prodautoschedule      get_ref                   get_rel_pos
get_rot                   get_rotx                  get_roty
get_rotz                  get_selectable            get_sequenceactive
get_shield_class          get_snaptowall            get_storable
get_undeletable           get_user_groups           get_vel
get_velcomp               get_viewinfog             get_visibility
get_weapon_class          get_weapon_id             get_weapon_range
get_worktime              hide_obj_ghost            is_contained
is_selected               is_wearing_pannier        link_obj
new                       obj_find                  obj_find_list
obj_find_nearest          obj_find_nearest_storable obj_find_nearest_storable_cb
obj_find_nearest_type     obj_find_own              obj_find_own_list
obj_find_var              obj_list                  obj_next_visible
obj_query                 obj_to_particle           obj_valid
partner_info              path                      proddump
qnew                      ref2path                  ref_checkvar
ref_get                   ref_set                   sel
set_activegameplay        set_alternateanimdb       set_attackinprogress
set_autolight             set_boxed                 set_buildupstate
set_camerafollow          set_climbability          set_cloaked
set_collision             set_fogofwar              set_forceipol
set_hoverable             set_icon                  set_instore
set_invulnerable          set_light                 set_lock
set_logactions            set_obj_logicfogskip      set_obj_logicskip
set_objectcollision       set_objgender             set_objicon
set_objiconoffset         set_objinfo               set_objname
set_objworkicons          set_owner                 set_ownerrace
set_pf_influence          set_physic                set_placesnapmode
set_pos                   set_posbottom             set_posx
set_posy                  set_posz                  set_processactions
set_prodalloclock         set_prodautoschedule      set_renderlast
set_rot                   set_rotx                  set_roty
set_rotz                  set_selectable            set_sequenceactive
set_shield_class          set_snaptowall            set_storable
set_textureanimation      set_undeletable           set_user_groups
set_vel                   set_viewinfog             set_visibility
set_weapon_class          set_worktime
```

#### Inventory

```
inv_add                   inv_cnt                   inv_cnt_raw
inv_find                  inv_find_obj              inv_find_raw
inv_get                   inv_get_raw               inv_getsize
inv_list                  inv_rem                   inv_check
```

#### Task List

```
tasklist_add              tasklist_addfront         tasklist_clear
tasklist_cnt              tasklist_find             tasklist_get
tasklist_list             tasklist_rem
```

#### Production & Energy

```
get_ballisticresult       get_energy                get_energysourceload
get_energystore           get_prod_buildup          get_prod_directevents
get_prod_enabled          get_prod_exclusivemode    get_prod_materialneed
get_prod_ownerstrength    get_prod_pack             get_prod_schedule
get_prod_slot_buildable   get_prod_slot_cnt         get_prod_slot_inventable
get_prod_slot_invented    get_prod_slot_list        get_prod_switchmode
get_prod_task_list        get_prod_toolneed         get_prod_total_task_cnt
get_prod_unpack           get_remaining_sparetime   get_walkresult
gnome_announce_dig        gnome_failed_work         gnome_idle
gnome_stopped_work        info_end_prod             info_progress_prod
info_start_prod           prod_assignworker         prod_get_task_active_places
prod_get_task_all_places  prod_get_task_total_cnt   prod_gnome_get_last_workplace
prod_gnome_get_preferred_workplace                  prod_gnome_last_workplace
prod_gnome_preferred_workplace                      prod_gnome_state
prod_gnomeidle            prod_guest                prod_valid
set_doorproperties        set_elevatorproperties    set_energyclass
set_energyconsumption     set_energymaxstore        set_energyrange
set_energystore           set_inventoryslotuse      set_ladderrange
set_prod_buildup          set_prod_directevents     set_prod_enabled
set_prod_exclusivemode    set_prod_materialneed     set_prod_ownerstrength
set_prod_pack             set_prod_schedule         set_prod_slot_cnt
set_prod_switchmode       set_prod_toolneed         set_prod_unpack
prodslot_override
```

#### Fight

```
chack_weapon_exp          def_hp_ratio              fight_action
fight_map_class2db        fight_setactions           fight_setactions_ballistic
fight_setactions_strikeback                          fight_setactions_training
fight_weapon              fight_weapon_kombi         get_best_weapon
get_escape_value
```

#### Map & Terrain

```
cave_skin                 dig_apply                 dig_mark
dig_next                  generate_color_variation  get_hmap
get_lmap_blue             get_lmap_green            get_lmap_light
get_lmap_red              get_map_height            get_map_width
get_material              get_place                 get_place_long
ground_fix                ground_pos                map
map_setlayer2             placelock_log             remove_black_fog
reset_map                 save_map                  sm_mark_temparea
```

#### Level Generation (`lg_*`)

```
lg_add_preset             lg_addfilterclass         lg_dec_templatecount
lg_get_level              lg_get_objcount           lg_get_temp_size
lg_mark_area              lg_set_area               lg_set_callback
lg_set_leveltype          lg_set_objcount           lg_set_starttemplate
lg_set_starttemplatepro   lg_set_templategroup      lg_set_templategroupprops
lg_set_templategroupvalue lg_set_templateprops      lg_set_templateratio
lg_set_templatevalue      lg_sort_level             lg_start
lg_tp_addtemplates        lg_tp_addtemplatesets     lg_tp_clear
lg_tp_log                 lg_tp_mapfilter           lg_tp_objfilter
lg_tp_setfilter
```

#### Story Map (`sm_*`)

```
sm_add_event              sm_add_temp               sm_add_zone
sm_create_map             sm_def_temp_group         sm_dig_message
sm_draw_stone             sm_force_zone             sm_get_event
sm_get_level_info         sm_get_resolution         sm_get_temppos
sm_get_zone               sm_log                    sm_map_get
sm_map_move               sm_map_set                sm_music_theme
sm_mark_temparea          sm_register               sm_reset
sm_scan                   sm_send_message           sm_set_digcount
sm_set_event              sm_set_temp               sm_set_zone
```

#### Graphics & Animation

```
db_animlength             db_findanim               db_load
db_search                 reset_anim                set_anim
Material                  set_rendermaterial         shader
textstage
```

#### Particles

```
blow_particlesource       change_particlesource     create_particlesource
free_particlesource       set_particlesource
```

Also see [Particles.md](Particles.md) for visual catalog of all 42 particle types.

#### Sound

```
sound                     adaptive_sound
```

#### Vector Math

```
vector_abs                vector_add                vector_angle
vector_dist               vector_dist3d             vector_fix
vector_fixdig             vector_inbox              vector_mul
vector_normalize          vector_pack               vector_random
vector_rotx               vector_roty               vector_rotz
vector_setx               vector_sety               vector_setz
vector_sub                vector_unpackx            vector_unpacky
vector_unpackz
```

#### UI & Layout

```
layout                    newsticker                textwin
keybind                   selection                 get_selectedobject
set_selectedobject        speechicon
```

Also see [Layout.md](Layout.md) for layout modifier reference.

#### Camera & View

```
camera_set                camctrlmapping            get_cameramoving
get_camerafollowdist      screen2world              screen3world
scroller                  scrollrange               set_camerafollow
set_fov                   set_view                  set_view_begin
set_viewpos               viewlock
```

#### Game Control

```
autoloadlevel             gameload                  gamesave
gamestats                 gametime                  get_ingame_loading
get_local_player          get_mapedit               get_maxprodera
get_system_name           gui_new_game              load_done
load_file                 load_info                 loading_objdetail
option                    quit                      set_ingame_loading
set_maxprodera            set_run_info              set_sequence
set_split_load            show_loading              show_maped
sleep
```

#### Fog, Lighting, Water, Terrain Rendering

```
cancel_fade               get_brightness            get_contrast
get_fill                  get_waterheight            horizon_clear
horizon_rem               horizon_set               isunderwater
land                      remove_black_fog          render_enable
render_gray               set_brightness            set_contrast
set_fogofwar              set_fow_begin             set_ground_begin
set_level                 set_light_begin           set_water
show_fogofwar             start_fade
```

#### Special Effects

```
delete_laserbeams         delete_lightning           laser
laserbeam                 lightning                  notifyflare
```

#### Diplomacy & Multiplayer

```
get_diplomacy             set_diplomacy             get_mpstartpos
get_player_color          net                       reconnect
playerinfo
```

#### Miscellaneous

```
//                        call                      callnc
calc_text_time            def_texture               delete_transportlogic
exec_deferred             fincr                     find_free_place
find_free_place_self      flush_all_textures        gamedelayannounce
gameisloading             get_anglexz               get_digedge
get_fsource               get_ftype                 get_next_relocobj
get_place_info            get_sequencebreaked       get_vectorxz
get_view                  get_weapon_pose           gethours
gettime                   global_inv_rem            has_cmap
hceil                     hf2i                      hfloor
hi2f                      hmax                      hmin
inc_playerdigmarkid       init_techtree             inputmode
irandom                   is_dig_marked             lcount
lnand                     load_all_textures         load_scape_texture
locale                    log                       log_mask
logdebug                  logmod                    lor
lrem                      lrep                      meminfo
minimalrun                obj_clear                 obj_eval
output_3ddbstats          park_obj_actions          particle_processing
peek                      perfoptions               perfwin
poke                      print                     random
release_energy            rem_fsource               rem_fstopper
remove_parked_obj         restore_obj_actions       rjreusecheck
save_scene                screen_mode               seq_audiostream
set_fsource               set_fstopper              set_objvariation
set_speechout             set_texturevariation      smalltalk
sparetime                 startcache                talkissue
tclhelp                   template_set              time_line_log
time_schedule             toggle_wf                 uncapturemouse
update_objdetail          vtune                     waterdbg
elf                       trigger
```

---

## Binary Formats

### .3db — 3D Model Database

**Magic**: `3DDB 1.0`

Contains meshes, materials, animations, and shadow data in a proprietary binary format. Loaded by `C3DDB` class in the engine.

**Known sections** (from binary analysis):

| Section | Content |
|---------|---------|
| Header | Magic, version |
| Mapping | Coordinate/UV mapping data |
| Materials | Material definitions referencing TGA textures |
| Meshes | Vertex, normal, UV, index data |
| Objects | Named object groups within the model |
| Animations | Skeletal/keyframe animation data |
| Shadows | Pre-computed shadow meshes |
| CMaps | Collision maps |

**42 model files** in `data/3db/`:
- Characters: `mann.3db`, `frau.3db`, `odin.3db`, `fenrir.3db`, `troll.3db`, `drache01.3db`
- Buildings: `produktionsstaetten.3db`, `einrichtung.3db`, `freizeit.3db`
- Items: `werkzeuge.3db`, `halbzeuge.3db`
- Environment: `lavawelt.3db`, `wandboden.3db`, `flusslandschaft.3db`
- Technical: `metalltech.3db`, `Interface.3db`, `JoinedObjs.3db`

**Tools**: [wiggles-3db-parser](https://git.aachen.ccc.de/~spq/wiggles-3db-parser) by spq — Python read-only parser (PIL + pyglet). Can extract and display models with textures. **No write support exists.**

### .l2m — Layer Map

**Magic**: `M2L` (reversed)

Binary format containing terrain/collision layer data. Used by the template system for procedural level generation. No documentation or tools available.

### .pmp — Polygon Map

dBase III DBT format header. Contains terrain geometry data as indexed structures. No documentation or tools available.

### .ent — Entity Placement

Text-based or empty files. Define object spawn lists for templates. Can be edited with a text editor.

### texmaps.bin — Texture Atlas Cache

Pre-compiled texture atlas. **Must be deactivated** (renamed) when adding custom textures — DigglesModManager handles this automatically.

### cache.bin — Startcache

Pre-compiled Tcl class definitions for faster loading. Located at `data/scripts/cache.bin`. Regenerated when `startcache write` is called.

---

## What Can Be Modded

| System | How | Difficulty |
|--------|-----|-----------|
| Items / materials | `def_class` + tech tree entry | Easy |
| Production buildings | `def_class` + `genericprod.tcl` | Medium |
| Recreation buildings | `def_class` + sparetime system | Medium |
| Tech tree / recipes | Edit `techtree.tcl` | Easy |
| AI behavior | `std_ai.tcl`, state machine scripts | Hard |
| Quests / story | `Scripts/classes/story/`, trigger scripts | Hard |
| Dialogs / text | `MESSAGES.TXT`, `Scripts/text/` | Easy |
| Level generation | Template .tcl + .ent files | Medium-Hard |
| Scenarios / missions | `GameScripts/*.tcl` | Medium |
| Particle effects | `create_particlesource` (42 types) | Easy |
| Object lighting | `set_light`, `change_light` | Easy |
| Fog of war | `set_fogofwar` | Easy |
| Animations (existing) | `set_anim` with existing .3db anims | Easy |
| UI / layout | `layout`, `textwin`, `newsticker` | Medium |
| Shaders (post-process) | Edit HLSL/FX in `data/Shaders/` | Medium |
| Textures | Replace TGA files in `data/Texture/` | Easy |
| Sounds / music | Replace WAV/MP3 files | Easy |
| Game speed | Registry: `NoGamespeedLock` | Easy |
| Combat | `fight_action`, `fight_weapon` | Medium |
| Pathfinding params | `set_pf_influence`, `get_pathrandflags` | Medium |
| Diplomacy | `set_diplomacy`, `get_diplomacy` | Easy |
| Camera | `camera_set`, `set_fov`, `set_view` | Easy |
| Multiplayer scenarios | `GameScripts/multi_*` | Hard |

## What Cannot Be Modded

| Limitation | Why | Workaround |
|-----------|-----|-----------|
| **New 3D models** | .3db format is proprietary, no creation tools. Parser is read-only. | Reuse existing 42 models and their animations. |
| **New animations** | Stored in .3db, no exporter from Blender/3DS Max | Reuse existing animations (`dimensionstor`, `walk`, `fight`, etc.) |
| **New Tcl commands** | Registered in C++ via `CTclGlobalMethods::Register()` | Work within the ~500 existing commands. |
| **New object types** | `ObjectType` enum is in C++: none, material, production, energy, service, store, elevator, protection, dummy | Use one of the 9 existing types. |
| **Rendering fundamentals** | D3D7 emulation layer is in C++ | Can modify post-processing via HLSL shaders. |
| **Physics engine** | `PhysicDestructor`, `MeshDestructor` in C++ | Not modifiable. |
| **Pathfinding algorithm** | `FloorPathMap` in C++ | Parametric tuning via `set_pf_influence`. |
| **Save file format** | Binary, undocumented | Not modifiable. |
| **New GUI widget types** | `ViWin*` hierarchy in C++ | `layout` command can arrange text/icons but cannot create new widget types. |
| **Network protocol** | `KNetConnection`, `KNetMsg` in C++ | Can create multiplayer scenarios but not modify the protocol. |
| **Terrain formats (.l2m/.pmp)** | Binary, undocumented | Can modify .tcl and .ent (text-based) templates. |
| **Collision system** | `class_collosion` (yes, typo in engine) sets category, but detection is in C++ | Parametric only. |
| **Audio voice limit** | 256 max, hardcoded in SoLoud | Not modifiable. |

---

## Hidden Settings

Settings stored in Windows Registry at `HKEY_CURRENT_USER\Software\SekOst\Diggles`. **Close the game before editing** — running game resets values on exit.

| Key | Default | Description |
|-----|---------|-------------|
| `MaxFramerate` | — | FPS cap (set to monitor refresh rate) |
| `NoGamespeedLock` | 0 | 1 = unlock speed control (+/- numpad: 1×, 2×, 4×) |
| `MaxGametimeFactor` | 4 | Maximum speed multiplier |
| `PauseOnDeactivate` | 1 | 0 = game keeps running when minimized |
| `ShowFMV` | 1 | 0 = skip intro video |
| `ShowSubText` | 0 | 1 = enable subtitles |
| `RatingCPU` | 25 | CPU performance rating |
| `RatingGfx` | 25 | Graphics performance rating |
| `RatingMem` | 25 | Memory performance rating |

### Launch Parameters

| Parameter | Effect |
|-----------|--------|
| `-console` | Enable developer console (press Scroll Lock to open) |

---

## Community Resources

| Resource | URL |
|----------|-----|
| Wiggles Forum | https://wiggles.ruka.at/forum/ |
| Tcl Command Reference | https://wiggles.ruka.at/tipstricks/wiggles_tcl.html |
| DigglesModManager + Mods | https://github.com/DigglesMods |
| 3db Parser (Python, read-only) | https://git.aachen.ccc.de/~spq/wiggles-3db-parser |
| Diggles Wiki | https://diggles.fandom.com/ |
| Nexus Mods | https://www.nexusmods.com/games/digglesthemythoffenris |
| GOG Forum (hidden settings) | https://www.gog.com/forum/diggles_the_myth_of_fenris/the_hidden_diggles_settings |
