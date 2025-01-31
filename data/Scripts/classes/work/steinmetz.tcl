call scripts/misc/utility.tcl


def_class Steinmetz stone production 0 {} {

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 2

	method prod_item_actions item {
		global current_worker BOXED_CLASSES
		set exp_incr [call_method this prod_item_exp_incr $item]
		set exp_infls [call_method this prod_item_exp_infl $item]
		set exp_infl [prod_getgnomeexper $current_worker $exp_infls]
		set materiallist [call_method this prod_item_materials $item]
		set rlst [list]

		if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {			;// leere Kiste hinstellen
			lappend rlst "prod_create_itemtype_ppinv_hidden Halbzeug_kiste"
			lappend rlst "prod_goworkdummy 4"
			lappend rlst "prod_turnright"
			lappend rlst "prod_anim benda"
			lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 4 0.5 0 0"
			lappend rlst "prod_anim bendb"
			lappend rlst "prod_goworkdummy 2"
		}

		foreach material $materiallist {
			if {[check_method [get_objclass this] "prod_actions_$material"]} {
				set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
				lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
			} else {
				log "WARNING: steinmetz.tcl: no prod_actions method for $material (calling prod_actions_default)"
				set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
			}
			if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
				lappend rlst "prod_goworkdummy 4"   ;// jedes Werkstück zur leeren Kiste bringen
				lappend rlst "prod_turnright"
				lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
			}
		}


		if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
			lappend rlst "prod_goworkdummy 4"		;// Kiste holen
			lappend rlst "prod_turnright"
			lappend rlst "prod_anim puta"
			if {$item=="Grabstein"} {
				global zwergenname muetzenanim
				lappend rlst "prod_createproduct_inv_boxed $item $zwergenname $muetzenanim; prod_itemtype_change_look Halbzeug_kiste geschlossen"
			} else {
				lappend rlst "prod_createproduct_inv_boxed $item; prod_itemtype_change_look Halbzeug_kiste geschlossen"
			}
			lappend rlst "prod_anim putb"
			lappend rlst "prod_anim takeboxa"
			lappend rlst "prod_itemtype_change_look Halbzeug_kiste tragen; prod_link_itemtype_to_hand Halbzeug_kiste"
			lappend rlst "prod_anim takeboxb"
			lappend rlst "prod_goworkdummy_with_box 2"
			lappend rlst "prod_createproduct_box_with_dummybox $item"
		} else {
			lappend rlst "prod_goworkdummy 2"
			lappend rlst "prod_createproduct_rndrot $item"
		}

		return $rlst
	}

// Stein

	method prod_actions_Stein {itemtype exp_infl} {
		set rlst [list]

		lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Stein holen
		set itemtype Halbzeug_stein
		lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
		lappend rlst "prod_goworkdummy 2"

		set rnd [random 3.0] 										;// zufällige Pos
		if {$rnd < 1} {
			lappend rlst "prod_turnback"
			lappend rlst "prod_anim puta"
			lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 9"
			lappend rlst "prod_anim putb"
		} elseif {$rnd < 2} {
			lappend rlst "prod_goworkdummy 1"
			lappend rlst "prod_goworkdummy 0"
			lappend rlst "prod_turnright"
			lappend rlst "prod_anim puta"
			lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 9"
			lappend rlst "prod_anim putb"
		} else {
			lappend rlst "prod_goworkdummy 3"
			lappend rlst "prod_goworkdummy 4"
			lappend rlst "prod_turnleft"
			lappend rlst "prod_anim puta"
			lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 8"
			lappend rlst "prod_anim putb"
		}


		if {[random 1.0] < 0.5} {
			// hämmern
			lappend rlst "prod_changetool Hammer"
			lappend rlst "prod_anim hammerstart"
			lappend rlst "prod_anim hammerloopstein"
			lappend rlst "prod_call_method dust_on"
			lappend rlst "prod_anim_loop_expinfl hammerloopstein 2 7 $exp_infl"
			lappend rlst "prod_itemtype_change_look $itemtype mauer"
			 lappend rlst "prod_anim_loop_expinfl hammerloopstein 1 3 $exp_infl"
				if {$exp_infl < 0.5} {
				lappend rlst "prod_anim hammeraccidenta"
			}
			lappend rlst "prod_anim_loop_expinfl hammerloopstein 1 3 $exp_infl"
			lappend rlst "prod_call_method dust_off"
			lappend rlst "prod_anim hammerend"

		} else {
			// meisseln

			lappend rlst "prod_changetool Hammer"
			lappend rlst "prod_changetool Meissel 1"
			lappend rlst "prod_anim carvestonestart"
			lappend rlst "prod_anim carvestoneloop"
			lappend rlst "prod_call_method dust_on"
			lappend rlst "prod_anim_loop_expinfl carvestoneloop 2 7 $exp_infl"
			lappend rlst "prod_itemtype_change_look $itemtype mauer"
			lappend rlst "prod_anim_loop_expinfl carvestoneloop 1 3 $exp_infl"
			if {$exp_infl < 0.5} {
				lappend rlst "prod_anim hammeraccidenta"
			}
			lappend rlst "prod_anim_loop_expinfl carvestoneloop 1 3 $exp_infl"
			lappend rlst "prod_call_method dust_off"
			lappend rlst "prod_anim carvestonestop"
		}

		lappend rlst "prod_changetool 0"

		lappend rlst "prod_anim puta"
		lappend rlst "prod_consume_from_workplace $itemtype"
		lappend rlst "prod_anim putb"

		return $rlst
	}


