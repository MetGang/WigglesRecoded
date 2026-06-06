call scripts/debug.tcl ; setup_logging

log INIT "systeminit.tcl started"

# Setup info
set_run_info "Wiggles Re:coded - [lmsg Language] Full version"

# QoL changes
perfoptions MaxGametimeFactor 16
perfoptions NoGamespeedLock 1

# Scripts
call scripts/init/shader.tcl
call scripts/init/txtinit.tcl
call scripts/init/animinit.tcl
call scripts/init/classinit.tcl
call scripts/init/soundinit.tcl
call scripts/init/adaptiveinit.tcl
call scripts/init/lginit.tcl
call scripts/init/talkinit.tcl
call scripts/init/makettree.tcl
init_techtree scripts/gameplay/gen_tt.tcl
call scripts/init/fight.tcl
ai init 0 data/scripts/ai/std_ai.tcl

# Main menu
map create 64 64 {}

call templates/unq_menue.tcl
MapTemplateSet 25 28

call templates/urw_gng_021_a.tcl
MapTemplateSet 21 40

call templates/urw_gng_022_a.tcl
MapTemplateSet 45 40

set_view 32.368 40.858 1.38 -0.355 0.165
sel /obj
set FR [new FogRemover]
set pos { 32.368 39.5 10 }
set_pos $FR [vector_add $pos {0 0 0}]
call_method $FR fog_remove 0 50 50
call_method $FR timer_delete -1
adaptive_sound marker menue $pos
adaptive_sound primary menue

sel /obj
set ts [new Trigger_StartScreen]
call_method $ts validate
call_method $ts disable_logging

# Finishing
gui_new_game
show_loading no

# Finalizing
gametime start
load_done

log INIT "systeminit.tcl finished"
