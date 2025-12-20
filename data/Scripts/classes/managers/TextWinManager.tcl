call scripts/debug.tcl

def_class TextWinManager none none 0 {} {

	#
	method_static get_instance {} {
		set id [obj_query 0 -class TextWinManager -limit 1]

		if { $id == 0 } {
			set id [new TextWinManager]
			log INFO "Created new TextWinManager $id"
		}

		return $id
	}

	set saved_state {}

	#
	method open_window {name state} {
		open_window $name $state
	}

	#
	method embed_window {name state} {
		embed_window $name $state
	}

	#
	method has_saved_state {} {
		return [has_saved_state]
	}

	#
	method pop_saved_state {} {
		return [pop_saved_state]
	}

	# Constructor
	obj_init {

		#
		proc handle_window { cmd name state } {
			global saved_state
			set saved_state $state
			switch $name {
				"info_achievement" {
					eval $cmd "data/scripts/text/doc/common/info_achievement.tcl"
				}
				"info_invention" {
					eval $cmd "data/scripts/text/doc/common/info_invention.tcl"
				}
			}
		}

		#
		proc open_window {name state} {
			handle_window "textwin run" $name $state
		}

		#
		proc embed_window {name state} {
			handle_window "call" $name $state
		}

		#
		proc has_saved_state {} {
			global saved_state
			if { $saved_state != {} } { return 1 } { return 0 }
		}

		#
		proc pop_saved_state {} {
			global saved_state
			set tmp $saved_state
			set saved_state {}
			return $tmp
		}
	}
}
