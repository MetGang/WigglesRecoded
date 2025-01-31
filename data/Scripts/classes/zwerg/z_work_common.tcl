// ---------------------------------------------------------------------
// z_work_common.tcl
//
// Dinge, die Zwerge in der Arbeitszeit tun :-)
// ---------------------------------------------------------------------


proc prod_inventattribute {type place} {
	global myref
	set ownerid [get_owner this]
	set type [string trimright $type "_"]
	for {set i 0} {$i<4} {incr i} {
		add_owner_attrib $ownerid ${type}[string repeat "_" $i] 1
	}
	set type [string range $type 2 30]

	if {[net localid] == [get_owner this]} {
		set id [newsticker new [get_owner this] -text "[lmsg $type] [lmsg erfunden]" -time [expr {3 * 60}]]
		set page $type
		// ein paar Special Hacks - items, die auf eine andere Seite als ihre eigene springen
		if {$type == "Pilz"  ||  $type == "Raupe"  ||  $type == "Hamster"} {
			set page "Farm"
		}

		newsticker change $id -click "newsticker delete $id; textwin run tt_$page.tcl"
	}

	if {[get_prod_switchmode $place]} {
		set_prod_slot_cnt $place $type 0
	}
	return true
}


// verlegt ein Item aus dem Inventar des Zwerges in das der Produktionsstätte

proc prod_transfertoprod {item prodplace pos} {
	global current_lock_obj

	if {[vector_dist3d [get_pos this] $pos] > 3.0} {
		gnome_failed_work this
		tasklist_clear this
		return false
	}

	if {[inv_find_obj this $item] < 0} {
		gnome_failed_work this
		tasklist_clear this
		return false
	}
	inv_rem this $item
	inv_add $prodplace $item
	set_hoverable $item 0
	set_selectable $item 0
	set_visibility $item 1
	set_pos $item $pos
	if {$item==$current_lock_obj} {
		set current_lock_obj 0
	}
	exp_transp_increase
}

// bringt einen einzelnen Gegenstand (aus dem Inventar) zur Produktionsstätte,
// d.h. sucht einen Platz zum Hinlegen, läuft hin und legt den Gegenstand ab
// (und transportiert ihn ins Inventar der Produktionsstätte via prod_transfertoprod)

proc prod_bringtoprod {item prodplace} {
	if {[check_method [get_objclass $prodplace] get_deliverypos]} {
		set itempos [call_method $prodplace get_deliverypos]
	} else {
		set itempos [get_place -center [get_pos $prodplace] -rect -10 [hmin 1 [expr {11-[get_posz $prodplace]}]] 10 [expr {13-[get_posz $prodplace]}] -mindist 1.5 -random 2 -nearpos [get_pos this]]
		if {[lindex $itempos 0]<0} {
			set itempos [get_place -center [get_pos $prodplace] -rect -10 [hmin 1 [expr {11-[get_posz $prodplace]}]] 10 [expr {13-[get_posz $prodplace]}] -mindist 1.5 -random 2 -nearpos [get_pos this] -materials false]
			if {[lindex $itempos 0]<0} {
				log "itempos not found! - prod_bringtoprod"
				gnome_failed_work this
				tasklist_clear this
				return false
			}
		}
	}
//	set walkpos [get_place -center $itempos -circle 2 -mindist 0.7 -except this -nearpos [get_pos this] -materials false]
//	if {[lindex $walkpos 0]<0} {
//		log "walkpos not found! - prod_transfertoprod"
//		gnome_failed_work this
//		tasklist_clear this
//		return false
//	}

	if {-1!=[lsearch "Pilzstamm Pilzhut" [get_objclass $item]]} {set_roty $item [random -0.7 0.7]}
	tasklist_addfront this "prod_transfertoprod $item $prodplace \{$itempos\};play_anim bendb"
	tasklist_addfront this "play_anim benda"
	tasklist_addfront this "rotate_towards \{$itempos\}"
	tasklist_addfront this "walk_near_item \{$itempos\} 0.7"
	return true
}


proc prod_bringtoprodref {itemref prodplace} {
	set invl [inv_list this]
	foreach item $invl {
		if { $item == $itemref } {
			tasklist_add this "prod_bringtoprod $itemref $prodplace"
		return true
		}
	}
	return false
}

