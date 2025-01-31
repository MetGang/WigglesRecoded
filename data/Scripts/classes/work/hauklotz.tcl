call scripts/misc/utility.tcl


def_class Hauklotz wood production 0 {} {

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 1.5

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
            	log "WARNING: hauklotz.tcl: no prod_actions method for $material (calling prod_actions_default)"
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
   	    	lappend rlst "prod_createproduct_inv_boxed $item; prod_itemtype_change_look Halbzeug_kiste geschlossen"
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

        lappend rlst "prod_turnfront"
		lappend rlst "prod_anim impatient"

		return $rlst
	}


// Pilzstamm

	method prod_actions_Pilzstamm {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Pilzstamm holen
        set itemtype Halbzeug_holz
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
        lappend rlst "prod_goworkdummy 2"

        set rnd [random 3.0]
        if {$rnd < 1} {
            lappend rlst "prod_turnback"
        } elseif {$rnd < 2} {
            lappend rlst "prod_goworkdummy 1"
            lappend rlst "prod_goworkdummy 0"
            lappend rlst "prod_turnright"
        } else {
    	    lappend rlst "prod_goworkdummy 3"
    	    lappend rlst "prod_goworkdummy 4"
    	    lappend rlst "prod_turnleft"
    	}

       	lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 8"
       	lappend rlst "prod_anim putb"
        lappend rlst "prod_changetool Axt"
        lappend rlst "prod_anim hammerstart"
        lappend rlst "prod_anim hammerloopholz"
   	    lappend rlst "prod_call_method set_chips 1; prod_call_method set_dust 1"
        lappend rlst "prod_anim_loop_expinfl hammerloopholz 3 15 $exp_infl"
        lappend rlst "prod_itemtype_change_look $itemtype kant"
        lappend rlst "prod_anim_loop_expinfl hammerloopholz 2 5 $exp_infl"
   	    lappend rlst "prod_call_method set_chips 0; prod_call_method set_dust 0"
        lappend rlst "prod_anim hammerend"
        lappend rlst "prod_changetool 0"

        if {$exp_infl-0.1 < [random 1.0]} {				;// Extraarbeit für dumme Zwerge
        	lappend rlst "prod_anim kontrol"
        	lappend rlst "prod_anim scratchhead"
            lappend rlst "prod_goworkdummy 2"
            lappend rlst "prod_turnback"
            lappend rlst "prod_anim workholz"
            lappend rlst "prod_call_method set_dust 1; prod_call_method set_chips 1"
        	lappend rlst "prod_anim_loop_expinfl workholz 1 3 $exp_infl"
            lappend rlst "prod_call_method set_dust 0; prod_call_method set_chips 0"
        	lappend rlst "prod_anim kontrol"

        	if {$rnd < 1} {							;// zurück an ursprüngliche Pos
    	        lappend rlst "prod_turnback"
	        } elseif {$rnd < 2} {
            	lappend rlst "prod_goworkdummy 1"
        	    lappend rlst "prod_goworkdummy 0"
    	        lappend rlst "prod_turnright"
	        } else {
    		    lappend rlst "prod_goworkdummy 3"
	    	    lappend rlst "prod_goworkdummy 4"
	    	    lappend rlst "prod_turnleft"
	    	}
		}

        if {[random 1.0] > 0.5} {                            	;// zufällig...
	        lappend rlst "prod_changetool Hammer"				;// Hämmern oder ...
    	    lappend rlst "prod_anim hammerstart"
        	lappend rlst "prod_anim hammerloopholz"
			lappend rlst "prod_call_method set_dust 1"
	        if {[random 1.0] < 0.4} {
    	    	lappend rlst "prod_anim_loop_expinfl hammerloopholz 3 10 $exp_infl"
       		} else {
        		lappend rlst "prod_anim_loop_expinfl hammerloopholz 2 5 $exp_infl"
        		lappend rlst "prod_itemtype_change_look $itemtype brett"
        		lappend rlst "prod_anim_loop_expinfl hammerloopholz 2 5 $exp_infl"
        	}
			lappend rlst "prod_call_method set_dust 0"
        	lappend rlst "prod_anim hammerend"
        } else {
//	        lappend rlst "prod_changetool Fuchsschwanz"			;// ... Sägen
    	    lappend rlst "prod_anim foxtailstart"
    	    lappend rlst "prod_anim foxtailloop"
    	    lappend rlst "prod_call_method set_chips 1; prod_call_method set_dust 1"
	        if {[random 1.0] < 0.4} {
    	    	lappend rlst "prod_anim_loop_expinfl foxtailloop 3 10 $exp_infl"
       		} else {
        		lappend rlst "prod_anim_loop_expinfl foxtailloop 2 5 $exp_infl"
        		lappend rlst "prod_itemtype_change_look $itemtype brett"
        		lappend rlst "prod_anim_loop_expinfl foxtailloop 2 5 $exp_infl"
        	}
    	    lappend rlst "prod_call_method set_chips 0; prod_call_method set_dust 0"
        	lappend rlst "prod_anim foxtailstop"
        }

        lappend rlst "prod_changetool 0"

       	lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
       	lappend rlst "prod_anim putb"
        lappend rlst "prod_goworkdummy 2"

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
			lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 8"
			lappend rlst "prod_anim putb"
		} elseif {$rnd < 2} {
			lappend rlst "prod_goworkdummy 1"
			lappend rlst "prod_goworkdummy 0"
			lappend rlst "prod_turnright"
			lappend rlst "prod_anim puta"
			lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 8"
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
			lappend rlst "prod_call_method set_dust 1"
			lappend rlst "prod_anim_loop_expinfl hammerloopstein 2 7 $exp_infl"
			lappend rlst "prod_itemtype_change_look $itemtype mauer"
			 lappend rlst "prod_anim_loop_expinfl hammerloopstein 1 3 $exp_infl"
				if {$exp_infl < 0.5} {
				lappend rlst "prod_anim hammeraccidenta"
			}
			lappend rlst "prod_anim_loop_expinfl hammerloopstein 1 3 $exp_infl"
			lappend rlst "prod_call_method set_dust 0"
			lappend rlst "prod_anim hammerend"

		} else {
			// meisseln

			lappend rlst "prod_changetool Hammer"
			lappend rlst "prod_changetool Meissel 1"
			lappend rlst "prod_anim carvestonestart"
			lappend rlst "prod_anim carvestoneloop"
			lappend rlst "prod_call_method set_dust 1"
			lappend rlst "prod_anim_loop_expinfl carvestoneloop 2 7 $exp_infl"
			lappend rlst "prod_itemtype_change_look $itemtype mauer"
			lappend rlst "prod_anim_loop_expinfl carvestoneloop 1 3 $exp_infl"
			if {$exp_infl < 0.5} {
				lappend rlst "prod_anim hammeraccidenta"
			}
			lappend rlst "prod_anim_loop_expinfl carvestoneloop 1 3 $exp_infl"
			lappend rlst "prod_call_method set_dust 0"
			lappend rlst "prod_anim carvestonestop"
		}

		lappend rlst "prod_changetool 0"

		lappend rlst "prod_anim puta"
		lappend rlst "prod_consume_from_workplace $itemtype"
		lappend rlst "prod_anim putb"

		return $rlst
	}


// default

    method prod_actions_default {itemtype exp_infl} {
		lappend rlst "prod_walk_and_consume_itemtype $itemtype"
		return $rlst
    }


	method set_dust {bool} {
		set_particlesource this 0 $bool
	}


	method set_chips {bool} {
		set_particlesource this 1 $bool
	}


	method deinit_production {} {
		call_method this set_dust 0
		call_method this set_chips 0
	}


    method init {} {
    	set_collision this 1

		change_particlesource this 0 19 {0 0 0.5} {0.5 0.5 0.5} 64 4 0 8   ;// staub auf dem Hauklotz
		set_particlesource this 0 0
		change_particlesource this 1 26 {0 -0.1 0.2} {0 0 0} 64 1 0 8      ;// späne auf dem Hauklotz
		set_particlesource this 1 0
    }

	class_defaultanim hauklotz.standard
	class_flagoffset 1.3 2.3

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this hauklotz.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Hauklotz
        set_energyconsumption this $tttenergycons_Hauklotz
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 12 13 14 15 16 17 18 19]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsholz unten_rechtsholz unten_linksholz unten_rechtsholz oben_linksholz oben_rechtsholz oben_linksholz oben_rechtsholz}
		set damage_dummys {20 27}
	}
}

