#
proc get_formatted_gametime {timestamp} {
	if { $timestamp < 1 } {
		return "0 [lmsg s]"
	}

	set seconds $timestamp
	set minutes 0.0
	set hours 0.0

	if { $seconds > 60 } {
		set minutes [expr $seconds / 60]
		set seconds [expr int($seconds - int($minutes) * 60)]
		if { $minutes > 60 } {
			set hours [expr $minutes / 60]
			set minutes [expr int($minutes - int($hours) * 60)]
		}
	}

	set seconds [expr int($seconds)]
	set minutes [expr int($minutes)]
	set hours [expr int($hours)]

	if { $seconds < 10 && $minutes > 0 } {
		set seconds "0$seconds"
	}
	if { $minutes < 10 && $hours > 0 } {
		set minutes "0$minutes"
	}

	if { $hours > 0 } {
		return "${hours} [lmsg h] ${minutes} [lmsg min] ${seconds} [lmsg s]"
	}
	if { $minutes > 0 } {
		return "${minutes} [lmsg min] ${seconds} [lmsg s]"
	}
	if { $seconds > 0 } {
		return "${seconds} [lmsg s]"
	}

	return {}
}
