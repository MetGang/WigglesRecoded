//z_work_strike.tcl
if {[in_class_def]} {

	state_enter strike {
		strike_start
	}

	state strike {
		strike_loop
	}

	state_leave strike {
		strike_end
	}

} else {

	set offset_mood 0.02

	proc strike_start {} {
		//Testen ob der Zwerg nicht an der Wand h�ngt
		//falls ja runter gehen
		if {[get_gnomeposition this] == 1} {
			if {[walk_down_from_wall] == 1} {
				log "WARNING: Zwerg kann an der Wand nich streiken, und freien Platz hat er auch nicht gefunden -> also Strike gleich beenden"
				state_triggerfresh this work_idle
			}
		}
		log "Zwerg '[get_objname this]' f�ngt an zu streiken"
		tasklist_add this "change_tool Streikschild"
        do_strike
		set_attrib this GnomeStrike 1
	}

	proc strike_loop {} {
		global offset_mood
		if { [tasklist_cnt this] > 0 } {
			set command [tasklist_get this 0]
			tasklist_rem this 0
#			log "[get_objname this]-prodfill:$command remaining: [tasklist_cnt this]"
			eval $command
			return
		} else {
			if {[get_attrib this atr_Mood] >= 0.35 || [get_remaining_sparetime this]>0.0} {
				log "Zwerg '[get_objname this]' hat aufgehoert an zu streiken"
			//Stimmung verbessern und Status �ndern
				state_triggerfresh this work_idle
			} else {
				set_attrib this atr_Mood [expr [get_attrib this atr_Mood] + $offset_mood]
				do_strike
			}
		}
	}

	proc strike_end {} {
		set_attrib this GnomeStrike 0
	}

	proc do_strike {} {
		for {set i 0} {$i < 6} {incr i} {
			tasklist_add this "walk_random 10"
      	}
	}
}
