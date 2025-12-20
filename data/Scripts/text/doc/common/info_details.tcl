call scripts/db/gnome_skills.tcl
call scripts/lib/time.tcl
call scripts/lib/ui.tcl
call scripts/utility.tcl

### F6 menu - Details ###

layout clear
render_info_window_title [lmsg Details]

# ---------------------------------------------------------------------------- #

proc di_reload_layout {} {
	global di_tab di_gnome_tab
	layout reload
}

# ---------------------------------------------------------------------------- #

set di_id [get_selectedobject]

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

if { ![info exists di_gnome_tab] } {
	set di_gnome_tab "tab_main_natural"
}

proc di_set_gnome_tab {tab} {
	global di_gnome_tab
	set di_gnome_tab $tab
	di_reload_layout
}

proc di_btn_set_gnome_tab {tab lkey} {
	global di_gnome_tab
	return [btn [lmsg $lkey] "di_set_gnome_tab $tab" [expr {$di_gnome_tab != $tab}]]
}

# ---------------------------------------------------------------------------- #

proc di_render_details_section {title cmd} {
	layout print "/(ml10,ta10,bo10)"
	layout print "/(fn1)--- $title ---/p"
	layout print "/(bo4)"
	eval $cmd
	layout print "/p"

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_subwindow_main_player {} {
	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_subwindow_main_gnome {} {
	global di_id
	set gid $di_id

	layout print "/(al,bo6)"

	println_kv [lmsg Name] [get_objname $gid]
	println_kv [lmsg Age] [format %0.0f [calc_gnome_age $gid]]
	println_kv [lmsg Gender] [lmsg [get_objgender $gid]]

	layout print "/p"

	println_kv [lmsg Level] [call_method $gid get_exp_level]
	println_kv [lmsg Experience] "[call_method $gid get_exp_points] / [call_method $gid get_exp_points_ftnl]"
	println_kv [lmsg SkillPoints] [call_method $gid get_exp_skill_points]

	foreach key [db_gnome_skills_keys] {
		if { ![call_method $gid has_acquired_skill $key] } {
			layout print "/(ta10)/(iidata/gui/icons/[db_gnome_skills_get_icon $key].tga)/p"
			layout print [btn [lmsg $key] "call_method $gid acquire_skill $key; di_reload_layout" [call_method $gid can_acquire_skill $key]]
			layout print "/p"
		}
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_subwindow_main_baby {} {
	global di_id
	set bid $di_id

	layout print "/(al,bo6)"

	println_kv [lmsg Name] [get_objname $bid]
	# FIXME: Replace magic constant
	println_kv [lmsg TimeLeftToGrowUp] [get_formatted_gametime [expr 1200.0 - ([gettime] - [get_attrib $bid GnomeAge])]]

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_info_section_main {} {
	global di_id
	set id $di_id

	println_kv "Name" [underscornt [get_objname $id]]
}

proc di_render_info_section_production {} {
	global di_id
	set id $di_id

	println_kv "CurrentWorker" [underscornt [get_objname [call_method $id get_current_worker]]]
	println_kv "EnergyConsumption" [call_method $id get_energy_consumption]
}

proc di_render_info_section_culinary {} {
	global di_id
	set id $di_id

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

proc di_render_info_section_energy {} {
	global di_id
	set id $di_id

	println_kv "EnergyStore" [call_method $id get_energy_store]
	println_kv "EnergyMaxStore" [call_method $id get_energy_max_store]
	println_kv "EnergyYield" [call_method $id get_energy_yield]
	println_kv "EnergyClass" [call_method $id get_energy_class]
	println_kv "EnergyRange" [call_method $id get_energy_range]
}

proc di_render_info_section_links {} {
	global di_id
	set id $di_id

	layout print [btn_run_doc [lmsg InventPage] "tt_[get_objclass $id].tcl"]
	layout print "/p"
}

proc di_render_subwindow_main_building {} {
	global di_id
	set id $di_id
	set cn [get_objclass $id]

	di_render_details_section [lmsg Section_Main] "di_render_info_section_main"

	if { [get_objtype $id] == "production" } {
		di_render_details_section [lmsg Section_Production] "di_render_info_section_production"
	}

	if { [lsearch {Feuerstelle Mittelalterkueche Industriekueche Luxuskueche} $cn] != -1 } {
		di_render_details_section [lmsg Section_Culinary] "di_render_info_section_culinary"
	}

	if { [lsearch {Laufrad Wasserrad Dampfmaschine Reaktor} $cn] != -1 } {
		di_render_details_section [lmsg Section_Energy] "di_render_info_section_energy"
	}

	di_render_details_section [lmsg Section_Links] "di_render_info_section_links"

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_subwindow_main {} {
	global di_id
	set id $di_id
	set type [get_objtype $id]

	if { $id == 0 } {
		di_render_subwindow_main_player
	} elseif { $type == "gnome" } {
		di_render_subwindow_main_gnome
	} elseif { $type == "baby" } {
		di_render_subwindow_main_baby
	} else {
		di_render_subwindow_main_building
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_subwindow_dump_player {} {
	layout print "/(ml10,ta10,bo4)"

	set local_player [get_local_player]
	foreach name [get_attrib_names] {
		println_kargs $name [get_owner_attrib $local_player $name]
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_subwindow_dump_general {} {
	global di_id
	set id $di_id

	layout print "/(ml10,ta10,bo4)"

	println_kargs "Id" $id
	println_kargs "Class" [get_objclass $id]
	println_kargs "Name" [get_objname $id]
	println_kargs "Lock" [get_lock $id]
	println_kargs "Owner" [get_owner $id]
	println_kargs "Selectable" [get_selectable $id]
	println_kargs "Selected" [is_selected $id]
	println_kargs "Contained" [is_contained $id]
	println_kargs "State" [state_get $id]
	println_kargs "Tasks" [tasklist_cnt $id] [tasklist_list $id]
	println_kargs "Inventory" [inv_cnt $id] [inv_list $id]
	println_kargs "Position" [get_pos $id]
	println_kargs "Physic" [get_physic $id]
	println_kargs "View in fog" [get_viewinfog $id]
	println_kargs "Light" [get_light $id]
	println_kargs "Autolight" [get_autolight $id]
	println_kargs "Climbability" [get_climbability $id]

	layout print "/p"

	foreach name [get_attrib_names] {
		println_kargs $name [get_attrib $id $name]
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_subwindow_dump {} {
	global di_id
	set id $di_id

	if { $id == 0 } {
		di_render_subwindow_dump_player
	} else {
		di_render_subwindow_dump_general
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc di_render_subwindow_cheats_player {} {
	global di_id
	set id $di_id

	layout print "/(ml10,ta10,bo4)"

	foreach name {Achievement Cheat Config Statistics TextWin} {
		set mgr_id [call_method_static $name\Manager get_instance]
		# FIXME: Reloading
		layout print [btn "[lmsg Delete] $name\Manager ($mgr_id)" "del $mgr_id; di_reload_layout"]
		layout print "/p"
	}

	reset_info_window_style
}

proc di_render_subwindow_cheats_gnome {} {
	global di_id
	set id $di_id

	layout print "/(ml10,ta10,bo4)"

	foreach attr {atr_Hitpoints atr_Nutrition atr_Alertness atr_Mood atr_ExpMax exp_Nahrung exp_Holz exp_Stein exp_Metall exp_Transport exp_Energie exp_Service exp_F_Sword exp_F_Twohanded exp_F_Defense exp_F_Ballistic exp_F_Kungfu} {
		println_kargs $attr [btn -100 "add_attrib $id $attr -1.0; di_reload_layout"] [btn -10 "add_attrib $id $attr -0.1; di_reload_layout"] [btn -5 "add_attrib $id $attr -0.05; di_reload_layout"] [btn -1 "add_attrib $id $attr -0.01; di_reload_layout"] [btn 0 "set_attrib $id $attr 0.0; di_reload_layout"] [btn +1 "add_attrib $id $attr 0.01; di_reload_layout"] [btn +5 "add_attrib $id $attr 0.05; di_reload_layout"] [btn +10 "add_attrib $id $attr 0.1; di_reload_layout"] [btn +100 "add_attrib $id $attr 1.0; di_reload_layout"]
	}

	reset_info_window_style
}

proc di_render_subwindow_cheats_baby {} {
	global di_id
	set id $di_id

	layout print "/(ml10,ta10,bo4)"

	reset_info_window_style
}

proc di_render_subwindow_cheats_building {} {
	global di_id
	set id $di_id
	set cn [get_objclass $id]

	layout print "/(ml10,ta10,bo4)"

	if { [lsearch {Lager} $cn] != -1 } {
		println [btn [lmsg DropAllItems] "call_method $id drop_all_items"]
	}

	reset_info_window_style
}

proc di_render_subwindow_cheats {} {
	if { ![chm_cheating_enabled] } {
		layout print "/(fn0,ac)[lmsg YouWereNotSupposedToBeHere]/p"
		reset_info_window_style
		return
	}

	global di_id
	set id $di_id
	set type [get_objtype $id]

	if { $id == 0 } {
		di_render_subwindow_cheats_player
	} elseif { $type == "gnome" } {
		di_render_subwindow_cheats_gnome
	} elseif { $type == "baby" } {
		di_render_subwindow_cheats_baby
	} else {
		di_render_subwindow_cheats_building
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

layout print "/(fn1,ac)"
layout print [di_btn_set_tab tab_main Main]
layout print "/(tx   )"
layout print [di_btn_set_tab tab_dump Dump]
if { [chm_cheating_enabled] } {
	layout print "/(tx   )"
	layout print [di_btn_set_tab tab_cheats Cheats]
}
layout print "/p/p"

reset_info_window_style

switch $di_tab {
	"tab_main" {
		di_render_subwindow_main
	}
	"tab_dump" {
		di_render_subwindow_dump
	}
	"tab_cheats" {
		di_render_subwindow_cheats
	}
}
