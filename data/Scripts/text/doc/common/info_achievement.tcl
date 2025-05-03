call scripts/lib/ui.tcl
call scripts/utility.tcl

### Achievement ###

layout clear
render_info_window_title [lmsg Achievement]

# ---------------------------------------------------------------------------- #

set key [twm_pop_saved_state]

set title [lmsg AchvTitle_$key]
set short [lmsg AchvShort_$key]
set desc [lmsg AchvDesc_$key]

layout print "/(ml10,ta10)"
layout print "/(fn1,bo6)$title"
layout print "/p"
layout print "/(fn0,bo14)$short"
layout print "/p"
layout print "/(fn1,bo0)$desc"
layout print "/p"
