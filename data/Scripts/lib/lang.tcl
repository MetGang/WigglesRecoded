#
proc lmsgp {lkey args} {
	set result $lkey
	for { set i 0 } { $i < [llength $args] } { incr i } {
		set placeholder "\$[expr {$i + 1}]"
		set replacement [lindex $args $i]
		set result [string map [list $placeholder $replacement] $result]
	}
	return $result
}