//proc prod_transfertoprodlist {itemreflist prodplace} {
//	global current_workplace current_worklist
//
//	foreach itmref $itemreflist {
//		lappend current_worklist "prod_bringtoprodref $itmref $prodplace"
//	}
//	if { [llength $current_worklist] > 0 } {
//		state_triggerfresh this work_dispatch
//	}
//	return true
//}
//
//proc prod_transporttoprodlist {itemtypelist prodplace} {
//	global current_workplace current_worklist
//	set objlist [list]
//	set invlist [list]
//	set orginvlist [inv_list this]
//
//	foreach itemtype $itemtypelist {
//		set objidx -1
//		set ilen [llength $orginvlist]
//		for {set iidx 0} {$iidx < $ilen} {incr iidx} {
//			if { [get_objclass [inv_get this $iidx]] == $itemtype } {
//				set objidx $iidx
//				set ilen 0
//			}
//		}
//		if { $objidx != -1 } {
//			set objref [inv_get this $objidx]
//			set_lock $objref 1
//			lappend invlist $objref
//			set orginvlist [lreplace $orginvlist $objidx $objidx]
//		} else {
//			set objref [obj_find this $itemtype 95]
//			if {! $objref} {
//				log "Objekt von der Classe $itemtype nicht gefunden -> es werden Lager in der Naehe abgefragt"
//				set lager [obj_query this "-class Lager -range 95"]
//				log "naechstliegende lager = $lager"
//				if {$lager == 0} {
//					log "Lager nicht gefunden -> abbruch"
//					return false
//				}
//				set gefunden false
//				for {set i 0} {$i < [llength $lager]} {incr i} {
//
//					if {$gefunden == "true"} {break}
//					set tmp_lager [lindex $lager $i]
//					log "in FOR Schleife i = $i, tmp_lager = $tmp_lager"
//					set objref [call_method $lager get_unlockeditem_from_class $itemtype]
//					if {$objref} {
//						log "Item von der Classe $itemtype wurde gefunden: Item = $objref"
//						set gefunden true
//					}
//				}
//				if {!$objref} {
//					log "Es wurden keine Objekte von der Klasse $itemtype in den naechstliegenden Lagern nicht gefunden -> abbruch"
//					return false
//				}
//
//			}
//			set_lock $objref 1
//			lappend objlist $objref
//		}
//	}
//	log "Prod-Transport $itemtypelist:"
//
//	prod_change_muetze transport
//
//	foreach itmref $objlist {
//		lappend current_worklist "pickup $itmref"
//		log "  Pickup $itmref [get_objclass $itmref]"
//	}
//
//	foreach itmref $objlist {
//		lappend current_worklist "prod_bringtoprodref $itmref $prodplace"
//		log "   Bring $itmref [get_objclass $itmref] (out)"
//	}
//	foreach itmref $invlist {
//		lappend current_worklist "prod_bringtoprodref $itmref $prodplace"
//		log "   Bring $itmref [get_objclass $itmref] (inv)"
//	}
//	if { [llength $current_worklist] > 0 } {
//		state_triggerfresh this work_dispatch
//	}
//	return true
//}


proc prod_callmethod {args} {
	set ev "call_method $args"
	eval $ev
	return true
}

proc prod_end_prod {} {
	global current_workplace current_worklist
	set current_worklist {}
	info_end_prod $current_workplace
}

proc prod_finishitem {itemtype} {
	global current_workplace current_worklist
	call_method $current_workplace finish_itemprod $itemtype
	return true;
}


proc prod_invent {item} {
	global current_workplace
	prod_changetool 0
	if [check_method [get_objclass $current_workplace] prod_item_attribs] {
		if {""!=[set exp_infls [call_method $current_workplace prod_item_attribs [string range $item 2 30]]]} {
			set exper 0.0
			set minexp 0.0
			//log "Exp_infl zum Erfinden:$exp_infls"
			foreach exp_infl $exp_infls {
				set minval [lindex $exp_infl 1]
				fincr minexp $minval
				set myval [hmax [expr {[get_attrib this [lindex $exp_infl 0]]-$minval}] 0.0]
				fincr exper $myval
			}
			if {$minexp>0.0} {
				set exper [hmin [expr {int($exper*80.0)}] 10]
			} else {
				set exper 4
			}
		} else {
			set exper 4
		}
	} else {
		set exper 4
	}
	set animlist [lindex "aabaacaba aabaacaba abaacaba aabaaca aabaca abaca aaba aba aa a a" $exper]

	if {[check_method [get_objclass $current_workplace] prod_get_invention_dummy]} {
		tasklist_add this "walk_dummy $current_workplace [call_method $current_workplace prod_get_invention_dummy]"
//          log "inventiondummy found & used"
	} else {
		tasklist_add this "walk_dummy $current_workplace 2"
//		    log "no inventiondummy found, using dummy 2"
	}

	tasklist_add this "prod_turnleft"
	for {set ianim 0} {$ianim<[string length $animlist]} {incr ianim} {
		set canim invent_[string index $animlist $ianim]
		tasklist_add this "prod_anim $canim"
	}
	tasklist_add this "create_particlesource 13 \"\[get_pos this\]\" {0 -0.1 0.1} 32 2; prod_anim invent_done"
	tasklist_add this "prod_inventattribute $item $current_workplace"
	return true
}


