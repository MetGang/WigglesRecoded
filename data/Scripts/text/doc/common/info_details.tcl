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

proc di_render_subwindow_main_gnome {id} {
	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_subwindow_main_baby {id} {
	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_info_section_main {id} {
	println_kv "Name" [underscornt [get_objname $id]]
}

proc di_render_info_section_production {id} {
	println_kv "CurrentWorker" [underscornt [get_objname [call_method $id get_current_worker]]]
	println_kv "EnergyConsumption" [call_method $id get_energy_consumption]
}

proc di_render_info_section_culinary {id} {
	set edibles {Grillpilz Grillhamster Pilzbrot Raupensuppe Raupenschleimkuchen Gourmetsuppe Hamstershake}
	set food_nearby [call_method $id get_eat_objects $edibles]
	set food_list {}
	for { set i 0 } { $i < [llength $food_nearby] } { incr i } {
		if { [lindex $food_nearby $i] != 0 } {
			lappend food_list "[lindex $food_nearby $i]x [lmsg [lindex $edibles $i]]"
		}
	}
	println_kv "FoodNearby" $food_list
}

proc di_render_info_section_energy {id} {
	println_kv "EnergyStore" [call_method $id get_energy_store]
	println_kv "EnergyMaxStore" [call_method $id get_energy_max_store]
	println_kv "EnergyYield" [call_method $id get_energy_yield]
	println_kv "EnergyClass" [call_method $id get_energy_class]
	println_kv "EnergyRange" [call_method $id get_energy_range]
}

proc di_render_info_section_links {id} {
	layout print [btn_run_doc [lmsg InventPage] "tt_[get_objclass $id].tcl"]
	layout print "/p"
}

proc di_render_info_section_cheats {id} {
	set cn [get_objclass $id]
	if { [lsearch {Lager} $cn] != -1 } {
		layout print "/(fn0,ta10)"
		layout print [btn [lmsg DropAllItems] "call_method $id drop_all_items"]
		layout print "/p"
	}
}

proc di_render_details_section {title cmd} {
	layout print "/(ml10,bo10)"
	layout print "/(fn1)--- $title ---"
	layout print "/p"
	layout print "/(bo4)"
	eval $cmd
	layout print "/p"

	reset_info_window_style
}

proc di_render_subwindow_main_building {id} {
	set cn [get_objclass $id]

	di_render_details_section [lmsg Section_Main] "di_render_info_section_main $id"

	if { [get_objtype $id] == "production" } {
		di_render_details_section [lmsg Section_Production] "di_render_info_section_production $id"
	}

	if { [lsearch {Feuerstelle Mittelalterkueche Industriekueche Luxuskueche} $cn] != -1 } {
		di_render_details_section [lmsg Section_Culinary] "di_render_info_section_culinary $id"
	}

	if { [lsearch {Laufrad Wasserrad Dampfmaschine Reaktor} $cn] != -1 } {
		di_render_details_section [lmsg Section_Energy] "di_render_info_section_energy $id"
	}

	di_render_details_section [lmsg Section_Links] "di_render_info_section_links $id"

	if { [cheats_enabled] } {
		di_render_details_section [lmsg Section_Links] "di_render_info_section_cheats $id"
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_subwindow_main {} {
	set id [get_selectedobject]
	set type [get_objtype $id]

	layout print "/(al)"

	if { $type == "gnome" } {
		di_render_subwindow_main_gnome $id
	} elseif { $type == "baby" } {
		di_render_subwindow_main_baby $id
	} else {
		di_render_subwindow_main_building $id
	}

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
