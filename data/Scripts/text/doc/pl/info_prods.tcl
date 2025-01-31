layout clear

layout print "/(fn2)"
layout print "/(ac)[lmsg Produktion]"
layout print "/p"
layout print "/(fn1,ls2,ml5,mr5,al)"

set playerid [get_local_player]

set prodlist [obj_query 0 -type {production energy} -owner $playerid]

proc centerandselect {gid} {
	set view [get_view]
	set pos [get_pos $gid]
	set_view [vector_unpackx $pos] [vector_unpacky $pos] [vector_unpackz $view]
	selection clear
	selection include $gid
	layout reload
}

proc prodname {gid} {
	if { [selection check $gid] || [is_contained $gid] } {
		return "[get_objname $gid]"
	} else {
		return "[layout autoxlink "centerandselect $gid" "[get_objname $gid]"]"
	}
}

proc prodinfo_stats {gid} {

	set slist [get_prod_slot_list $gid]
//	layout print "$slist"

	set prodlist [list]
	set invlist [list]

	foreach class $slist {
		if {! [get_prod_slot_invented $gid $class] } {
			if { [get_prod_slot_inventable $gid $class] } {
				lappend invlist $class
			}
		} else {
			lappend prodlist $class
		}
	}
	//if {[llength $prodlist] == 0} {return}
	layout print "/(ls5)/(fn0)/(bo0)"
	layout print "/(ta20)[prodname $gid]/p"
	layout print "/(fn0)/(ta80)/(bo-10)"


	set x 50
	set show 1
	set boxed [get_boxed $gid]
	if {$boxed} {
		set icon "data/gui/icons/unpack.tga"
		layout print "/(ta$x)/(ii$icon)"
		set x [expr $x + 38]
		set show 0
	}
	if {[get_objtype $gid] == "energy" && $show} {
		if {[get_prod_enabled $gid]} {
			set icon "data/gui/icons/energyon.tga"
		} else {
			set icon "data/gui/icons/energyoff.tga"
		}

		layout print "/(ta$x)/(ii$icon)"
		set x [expr $x + 38]
		set show 0
	}
	if {([llength $prodlist] != 0) && $show} {
		foreach class $prodlist {
			set count [get_prod_slot_cnt $gid $class]
			set icon "data/gui/icons/$class.tga"

			if { ![get_prod_slot_buildable $gid $class] } {
				set icon "data/gui/icons/Red$class.tga"
			}

			layout print "/(ta$x)/(ii$icon)"
			if { $count > 0 } {
				if { $count == 10 } {
						layout print "/(ta[expr $x + 25])o"
				layout print "/(ta[expr $x + 30])o"
				} else {
					layout print "/(ta[expr $x + 25])$count"
				}
			}
			set x [expr $x + 38]
		}
	}
	if {[get_attrib $gid atr_Hitpoints] < 1} {
		set icon "data/gui/icons/repair.tga"
		layout print "/(ta$x)/(ii$icon)"
	}

	layout print "/(ls15)/p/(fn0)/(bo0)"
}

layout print "/(fn1)"

set namelist ""
foreach item $prodlist {
	lappend namelist [get_objname $item]
}
set namelist [lsort $namelist]
set prodlist ""
foreach item $namelist {
	lappend prodlist [get_ref /obj/$item]
}
foreach gid $prodlist {
	prodinfo_stats $gid
};









// get_prod_slot_cnt <object> <itemclass>@obj@ get task count for production slot
// get_prod_total_task_cnt <object>@obj@ get total number of open tasks
// get_prod_task_list <object>@obj@ get list of open tasks
// get_prod_slot_list <object>@obj@ get list of all slots
// get_prod_slot_buildable <object> <class>@obj@ check if slot is buildable
// get_prod_slot_inventable <object> <class>@obj@ check if slot is inventable
// get_prod_slot_invented <object> <class>@obj@ check if slot is invented
// get_prod_unpack <object>@obj@ get object unpack task state
// get_prod_pack <object>@obj@ get object pack task state
// get_prod_buildup <object>@obj@ get object unpack task state
// get_prod_ownerstrength <object>@obj@ get object owner strength
//@TCL get_prod_enabled <objref>@@get true if energy source is on
//@TCL get_prod_exclusivemode <objref> @obj@ set exclusive production mode
//@TCL get_prod_switchmode <objref> @obj@ set switch production mode
//@TCL get_prod_schedule <objref> @obj@ set switch production mode
