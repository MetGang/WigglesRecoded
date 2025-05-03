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
proc btn_doc {label filepath {active true}} {
	if { $active } {
		return [layout autolink $filepath [underscornt $label]]
	} else {
		return [underscornt $label]
	}
}

#
proc btn_run_doc {label filepath {active true}} {
	return [btn $label "textwin run $filepath" $active]
}

#
proc reset_info_window_style {} {
	layout print "/(fn0,al,ml0,mr0,ls0,bo0)"
}

#
proc render_info_window_title {title} {
	layout print "/(fn2,ac,bo16)[underscornt $title]/(bo0)/p"
	reset_info_window_style
}

#
proc println {v} {
	layout print $v
	layout print "/p"
}

#
proc println_kv {k v} {
	layout print "/(fn1)$k:"
	layout print "/(fn0)$v"
	layout print "/p"
}

#
proc println_kargs {k args} {
	layout print "/(fn1)$k:"
	layout print "/(fn0)$args"
	layout print "/p"
}
