call scripts/db/achievements.tcl
call scripts/db/cheats.tcl
call scripts/lib/compare.tcl
call scripts/lib/time.tcl
call scripts/lib/ui.tcl
call scripts/utility.tcl

### F4 menu - Assistant ###

layout clear
render_info_window_title [lmsg Assistant]

# ---------------------------------------------------------------------------- #

proc pi_reload_layout {} {
	global pi_tab pi_buildings_tab pi_sflag_age pi_sflag_gender pi_sflag_working pi_sflag_striking pi_aflag_rarity pi_aflag_status
	layout reload
}

# ---------------------------------------------------------------------------- #

if { ![info exists pi_tab] } {
	set pi_tab "tab_buildings"
}

proc pi_set_tab {value} [uigen_var_setter pi_tab pi_reload_layout]

proc pi_btn_set_tab {value lkey} [uigen_var_setter_btn pi_tab pi_set_tab]

# ---------------------------------------------------------------------------- #

proc pi_center_and_select {id} {
	center_and_select $id
	pi_reload_layout
}

proc pi_btn_select_object {id} {
	return [btn [get_objname $id] "pi_center_and_select $id"]
}

# ---------------------------------------------------------------------------- #

if { ![info exists pi_buildings_tab] } {
	set pi_buildings_tab "tab_buildings_all"
}

proc pi_set_buildings_tab {value} [uigen_var_setter pi_buildings_tab pi_reload_layout]

proc pi_btn_set_buildings_tab {value lkey} [uigen_var_setter_btn pi_buildings_tab pi_set_buildings_tab]

