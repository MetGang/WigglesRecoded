call scripts/lib/ui.tcl
call scripts/utility.tcl

### F6 menu - Dev ###

layout clear
render_info_window_title [lmsg Dev]

# ---------------------------------------------------------------------------- #

proc di_reload_layout {} {
	global di_tab
	layout reload
}

# ---------------------------------------------------------------------------- #

if { ![info exists di_tab] } {
	set di_tab "tab_dump"
}

proc di_set_tab {tab} {
	global di_tab
	set di_tab $tab
	di_reload_layout
}

proc di_btn_set_tab {tab lkey} {
	global di_tab
	return [btn [lmsg $lkey] "di_set_tab $tab" [expr {$di_tab != $tab}]]
}

# ---------------------------------------------------------------------------- #

proc di_render_subwindow_dump {} {
	proc println {k args} {
		layout print "/(fn1,ta10)$k:"
		layout print "/(fn0)$args"
		layout print "/p"
	}

	layout print "/(al,ml10,bo4)"

	set id [get_selectedobject]

	if { $id == 0 } {
		set local_player [get_local_player]
		foreach name [get_attrib_names] {
			println $name [get_owner_attrib $local_player $name]
		}
	} else {
		println "Id" $id
		println "Class" [get_objclass $id]
		println "Name" [get_objname $id]
		println "Lock" [get_lock $id]
		println "Owner" [get_owner $id]
		println "Contained" [is_contained $id]
		println "State" [state_get $id]
		println "Inventory" [inv_cnt $id] [inv_list $id]
		println "Tasks" [tasklist_cnt $id] [tasklist_list $id]
		println "Position" [get_pos $id]
		println "Physic" [get_physic $id]
		println "View in fog" [get_viewinfog $id]
		println "Light" [get_light $id]
		println "Autolight" [get_autolight $id]
		println "Climbability" [get_climbability $id]
		println "Selectable" [get_selectable $id]

		layout print "/p"

		foreach name [get_attrib_names] {
			println $name [get_attrib $id $name]
		}
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_subwindow_cheats {} {
	proc println {args} {
		layout print "/(fn0,ta10)$args"
		layout print "/p"
	}

	proc set_all_invented {value} {
		set owner [get_local_player]
		foreach attr [get_bp_attrib_names] {
			set_invented $owner $attr $value
		}
	}

	layout print "/(al,bo4)"

	println [btn [lmsg InventAll] "set_all_invented 1"]
	println [btn [lmsg UninventAll] "set_all_invented 0"]

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

layout print "/(fn1,ac)"
layout print [di_btn_set_tab tab_dump Dump]
layout print "/(tx   )"
layout print [di_btn_set_tab tab_cheats Cheats]
layout print "/p/p"

switch $di_tab {
	"tab_dump" {
		di_render_subwindow_dump
	}
	"tab_cheats" {
		di_render_subwindow_cheats
	}
}
