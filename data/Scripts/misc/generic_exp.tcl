if { [in_class_def] } {

	#
	method gain_exp_points {points} {
		gain_exp_points $points
	}

	#
	method get_exp_points {} {
		return [get_exp_points]
	}

	#
	method get_exp_points_ftnl {} {
		return [get_exp_points_ftnl]
	}

	#
	method get_exp_level {} {
		return [get_exp_level]
	}

	#
	method get_exp_skill_points {} {
		return [get_exp_skill_points]
	}

	#
	method has_acquired_skill {key} {
		return [has_acquired_skill $key]
	}

	#
	method can_acquire_skill {key} {
		return [can_acquire_skill $key]
	}

	#
	method acquire_skill {key} {
		acquire_skill $key
	}

} else {

	call scripts/db/gnome_skills.tcl
	call scripts/lib/lang.tcl

	set exp_points 0
	set exp_level 1
	set exp_skill_points 0
	set exp_skill_list {}

	#
	proc create_level_up_sticker {} {
		set msg [lmsgp [lmsg ExpSticker_LevelUp] [get_objname this] [get_exp_level]]
		set id [newsticker new 0 -text $msg -time 60 -color {144 255 255}]
		newsticker change $id -click "newsticker delete $id; center_and_select [get_ref this]"
	}

	#
	proc maybe_level_up {} {
		global exp_level exp_skill_points
		set success 0
		while { [get_exp_points] >= [get_exp_points_ftnl] } {
			incr exp_level
			incr exp_skill_points
			set success 1
		}
		if { $success } {
			create_level_up_sticker
		}
	}

	#
	proc gain_exp_points {points} {
		global exp_points
		incr exp_points $points
		maybe_level_up
	}

	#
	proc get_exp_points {} {
		global exp_points
		return [expr {int($exp_points)}]
	}

	#
	proc get_exp_points_ftnl {} {
		global exp_level
		return [expr {int(pow(2, $exp_level))}]
	}

	#
	proc get_exp_level {} {
		global exp_level
		return [expr {int($exp_level)}]
	}

	#
	proc get_exp_skill_points {} {
		global exp_skill_points
		return [expr {int($exp_skill_points)}]
	}

	#
	proc has_acquired_skill {key} {
		global exp_skill_list
		if { [lsearch $exp_skill_list $key] != -1 } { return 1 } { return 0 }
	}

	#
	proc can_acquire_skill {key} {
		if { [has_acquired_skill $key] } { return 0 }
		if { [get_exp_skill_points] >= [db_gnome_skills_get_cost $key] } { return 1 } { return 0 }
	}

	#
	proc acquire_skill {key} {
		global exp_skill_points exp_skill_list
		if { ![can_acquire_skill $key] } { return 0 }
		set exp_skill_points [expr {$exp_skill_points - [db_gnome_skills_get_cost $key]}]
		lappend exp_skill_list $key
		return 1
	}
}