proc pi_render_subwindow_buildings {} {
	global pi_buildings_tab

	layout print "/(fn1,ac,bo8)"

	layout print [pi_btn_set_buildings_tab tab_buildings_all AllCategories]
	layout print "/p"
	layout print [pi_btn_set_buildings_tab tab_buildings_production Production]
	layout print "/(tx  )"
	layout print [pi_btn_set_buildings_tab tab_buildings_energy Energy]
	layout print "/(tx  )"
	layout print [pi_btn_set_buildings_tab tab_buildings_storage Store]
	layout print "/(tx  )"
	layout print [pi_btn_set_buildings_tab tab_buildings_elevator Elevator]
	layout print "/(tx  )"
	layout print [pi_btn_set_buildings_tab tab_buildings_protection Protection]
	layout print "/p/p"

	reset_info_window_style

	switch $pi_buildings_tab {
		"tab_buildings_all" {
			pi_render_subwindow_buildings_all
		}
		"tab_buildings_production" {
			pi_render_subwindow_buildings_production
		}
		"tab_buildings_energy" {
			pi_render_subwindow_buildings_energy
		}
		"tab_buildings_storage" {
			pi_render_subwindow_buildings_storage
		}
		"tab_buildings_elevator" {
			pi_render_subwindow_buildings_elevator
		}
		"tab_buildings_protection" {
			pi_render_subwindow_buildings_protection
		}
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc pi_render_subwindow_buildings_all {} {
	set all [query_buildings [get_local_player]]

	if { [llength $all] == 0 } {
		layout print "/(fn0,ac)[lmsg NoBuildingsAtAll]/p"
		return
	}

	layout print "/(fn1,ls6)"

	set parity 1

	foreach id $all {
		if { $parity } {
			layout print "/(fn1,ta10)[pi_btn_select_object $id]"
		} else {
			layout print "/(fn1,ta250)[pi_btn_select_object $id]"
			layout print "/p"
		}
		set parity [expr {!$parity}]
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc pi_render_subwindow_buildings_production {} {
	set all [query_buildings [get_local_player] production]

	if { [llength $all] == 0 } {
		layout print "/(fn0,ac)[lmsg NoBuildings]/p"
		return
	}

	layout print "/(al)"

	foreach id $all {
		layout print "/(fn1,ta10,bo8)[pi_btn_select_object $id]/p"

		set x 10

		foreach class [get_prod_slot_list $id] {
			if { [get_prod_slot_invented $id $class] } {
				if { [get_prod_slot_buildable $id $class] } {
					layout print "/(ta$x)/(iidata/gui/icons/$class.tga)"
				} else {
					layout print "/(ta$x)/(iidata/gui/icons/Red$class.tga)"
				}
			} else {
				if { [get_prod_slot_inventable $id $class] } {
					layout print "/(ta$x)/(iidata/gui/icons/$class.tga)"
					layout print "/(ta$x)/(iidata/gui/icons/xoverlay_question.tga)"
				} else {
					layout print "/(ta$x)/(iidata/gui/icons/Red$class.tga)"
					layout print "/(ta$x)/(iidata/gui/icons/Redxoverlay_question.tga)"
				}
			}

			set cnt [get_prod_slot_cnt $id $class]

			if { [get_prod_switchmode $id] } {
				if { $cnt > 0 } {
					layout print "/(ta$x])/(iidata/gui/icons/xoverlay_switchon.tga)"
				} else {
					layout print "/(ta$x])/(iidata/gui/icons/xoverlay_switchoff.tga)"
				}
			} else {
				if { $cnt > 0 } {
					if { $cnt > 9 } {
						layout print "/(ta[expr {$x + 27}])o"
						layout print "/(ta[expr {$x + 32}])o"
					} else {
						layout print "/(ta[expr {$x + 27}])$cnt"
					}
				}
			}

			incr x 40
		}

		layout print "/p"
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc pi_render_subwindow_buildings_energy {} {
	set all [query_buildings [get_local_player] energy]

	if { [llength $all] == 0 } {
		layout print "/(fn0,ac)[lmsg NoBuildings]/p"
		return
	}

	foreach id $all {
		layout print "/(fn1,ta10,bo8)[pi_btn_select_object $id]/p"

		if { ![get_boxed $id] && [get_prod_enabled $id] } {
			layout print "/(ta10)/(iidata/gui/icons/energyon.tga)"
		} else {
			layout print "/(ta10)/(iidata/gui/icons/energyoff.tga)"
		}

		layout print "/p"
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc pi_render_subwindow_buildings_storage {} {
	set all [query_buildings [get_local_player] store]

	if { [llength $all] == 0 } {
		layout print "/(fn0,ac)[lmsg NoBuildings]/p"
		return
	}

	layout print "/(al)"

	foreach id $all {
		layout print "/(fn1,ta10,bo8)[pi_btn_select_object $id]"
		layout print "/(bo0)"
		layout print "/p"

		set inv [inv_list $id]

		if { [llength $inv] == 0 } {
			layout print "/(fn0,ta10)[lmsg EmptyStore]/p/p"
			continue
		}

		set x 10
		layout print "/(fn0,bo6)"
		layout print "/(ta$x)[lmsg Item]"; incr x 280
		layout print "/(ta$x)[lmsg InStore]"; incr x 90
		layout print "/p"

		set inv [inv_list $id]
		set inv [lsort -command compare_by_class_translated $inv]
		lappend inv ""

		set last_class [get_objclass [lindex $inv 0]]
		set cnt 0

		layout print "/(bo0)"

		foreach item $inv {
			set class [get_objclass $item]
			if { $class != $last_class } {
				set x 10
				layout print "/(fn1)"
				layout print "/(ta$x)[lmsg $last_class]"; incr x 280
				layout print "/(fn0)"
				layout print "/(ta$x)$cnt"; incr x 90
				layout print "/p"

				set last_class $class
				set cnt 0
			}
			incr cnt
		}

		layout print "/p"
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc pi_render_subwindow_buildings_elevator {} {
	set all [query_buildings [get_local_player] elevator]

	if { [llength $all] == 0 } {
		layout print "/(fn0,ac)[lmsg NoBuildings]/p"
		return
	}

	layout print "/(al)"

	foreach id $all {
		layout print "/(fn1,ta10,bo8)[pi_btn_select_object $id]/p"
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc pi_render_subwindow_buildings_protection {} {
	set all [query_buildings [get_local_player] protection]

	if { [llength $all] == 0 } {
		layout print "/(fn0,ac)[lmsg NoBuildings]/p"
		return
	}

	layout print "/(al)"

	foreach id $all {
		layout print "/(fn1,ta10,bo8)[pi_btn_select_object $id]/p"

		set x 10

		foreach class [get_prod_slot_list $id] {
			layout print "/(ta$x)/(iidata/gui/icons/$class.tga)"

			set cnt [get_prod_slot_cnt $id $class]
			if { $cnt > 0 } {
				layout print "/(ta$x])/(iidata/gui/icons/xoverlay_switchon.tga)"
			} else {
				layout print "/(ta$x])/(iidata/gui/icons/xoverlay_switchoff.tga)"
			}

			incr x 40
		}

		layout print "/p"
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc pi_render_subwindow_items {} {
	layout print "/(fn0,al)"

	set x 10
	layout print "/(fn0,bo6)"
	layout print "/(ta$x)[lmsg Item]"; incr x 280
	layout print "/(ta$x)[lmsg InStore]"; incr x 90
	layout print "/(ta$x)[lmsg Contained]"; incr x 90
	layout print "/(ta$x)[lmsg Total]"; incr x 90
	layout print "/p"

	set all [obj_query 0 -type {material tool} -owner [get_local_player]]
	set all [lsort -command compare_by_class_translated $all]
	lappend all ""

	set last_class [get_objclass [lindex $all 0]]
	set cnt 0
	set cnt_instore 0
	set cnt_contained 0

	foreach entry $all {
		set class [get_objclass $entry]
		if { $class != $last_class } {
			set x 10
			layout print "/(fn1,bo0)"
			layout print "/(ta$x)[lmsg $last_class]"; incr x 280
			layout print "/(fn0)"
			layout print "/(ta$x)$cnt_instore"; incr x 90
			layout print "/(ta$x)$cnt_contained"; incr x 90
			layout print "/(ta$x)$cnt"; incr x 90
			layout print "/p"

			set last_class $class
			set cnt 0
			set cnt_instore 0
			set cnt_contained 0
		}
		incr cnt
		if { [get_instore $entry] } {
			incr cnt_instore
		}
		if { [is_contained $entry] } {
			incr cnt_contained
		}
	}

	layout print "/p"

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

if { ![info exists pi_sflag_age] } {
	set pi_sflag_age "all"
}

if { ![info exists pi_sflag_gender] } {
	set pi_sflag_gender "all"
}

if { ![info exists pi_sflag_working] } {
	set pi_sflag_working "all"
}

if { ![info exists pi_sflag_striking] } {
	set pi_sflag_striking "all"
}

proc pi_set_sflag_age {value} [uigen_var_setter pi_sflag_age pi_reload_layout]

proc pi_btn_set_sflag_age {value lkey} [uigen_var_setter_btn pi_sflag_age pi_set_sflag_age]

proc pi_set_sflag_gender {value} [uigen_var_setter pi_sflag_gender pi_reload_layout]

proc pi_btn_set_sflag_gender {value lkey} [uigen_var_setter_btn pi_sflag_gender pi_set_sflag_gender]

proc pi_set_sflag_working {value} [uigen_var_setter pi_sflag_working pi_reload_layout]

proc pi_btn_set_sflag_working {value lkey} [uigen_var_setter_btn pi_sflag_working pi_set_sflag_working]

proc pi_set_sflag_striking {value} [uigen_var_setter pi_sflag_striking pi_reload_layout]

proc pi_btn_set_sflag_striking {value lkey} [uigen_var_setter_btn pi_sflag_striking pi_set_sflag_striking]

proc pi_render_subwindow_selection {} {
	proc select_filtered_objects {} {
		global pi_sflag_age pi_sflag_gender pi_sflag_working pi_sflag_striking

		switch $pi_sflag_age {
			"all" {
				set type {gnome baby}
			}
			"adult" {
				set type {gnome}
			}
			"baby" {
				set type {baby}
			}
		}

		switch $pi_sflag_gender {
			"all" {
				set flagpos {}
			}
			"female" {
				set flagpos {female}
			}
			"male" {
				set flagpos {male}
			}
		}

		set ls [obj_query 0 -type $type -flagpos $flagpos -owner [get_local_player]]

		if { $pi_sflag_working != "all" } {
			set tmp_ls [list]
			foreach entry $ls {
				if { $pi_sflag_working == "working" && [get_remaining_sparetime $entry] == 0.0 } {
					lappend tmp_ls $entry
				} elseif { $pi_sflag_working == "freetime" && [get_remaining_sparetime $entry] > 0.0 } {
					lappend tmp_ls $entry
				}
			}
			set ls $tmp_ls
		}

		if { $pi_sflag_striking != "all" } {
			set tmp_ls [list]
			foreach entry $ls {
				if { $pi_sflag_striking == "striking" && [get_attrib $entry GnomeStrike] == 1 } {
					lappend tmp_ls $entry
				} elseif { $pi_sflag_striking == "laboring" && [get_attrib $entry GnomeStrike] == 0 } {
					lappend tmp_ls $entry
				}
			}
			set ls $tmp_ls
		}

		selection clear
		foreach entry $ls {
			selection include $entry
		}
	}

	layout print "/(al)"

	set x 10
	layout print "/(fn1)"
	layout print "/(ta$x)[lmsg Age]"; incr x 100
	layout print "/(fn0)"
	layout print "/(ta$x)[pi_btn_set_sflag_age all AllAge]"; incr x 80
	layout print "/(ta$x)[pi_btn_set_sflag_age adult Adults]"; incr x 80
	layout print "/(ta$x)[pi_btn_set_sflag_age baby Babies]"; incr x 80
	layout print "/p"

	set x 10
	layout print "/(fn1)"
	layout print "/(ta$x)[lmsg Gender]"; incr x 100
	layout print "/(fn0)"
	layout print "/(ta$x)[pi_btn_set_sflag_gender all AllGender]"; incr x 80
	layout print "/(ta$x)[pi_btn_set_sflag_gender female Females]"; incr x 80
	layout print "/(ta$x)[pi_btn_set_sflag_gender male Males]"; incr x 80
	layout print "/p"

	set x 10
	layout print "/(fn1)"
	layout print "/(ta$x)[lmsg Worktime]"; incr x 100
	layout print "/(fn0)"
	layout print "/(ta$x)[pi_btn_set_sflag_working all AllWorktime]"; incr x 80
	layout print "/(ta$x)[pi_btn_set_sflag_working working Working]"; incr x 80
	layout print "/(ta$x)[pi_btn_set_sflag_working freetime Freetime]"; incr x 80
	layout print "/p"

	# TODO: Translation
	set x 10
	layout print "/(fn1)"
	layout print "/(ta$x)[lmsg Strike]"; incr x 100
	layout print "/(fn0)"
	layout print "/(ta$x)[pi_btn_set_sflag_striking all AllStrike]"; incr x 80
	layout print "/(ta$x)[pi_btn_set_sflag_striking striking Striking]"; incr x 80
	layout print "/(ta$x)[pi_btn_set_sflag_striking laboring Laboring]"; incr x 80
	layout print "/p"

	set x 10
	layout print "/p"
	layout print "/(ta$x)[btn [lmsg Select] select_filtered_objects]"
	layout print "/p"

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc pi_render_subwindow_statistics {} {
	proc println {k v} {
		layout print "/(fn1,ta10)$k:/(tx )"
		layout print "/(fn0)$v"
		layout print "/p"
	}

	layout print "/(al,bo6)"

	set owner [get_local_player]
	println [lmsg Stats_GameTime] [get_formatted_gametime [gettime]]
	println [lmsg Stats_CivState] [calc_civ_state $owner]
	println [lmsg Stats_NumGnomes] [gamestats numgnomes $owner]
	println [lmsg Stats_NumBabies] [gamestats numbabies $owner]
	println [lmsg Stats_BuiltProds] [gamestats numbuiltprodclasses $owner]

	layout print "/p"

	set stman [call_method_static StatisticsManager get_instance]
	foreach key [call_method $stman get_stat_list] {
		println [lmsg StatName_$key] [call_method $stman get_stat_value $key]
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

if { ![info exists pi_aflag_rarity] } {
	set pi_aflag_rarity "all"
}

if { ![info exists pi_aflag_status] } {
	set pi_aflag_status "all"
}

proc pi_set_aflag_rarity {value} [uigen_var_setter pi_aflag_rarity pi_reload_layout]

proc pi_btn_set_aflag_rarity {value lkey} [uigen_var_setter_btn pi_aflag_rarity pi_set_aflag_rarity]

proc pi_set_aflag_status {value} [uigen_var_setter pi_aflag_status pi_reload_layout]

proc pi_btn_set_aflag_status {value lkey} [uigen_var_setter_btn pi_aflag_status pi_set_aflag_status]

proc pi_render_subwindow_achievements {} {
	global pi_aflag_rarity pi_aflag_status

	layout print "/(fn1,ac,bo4)"

	layout print [pi_btn_set_aflag_rarity all AllRarities]
	layout print "/(tx | )"
	layout print [pi_btn_set_aflag_rarity Common Common]
	layout print "/(tx  )"
	layout print [pi_btn_set_aflag_rarity Uncommon Uncommon]
	layout print "/(tx  )"
	layout print [pi_btn_set_aflag_rarity Rare Rare]
	layout print "/(tx  )"
	layout print [pi_btn_set_aflag_rarity Epic Epic]
	layout print "/(tx  )"
	layout print [pi_btn_set_aflag_rarity Legendary Legendary]
	layout print "/p"

	layout print "/(fn1,ac,bo8)"

	layout print [pi_btn_set_aflag_status all AllStatuses]
	layout print "/(tx | )"
	layout print [pi_btn_set_aflag_status unlocked Unlocked]
	layout print "/(tx  )"
	layout print [pi_btn_set_aflag_status locked Locked]
	layout print "/p"

	reset_info_window_style

	layout print "/(ml10,ta10)"

	set aman [call_method_static AchievementManager get_instance]

	if { $pi_aflag_status == "all" } {
		set unlocked_count [call_method $aman get_unlocked_achv_count $pi_aflag_rarity]
		set total_count [call_method $aman get_total_achv_count $pi_aflag_rarity]
		layout print "/(fn1)[lmsg Progress]:/(tx )/(fn0)$unlocked_count / $total_count"
		layout print "/p"
	} else {
		if { $pi_aflag_status == "unlocked" } {
			set unlocked_count [call_method $aman get_unlocked_achv_count $pi_aflag_rarity]
			layout print "/(fn1)[lmsg Unlocked]:/(tx )/(fn0)$unlocked_count"
		} elseif { $pi_aflag_status == "locked" } {
			set locked_count [call_method $aman get_locked_achv_count $pi_aflag_rarity]
			layout print "/(fn1)[lmsg Locked]:/(tx )/(fn0)$locked_count"
		}
		layout print "/p"
	}

	layout print "/p"

	foreach key [call_method $aman get_achv_list $pi_aflag_rarity] {
		if { $pi_aflag_status == "unlocked" && ![call_method $aman is_achv_unlocked $key] } { continue }
		if { $pi_aflag_status == "locked" && [call_method $aman is_achv_unlocked $key] } { continue }
		set progress [call_method $aman get_achv_progress $key]
		set dividend [lindex $progress 0]
		set divisor [lindex $progress 1]
		set title [lmsg AchvTitle_$key]
		layout print "/(fn1,bo6)"
		layout print [btn "$title" "twm_open_window info_achievement $key" [call_method $aman is_achv_unlocked $key]]
		layout print "/p"
		layout print "/(fn0,bo14)[lmsg AchvShort_$key]/(tx )($dividend / $divisor)/p"
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc pi_render_subwindow_cheats {} {
	if { ![chm_cheating_enabled] } {
		layout print "/(fn0,ac)[lmsg YouWereNotSupposedToBeHere]/p"
		reset_info_window_style
		return
	}

	layout print "/(fn0,bo6,ml10,ta10)"

	set chman [call_method_static CheatManager get_instance]

	foreach key [db_cheats_keys] {
		println [chbx_toggle_btn $key "call_method $chman toggle_cheat_enabled $key; pi_reload_layout" [call_method $chman is_cheat_enabled $key]]
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

layout print "/(fn1,ac)"
layout print [pi_btn_set_tab tab_buildings Buildings]
layout print "/(tx  )"
layout print [pi_btn_set_tab tab_items Items]
layout print "/(tx  )"
layout print [pi_btn_set_tab tab_selection Selection]
layout print "/(tx  )"
layout print [pi_btn_set_tab tab_statistics Statistics]
layout print "/(tx  )"
layout print [pi_btn_set_tab tab_achievements Achievements]
if { [chm_cheating_enabled] } {
	layout print "/(tx  )"
	layout print [pi_btn_set_tab tab_cheats Cheats]
}
layout print "/p/p"

reset_info_window_style

switch $pi_tab {
	"tab_buildings" {
		pi_render_subwindow_buildings
	}
	"tab_items" {
		pi_render_subwindow_items
	}
	"tab_selection" {
		pi_render_subwindow_selection
	}
	"tab_statistics" {
		pi_render_subwindow_statistics
	}
	"tab_achievements" {
		pi_render_subwindow_achievements
	}
	"tab_cheats" {
		pi_render_subwindow_cheats
	}
}
