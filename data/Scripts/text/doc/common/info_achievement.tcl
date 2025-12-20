call scripts/lib/time.tcl
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
set aman [call_method_static AchievementManager get_instance]
set rarity [call_method $aman get_achv_rarity $key]
set acquire_time [call_method $aman get_achv_acquire_time $key]

layout print "/(ml10,ta10)"
layout print "/(fn1,bo6)$title"
layout print "/p"
layout print "/(fn0,bo14)$short"
layout print "/p"
layout print "/(fn1,bo0)$desc"
layout print "/p/p"
layout print "/(fn1,bo6)[lmsg AchvRarity]:/(fn0,tx )[lmsg $rarity]"
layout print "/p"
layout print "/(fn1,bo6)[lmsg AchvUnlockedAt]:/(fn0,tx )[get_formatted_gametime $acquire_time]"
layout print "/p"
