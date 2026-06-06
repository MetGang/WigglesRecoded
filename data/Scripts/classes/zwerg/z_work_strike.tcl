call scripts/debug.tcl

if { [in_class_def] } {

	#
	state_enter strike {
		strike_start
	}

	#
	state strike {
		strike_loop
	}

	#
	state_leave strike {
		strike_end
	}

} else {

	#
	proc strike_start {} {
		# If gnome is on the wall
		if { [get_gnomeposition this] == 1 } {
			# Try to get down from the wall
			if { [walk_down_from_wall] == 1 } {
				log WARN "[get_objname this] cannot strike against the wall and no free space has been found"
				state_triggerfresh this work_idle
			}
		}

		tasklist_add this "change_tool Streikschild"
        do_strike
		set_attrib this GnomeStrike 1
	}

	#
	proc strike_loop {} {
		if { [tasklist_cnt this] > 0 } {
			set cmd [tasklist_get this 0]
			tasklist_rem this 0
			eval $cmd
		} else {
			if { [get_attrib this atr_Mood] >= 0.35 || [get_remaining_sparetime this] > 0.0 } {
				state_triggerfresh this work_idle
			} else {
				set_attrib this atr_Mood [expr [get_attrib this atr_Mood] + 0.02]
				do_strike
			}
		}
	}

	#
	proc strike_end {} {
		set_attrib this GnomeStrike 0
	}

	#
	proc do_strike {} {
		for { set i 0 } { $i < 6 } { incr i } {
			tasklist_add this "walk_random 10"
      	}
	}
}