// ----------------------------------------------------------------------------------
//								    Auf- und Abbau
// ----------------------------------------------------------------------------------


proc prod_autobuild {itemtype prodplace} {
	global current_workplace current_worklist
	set current_worklist [call_method $current_workplace get_itemtasklist $itemtype [get_ref this]]
	prod_gnome_last_workplace this $current_workplace
#			log "WorkList:$current_worklist"
	if { [llength $current_worklist] > 0 } {
		state_triggerfresh this work_dispatch
		return true;
	}
	return true;
}

proc prod_autopack {prodplace} {
	global current_workplace current_worklist
	set current_workplace $prodplace
	prod_gnome_last_workplace this $current_workplace
	set current_worklist [list "pack \{$prodplace\}"]
	if { [llength $current_worklist] > 0 } {
		state_triggerfresh this work_dispatch
		return true;
	}
	return true;
}

proc prod_autobuildup {prodplace} {
	global current_workplace current_worklist
	set current_workplace $prodplace
	prod_gnome_last_workplace this $current_workplace
	set current_worklist [list]
	lappend current_worklist "walk_dummy $prodplace 0"
	lappend current_worklist "prod_buildup $prodplace"
	if { [llength $current_worklist] > 0 } {
		state_triggerfresh this work_dispatch
		return true;
	}
	return true;
}

proc prod_autorepair {prodplace} {
	global current_workplace current_worklist

	set current_workplace $prodplace
	prod_gnome_last_workplace this $current_workplace
	set current_worklist [list]

	if {[get_prod_ownerstrength $current_workplace] < 0.95} {
        lappend current_worklist "conquer $prodplace"
	} else {
		lappend current_worklist "prod_repair $prodplace"
	}

	if { [llength $current_worklist] > 0 } {
		state_triggerfresh this work_dispatch
		return true
	}
	return true
}

proc prod_autounpack {prodplace prodpos} {
	global current_workplace current_worklist current_worknum
	set wpos [vector_add $prodpos {0 0 2}]
	set current_workplace $prodplace
	prod_gnome_last_workplace this $current_workplace

	if {[get_boxed $prodplace]} {
		set current_worklist [list "walk_pos \{$wpos\}" "prod_buildup_check $prodplace" "send_gnomes_outofplacement $prodplace" "pickup $prodplace" "unpack_pos_unfixed $prodplace \{$prodpos\} $current_worknum"]
	} else {
		set current_worklist [list "walk_pos \{$wpos\}" "prod_buildup_check $prodplace" "send_gnomes_outofplacement $prodplace" "prod_changetool Hammer" "get_beambackpos" "prod_buildup_rep $prodplace" "beam_back"]
	}
	if { [llength $current_worklist] > 0 } {
		state_triggerfresh this work_dispatch
		return true;
	}
	return true;
}


proc prod_buildup_check {item} {
	set ok 1
	if { [check_ghost_coll objects this $item] } {
		log "cannot place [get_objname $item] (collision)"
		set ok 0
	} else {
		log "no collision!"
	}

	if { [get_boxed $item]  &&  [inv_find_obj this $item] < 0 } {
		log "cannot place [get_objname $item] - dont have it!"
		set ok 0
	}

	if {$ok == 0} {
		global current_worklist

		tasklist_clear this
		set_prod_unpack $item 0
		hide_obj_ghost $item
		set current_worklist ""
		stop_prod
		return false
	}

	return true
}

proc send_gnomes_outofplacement {item} {
	set slist [check_ghost_coll gnomes this $item]
	if { $slist != 0 } {
		foreach ref $slist {
			call_method $ref walk_outofplacement $item
		}
	}
	return 1
}

