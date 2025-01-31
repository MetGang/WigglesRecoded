//# STOPIFNOT FULL
call scripts/misc/utility.tcl


def_class Dreherei metal production 3 {} {

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 2.0

	method prod_item_actions item {
		global current_worker BOXED_CLASSES
		set exp_incr [call_method this prod_item_exp_incr $item]
		set exp_infls [call_method this prod_item_exp_infl $item]
		set exp_infl [prod_getgnomeexper $current_worker $exp_infls]
		set materiallist [call_method this prod_item_materials $item]
		set rlst [list]

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {			;// leere Kiste hinstellen
	        lappend rlst "prod_create_itemtype_ppinv_hidden Halbzeug_kiste"
	        lappend rlst "prod_goworkdummy 18"
	        lappend rlst "prod_turnleft"
	        lappend rlst "prod_anim benda"
	     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 18 -0.7 0 0"
	        lappend rlst "prod_anim bendb"
    	    lappend rlst "prod_goworkdummy 0"
		}

        foreach material $materiallist {
            if {[check_method [get_objclass this] "prod_actions_$material"]} {
                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
                lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
            } else {
            	log "WARNING: dreherei.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }
	        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
        	 	lappend rlst "prod_goworkdummy 18"   ;// jedes Werkstück zur leeren Kiste bringen
            	lappend rlst "prod_turnleft"
            	lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
			}
        }

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
	        lappend rlst "prod_goworkdummy 18"		;// Kiste holen
    	    lappend rlst "prod_turnleft"
    	    lappend rlst "prod_anim puta"
   	    	lappend rlst "prod_createproduct_inv_boxed $item; prod_itemtype_change_look Halbzeug_kiste geschlossen"
	        lappend rlst "prod_anim putb"
       		lappend rlst "prod_anim takeboxa"
       		lappend rlst "prod_itemtype_change_look Halbzeug_kiste tragen; prod_link_itemtype_to_hand Halbzeug_kiste"
            lappend rlst "prod_anim takeboxb"
 			lappend rlst "prod_goworkdummy_with_box 0"
			lappend rlst "prod_createproduct_box_with_dummybox $item"
		} else {
			lappend rlst "prod_goworkdummy 0"
	        lappend rlst "prod_createproduct_rndrot $item"
        }

        lappend rlst "prod_turnfront"
		lappend rlst "prod_anim tired"

		return $rlst
	}


// Eisen

	method prod_actions_Eisen {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Eisen holen
        lappend rlst "prod_create_itemtype_ppinv_hidden Halbzeug_eisen"
        set itemtype Halbzeug_eisen
        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 10"
        lappend rlst "prod_anim putb"

        lappend rlst "prod_goworkdummy 18"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim kickmachine"
        if {[random 1.0] > $exp_infl} {
            lappend rlst "prod_anim scratchhead"
            lappend rlst "prod_anim work"
            lappend rlst "prod_anim kickmachine"
        }
        lappend rlst "prod_machineanim dreherei.anim"
        lappend rlst "prod_call_method set_dust 1"

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_call_method set_welding 1; prod_anim_loop_expinfl workmetall 1 5 $exp_infl"
        lappend rlst "prod_itemtype_change_look $itemtype stab"
        lappend rlst "prod_anim_loop_expinfl workmetall 1 5 $exp_infl"
        lappend rlst "prod_call_method set_welding 0"
        lappend rlst "prod_goworkdummy 18"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim kickmachine"
        lappend rlst "prod_call_method set_dust 0"
        lappend rlst "prod_machineanim dreherei.standard"

        if {[random 1.5] > $exp_infl} {
            lappend rlst "prod_goworkdummy 1"
            lappend rlst "prod_turnfront"
            lappend rlst "prod_anim weldglason; prod_sunglasses 1"
            lappend rlst "prod_changetool Handschweissgeraet"
            lappend rlst "prod_turnback"
            lappend rlst "prod_anim weldstart"
            lappend rlst "prod_call_method set_welding 1"
            lappend rlst "prod_anim_loop_expinfl weldloop 1 10 $exp_infl"
            lappend rlst "prod_call_method set_welding 0"
            lappend rlst "prod_anim weldstop"
            lappend rlst "prod_turnfront"
            lappend rlst "prod_changetool 0"
            lappend rlst "prod_anim weldglasoff"
            lappend rlst "prod_sunglasses 0"
        }

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
        lappend rlst "prod_anim putb"

		return $rlst
	}


