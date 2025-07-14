# Return difference of two lists
proc ldiff {lst1 lst2} {
	set rlst [list]
	foreach entry $lst1 {
		if { [lsearch -exact $lst2 $entry] == -1 } {
			lappend rlst $entry
		}
	}
	return $rlst
}

# Return random entry from the list
proc lrentry {lst} {
	return [lindex $lst [irandom [llength $lst]]]
}