// Eisen

	method prod_actions_Eisen {itemtype exp_infl} {
		return [call_method this prod_actions_Stein $itemtype $exp_infl]
	}


// Eisenerz

	method prod_actions_Eisenerz {itemtype exp_infl} {
		return [call_method this prod_actions_Stein $itemtype $exp_infl]
	}



// Pilzstamm

	method prod_actions_Pilzstamm {itemtype exp_infl} {
		set rlst [list]

		lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Pilzstamm holen
		set itemtype Halbzeug_holz
		lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"

		lappend rlst "prod_goworkdummy 2"
		lappend rlst "prod_turnback"
		lappend rlst "prod_anim puta"
		lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 9"
		lappend rlst "prod_anim putb"

		if {[random 1.0] < 0.5} {
			lappend rlst "prod_changetool Hobel"					;// Hobeln
			lappend rlst "prod_anim planestart"
			lappend rlst "prod_anim planeloop"
			lappend rlst "prod_call_method chips_on"
			lappend rlst "prod_anim_loop_expinfl planeloop 2 8 $exp_infl"
			lappend rlst "prod_itemtype_change_look $itemtype kant"
			lappend rlst "prod_anim_loop_expinfl planeloop 2 7 $exp_infl"
			lappend rlst "prod_call_method chips_off"
			lappend rlst "prod_anim planeend"
			lappend rlst "prod_changetool 0"
		} else {
			lappend rlst "prod_anim workholz"
			lappend rlst "prod_call_method chips_on"
			lappend rlst "prod_anim_loop_expinfl workholz 2 5 $exp_infl"	;// oder werkeln
			lappend rlst "prod_itemtype_change_look $itemtype kant"
			lappend rlst "prod_anim_loop_expinfl workholz 2 5 $exp_infl"	;// oder werkeln
			lappend rlst "prod_call_method chips_off"
		}

		lappend rlst "prod_anim puta"
		lappend rlst "prod_consume_from_workplace $itemtype"
		lappend rlst "prod_anim putb"
		lappend rlst "prod_goworkdummy 2"

		return $rlst
	}


// Pilzhut

	method prod_actions_Pilzhut {itemtype exp_infl} {
		return [call_method this prod_actions_Pilzstamm $itemtype $exp_infl]
	}

// Zipfelmuetze

	method prod_actions_Zipfelmuetze {itemtype exp_infl} {
		global zwergenname muetzenanim
		set rlst [list]

		set midx [inv_find this Zipfelmuetze]
		if {$midx==-1} {log "Fehler: no Zipfelmuetze found in [get_ref this]"}
		set muetze [inv_get this $midx]
		set zwergenname [call_method $muetze get_name]s[lmsg "Grab"]
		set muetzenanim [call_method $muetze get_anim]
		lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Muetze holen
		return $rlst
	}

// default

	method prod_actions_default {itemtype exp_infl} {
		return [call_method this prod_actions_Stein $itemtype $exp_infl]
	}


	method dust_on {} {
		set_particlesource this 0 1
	}


	method dust_off {} {
		set_particlesource this 0 0
	}


	method chips_on {} {
		set_particlesource this 1 1
	}


	method chips_off {} {
		set_particlesource this 1 0
	}


	method deinit_production {} {
		call_method this dust_off
		call_method this chips_off
	}


	method init {} {
		set_collision this 1

		change_particlesource this 0 19 {0 0 0.5} {0.5 0.5 0.5} 32 4 0 9   ;// staub auf dem Stein
		set_particlesource this 0 0
		change_particlesource this 1 17 {0 -0.1 0.2} {0 0 0} 64 1 0 9      ;// späne auf dem Stein
		set_particlesource this 1 0
	}


	class_defaultanim steinmetz.standard
	class_flagoffset 1.3 3.0

	obj_init {
		call scripts/misc/genericprod.tcl
		
		set_anim this steinmetz.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Steinmetz
		set_energyconsumption this $tttenergycons_Steinmetz
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 12 13 14 15 16 17 18 19]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsstein unten_linksstein unten_linksstein unten_rechtsstein oben_rechtsholz oben_rechtsstein oben_linksholz oben_rechtsholz}
		set damage_dummys {20 27}

		set zwergenname ""
	}
}