// Stein

	method prod_actions_Stein {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Stein holen
        lappend rlst "prod_create_itemtype_ppinv_hidden Halbzeug_stein"
        set itemtype Halbzeug_stein
        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 10"
        lappend rlst "prod_anim putb"

        lappend rlst "prod_goworkdummy 18"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim kickmachine"
        if {[random 1.0] > $exp_infl} {
            lappend rlst "prod_anim scratchhead"
            lappend rlst "prod_anim work"
            lappend rlst "prod_anim kickmachine"
        }
        lappend rlst "prod_machineanim dreherei.anim"
        lappend rlst "prod_call_method set_dust 1"

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim_loop_expinfl workstein 1 5 $exp_infl"
        lappend rlst "prod_itemtype_change_look $itemtype mauer"
        lappend rlst "prod_anim_loop_expinfl workstein 1 5 $exp_infl"
        lappend rlst "prod_goworkdummy 18"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim kickmachine"
        lappend rlst "prod_call_method set_dust 0"
        lappend rlst "prod_machineanim dreherei.standard"

        if {[random 1.5] > $exp_infl} {
            lappend rlst "prod_goworkdummy 1"
            lappend rlst "prod_turnfront"
            lappend rlst "prod_changetool Hammer"
            lappend rlst "prod_turnback"
            lappend rlst "prod_anim hammerstart"
            lappend rlst "prod_call_method set_dust 1"
            lappend rlst "prod_anim_loop_expinfl hammerloopstein 1 10 $exp_infl"
            lappend rlst "prod_call_method set_dust 0"
            lappend rlst "prod_anim hammerend"
            lappend rlst "prod_turnfront"
            lappend rlst "prod_changetool 0"
        }

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
        lappend rlst "prod_anim putb"

		return $rlst
	}



// Pilzstamm

	method prod_actions_Pilzstamm {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Eisen holen
        lappend rlst "prod_create_itemtype_ppinv_hidden Halbzeug_holz"
        set itemtype Halbzeug_holz
        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 10"
        lappend rlst "prod_anim putb"

        if {[random 1.5] > $exp_infl} {
    	    lappend rlst "prod_anim foxtailstart"
    	    lappend rlst "prod_anim foxtailloop"
    	    lappend rlst "prod_call_method set_chips 1; prod_call_method set_dust 1"
	        if {[random 1.0] < 0.4} {
    	    	lappend rlst "prod_anim_loop_expinfl foxtailloop 3 10 $exp_infl"
       		} else {
        		lappend rlst "prod_anim_loop_expinfl foxtailloop 2 5 $exp_infl"
        		lappend rlst "prod_itemtype_change_look $itemtype half"
        		lappend rlst "prod_anim_loop_expinfl foxtailloop 2 5 $exp_infl"
        	}
    	    lappend rlst "prod_call_method set_chips 0; prod_call_method set_dust 0"
        	lappend rlst "prod_anim foxtailstop"
        }

        lappend rlst "prod_goworkdummy 18"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim kickmachine"
        if {[random 1.0] > $exp_infl} {
            lappend rlst "prod_anim scratchhead"
            lappend rlst "prod_anim work"
            lappend rlst "prod_anim kickmachine"
        }
        lappend rlst "prod_machineanim dreherei.anim"
        lappend rlst "prod_call_method set_dust 1"

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_call_method set_chips 1; prod_anim_loop_expinfl workholz 1 5 $exp_infl"
   		lappend rlst "prod_itemtype_change_look $itemtype brett"
        lappend rlst "prod_anim_loop_expinfl workholz 1 5 $exp_infl"
        lappend rlst "prod_call_method set_chips 0"
        lappend rlst "prod_goworkdummy 18"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim kickmachine"
        lappend rlst "prod_call_method set_dust 0"
        lappend rlst "prod_machineanim dreherei.standard"

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
        lappend rlst "prod_anim putb"

		return $rlst
	}


// Hamster

    method prod_actions_Hamster {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_hide_itemtype $itemtype"
        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 10"
        lappend rlst "prod_anim putb"
        lappend rlst "prod_anim_loop_expinfl work 1 6 $exp_infl"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
        lappend rlst "prod_anim putb"

		return $rlst
    }



