call scripts/debug.tcl
call scripts/utility.tcl

def_class CheatManager none none 0 {} {
	call scripts/db/cheats.tcl

	#
	method_static get_instance {} {
		set id [obj_query 0 -class CheatManager -limit 1]

		if { $id == 0 } {
			set id [new CheatManager]
			log INFO "Created new CheatManager $id"
			call_method $id apply_config
			log INFO "Config applied to CheatManager $id"
		}

		return $id
	}

	#
	method apply_config {} {
		call_method this set_cheating_enabled [cfm_get_value_or "main.Cheats" 0]

		foreach key [db_cheats_keys] {
			call_method this set_cheat_enabled $key [cfm_get_value_or "cheats.$key" 0]
		}
	}

	set cheating_enabled 0
	member cheating_enabled

	#
	method is_cheating_enabled {} {
		return $cheating_enabled
	}

	#
	method set_cheating_enabled {flag} {
		set cheating_enabled $flag
	}

	#
	method toggle_cheating_enabled {} {
		set cheating_enabled [expr {!$cheating_enabled}]
	}

	#
	method is_cheat_enabled {key} {
		return [subst \$cheat_$key]
	}

	#
	method set_cheat_enabled {key flag} {
		set cheat_$key $flag
	}

	#
	method toggle_cheat_enabled {key} {
		if { [call_method this is_cheat_enabled $key] } { set cheat_$key 0 } { set cheat_$key 1 }
	}

	# Constructor
	obj_init {
		call scripts/db/cheats.tcl
		call scripts/utility.tcl

		foreach key [db_cheats_keys] {
			set cheat_$key 0
		}
	}
}
