#
proc compare_string {a b} {
	return [string compare $a $b]
}

#
proc compare_string_translated {a b} {
	return [string compare [lmsg $a] [lmsg $b]]
}

#
proc compare_by_name {a b} {
	return [string compare [get_objname $a] [get_objname $b]]
}

#
proc compare_by_name_ext {a b} {
	proc split_name {name} {
		if { [regexp {^(.*?)[ ]?([0-9]+)?$} $name -> prefix num] } {
			if { $num == "" } { set num 0 }
			return [list $prefix $num]
		}
		return [list $name 0]
	}

	set name1 [get_objname $a]
	set name2 [get_objname $b]

	set parts1 [split_name $name1]
	set parts2 [split_name $name2]

	set prefix1 [lindex $parts1 0]
	set num1 [lindex $parts1 1]

	set prefix2 [lindex $parts2 0]
	set num2 [lindex $parts2 1]

	set cmp [string compare $prefix1 $prefix2]
	if { $cmp != 0 } { return $cmp }

	return [expr {$num1 - $num2}]
}

#
proc compare_by_class {a b} {
	return [string compare [get_objclass $a] [get_objclass $b]]
}

#
proc compare_by_class_translated {a b} {
	return [string compare [lmsg [get_objclass $a]] [lmsg [get_objclass $b]]]
}
