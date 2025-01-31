layout clear

layout print "/(fn2)"
layout print "/(ac)[lmsg Stammbaum]"
layout print "/p/p"
layout print "/(ls2,ml5,mr5)"

set infowin_pedigreegnome [get_selectedobject]

proc infowin_link_id {gid} {
	set objname [get_objname $gid]
}

proc centerandselect {gid} {
	set view [get_view]
	set pos [get_pos $gid]
	set_view [vector_unpackx $pos] [vector_unpacky $pos] [vector_unpackz $view]
	selection clear
	selection include $gid
	layout reload
}

proc gnomename {gid} {
	if { [selection check $gid] } {
		return "[get_objname $gid]"
	} else {
		return "[layout autoxlink "centerandselect $gid" "[get_objname $gid]"]"
	}
}

proc infowin_pedigreeshow {gid} {


	set partner [partner_info getpartner $gid]
	if {$partner != 0} {
		set pname [gnomename $partner]
	}

	set mother [partner_info getmother $gid]
	set mname "-----"
	if {$mother > 0} {
		set mname [gnomename $mother]
		//set mname [get_objname $mother]
	} elseif {$mother == -1} {
		set mname "[lmsg {dead!}]"
	}
	set father [partner_info getfather $gid]
	set fname "-----"
	if {$father > 0} {
		set fname [gnomename $father]
	} elseif {$father == -1} {
		set fname "[lmsg {dead!}]"
	}


	set children [partner_info getchildren $gid]

	if { [llength $children] == 0} {
		if { $partner != 0 } {
			set children [partner_info getchildren $partner]
		}
	}


	###########
//	textwin clear
	call /scripts/misc/onlinehelputils.tcl
	ohlp_initstyle
	if {[get_objtype $gid] == "baby"} {
		set imgname "/gui/docpix/baby_wiggles.tga"
	} else {
		if {[get_objgender $gid]=="male"} {
			set imgname "/gui/docpix/mann_wiggles.tga"
		} else {
			set imgname "/gui/docpix/frau_wiggles.tga"
		}
	}

	layout print "/(is5)/(ildata$imgname)"

// ---- text starts here - do not change anything above this line ---

	layout print "[get_objname $gid]/p/p/(al)"
	layout print "/(fn1)"
	layout print "[lmsg {Mother: }]/(ta400)$mname /p/p"
	layout print "[lmsg {Father: }]/(ta400)$fname/p/p"
	if {$partner != 0} {
		layout print "[lmsg {Partner: }]/(ta400)$pname/p/p"
	}
	set length [llength $children]
	if { $length != 0} {
		if {$length == 1} {
			layout print "[lmsg {Child: }]"
		} else {
			layout print "[lmsg {Children: }]"
		}
		//set children [list andrej Oxana Anton Nikita Anatol Dimitrij Wladimir]
		layout print "/(ls5)"
		foreach child $children {
			set path /obj/$child
			layout print "/(ta400)[gnomename $path]/p"
		}
	}

// ---- do not change anything below this line ---

textwin print "/p"
####################


	//set imgname "/gui/docpix/mann_wiggles.tga"

	set x 80
	//layout print "/(ta$x)[lmsg Name]"; set x [expr $x + 90
	//layout print "/(al)"
	if {$mother != 0} {
	//	layout print "/(ta$x)Mother:$mname"; set x [expr $x + 280]
	}
	if {$father != 0} {
	//	layout print "/(ta$x)Father:$fname "
	}
	//layout print "/p/p"

    //layout print "/(is10)/(ildata$imgname)"
	set x 20
	if {$partner != 0} {
	//	layout print "/(ta$x)Partner:$pname "
    }

    if { [llength $children] != 0} {
    //	layout print "/p/p/p/p/p/p"
    //	layout print "/(ws15)Children:/(ws10)"
		foreach child $children {
			set path /obj/$child
	//		layout print " [gnomename $path] "
		}
    }
    //set imgname "/gui/docpix/mann_wiggles.tga"
	//set x [expr $x + 100]
	//layout print "/(ta$x)/(iidata$imgname)  "
	//layout print "/(ac)Partner:$pname"

	//layout print "Children:"
	//foreach child $children {
	//	set path /obj/$child
	//	layout print "[gnomename $path] "
	//}
}


set objtype [get_objtype $infowin_pedigreegnome]
if {$objtype != "gnome" && $objtype != "baby"} {set infowin_pedigreegnome 0}
if {$infowin_pedigreegnome != 0} {
	infowin_pedigreeshow $infowin_pedigreegnome
} else {
	layout print "/(fn2)"
	layout print "/(ac)[lmsg BitteeinenZwerganwaehlen]"
}

layout print "/p"