// Pilzhut

	method prod_actions_Pilzhut {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_hide_itemtype $itemtype"
        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 10"
        lappend rlst "prod_anim putb"

        if {[random 1.5] > $exp_infl} {
    	    lappend rlst "prod_anim foxtailstart"
    	    lappend rlst "prod_anim foxtailloop"
    	    lappend rlst "prod_call_method set_chips 1; prod_call_method set_dust 1"
   	    	lappend rlst "prod_anim_loop_expinfl foxtailloop 1 10 $exp_infl"
    	    lappend rlst "prod_call_method set_chips 0; prod_call_method set_dust 0"
        	lappend rlst "prod_anim foxtailstop"
        }

        lappend rlst "prod_goworkdummy 18"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim kickmachine"
        if {[random 1.0] > $exp_infl} {
            lappend rlst "prod_anim scratchhead"
            lappend rlst "prod_anim work"
            lappend rlst "prod_anim kickmachine"
        }
        lappend rlst "prod_machineanim dreherei.anim"
        lappend rlst "prod_call_method set_dust 1"

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_call_method set_chips 1; prod_anim_loop_expinfl workholz 1 6 $exp_infl"
        lappend rlst "prod_call_method set_chips 0"
        lappend rlst "prod_goworkdummy 18"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim kickmachine"
        lappend rlst "prod_call_method set_dust 0"
        lappend rlst "prod_machineanim dreherei.standard"

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
        lappend rlst "prod_anim putb"

		return $rlst
	}


// Gold

    method prod_actions_Gold {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_hide_itemtype $itemtype"        ;// Eisen holen
        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 10"
        lappend rlst "prod_anim putb"

        lappend rlst "prod_goworkdummy 18"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim kickmachine"
        if {[random 1.0] > $exp_infl} {
            lappend rlst "prod_anim scratchhead"
            lappend rlst "prod_anim work"
            lappend rlst "prod_anim kickmachine"
        }
        lappend rlst "prod_machineanim dreherei.anim"
        lappend rlst "prod_call_method set_dust 1"

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_call_method set_welding 1; prod_anim_loop_expinfl workmetall 1 8 $exp_infl"
        lappend rlst "prod_call_method set_welding 0"
        lappend rlst "prod_goworkdummy 18"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim kickmachine"
        lappend rlst "prod_call_method set_dust 0"
        lappend rlst "prod_machineanim dreherei.standard"

        if {[random 1.5] > $exp_infl} {
            lappend rlst "prod_goworkdummy 1"
            lappend rlst "prod_turnfront"
            lappend rlst "prod_changetool Hammer"
            lappend rlst "prod_turnback"
            lappend rlst "prod_anim hammerstart"
            lappend rlst "prod_call_method set_dust 1"
            lappend rlst "prod_anim_loop_expinfl hammerloopmetall 1 10 $exp_infl"
            lappend rlst "prod_call_method set_dust 0"
            lappend rlst "prod_anim hammerend"
            lappend rlst "prod_turnfront"
            lappend rlst "prod_changetool 0"
        }

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
        lappend rlst "prod_anim putb"

		return $rlst    }


// Kristall

    method prod_actions_Kristall {itemtype exp_infl} {
        return [call_method this prod_actions_Gold $itemtype $exp_infl]
    }



// default

    method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Eisen $itemtype $exp_infl]
    }


    method prod_get_invention_dummy {} {
        return 0
    }


	method deinit_production {} {
	    call_method this set_welding 0
	}


    method set_welding {bool} {
        set_particlesource this 0 $bool
        set_particlesource this 1 $bool
    }


    method set_chips {bool} {
        set_particlesource this 2 $bool
        set_particlesource this 3 $bool
    }


	method set_dust {bool} {
		set_particlesource this 4 $bool
	}


    method init {} {
    	set_collision this 1

        change_particlesource this 0 18 {0 -0.1 0} { 0.05 -0.07 0} 128 8 0 10   ;// Funken
        change_particlesource this 1 18 {0 -0.1 0} {-0.05 -0.07 0} 128 8 0 10
        set_particlesource this 0 0
        set_particlesource this 1 0
        change_particlesource this 2 17 {0 -0.1 0} { 0.05 -0.07 0} 64 2 0 10   ;// Späne
        change_particlesource this 3 17 {0 -0.1 0} {-0.05 -0.07 0} 64 2 0 10
        set_particlesource this 2 0
        set_particlesource this 3 0
		change_particlesource this 4 19 {0 0 0.5} {0.5 0.5 0.5} 64 4 0 10       ;// Staub
		set_particlesource this 4 0
    }


	class_defaultanim dreherei.standard
	class_flagoffset 2.0 3.3

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this dreherei.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Dreherei
		set_energyconsumption this $tttenergycons_Dreherei
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 12 13 14 15 16 17 18 19]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsmetall unten_linksholz oben_linksholz oben_rechtsmetall oben_rechtsmetall oben_rechtsmetall unten_rechtsmetall unten_rechtsholz}
		set damage_dummys {20 27}

	}
}

