call scripts/debug.tcl
call scripts/utility.tcl

def_class AchievementManager none none 0 {} {

	#
	method_static get_instance {} {
		set id [obj_query 0 -class AchievementManager -limit 1]

		if { $id == 0 } {
			set id [new AchievementManager]
			log INFO "Created new AchievementManager $id"
			call_method $id apply_config
			log INFO "Config applied to AchievementManager $id"
		}

		return $id
	}

	#
	method apply_config {} {
		
	}

	#
	method get_achv_list {rarity} {
		set all [get_available_achvs]
		if { $rarity == "all" } {
			return $all
		} else {
			set rlst {}
			foreach entry $all {
				if { [call_method this get_achv_rarity $entry] == $rarity } {
					lappend rlst $entry
				}
			}
			return $rlst
		}
	}

	#
	method trigger_achv_step {key} {
		if { ![call_method this is_achv_unlocked $key] } {
			if { [incr_achv_progress $key] } {
				create_achv_sticker $key
			}
		}
	}

	#
	method is_achv_unlocked {key} {
		set dividend [lindex [subst \$achv_$key] 0]
		set divisor [lindex [subst \$achv_$key] 1]
		return [expr {$dividend >= $divisor}]
	}

	#
	method get_achv_progress {key} {
		set dividend [lindex [subst \$achv_$key] 0]
		set divisor [lindex [subst \$achv_$key] 1]
		return [list $dividend $divisor]
	}

	#
	method get_achv_rarity {key} {
		return [lindex [subst \$achv_$key] 2]
	}

	#
	method get_achv_acquire_time {key} {
		return [lindex [subst \$achv_$key] 3]
	}

	#
	method get_unlocked_achv_count {rarity} {
		set cnt 0
		foreach key [call_method this get_achv_list $rarity] {
			if { [call_method this is_achv_unlocked $key] } {
				incr cnt
			}
		}
		return $cnt
	}

	#
	method get_locked_achv_count {rarity} {
		set cnt 0
		foreach key [call_method this get_achv_list $rarity] {
			if { ![call_method this is_achv_unlocked $key] } {
				incr cnt
			}
		}
		return $cnt
	}

	#
	method get_total_achv_count {rarity} {
		return [llength [call_method this get_achv_list $rarity]]
	}

	# Constructor
	obj_init {
		call scripts/db/achievements.tcl
		call scripts/lib/lang.tcl
		call scripts/utility.tcl

		foreach key [db_achievements_keys] {
			set achv_$key [list 0 [db_achievements_value $key 0] [db_achievements_value $key 1] 0]
		}

		#
		proc get_available_achvs {} {
			return [db_achievements_keys]
		}

		#
		proc create_achv_sticker {key} {
			set msg [lmsgp [lmsg AchvSticker_Unlocked] [lmsg AchvTitle_$key]]
			set id [newsticker new 0 -text $msg -time 60 -color {255 255 144}]
			newsticker change $id -click "newsticker delete $id; twm_open_window info_achievement $key"
		}

		#
		proc incr_achv_progress {key} {
			upvar achv_$key achv

			set dividend [lindex $achv 0]
			set divisor [lindex $achv 1]
			incr dividend
			set achv [lreplace $achv 0 0 $dividend]

			if { $dividend >= $divisor } {
				set achv [lreplace $achv 3 3 [gettime]]
				return 1
			}

			return 0
		}
	}
}
