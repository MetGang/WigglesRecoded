call scripts/lib/compare.tcl
call scripts/lib/ui.tcl

# ---------------------------------------------------------------------------- #

proc cheats_enabled {} {
	return 1
}

# ---------------------------------------------------------------------------- #

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

proc is_building_by_type {type} {
    return [expr {[lsearch {production energy store elevator protection} $type] != -1}]
}

proc is_building_by_id {id} {
	return [is_building_by_type [get_objtype $id]]
}

proc is_building_by_classname {classname} {
	return [is_building_by_type [get_class_type $classname]]
}

# ---------------------------------------------------------------------------- #

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

proc calc_gnome_age {gid} {
	return [expr {([gettime] - [get_attrib $gid GnomeAge]) / 1800.0}]
}

proc calc_gnome_expsum {gid} {
	set expsum 0.0
	foreach attr [get_expattrib] {
		if { $attr == "exp_Kampf" } { continue }
		fincr expsum [get_attrib $gid $attr]
	}
	return $expsum
}

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

proc calc_civ_state {owner} {
	return [expr {([gamestats attribsum $owner expsum] + [gamestats numbuiltprodclasses $owner]) * 0.01}]
}

# ---------------------------------------------------------------------------- #

proc get_bp_attrib_names {} {
	set rlst [list]
	foreach attr [get_attrib_names] {
		if { [string first "Bp" $attr] == 0 } {
			lappend rlst $attr
		}
	}
	return $rlst
}

proc set_invented {owner attr value} {
	set_owner_attrib $owner $attr $value
}

proc is_invented {owner attr} {
	if { [get_owner_attrib $owner "Bp$attr"] != 0 } { return 1 } { return 0 }
}