proc prod_buildup_waitforfree {item timeout} {
	if { [gettime] > $timeout } {
		log "wait for gnomes timed out.........."
		return true
	}
	if { [check_ghost_coll gnomes this $item] != 0 } {
		send_gnomes_outofplacement $item
		tasklist_addfront this "prod_buildup_waitforfree $item $timeout"
		if { [irandom 30] == 1 } {
			play_anim impatient
		} else {
			play_anim standloopa
		}
		log "jemand im weg!! ([check_ghost_coll gnomes this $item])  "
		return true
	}
	log "niemand im weg!"
	return true
}

proc prod_buildup_new {item pos} {
	global sendout_gnomes
	set sendout_gnomes [list]
	tasklist_add this "prod_buildup_check $item"
	tasklist_add this "prod_buildup_waitforfree $item [expr {[gettime]+ 40}]"
	tasklist_add this "inv_rem this $item; set_boxed $item 0; call_method $item set_buildupstep 0; set_visibility $item 1; set_pos $item \[vector_add \{$pos\} { 0 0 0 } \]"
	tasklist_add this "prod_buildup $item"
	tasklist_add this "unlock_item"
}

proc prod_buildup {item} {
//	log "PROGD_BUILDUP: this = [get_ref this], item = $item"
	set pclass [get_objclass $item]
	tasklist_add this "hide_obj_ghost $item"
    set_roty $item 0
	# Schnellaufbau für Items ohne Aufbauanimation

	if {[lsearch {Abfluss Leiter Leiter_Kristall Leiter_Metall Plattmachfalle SteinfalleMedusa} $pclass]!=-1} {
		tasklist_add this "get_beambackpos"
		tasklist_add this "call_method $item set_buildupstep 4"
		tasklist_add this "call_method $item unpackfrombox"
		if {[lsearch {Leiter Leiter_Kristall Leiter_Metall} $pclass]!=-1} {
			return true
		}
		tasklist_add this "beam_back"
		return true
	}

	# ... sonst animierter Aufbau

	tasklist_add this "get_beambackpos"
	tasklist_add this "prod_changetool Hammer"
	tasklist_add this "prod_buildup_rep $item"
	return true
}

proc prod_builddown {item} {
	if {![obj_valid $item]} {
		return
	}

	if {![get_prod_pack $item]} {
		// eventuell ist das Abbauen inzwischen gecancelt...
		return
	}

	set pclass [get_objclass $item]
		log "PROD_BUILDDOWN item = $item"
	// Schnellaufbau für Items ohne Aufbauanimation

	if {[lsearch {Abfluss Leiter Leiter_Kristall Leiter_Metall Plattmachfalle SteinfalleMedusa} $pclass]!=-1} {
		tasklist_add this "get_beambackpos"
		tasklist_add this "call_method $item set_buildupstep 0"
		tasklist_add this "call_method $item packtobox"
		if {[lsearch {Leiter Leiter_Kristall Leiter_Metall} $pclass]!=-1} {
			return true
		}
		tasklist_add this "beam_back"
		return true
	}

	// ... sonst animierter Abbau

	tasklist_add this "get_beambackpos"
	tasklist_add this "prod_changetool Hammer"
	tasklist_add this "prod_builddown_rep $item"
	return true
}


proc prod_buildup_rep {item} {
	global tttgain_buildup
	set bstep [call_method $item get_buildupstep]
	set maxbstep [call_method $item get_maxbuildupstep]
	set bani [call_method $item get_buildupanim]
//	log "buildup: $bstep von $maxbstep -> $bani"
	if { $bstep > $maxbstep } {
		//tasklist_add this "call_method $item set_buildupstep [expr {$bstep + 1}]"
		tasklist_add this "call_method $item unpackfrombox"
		tasklist_add this "beam_back"
		tasklist_add this "prod_changetool 0"
		if {[get_objclass $item]=="Grabstein"} {
			tasklist_add this "walk_dummy $item 5"
			tasklist_add this "prod_turnback"
			tasklist_add this "prod_anim praystart"
			tasklist_add this "prod_anim prayloop"
			tasklist_add this "prod_anim prayloop"
			tasklist_add this "prod_anim prayloop"
			tasklist_add this "prod_anim praystop"
		}
		return true
	}
	if { $bstep > 0 } {
		set dummy [call_method $item get_build_dummy $bstep]
	//	log "DUMMY = $dummy -------------------- bstep = $bstep"
		set steplink $dummy
		set partlink [expr {19 + $bstep}]
		tasklist_add this "set_pos this [vector_add [get_linkpos $item $steplink] [get_pos $item]];set_roty this [expr {[lindex [get_linkrot $item $steplink] 1] + 3.1415}]"
	}
	set maxanimcnt [get_buildanim_count $item $maxbstep]
	for {set rep 0} {$rep < $maxanimcnt} {incr rep} {	tasklist_add this "prod_anim $bani"	}
	tasklist_add this "call_method $item set_buildupstep [expr {$bstep + 1}]"
	tasklist_add this "prod_buildup_rep $item"
	add_attrib this exp_Transport [expr {$tttgain_buildup*[clan_exp_factor exp_Transport]}]
	return true
}

