call scripts/lib/ui.tcl
call scripts/utility.tcl

### F6 menu - Details ###

layout clear
render_info_window_title [lmsg Details]

# ---------------------------------------------------------------------------- #

proc di_reload_layout {} {
	global di_tab
	layout reload
}

# ---------------------------------------------------------------------------- #

if { ![info exists di_tab] } {
	set di_tab "tab_main"
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

proc di_render_subwindow_main {} {
	set id [get_selectedobject]
	set class [get_objclass $id]
	set type [get_objtype $id]
	set name [get_objname $id]

	layout print "/(al)"

	layout print "/(ta10)$id $class $type $name/p/p"

	if { $type == "gnome" } {
		layout print $name
	} elseif { $type == "baby" } {
		layout print $name
	} else {
		layout print "/(fn0)" [btn [lmsg InventPage] "textwin run tt_$class.tcl"]
	}

	layout print "/p"

	reset_info_window_style
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

layout print "/(fn1,ac)"
layout print [di_btn_set_tab tab_main Main]
layout print "/(tx   )"
layout print [di_btn_set_tab tab_dump Dump]
layout print "/p/p"

switch $di_tab {
	"tab_main" {
		di_render_subwindow_main
	}
	"tab_dump" {
		di_render_subwindow_dump
	}
}
