# Place this at the top of systeminit.tcl to setup logging
# call scripts/debug.tcl ; setup_logging

# Place this at the top of the file and/or inside obj_init to enable logging
# call scripts/debug.tcl

# To deactivate certain logging level prepend it with //
# i.e. //EVENT

#
proc setup_logging {} {
	close [open "debug.log" "w"]
}

#
proc log {level args} {
    set debug_levels {
		INIT
		INFO
		WARN
		ERROR
		EVENT
		//STATE
		PROCS
		CLASS
		//AI
	}

    if { [lsearch $debug_levels $level] == -1 } { return }

	set file [open "debug.log" "a"]
	set timestamp [format "%.5f" [gettime]]

	puts $file "\[$timestamp\] $level: $args"

	close $file
}