proc prod_builddown_rep {item} {
	global tttgain_buildup
	set bstep [call_method $item get_buildupstep]
	set maxbstep [call_method $item get_maxbuildupstep]
	if { $bstep > $maxbstep } {
		tasklist_add this "call_method $item prepare_packtobox"
		incr bstep -1
		call_method $item set_buildupstep $bstep
	}
	set bani [call_method $item get_buildupanim]
	//log "builddown: $bstep von $maxbstep -> $bani"
	if { $bstep > 0 } {
		set dummy [call_method $item get_build_dummy $bstep]
		set partlink [expr {19 + $bstep}]
		tasklist_add this "set_pos this [vector_add [get_linkpos $item $dummy] [get_pos $item]];set_roty this [expr {[lindex [get_linkrot $item $dummy] 1] + 3.1415}]"
		set maxanimcnt [get_buildanim_count $item $maxbstep]
		for {set rep 0} {$rep < $maxanimcnt} {incr rep} {	tasklist_add this "prod_anim $bani"	}
		tasklist_add this "call_method $item set_buildupstep [expr {$bstep - 1}]"
		tasklist_add this "prod_builddown_rep $item"
	} else {
		tasklist_add this "set_pos this [vector_add [get_pos $item] {0 0 2}];set_roty this 3.14;clear_beambackpos"
		set maxanimcnt [expr {[get_buildanim_count $item $maxbstep]*0.5}]
		for {set rep 0} {$rep < $maxanimcnt} {incr rep} {	tasklist_add this "prod_anim $bani"	}
		tasklist_add this "call_method $item set_buildupstep 0"
		tasklist_add this "call_method $item packtobox; call_method $item letfalldown"
		tasklist_add this "prod_changetool 0"
	}
	add_attrib this exp_Transport [expr {$tttgain_buildup*[clan_exp_factor exp_Transport]}]
	return true
}

proc get_buildanim_count {item steps} {
	set exper [get_attrib this exp_Transport]
	set cat [get_class_category [get_objclass $item]]
	switch $cat {
		"wood" {set exper [expr {$exper+[get_attrib this exp_Holz]*0.3}]}
		"metal" {set exper [expr {$exper+[get_attrib this exp_Metall]*0.3}]}
		"stone" {set exper [expr {$exper+[get_attrib this exp_Stein]*0.3}]}
		default {set exper [expr {$exper*1.3}]}
	}
	set exper [hmax 0.1 [hmin 0.8 $exper]]
	return [expr {(1.0-$exper)*(8.0+$steps*0.7)}]
}

proc prod_repair {item} {
	set pclass [get_objclass $item]
	tasklist_add this "hide_obj_ghost $item"
    tasklist_add this "get_beambackpos"
	tasklist_add this "rotate_toback"
	tasklist_add this "prod_changetool Hammer"
	tasklist_add this "prod_repair_rep $item 0"
	return true
}

proc prod_repair_rep {item index} {
	set maxbstep [call_method $item get_maxbuildupstep]
	if {$index > $maxbstep} {
		set index 1
	}

	set bani [call_method $item get_repairanim $index]
	if { $index > 0 } {
		set dummy [call_method $item get_build_dummy $index]
		set steplink $dummy
		tasklist_add this "set_pos this [vector_add [get_linkpos $item $steplink] [get_pos $item]];set_roty this [expr {[lindex [get_linkrot $item $steplink] 1] + 3.1415}]"
	}
	set maxanimcnt [get_buildanim_count $item $maxbstep]
	for {set rep 0} {$rep < $maxanimcnt} {incr rep} {	tasklist_add this "prod_anim $bani; add_attrib $item atr_Hitpoints 0.01; call_method $item show_damage"	}

	if {[get_attrib $item atr_Hitpoints] >= 1.0} {
		tasklist_add this "beam_back"
		tasklist_add this "prod_changetool 0"
		return true
	}
	incr index
	tasklist_add this "prod_repair_rep $item $index"
	return true
}

