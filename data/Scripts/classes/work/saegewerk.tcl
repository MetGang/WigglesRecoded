//# STOPIFNOT FULL
call scripts/misc/utility.tcl


def_class Saegewerk wood production 2 {} {

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 2.5

	method prod_item_actions item {
		global current_worker BOXED_CLASSES
		set exp_incr [call_method this prod_item_exp_incr $item]
		set exp_infls [call_method this prod_item_exp_infl $item]
		set exp_infl [prod_getgnomeexper $current_worker $exp_infls]
        log "exp_infl $exp_infl"
		set materiallist [call_method this prod_item_materials $item]
		set rlst [list]

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {			;// leere Kiste hinstellen
	        lappend rlst "prod_create_itemtype_ppinv_hidden Halbzeug_kiste"
	        lappend rlst "prod_goworkdummy 3"
	        lappend rlst "prod_turnright"
	        lappend rlst "prod_anim benda"
	     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 3 0.5 0 0"
	        lappend rlst "prod_anim bendb"
    	    lappend rlst "prod_goworkdummy 2"
		}

        foreach material $materiallist {
            if {[check_method [get_objclass this] "prod_actions_$material"]} {
                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
                lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
            } else {
            	log "WARNING: schmiede.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }
	        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
        	 	lappend rlst "prod_goworkdummy 3"   ;// jedes Werkstück zur leeren Kiste bringen
            	lappend rlst "prod_turnright"
            	lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
			}                    }

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
	        lappend rlst "prod_goworkdummy 3"		;// Kiste holen
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

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"
        set itemtype Halbzeug_holz
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"

        lappend rlst "prod_goworkdummy 3"
        lappend rlst "prod_turnleft"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_set_item_rotation $itemtype 0 1.6 0"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 29"
        lappend rlst "prod_anim putb"

        lappend rlst "prod_goworkdummy 2"		;// zum Schalter laufen & einschalten
        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim switchnorm"
        lappend rlst "prod_machineanim saegewerk.saegen"

		if {[random 1.0] > $exp_infl} {			;// entscheiden, ob das sägen sofort klappt
			set successful 0
		} else {
			set successful 1
		}

        set vel -0.1                            ;// Holz läuft durch die Säge
        for {set x 0} {$x<5} {incr x} {
        	lappend rlst "prod_move_item $itemtype $vel 0 0"
        	lappend rlst "prod_waittime 0.5"
        }
        lappend rlst "prod_call_method chips_saw_on"
        for {set x 0} {$x<18} {incr x} {
        	lappend rlst "prod_move_item $itemtype $vel 0 0"
        	lappend rlst "prod_waittime 0.5"
            if {$x == 10  &&  $successful == 1} {
        		lappend rlst "prod_itemtype_change_look $itemtype kant"
			}
        }
        lappend rlst "prod_call_method chips_saw_off"
        for {set x 0} {$x<2} {incr x} {
        	lappend rlst "prod_move_item $itemtype $vel 0 0"
        	lappend rlst "prod_waittime 0.5"
        }

        lappend rlst "prod_goworkdummy 1"		;// zum Schalter laufen, abschalten
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim switchnorm"
        lappend rlst "prod_machineanim saegewerk.standard"

        lappend rlst "prod_goworkdummy 0"
        lappend rlst "prod_goworkdummy 13"
        lappend rlst "prod_turnright"

		if {$successful == 0} {
			lappend rlst "prod_anim kontrol"				    ;// hat nicht geklappt...
			lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_anim shock"
	        lappend rlst "prod_changetool Axt"					;// ... also nochmal Hacken!!!
    	    lappend rlst "prod_anim hammerstart"
			lappend rlst "prod_anim hammerloopholz"
    	    lappend rlst "prod_call_method chips_bank_on"
       		lappend rlst "prod_anim_loop_expinfl hammerloopholz 2 5 $exp_infl"
       		lappend rlst "prod_itemtype_change_look $itemtype kant"
       		lappend rlst "prod_anim_loop_expinfl hammerloopholz 2 5 $exp_infl"
    	    lappend rlst "prod_call_method chips_bank_off"
        	lappend rlst "prod_anim hammerend"
        	lappend rlst "prod_changetool 0"
        }

        lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
        lappend rlst "prod_anim putb"

		return $rlst
	}


// Stein

	method prod_actions_Stein {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Stein holen
        set itemtype Halbzeug_stein
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"

        lappend rlst "prod_goworkdummy 0"
        lappend rlst "prod_goworkdummy 13"
        lappend rlst "prod_turnright"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 28"  ;// zur Werkbank
        lappend rlst "prod_anim putb"

       if {[random 1.0] < 0.5} {
	        lappend rlst "prod_changetool Hammer"                       ;// drauf rumhämmern
	        lappend rlst "prod_anim hammerstart"
	        lappend rlst "prod_anim hammerloopstein"
	        lappend rlst "prod_call_method dust_on"
	        lappend rlst "prod_anim_loop_expinfl hammerloopstein 2 8 $exp_infl"
	       	lappend rlst "prod_itemtype_change_look $itemtype mauer"
	        if {[random 1.0] > $exp_infl} {
	            lappend rlst "prod_anim hammeraccidenta"
	        }
	        lappend rlst "prod_anim_loop_expinfl hammerloopstein 2 10 $exp_infl"
	        lappend rlst "prod_call_method dust_off"
	        lappend rlst "prod_anim hammerend"

		} else {
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

        lappend rlst "prod_anim puta" 			       		        ;// Stein ist weg
        lappend rlst "prod_consume_from_workplace $itemtype"
		lappend rlst "prod_anim putb"
        lappend rlst "prod_goworkdummy 0"

		return $rlst
	}

// Eisenerz

    method prod_actions_Eisenerz {itemtype exp_infl} {
        return [call_method this prod_actions_Eisen $itemtype $exp_infl]
    }


// Eisen

    method prod_actions_Eisen {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Eisenstück holen
        set itemtype Halbzeug_eisen
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"

        lappend rlst "prod_goworkdummy 0"
        lappend rlst "prod_goworkdummy 13"
        lappend rlst "prod_turnright"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 28"  ;// zur Werkbank
        lappend rlst "prod_anim putb"

        lappend rlst "prod_changetool Hammer"                       ;// drauf rumhämmern
        lappend rlst "prod_anim hammerstart"
        lappend rlst "prod_anim hammerloopmetall"
        lappend rlst "prod_call_method dust_on"
        lappend rlst "prod_anim_loop_expinfl hammerloopmetall 2 8 $exp_infl"
       	if {[random 1.0] > 0.5} {
	       	lappend rlst "prod_itemtype_change_look $itemtype blech"
    	} else {
	       	lappend rlst "prod_itemtype_change_look $itemtype rad"
    	}
        if {[random 1.0] > $exp_infl} {
            lappend rlst "prod_anim hammeraccidenta"
        }
        lappend rlst "prod_anim_loop_expinfl hammerloopmetall 2 10 $exp_infl"
        lappend rlst "prod_call_method dust_off"
        lappend rlst "prod_anim hammerend"
        lappend rlst "prod_changetool 0"

        lappend rlst "prod_anim puta" 			       		        ;// Eisenstück ist weg
        lappend rlst "prod_consume_from_workplace $itemtype"
		lappend rlst "prod_anim putb"
        lappend rlst "prod_goworkdummy 0"

		return $rlst
    }



// Pilzhut

	method prod_actions_Pilzhut {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_hide_itemtype $itemtype"        ;// Hut holen
        lappend rlst "prod_goworkdummy 0"
        lappend rlst "prod_goworkdummy 13"
        lappend rlst "prod_turnright"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 28"  ;// zur Werkbank
		lappend rlst "prod_anim putb"

		if {[random 1.0] > 0.5} {
	        lappend rlst "prod_changetool Hobel"                        ;// dran rumhobeln
    	    lappend rlst "prod_anim planestart"
    	    lappend rlst "prod_anim planeloop"
	        lappend rlst "prod_call_method chips_bank_on"
	        lappend rlst "prod_anim_loop_expinfl planeloop 5 20 $exp_infl"
	        lappend rlst "prod_call_method chips_bank_off"
	        lappend rlst "prod_anim planeend"
	        lappend rlst "prod_changetool 0"
    	} else {
	     	lappend rlst "prod_changetool Axt"							;// ... oder hacken
    		lappend rlst "prod_anim hammerstart"
    		lappend rlst "prod_anim hammerloopholz"
    		lappend rlst "prod_call_method chips_bank_on"
	    	lappend rlst "prod_anim_loop_expinfl hammerloopholz 1 6 $exp_infl"
	        if {[random 1.0] > $exp_infl} {
    	        lappend rlst "prod_anim hammeraccidenta"
        	}
	    	lappend rlst "prod_anim_loop_expinfl hammerloopholz 1 6 $exp_infl"
       		lappend rlst "prod_call_method chips_bank_off"
        	lappend rlst "prod_anim hammerend"
        	lappend rlst "prod_changetool 0"
		}

        lappend rlst "prod_anim puta" 			       			        ;// Hut ist weg
        lappend rlst "prod_consume_from_workplace $itemtype"
        lappend rlst "prod_anim putb"
        lappend rlst "prod_goworkdummy 0"

		return $rlst
	}


// default

	method prod_actions_default {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_itemtype $itemtype"        		           ;// zum Dings gehen
        lappend rlst "prod_anim_loop_expinfl workatfloor 5 25 $exp_infl"   ;// dran arbeiten
    	lappend rlst "prod_consume_from_workplace $itemtype"

    	lappend rlst "prod_goworkdummy 6"

		return $rlst
	}


	method chips_saw_on {} {
		set_particlesource this 0 1
		set_particlesource this 1 1
	}


	method chips_saw_off {} {
		set_particlesource this 0 0
		set_particlesource this 1 0
	}


	method chips_bank_on {} {
		set_particlesource this 2 1
	}

	method chips_bank_off {} {
		set_particlesource this 2 0
	}


	method dust_on {} {
		set_particlesource this 3 1
	}

	method dust_off {} {
		set_particlesource this 3 0
	}


	method deinit_production {} {
		call_method this dust_off
		call_method this chips_bank_off
		call_method this chips_saw_off
	}


    method init {} {
    	set_collision this 1

		change_particlesource this 0 17 {0 0 0} {0.2 -0.3 0} 256 4 0 9	   ;// Späne Säge
		set_particlesource this 0 0
		change_particlesource this 1 17 {0 0 0} {-0.2 -0.3 0} 256 4 0 8
		set_particlesource this 1 0
        change_particlesource this 2 17 {0 0 0} {0 -0.1 0} 64 1 0 28	   ;// Späne Werkbank
        set_particlesource this 2 0
		change_particlesource this 3 19 {0 0 0.5} {0.5 0.5 0.5} 32 4 0 28  ;// staub auf dem Stein
		set_particlesource this 3 0
    }


	class_defaultanim saegewerk.standard
	class_flagoffset 3.1 4.35

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this saegewerk.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Saegewerk
		set_energyconsumption this $tttenergycons_Saegewerk
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 12 13 14 15 16 17 18 19]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsholz unten_linksholz unten_linksholz unten_rechtsholz oben_rechtsholz oben_rechtsholz oben_linksholz oben_rechtsholz}
		set damage_dummys {20 27}
	}
}

