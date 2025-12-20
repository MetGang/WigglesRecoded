call scripts/lib/compare.tcl
call scripts/lib/ui.tcl

# ---------------------------------------------------------------------------- #

#
proc in_tutorial {} {
	if { [obj_query this -class {Trigger_Tutorial Trigger_Tournament} -limit 1] != 0 } { return 1 } { return 0 }
}

#
proc in_campaign {} {
	if { [is_storymgr] } { return 1 } { return 0 }
}

#
proc in_skirmish {} {
	if { ![in_campaign] && ![in_tutorial] } { return 1 } { return 0 }
}

# ---------------------------------------------------------------------------- #

#
proc am_trigger_achv_step {key} {
	set aman [call_method_static AchievementManager get_instance]
	call_method $aman trigger_achv_step $key
}

# ---------------------------------------------------------------------------- #

#
proc chm_cheating_enabled {} {
	set chman [call_method_static CheatManager get_instance]
	return [call_method $chman is_cheating_enabled]
}

#
proc chm_cheat_enabled {name} {
	set chman [call_method_static CheatManager get_instance]
	if { [call_method $chman is_cheating_enabled] } {
		return [call_method $chman is_cheat_enabled $name]
	}
	return 0
}

# ---------------------------------------------------------------------------- #

#
proc cfm_get_value {key} {
	set cfman [call_method_static ConfigManager get_instance]
	return [call_method $cfman get_value $key]
}

#
proc cfm_get_value_or {key fallback} {
	set cfman [call_method_static ConfigManager get_instance]
	return [call_method $cfman get_value $key $fallback]
}

# ---------------------------------------------------------------------------- #

#
proc stm_incr_stat_value {key value} {
	set stman [call_method_static StatisticsManager get_instance]
	call_method $stman incr_stat_value $key $value
}

# ---------------------------------------------------------------------------- #

#
proc twm_open_window {name state} {
	set twman [call_method_static TextWinManager get_instance]
	call_method $twman open_window $name $state
}

#
proc twm_embed_window {name state} {
	set twman [call_method_static TextWinManager get_instance]
	call_method $twman embed_window $name $state
}

#
proc twm_has_saved_state {} {
	set twman [call_method_static TextWinManager get_instance]
	return [call_method $twman has_saved_state]
}

#
proc twm_pop_saved_state {} {
	set twman [call_method_static TextWinManager get_instance]
	return [call_method $twman pop_saved_state]
}

# ---------------------------------------------------------------------------- #

#
proc center_and_select {id} {
	set view [get_view]
	set pos [get_pos $id]
	set_view [vector_unpackx $pos] [vector_unpacky $pos] [vector_unpackz $view]
	selection clear
	selection include $id
}

# ---------------------------------------------------------------------------- #

#
proc query_buildings {owner {category "*"}} {
	switch $category {
		"production" {
			set rlst [list]
			set objs [obj_query 0 -type {production} -owner $owner]
			if { $objs != 0 } {
				foreach id $objs {
					if { [lsearch {Zelt Grabstein Mittelalterschlafzimmer Mittelalterwohnzimmer Mittelalterbad Industrieschlafzimmer Industriewohnzimmer Industriebad Luxusschlafzimmer Luxuswohnzimmer Luxusbad Lager} [get_objclass $id]] == -1 } {
						lappend rlst $id
					}
				}
			}
		}
		"energy" {
			set rlst [obj_query 0 -type {energy} -owner $owner]
		}
		"store" {
			set rlst [obj_query 0 -class {Lager} -owner $owner]
		}
		"elevator" {
			set rlst [obj_query 0 -type {elevator} -owner $owner]
		}
		"protection" {
			set rlst [obj_query 0 -type {protection} -owner $owner]
		}
		"*" {
			set rlst [obj_query 0 -type {production energy store elevator protection} -owner $owner]
		}
	}

	if { $rlst == 0 } { return [list] }

	return [lsort -command compare_by_name_ext $rlst]
}

#
proc is_building_by_type {type} {
    return [expr {[lsearch {production energy store elevator protection} $type] != -1}]
}

#
proc is_building_by_id {id} {
	return [is_building_by_type [get_objtype $id]]
}

#
proc is_building_by_classname {classname} {
	return [is_building_by_type [get_class_type $classname]]
}

# ---------------------------------------------------------------------------- #

#
proc can_use_weapon {gid wid} {
	set widtrue [get_weapon_id $wid true]
	set widfalse [get_weapon_id $wid false]

	if { $widtrue > $widfalse } {
		set wid $widtrue
	} else {
		set wid $widfalse
	}

	if { [check_weapon_exp $gid $wid] } {
		return true
	} else {
		return false
	}
}

# ---------------------------------------------------------------------------- #

#
proc calc_gnome_age {gid} {
	return [expr {([gettime] - [get_attrib $gid GnomeAge]) / 1800.0}]
}

#
proc calc_gnome_expsum {gid} {
	set expsum 0.0
	foreach attr [get_expattrib] {
		if { $attr == "exp_Kampf" } { continue }
		fincr expsum [get_attrib $gid $attr]
	}
	return $expsum
}

#
proc calc_fitness {} {
	if { [get_attrib this atr_Alertness] < 0.4 } {
		return 0
	}

	foreach attr {atr_Hitpoints atr_Nutrition atr_Alertness atr_Mood} {
		if { [get_attrib this $attr] < 0.75 } {
			return 1
		}
	}

	return 2
}

#
proc calc_civ_state {owner} {
	return [expr {([gamestats attribsum $owner expsum] + [gamestats numbuiltprodclasses $owner]) * 0.01}]
}

# ---------------------------------------------------------------------------- #

#
proc get_bp_attrib_names {} {
	set rlst [list]
	foreach attr [get_attrib_names] {
		if { [string first "Bp" $attr] == 0 } {
			lappend rlst $attr
		}
	}
	return $rlst
}

#
proc set_invented {owner attr value} {
	set_owner_attrib $owner $attr $value
}

#
proc is_invented {owner attr} {
	if { [get_owner_attrib $owner "Bp$attr"] != 0 } { return 1 } { return 0 }
}
