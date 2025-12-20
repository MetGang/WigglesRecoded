call scripts/lib/ui.tcl
call scripts/utility.tcl

set quests 0

proc inventionlinks {classname} {
	layout print "/(al)/p/p"

	if { ![check_method $classname prod_items] || [lsearch {Lager Theater} $classname] != -1 } {
		return
	}

	if { [lsearch {Farm Feuerstelle} $classname] != -1 } {
		layout print "/p"
	}

	set parity 0

	foreach item [call_method_static $classname prod_items] {
		set item [string trim $item "_"]

		layout print "/(fn1)"

		if { [is_invented [net localid] $item] } {
			layout print [btn_run_doc [lmsg $item] "tt_$item.tcl"]
			if { [chm_cheat_enabled InventButtons] } {
				layout print "/(fn0)/(tx )"
				layout print [btn [lmsg Forget] "set_invented [net localid] Bp$item 0; layout reload"]
			}
		} else {
			layout print [lmsg $item]
			if { [chm_cheat_enabled InventButtons] } {
				layout print "/(fn0)/(tx )"
				layout print [btn [lmsg Invent] "set_invented [net localid] Bp$item 1; layout reload"]
			}
		}

		if { ($parity % 2) == 0 } {
			layout print "/(tb50)"
		} else {
			layout print "/p"
		}

		incr parity
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

	if { ![is_storymgr] } { return }

	if { ![sm_get_event $story_event] } { return }

	incr quests

	layout print "/(al)/(fn1)"
	layout print "$headline /p"
	layout print "/(al)/(fn0)/p"

	if { ![sm_get_event $done_event] } {
		layout print "$text"
	} else {
		layout print [lmsg "Quest Done"]
	}

	layout print "/p/p/p"
}

proc questlog_end {} {
	global quests

	if { $quests == 0 } {
		layout print "/(ac)/(fn0)/p/p"
		layout print [lmsg "No Quests"]
		layout print "/p"
	}
}

proc linkline {target text} {
	layout print [layout autolink $target "/(tx$text)/p"]
}

proc paragraph {text} {
	layout print "$text/p/p"
}

proc pickone {lst} {
	layout print [lindex $lst [irandom [llength $lst]]]
}
