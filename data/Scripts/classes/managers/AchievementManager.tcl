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
		call scripts/lib/list.tcl
		call scripts/utility.tcl

		foreach key [db_achievements_keys] {
			# The structure is as follows:
			# [0] = current step
			# [1] = max steps
			# [2] = rarity
			# [3] = timestamp when achieved
			# [4] = type {count time}
			# [5] = time window
			# [6] = entry idx
			# [7] = entries
			set achv_$key [list 0 [db_achievements_get_steps $key] [db_achievements_get_rarity $key] 0 [db_achievements_get_type $key] [db_achievements_get_time_window $key] 0 [lrepeat [db_achievements_get_window_count $key] -1]]
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

			set timestamp [gettime]
			set dividend [lindex $achv 0]
			set divisor [lindex $achv 1]
			set type [lindex $achv 4]

			switch $type {
				"count" {
					incr dividend
					set achv [lreplace $achv 0 0 $dividend]
				}
				"time" {
					set time_window [lindex $achv 5]
					set entries [lindex $achv 7]
					set entry_idx [lindex $achv 6]
					set ref_entry_idx [expr {($entry_idx + 1) % [llength $entries]}]

					set entries [lreplace $entries $entry_idx $entry_idx $timestamp]
					set achv [lreplace $achv 7 7 $entries]

					set entry_idx [expr {($entry_idx + 1) % [llength $entries]}]
					set achv [lreplace $achv 6 6 $entry_idx]

					if { [lindex $entries $ref_entry_idx] != -1 } {
						if { [lindex $entries $entry_idx] - [lindex $entries $ref_entry_idx] < $time_window } {
							incr dividend
							set achv [lreplace $achv 0 0 $dividend]
							set achv [lreplace $achv 7 7 [lrepeat [db_achievements_get_window_count $key] -1]]
						}
					}
				}
			}

			if { $dividend >= $divisor } {
				set achv [lreplace $achv 3 3 [gettime]]
				return 1
			}

			return 0
		}
	}
}