###############################Erobern#####################
proc conquer {building} {

	set fahne_pos [get_flag_pos $building]
	//einige Produktionsstätten haben buildup_step = 0 !!!!
	set buildup_step [call_method $building get_max_buildup_step]
	if {$buildup_step == 0} {
		log "WARNING!!! max_buildup_step bei [get_objname $building] = 0 "
		set buildup_step 1
	 }
	 set offset [expr 1.0 / $buildup_step / 6]
	 log "Offset = $offset"
	 tasklist_add this "walk_near_item \{$fahne_pos\} 0.6"
	 tasklist_add this "rotate_towards \{$fahne_pos\}"

     tasklist_add this "conquer_callback $building $offset"
	 if {[get_owner this] != [get_owner $building]} {
	 	tasklist_add this "call_method $building nt_conquer"
	 }
	 return true
}

proc conquer_callback {building offset} {
	//die Zeit soll von building_step abhängig sein
	set strength [get_prod_ownerstrength $building]
	//log "building_conquer_callback: strength = $strength"
	if {[get_owner $building] != [get_owner this]} {
		set_diplomacy [get_owner $building] [get_owner this] enemy
		set_diplomacy [get_owner this] [get_owner $building] enemy
		if {$strength > 0.01} {
			tasklist_add this "prod_anim pullrope; set_prod_ownerstrength $building [fincr strength -$offset]"
		} else {
			// Gebäude erobert!!
			//Newstickemeldung darf nur ein mal geschickt werden (im Mehrspielermodus werden attribute nicht so schnell aktualisiert)
			if {[get_attrib $building nt_Message] == 0} {
				set_attrib $building nt_Message 1
				call_method $building nt_conquer_inform

				call_method $building change_owner [get_owner this]

				set id [newsticker new [get_owner this] -text "[get_objclass $building] [lmsg wurdeerobert]" -time [expr {3 * 60}]]
				newsticker change $id -click "newsticker delete $id; set_view [get_posx $building] [expr {[get_posy $building] -1}] 0 -0.35 0"
			}
			//alle Aufträge löschen
			foreach item [call_method $building prod_items] {
				set_prod_slot_cnt $building $item 0
			}
			add_attrib $building atr_Hitpoints -0.1
		}
	} else {
		if {[get_attrib $building nt_Message] == 1} {
			set_attrib $building nt_Message 0
		}
		 if {$strength < 0.9} {
			tasklist_add this "prod_anim pullrope; set_prod_ownerstrength $building [fincr strength $offset]"
		} else {
			set_prod_ownerstrength $building 1.0 ;# damit strengt nicht größer als 1.0 wird
			if {[get_attrib $building atr_Hitpoints] > 0.85} {
				set_attrib $building atr_Hitpoints 1
			} else {
				add_attrib $building atr_Hitpoints 0.1
				tasklist_add this "prod_repair $building"
			}
			return true
		}
	}
	tasklist_add this "conquer_callback $building $offset"
	return true
}

#################################################################

// ----------------------------------------------------------------------------------
//								        Muetzen
// ----------------------------------------------------------------------------------


// wechselt die Mütze des Zwerges

proc prod_change_muetze {category {auf_ab both} {animopt "nothing"}} {
	global current_muetze_name current_muetze_ref is_wearing_divingbell is_counterwiggle

	if { $is_counterwiggle != 0 } {
		return true													;// in Counterwiggles keine Muetzenaktionen
	}

	if {$is_wearing_divingbell != 0} {
		return true													;// Taucherglocke verhindert alle Mützenaktionen
	}

	//log "CHANGE_MUETZE: Category = $category"
	set muetze [call_method this get_nameofmuetze $category]
	if {$current_muetze_name == $muetze} { 							;// nichts zu tun
		return true
	}

	switch $auf_ab {
	"ab" {		if {$current_muetze_ref != 0 } {
					muetze_ab $animopt
				}
		 }
	"both" {	muetze_ab $animopt
				muetze_auf $muetze $animopt
		   }
	}
	//log "neue Muetze: $muetze"
	return true
}



// Mütze abnehmen

