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

proc render_invention_links {classname} {
	proc render_indent {is_odd} {
		if { $is_odd } {
			layout print "/(tb50)"
		} else {
			layout print "/(ta10)"
		}
	}

	layout print "/(al)"

	if { ![check_method $classname prod_items] || [lsearch {Lager Theater} $classname] != -1 } {
		return
	}

	if { [lsearch {Farm Feuerstelle} $classname] != -1 } {
		layout print "/p"
	}

	set parity 0
	set localid [net localid]

	foreach item [call_method_static $classname prod_items] {
		set item [string trim $item "_"]
		set is_odd [expr {($parity % 2) != 0}]

		layout print "/(fn1)"

		if { [is_invented $localid $item] } {
			render_indent $is_odd
			layout print [btn_run_doc [lmsg $item] "tt_$item.tcl"]

			if { [chm_cheat_enabled InventButtons] } {
				layout print "/(fn0)/(tx )"
				layout print [btn [lmsg Forget] "set_invented $localid Bp$item 0; layout reload"]
			}
		} else {
			render_indent $is_odd
			layout print [lmsg $item]

			if { [chm_cheat_enabled InventButtons] } {
				layout print "/(fn0)/(tx )"
				layout print [btn [lmsg Invent] "set_invented $localid Bp$item 1; layout reload"]
			}
		}

		if { $is_odd } {
			layout print "/p"
		}

		incr parity
	}
}

render_invention_links $key

reset_info_window_style
