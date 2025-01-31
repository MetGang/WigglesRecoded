//# STOPIFNOT FULL
call scripts/misc/utility.tcl

def_class Schmiede metal production 3 {} {

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 2.0

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
	        lappend rlst "prod_turnback"
	        lappend rlst "prod_anim benda"
	     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 3 0 0 -1.5"
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
            	lappend rlst "prod_turnback"
            	lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
			}
        }

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
	        lappend rlst "prod_goworkdummy 3"		;// Kiste holen
    	    lappend rlst "prod_turnback"
    	    lappend rlst "prod_anim puta"
   	    	lappend rlst "prod_createproduct_inv_boxed $item; prod_itemtype_change_look Halbzeug_kiste geschlossen"
	        lappend rlst "prod_anim putb"
       		lappend rlst "prod_anim takeboxa"
       		lappend rlst "prod_itemtype_change_look Halbzeug_kiste tragen; prod_link_itemtype_to_hand Halbzeug_kiste"
            lappend rlst "prod_anim takeboxb"
 			lappend rlst "prod_goworkdummy_with_box 6"
			lappend rlst "prod_createproduct_box_with_dummybox $item"
		} else {
			lappend rlst "prod_goworkdummy 6"
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

        lappend rlst "prod_goworkdummy 6"
        if {[random 1.0] < 0.5} {                                 ;// zufällig ...
            lappend rlst "prod_turnback"                          ;// ... von vorn ...
        } else {
			lappend rlst "prod_goworkdummy 3"                     ;// ... oder rechts arbeiten
   		    lappend rlst "prod_turnleft"
        }

		lappend rlst "prod_anim puta"
   	    lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 8"
		lappend rlst "prod_anim putb"
    	lappend rlst "prod_changetool Hammer"             ;// rumhämmern
    	lappend rlst "prod_anim hammerstart"
    	lappend rlst "prod_anim hammerloopstein"
        lappend rlst "prod_call_method set_dust 1"
    	lappend rlst "prod_anim_loop_expinfl hammerloopstein 2 10 $exp_infl"
       	lappend rlst "prod_itemtype_change_look $itemtype mauer"
        if {$exp_infl < 0.5} {
            lappend rlst "prod_anim hammeraccidenta"
        }
    	lappend rlst "prod_anim_loop_expinfl hammerloopstein 2 10 $exp_infl"
        lappend rlst "prod_call_method set_dust 0"
        lappend rlst "prod_anim hammerend"
    	lappend rlst "prod_changetool 0"
		lappend rlst "prod_anim puta"
    	lappend rlst "prod_consume_from_workplace $itemtype"
		lappend rlst "prod_anim putb"

    	lappend rlst "prod_goworkdummy 6"

		return $rlst
	}


// Eisen

	method prod_actions_Eisen {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"   ;// Eisen holen
        set itemtype Halbzeug_eisen
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"

        lappend rlst "prod_goworkdummy 3"						  ;// Eisen ins Feuer
        lappend rlst "prod_turnright"
        lappend rlst "prod_anim benda"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 11"
        lappend rlst "prod_anim bendb"
        lappend rlst "prod_waittime 2"
        lappend rlst "prod_turnfront"
        lappend rlst "prod_anim impatient"
        lappend rlst "prod_turnright"
        lappend rlst "prod_waittime 2"
        lappend rlst "prod_anim benda"
        lappend rlst "prod_hide_itemtype $itemtype"
        lappend rlst "prod_anim bendb"

        lappend rlst "prod_goworkdummy 3"
        if {[random 1.0] < 0.5} {                                 ;// zufällig ...
            lappend rlst "prod_turnleft"                          ;// ... von rechts ...
        } else {
			lappend rlst "prod_goworkdummy 6"                     ;// ... oder vorn arbeiten
   		    lappend rlst "prod_turnback"
        }

		lappend rlst "prod_anim puta"
   	    lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 8"
		lappend rlst "prod_anim putb"
    	lappend rlst "prod_changetool Hammer"             			;// rumhämmern
    	lappend rlst "prod_anim hammerstart"
    	lappend rlst "prod_anim hammerloopmetall"
        lappend rlst "prod_call_method set_sparks 1"
    	lappend rlst "prod_anim_loop_expinfl hammerloopmetall 2 8 $exp_infl"
    	if {[random 1.0] > 0.4} {
            if {[random 1.0] > 0.5} {
                lappend rlst "prod_itemtype_change_look $itemtype half"
            } else {
                lappend rlst "prod_itemtype_change_look $itemtype stab"
            }
        } else {
                lappend rlst "prod_itemtype_change_look $itemtype blech"
        }

     	lappend rlst "prod_anim_loop_expinfl hammerloopmetall 1 4 $exp_infl"		;// mehr hämmern, evtl. Unfall
        if {$exp_infl < 0.5} {
            lappend rlst "prod_anim hammeraccidenta"
        }
     	lappend rlst "prod_anim_loop_expinfl hammerloopmetall 1 4 $exp_infl"

        lappend rlst "prod_call_method set_sparks 0"
    	lappend rlst "prod_anim hammerend"
    	lappend rlst "prod_changetool 0"
		lappend rlst "prod_anim puta"
    	lappend rlst "prod_hide_itemtype $itemtype"
		lappend rlst "prod_anim putb"

		lappend rlst "prod_goworkdummy 6"
    	lappend rlst "prod_goworkdummy 1"                ;// ins Wasserbad bringen
     	lappend rlst "prod_turnleft"
		lappend rlst "prod_anim puta"
     	lappend rlst "prod_beam_itemtype_near_dummypos $itemtype 10 0 -0.2 0"
		lappend rlst "prod_anim putb"
        lappend rlst "prod_call_method set_smoke 1"
        lappend rlst "prod_anim work"
    	lappend rlst "prod_waittime 10"
        lappend rlst "prod_call_method set_smoke 0"
		lappend rlst "prod_anim puta"
    	lappend rlst "prod_consume_from_workplace $itemtype"
		lappend rlst "prod_anim putb"
    	lappend rlst "prod_goworkdummy 6"

		return $rlst
	}


