call scripts/lib/ui.tcl
call scripts/utility.tcl

### F3 menu - Gnomes ###

layout clear
render_info_window_title [lmsg Zwerge]

# ---------------------------------------------------------------------------- #

# Query all gnomes' ids
set gi_gnome_list [obj_query 0 -type {gnome baby} -owner [get_local_player]]

# No gnomes, nothing to render, early return
if { $gi_gnome_list == 0 } { return }

# ---------------------------------------------------------------------------- #

proc gi_reload_layout {} {
	global gi_tab gi_ordering
	layout reload
}

# ---------------------------------------------------------------------------- #

if { ![info exists gi_tab] } {
	set gi_tab "tab_standard"
}

if { ![info exists gi_ordering] } {
	set gi_ordering "GnomeAge"
}

proc gi_set_tab {value} [uigen_var_setter gi_tab gi_reload_layout]

proc gi_btn_set_tab {value lkey} [uigen_var_setter_btn gi_tab gi_set_tab]

proc gi_set_ordering {value} [uigen_var_setter gi_ordering gi_reload_layout]

proc gi_btn_set_ordering {value lkey} [uigen_var_setter_btn gi_ordering gi_set_ordering]

# ---------------------------------------------------------------------------- #

proc gi_center_and_select {id} {
	center_and_select $id
	gi_reload_layout
}

proc gi_btn_select_gnome {gid} {
	# Gnome is invalid
	if { $gid == 0 } {
		return ""
	}
	# Gnome is dead
	if { $gid == -1 } {
		return "-"
	}
	# Gnome's id has been reassigned to something else
	if { !([get_objtype $gid] == "gnome" || [get_objtype $gid] == "baby") } {
		return ""
	}

	return [btn [get_objname $gid] "gi_center_and_select $gid" [expr {![selection check $gid]}]]
}

# ---------------------------------------------------------------------------- #

