call scripts/lib/ui.tcl
call scripts/utility.tcl

### Invention ###

layout clear
render_info_window_title [lmsg Invention]

# ---------------------------------------------------------------------------- #

set key [twm_pop_saved_state]

layout print "/(is10)/(ildata/gui/docpix/Info_$key.tga)"
layout print "/(fn1,ac)[lmsg $key]"
layout print "/p/p"
layout print "/(ab)[lmsg $key\Desc]"
layout print "/p/p"

proc inventionlinks {classname} {
	layout print "/(al)"

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

inventionlinks $key