proc muetze_ab {{animopt "nothing"}} {
	global current_muetze_ref current_muetze_name

	if {$current_muetze_ref != 0} {
		if {$animopt == "noanim"} {
			tasklist_add this "del_current_muetze"
			return
		}
		if {![get_gnomeposition this]} {
			tasklist_add this "play_anim hatofhead"
			tasklist_add this "play_anim hatofhand; del_current_muetze"
			tasklist_add this "play_anim hatofgone"
		} else {
			tasklist_add this "play_anim hatofhead_wall; del_current_muetze"
		}
	}
	return true
}


proc del_current_muetze {} {
	global current_muetze_ref current_muetze_name

	if {$current_muetze_ref == 0 } {
		return
	}

	if {[obj_valid $current_muetze_ref]} {
		set_visibility $current_muetze_ref 0
		link_obj $current_muetze_ref
		del $current_muetze_ref
	}
		
	set current_muetze_ref 0
	set current_muetze_name 0
}


proc muetze_auf {muetze {animopt "nothing"}} {
	global current_muetze_ref current_muetze_name is_wearing_divingbell

	if {$is_wearing_divingbell != 0} {
		return true													;// Taucherglocke verhindert alle Mützenaktionen
	}

//	log "Muetze $muetze wird aufgesetzt, Current_muetze_ref = $current_muetze_ref"
	if {$animopt == "noanim"} {
			tasklist_add this "create_muetze $muetze"
			return
		}

	if {![get_gnomeposition this]} {
		tasklist_add this "play_anim hatongone"
		tasklist_add this "play_anim hatonhand"
		tasklist_add this "play_anim hatonhead; create_muetze $muetze"
	} else {
		tasklist_add this "play_anim hatonhead_wall; create_muetze $muetze"
	}
	return true
}


// erzeugt eine Mütze und linkt sie an den Kopf; kann nach einer entsprechenden
// Anim in die Tasklist gehängt werden

proc create_muetze {muetze_name} {
	global current_muetze_ref current_muetze_name hatcolor

	del_current_muetze
	set m_ref [new $muetze_name]
	set current_muetze_ref $m_ref
	set current_muetze_name $muetze_name

	link_obj $m_ref this 4
	set_visibility $m_ref 1
	set_textureanimation $current_muetze_ref 0 $hatcolor 0 0
}

proc get_nameofmuetze_proc {category {force 0}} {
	;#nicht vergessen erfahrung und Geschlecht
	global gnome_gender clanname
	if {$gnome_gender == "male"} {
		set endung a
	} else {
		set endung b
	}

	if {$force == 0} {
		//falls es kein Storymanager existiert
		//bekommen alle andere Zwergeclans Standartmuetzen
		if {![im_a_human]} {
	//		log "Standardmuetze fuer: [get_objname this], ref: [get_ref this]"
			set muetze Dummy_$clanname\Muetze_$endung
			return $muetze
		}
	}

	switch $category {
	"sparetime"	{set muetze Dummy_$clanname\Muetze_$endung}
	"service"	{set muetze Dummy_Muetze_dienstleistung_$endung}
	"transport"	{set muetze Dummy_Muetze_dienstleistung_$endung}
	"stone"		{set muetze Dummy_Muetze_stein_$endung}
	"wood"		{set muetze Dummy_Muetze_holz_$endung}
	"metal"		{set muetze Dummy_Muetze_metall_$endung}
	"food"		{set muetze Dummy_Muetze_nahrung_$endung}
	"energy"	{set muetze Dummy_Muetze_energiemagie_$endung}
	"erfinden"	{set muetze Dummy_Muetze_energiemagie_$endung}
	"fight"		{
				set erfahrung [get_attrib this exp_Kampf]
				if { $erfahrung < 0.15 } {
					set erf 01
				} elseif { $erfahrung < 0.30 } {
					set erf 02
				} else {
					set erf 03
				}
				set muetze Dummy_Muetze_kampf_$erf\_$endung
				}
    "dive"		{set muetze taucherglocke_$endung}
    "arbeitslos" {set muetze Dummy_Muetze_arbeitslos_$endung}
    "pack" 		{set muetze Dummy_Muetze_dienstleistung_$endung}
    "unpack" 	{set muetze Dummy_Muetze_dienstleistung_$endung}
    "dig" 		{set muetze Dummy_Muetze_stein_$endung}
    "harvest" 	{set muetze Dummy_Muetze_holz_$endung}
	default		{
					log "MuetzeWarning: Falsche category - $category"
					set muetze Dummy_Muetze_$endung
				}
	}
	return $muetze
}