proc gi_render_subwindow_standard {gnome_list} {
	proc render_tablehead {} {
		set x 10
		layout print "/(fn0,al,bo6)"
		layout print "/(ta$x)[gi_btn_set_ordering Name Name]"; incr x 90
		layout print "/(ta$x)[gi_btn_set_ordering atr_Hitpoints Ges.]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering atr_Nutrition Ern.]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering atr_Alertness Aufm.]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering atr_Mood Stimm.]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering GnomeAge Age]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering Gender Gender]"; incr x 60
	}

	proc render_tablerow {gid} {
		set x 10
		layout print "/(fn1,bo0)"
		layout print "/(ta$x)[gi_btn_select_gnome $gid]"; incr x 90
		layout print "/(fn0)"
		layout print "/(ta$x)/(ccHealthbar $gid atr_Hitpoints)"; incr x 60
		layout print "/(ta$x)/(ccHealthbar $gid atr_Nutrition)"; incr x 60
		layout print "/(ta$x)/(ccHealthbar $gid atr_Alertness)"; incr x 60
		layout print "/(ta$x)/(ccHealthbar $gid atr_Mood)"; incr x 60
		layout print "/(ta$x)[format %0.0f [calc_gnome_age $gid]]"; incr x 60
		layout print "/(ta$x)[lmsg [get_objgender $gid]]"; incr x 60
	}

	render_tablehead
	layout print "/p"

	foreach gid $gnome_list {
		render_tablerow $gid
		layout print "/p"
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc gi_render_subwindow_production {gnome_list} {
	proc render_tablehead {} {
		set x 10
		layout print "/(fn0,al,bo6)"
		layout print "/(ta$x)[gi_btn_set_ordering Name Name]"; incr x 90
		layout print "/(ta$x)[gi_btn_set_ordering ExpSum Summe]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering exp_Nahrung Nahrung]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering exp_Holz Holz]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering exp_Stein Steine]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering exp_Metall Metalle]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering exp_Transport Transp.]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering exp_Energie Alchemie]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering exp_Service Service]"; incr x 60
	}

	proc render_tablerow {gid} {
		set x 10
		layout print "/(fn1,bo0)"
		layout print "/(ta$x)[gi_btn_select_gnome $gid]"; incr x 90
		layout print "/(fn0)"
		layout print "/(ta$x)/(ccAttribrangebar $gid)"; incr x 60
		layout print "/(ta$x)/(ccAttribbar $gid exp_Nahrung)"; incr x 60
		layout print "/(ta$x)/(ccAttribbar $gid exp_Holz)"; incr x 60
		layout print "/(ta$x)/(ccAttribbar $gid exp_Stein)"; incr x 60
		layout print "/(ta$x)/(ccAttribbar $gid exp_Metall)"; incr x 60
		layout print "/(ta$x)/(ccAttribbar $gid exp_Transport)"; incr x 60
		layout print "/(ta$x)/(ccAttribbar $gid exp_Energie)"; incr x 60
		layout print "/(ta$x)/(ccAttribbar $gid exp_Service)"; incr x 60
	}

	render_tablehead
	layout print "/p"

	foreach gid $gnome_list {
		render_tablerow $gid
		layout print "/p"
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc gi_render_subwindow_fight {gnome_list} {
	proc render_tablehead {} {
		set x 10
		layout print "/(fn0,al,bo6)"
		layout print "/(ta$x)[gi_btn_set_ordering Name Name]"; incr x 90
		layout print "/(ta$x)[gi_btn_set_ordering exp_Kampf Kampf]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering exp_F_Sword Schwertkampf]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering exp_F_Twohanded Zweihand]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering exp_F_Defense Verteid.]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering exp_F_Ballistic Ballist.]"; incr x 60
		layout print "/(ta$x)[gi_btn_set_ordering exp_F_Kungfu Kungfu]"; incr x 60
	}

	proc render_tablerow {gid} {
		set x 10
		layout print "/(fn1,bo0)"
		layout print "/(ta$x)[gi_btn_select_gnome $gid]"; incr x 90
		layout print "/(fn0)"
		layout print "/(ta$x)/(ccAttribbar $gid exp_Kampf)"; incr x 60
		layout print "/(ta$x)/(ccAttribbar $gid exp_F_Sword)"; incr x 60
		layout print "/(ta$x)/(ccAttribbar $gid exp_F_Twohanded)"; incr x 60
		layout print "/(ta$x)/(ccAttribbar $gid exp_F_Defense)"; incr x 60
		layout print "/(ta$x)/(ccAttribbar $gid exp_F_Ballistic)"; incr x 60
		layout print "/(ta$x)/(ccAttribbar $gid exp_F_Kungfu)"; incr x 60
	}

	render_tablehead
	layout print "/p"

	foreach gid $gnome_list {
		render_tablerow $gid
		layout print "/p"
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc gi_render_subwindow_inventory {gnome_list} {
	proc render_tablehead {} {
		set x 10
		layout print "/(fn0,al,bo6)"
		layout print "/(ta$x)[gi_btn_set_ordering Name Name]"; incr x 90
		layout print "/(ta$x)[gi_btn_set_ordering InvCnt Inventory]"; incr x 60
	}

	proc render_tablerow {gid} {
		layout print "/(fn1,bo0)"
		layout print "/(ta10)[gi_btn_select_gnome $gid]"

		set inv [inv_list $gid]
		set inv_sz [inv_getsize $gid]

		set i 0
		set x 90
		set row_cnt 0

		# Print items
		layout print "/(fn0)/(ta80)/(bo-10)"
		foreach item $inv {
			if { $row_cnt >= 14 } {
				layout print "/p"
				set x 90
				set row_cnt 0
			}

			set item_class [get_objclass $item]

			if { [can_use_weapon $gid $item] } {
				set img_color ""
			} else {
				set img_color "Red"
			}

			set img_name "/texture/classicons/${img_color}${item_class}.tga"
			layout print "/(ta$x)/(iidata$img_name)"

			incr i
			incr x 32
			incr row_cnt
		}
		layout print "/(bo0)"

		# Print empty slots
		for {} { $i < $inv_sz } { incr i } {
			if { $row_cnt >= 14 } {
				layout print "/p"
				set x 90
				set row_cnt 0
			}

			layout print "/(ta$x)/(tx__)"

			incr x 32
			incr row_cnt
		}
	}

	render_tablehead
	layout print "/p"

	foreach gid $gnome_list {
		render_tablerow $gid
		layout print "/p"
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

proc gi_render_subwindow_family {gnome_list} {
	proc render_tablehead {} {
		set x 10
		layout print "/(fn0,al,bo6)"
		layout print "/(ta$x)[gi_btn_set_ordering Name Name]"; incr x 90
		layout print "/(ta$x)[gi_btn_set_ordering PartnerName Partner]"; incr x 80
		layout print "/(ta$x)[gi_btn_set_ordering MotherName Mutter]"; incr x 80
		layout print "/(ta$x)[gi_btn_set_ordering FatherName Vater]"; incr x 80
		layout print "/(ta$x)[gi_btn_set_ordering ChildCount Kinder]"; incr x 80
	}

	proc render_tablerow {gid} {
		set x 10
		layout print "/(fn1,bo0)"
		layout print "/(ta$x)[gi_btn_select_gnome $gid]"; incr x 90
		layout print "/(fn0)"
		layout print "/(ta$x)[gi_btn_select_gnome [partner_info getpartner $gid]]"; incr x 80
		layout print "/(ta$x)[gi_btn_select_gnome [partner_info getmother $gid]]"; incr x 80
		layout print "/(ta$x)[gi_btn_select_gnome [partner_info getfather $gid]]"; incr x 80

		set children [partner_info getchildren $gid]
		if { [partner_info getpregnancy $gid] } {
			lappend children [lmsg schwanger]
		}

		set i 0
		set cnt 0

		foreach child $children {
			if { $cnt == 0 } {
				layout print "/(ta$x)"
			}
			layout print $child
			incr i
			incr cnt
			if { $cnt > 3 } {
				set cnt 0
				if { $i < [llength $children] } {
					layout print "/p"
				}
			}
		}
	}

	render_tablehead
	layout print "/p"

	foreach gid $gnome_list {
		render_tablerow $gid
		layout print "/p"
	}

	reset_info_window_style
}

# ---------------------------------------------------------------------------- #

switch $gi_ordering {
	"Name" {
		proc gi_compare_by_name {a b} {
			return [string compare [get_objname $a] [get_objname $b]]
		}

		set gi_gnome_list [lsort -command gi_compare_by_name $gi_gnome_list]
	}
	"GnomeAge" {
		proc gi_compare_by_age {a b} {
			return [expr {[get_attrib $a GnomeAge] >= [get_attrib $b GnomeAge]}]
		}

		set gi_gnome_list [lsort -command gi_compare_by_age $gi_gnome_list]
	}
	"Gender" {
		proc gi_compare_by_gender {a b} {
			return [string compare [get_objgender $a] [get_objgender $b]]
		}

		set gi_gnome_list [lsort -command gi_compare_by_gender $gi_gnome_list]
	}
	"ExpSum" {
		proc gi_compare_by_expsum {a b} {
			return [expr {[calc_gnome_expsum $a] < [calc_gnome_expsum $b]}]
		}

		set gi_gnome_list [lsort -command gi_compare_by_expsum $gi_gnome_list]
	}
	"InvCnt" {
		proc gi_compare_by_inv_cnt {a b} {
			return [expr {[inv_cnt $a] < [inv_cnt $b]}]
		}

		set gi_gnome_list [lsort -command gi_compare_by_inv_cnt $gi_gnome_list]
	}
	"PartnerName" {
		proc gi_compare_by_partner_name {a b} {
			return [string compare [partner_info getpartner $a] [partner_info getpartner $b]]
		}

		set gi_gnome_list [lsort -command gi_compare_by_partner_name $gi_gnome_list]
	}
	"MotherName" {
		proc gi_compare_by_mother_name {a b} {
			return [string compare [partner_info getmother $a] [partner_info getmother $b]]
		}

		set gi_gnome_list [lsort -command gi_compare_by_mother_name $gi_gnome_list]
	}
	"FatherName" {
		proc gi_compare_by_father_name {a b} {
			return [string compare [partner_info getfather $a] [partner_info getfather $b]]
		}

		set gi_gnome_list [lsort -command gi_compare_by_father_name $gi_gnome_list]
	}
	"ChildCount" {
		proc gi_compare_by_child_count {a b} {
			return [expr {[llength [partner_info getchildren $a]] < [llength [partner_info getchildren $b]]}]
		}

		set gi_gnome_list [lsort -command gi_compare_by_child_count $gi_gnome_list]
	}
	default {
		proc gi_compare_by_attrib {a b} {
			global gi_ordering
			return [expr {[get_attrib $a $gi_ordering] < [get_attrib $b $gi_ordering]}]
		}

		set gi_gnome_list [lsort -command gi_compare_by_attrib $gi_gnome_list]
	}
}

# ---------------------------------------------------------------------------- #

layout print "/(fn1,ac)"
layout print [gi_btn_set_tab tab_standard Standard]
layout print "/(tx  )"
layout print [gi_btn_set_tab tab_production Produktion]
layout print "/(tx  )"
layout print [gi_btn_set_tab tab_fight Fight]
layout print "/(tx  )"
layout print [gi_btn_set_tab tab_inventory Inventory]
layout print "/(tx  )"
layout print [gi_btn_set_tab tab_family Family]
layout print "/p/p"

reset_info_window_style

switch $gi_tab {
	"tab_standard" {
		gi_render_subwindow_standard $gi_gnome_list
	}
	"tab_production" {
		gi_render_subwindow_production $gi_gnome_list
	}
	"tab_fight" {
		gi_render_subwindow_fight $gi_gnome_list
	}
	"tab_inventory" {
		gi_render_subwindow_inventory $gi_gnome_list
	}
	"tab_family" {
		gi_render_subwindow_family $gi_gnome_list
	}
}
