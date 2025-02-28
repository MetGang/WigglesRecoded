#
proc underscornt {str} {
	set str [string map {"_" " "} $str]
	set str [string trim $str " "]
	return "/(tx$str)"
}

#
proc btn {label cmd {active true}} {
	if { $active } {
		return [layout autoxlink $cmd [underscornt $label]]
	} else {
		return [underscornt $label]
	}
}

#
proc reset_info_window_style {} {
	layout print "/(fn0,al,ml0,mr0,ls0,bo0)"
}

#
proc render_info_window_title {title} {
    layout print "/(fn2,ac,bo16)/(tx$title)/(bo0)/p"
	reset_info_window_style
}