// Hamster

	method prod_actions_Hamster {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"

        return $rlst
	}


// Eisenerz

    method prod_actions_Eisenerz {itemtype exp_infl} {
        return [call_method this prod_actions_Eisen $itemtype $exp_infl]
    }


// Kohle

    method prod_actions_Kohle {itemtype exp_infl} {
        return [call_method this prod_actions_Pilzstamm $itemtype $exp_infl]
    }


// Pilzstamm

	method prod_actions_Pilzstamm {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_hide_itemtype $itemtype"        ;// Stamm holen & verbrennen
        lappend rlst "prod_goworkdummy 3"
        lappend rlst "prod_turnright"
        lappend rlst "prod_anim benda"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 11"
        lappend rlst "prod_anim bendb"
        lappend rlst "prod_waittime 2"
        lappend rlst "prod_call_method set_fireburst 1"
        lappend rlst "prod_anim shock"
        lappend rlst "prod_waittime 5"
        lappend rlst "prod_consume_from_workplace $itemtype"
        lappend rlst "prod_waittime 2"
        lappend rlst "prod_call_method set_fireburst 0"

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




	method prod_get_invention_dummy {} {
		return 6								;// immer an dummy 6 forschen!
	}

    method set_fireburst {bool} {
    	if {$bool} {
			change_particlesource this 0 3 {0 0 0} {0 -0.3 0} 256 8 0 11
			change_particlesource this 1 6 {0 -1 0} {0 0 0} 128 8 0 11
		} else {
			change_particlesource this 0 0 {0 0 0} {0 0 0} 256 4 0 11
			change_particlesource this 1 6 {0 -1 0} {0 -0.1 0} 128 1 0 11
		}
    }


    method set_smoke {bool} {
		set_particlesource this 2 $bool
    }


    method set_sparks {bool} {
		set_particlesource this 3 $bool
		set_particlesource this 4 $bool
    }


    method set_dust {bool} {
		set_particlesource this 5 $bool
    }


	method deinit_production {} {
		call_method this set_dust 0
		call_method this set_sparks 0
		call_method this set_smoke 0
		call_method this set_fireburst 0
	}


    method init {} {
    	set_collision this 1

		// Feuer und Rauch an der Feuerstelle
		change_particlesource this 0 0 {0 0 0} {0 0 0} 256 4 0 11
		set_particlesource this 0 1

		change_particlesource this 1 6 {0 -1 0} {0 -0.1 0} 128 1 0 11
		set_particlesource this 1 1

		change_particlesource this 2 6 {0 0 0} {0 -0.1 0} 128 16 0 10     		;// Rauch Bottich
        set_particlesource this 2 0

		change_particlesource this 3 18 {0 -0.2 0.5} {0.05 0 0} 32 2 0 9     	;// Funken Amboss
        set_particlesource this 3 0
		change_particlesource this 4 18 {0 -0.2 0.5} {-0.05 0 0} 32 2 0 9		;// Funken Amboss
        set_particlesource this 4 0

		change_particlesource this 5 19 {0 0 0.5} {0.5 0.5 0.5} 32 4 0 9  		;// staub auf Amboss
		set_particlesource this 5 0

		change_light this [get_linkpos this 11] 4 "1 0.9 0.8"
		set_light this 1
    }


	class_defaultanim schmiede.standard
	class_flagoffset 2.6 1.8

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this schmiede.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Schmiede
		set_energyconsumption this $tttenergycons_Schmiede
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 12 13 14 15 16 17 18 19]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsholz unten_linksholz unten_linksholz unten_rechtsholz oben_rechtsholz unten_rechtsholz oben_linksholz oben_rechtsholz}
		set damage_dummys {20 27}
	}
}