// ----------------------------------------------------------------------------------
//								        Taucherglocke
// ----------------------------------------------------------------------------------


// Zwerg setzt Taucherglocke auf (es muss eine im Inventory sein)

proc wear_divingbell {{usercommand 0}} {
	global is_wearing_divingbell is_wearing_divingbell_by_usercommand

	if {$is_wearing_divingbell != 0} {
		return true
	}

	set is_wearing_divingbell_by_usercommand $usercommand
	set divingbell [inv_find this Taucherglocke]
	if {$divingbell < 0} {
		set is_wearing_divingbell 0
		return false
	}

	// nachsehen, ob das Kommando vielleicht schon in der Tasklist ist
	if {[tasklist_find this "play_anim hatonhead; link_divingbell"] != -1} {
		return true
	}

	muetze_ab

	if {![get_gnomeposition this]} {
		tasklist_add this "play_anim hatongone"
		tasklist_add this "play_anim hatonhand"
		tasklist_add this "play_anim hatonhead; link_divingbell"   ;// auf diese Zeile wird tasklist_find gemacht!!!
	} else {
		tasklist_add this "play_anim hatonhead_wall; link_divingbell"
	}
	return true
}



// linkt eine im Inventar befindliche Taucherglocke an den Kopf des Zwerges und
// setzt das entsprechende Flag
// kann nach einer entsprechenden Anim in die Tasklist gehängt werden

proc link_divingbell {} {
	global is_wearing_divingbell gnome_gender

	set divingbell [inv_find this Taucherglocke]
	if {$divingbell < 0} {
		set is_wearing_divingbell 0
		return false
	}

	set divingbell [inv_get this $divingbell]
	if {![obj_valid $divingbell]} {
		set is_wearing_divingbell 0
		return false
	}

	call_method $divingbell set_ownergender $gnome_gender
	link_obj $divingbell this 4
	set_visibility $divingbell 1
	set_hoverable $divingbell 0
	set is_wearing_divingbell 1

	return true
}



// Taucherglocke abnehmen

proc remove_divingbell {{usercommand 0}} {
	global is_wearing_divingbell is_wearing_divingbell_by_usercommand

	log "remove_divingbell"

	if {!$is_wearing_divingbell} {
		return true
	}

	if {$usercommand == 0  &&  $is_wearing_divingbell_by_usercommand != 0} {
		return false
	}

	if {[inv_find this Taucherglocke] < 0} {
		set is_wearing_divingbell 0
		return false
	}

	if {![get_gnomeposition this]} {
		tasklist_add this "play_anim hatofhead"
		tasklist_add this "play_anim hatofhand; unlink_divingbell"
		tasklist_add this "play_anim hatofgone"
	} else {
		tasklist_add this "play_anim hatofhead_wall; unlink_divingbell"
	}
	return true
}


// alle Taucherglocken aus Inv werden abgelinkt und wieder unsichtbar gemacht
// kann in Taskliste stehen

proc unlink_divingbell {} {
	global is_wearing_divingbell is_wearing_divingbell_by_usercommand

	foreach item [inv_list this] {
		if {[get_objclass $item] == "Taucherglocke"} {
			link_obj $item
			set_visibility $item 0
			set is_wearing_divingbell 0
			set is_wearing_divingbell_by_usercommand 0
		}
	}
	return true
}


// ----------------------------------------------------------------------------------
//								        allgemeines Item-Benutzen
// ----------------------------------------------------------------------------------

// benutzt ein benutzbaren Gegenstand, der sich im Inventory des Zwerges befindet

proc use_item {item} {
	if {![obj_valid $item]} {
		return
	}

	if {[inv_find_obj this $item] < 0} {
		return
	}

	tasklist_clear this						;// die Methode use des Items wird unsere Tasklist mit neuen Befehlen füllen
	call_method $item use [get_ref this]
}


// benutzt ein benutzbaren Gegenstand, der sich in der Welt befindet (und auch dort bleibt!)

proc objaction_item {item} {
	if {![obj_valid $item]} {
		return
	}

	set standoffdist [call_method $item get_standoff_dist]
	if {$standoffdist >= 0} {
		if {[vector_dist3d [get_pos this] [get_pos $item]] > [expr {$standoffdist + 0.3}]} {
			return
		}
	}

	tasklist_clear this						;// die Methode use des Items wird unsere Tasklist mit neuen Befehlen füllen
	call_method $item objaction [get_ref this]
}
