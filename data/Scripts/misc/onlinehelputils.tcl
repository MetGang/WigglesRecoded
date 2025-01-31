
set quests 0							;# für Questlog


proc is_invented {class} {
//	log "checking class $class"
	return [expr {[get_owner_attrib [net localid] "Bp$class"] > 0}]
}

proc inventionlinks {classname} {
	set links 0

	layout print "/(al)/p/p"
	if {![check_method $classname prod_items]} {
		return
	}
	
	foreach item [call_method_static $classname prod_items] {
		incr links

		set item [string trim $item "_"]		
		if {[is_invented $item]} {
			layout print [layout autolink "tt_$item.tcl" "/(tx[lmsg $item])"]
		} else {
			layout print "[lmsg $item]"
		}
		if {($links % 2) == 0} {
			layout print "/p "
		} else {
			layout print "/(tb50)"
		}
	}
}

proc ohlp_initstyle {} {
	layout print "/(ml15,mr15,ls0,hp3)"
}

proc ohlp_ttheadlinestyle {} {
	layout print "/(ac)/(fn2)"
}

proc ohlp_tttextbodystyle {} {
	layout print "/p/p/(ab)/(fn1)"
}


proc questlog_headline {} {
	layout print "/(ac)/(fn2)"
	layout print [lmsg Questlog]
	layout print "/p/p"
}

proc questlog {story_event headline text} {
	global quests

	set done_event $story_event
	append done_event _done
	
	if {![is_storymgr]} {
		return
	}
	
	if {![sm_get_event $story_event]} {
		return
	}
	
	incr quests
	
	layout print "/(al)/(fn1)"
	layout print "$headline /p"
	layout print "/(al)/(fn0)/p"

	if {![sm_get_event $done_event]} {
		layout print "$text"
	} else {
		layout print [lmsg "Quest Done"]
	}
	layout print "/p/p/p"
}


proc questlog_end {} {
	global quests

	if {$quests == 0} {
		layout print "/(ac)/(fn0)/p/p"
		layout print [lmsg "No Quests"]
		layout print "/p"
	}
}


proc linkline {target text} {
	layout print [layout autolink $target "/(tx$text)/p"]
}


proc paragraph {text} {
	layout print "$text /p/p"
}


proc pickone {lst} {
	set i [irandom [llength $lst]]
	layout print [lindex $lst $i]
}