//# STOPIFNOT FULL
call scripts/misc/utility.tcl


def_class Tischlerei wood production 3 {} {

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
	        lappend rlst "prod_goworkdummy 5"
	        lappend rlst "prod_turnright"
	        lappend rlst "prod_anim benda"
	     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 5 0.7 0 0"
	        lappend rlst "prod_anim bendb"
		}

        foreach material $materiallist {
            if {[check_method [get_objclass this] "prod_actions_$material"]} {
                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
                lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
            } else {
            	log "WARNING: moebeltischlerei.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }

	        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
        	 	lappend rlst "prod_goworkdummy 5"   ;// jedes Werkstück zur leeren Kiste bringen
            	lappend rlst "prod_turnright"
            	lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
			}
        }

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
	        lappend rlst "prod_goworkdummy 5"		;// Kiste holen
    	    lappend rlst "prod_turnright"
    	    lappend rlst "prod_anim puta"
   	    	lappend rlst "prod_createproduct_inv_boxed $item; prod_itemtype_change_look Halbzeug_kiste geschlossen"
	        lappend rlst "prod_anim putb"
       		lappend rlst "prod_anim takeboxa"
       		lappend rlst "prod_itemtype_change_look Halbzeug_kiste tragen; prod_link_itemtype_to_hand Halbzeug_kiste"
            lappend rlst "prod_anim takeboxb"
 			lappend rlst "prod_goworkdummy_with_box 3"
			lappend rlst "prod_createproduct_box_with_dummybox $item"
		} else {
			lappend rlst "prod_goworkdummy 3"
			for {set i 0} {$i < [call_method this prod_item_number2produce $item]} {incr i} {
		        lappend rlst "prod_createproduct_rndrot $item"
		    }
        }

        lappend rlst "prod_turnfront"
		lappend rlst "prod_anim tired"

		return $rlst
	}


// Pilzstamm

	method prod_actions_Pilzstamm {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"
        set itemtype Halbzeug_holz
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
        lappend rlst "prod_set_item_rotation $itemtype 0 1.6 0"
        lappend rlst "prod_go_near_workdummy 2 0 0 -1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 14"
        lappend rlst "prod_anim putb"

        lappend rlst "prod_anim kickmachine"							;// Maschine einschalten
        if {[random 1.0] > $exp_infl} {
			lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_anim kickmachine"
		}
        lappend rlst "prod_machineanim moebeltischlerei.anim; prod_call_method set_chips 1; prod_call_method set_dust 1"
        lappend rlst "prod_anim_loop_expinfl workholz 1 5 $exp_infl"
		if {[random 1.0] < $exp_infl} {
	        lappend rlst "prod_itemtype_change_look $itemtype kant"
			lappend rlst "prod_anim kickmachine"
	        lappend rlst "prod_machineanim moebeltischlerei.standard; prod_call_method set_chips 0; prod_call_method set_dust 0"
 		} else {
 			// dummer Zwerg: Extraarbeit

			lappend rlst "prod_itemtype_change_look $itemtype half"
			lappend rlst "prod_anim kickmachine"
	        lappend rlst "prod_machineanim moebeltischlerei.standard; prod_call_method set_chips 0; prod_call_method set_dust 0"

			if {[random 1.0] > 0.5} {
				// Zufällig Hacken ...
    	        lappend rlst "prod_changetool Axt"
        	    lappend rlst "prod_anim hammerstart"
        	    lappend rlst "prod_call_method set_dust 1; prod_anim_loop_expinfl hammerloopholz 2 5 $exp_infl"
           		lappend rlst "prod_itemtype_change_look $itemtype kant"
        	    if {[random 1.0] > $exp_infl} {
    	            lappend rlst "prod_anim hammeraccidenta"
    	        }
           		lappend rlst "prod_anim_loop_expinfl hammerloopholz 2 5 $exp_infl"
        	    lappend rlst "prod_call_method set_dust 0; prod_anim hammerend"
            	lappend rlst "prod_changetool 0"
        	} else {
        		// ... oder Sägen
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
			// Extraarbeit Ende
    	}

		lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
       	lappend rlst "prod_anim putb"

        lappend rlst "prod_anim tired"
        return $rlst
    }


// Pilzhut

	method prod_actions_Pilzhut {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_hide_itemtype $itemtype"
        lappend rlst "prod_go_near_workdummy 2 0 0 -1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 14"
        lappend rlst "prod_anim putb"

        lappend rlst "prod_anim kickmachine"							;// Maschine einschalten
        if {[random 1.0] > $exp_infl} {
			lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_anim kickmachine"
		}
        lappend rlst "prod_machineanim moebeltischlerei.anim; prod_call_method set_chips 1; prod_call_method set_dust 1"
        lappend rlst "prod_anim_loop_expinfl workholz 1 5 $exp_infl"
		if {[random 1.0] < $exp_infl} {
			lappend rlst "prod_anim kickmachine"
	        lappend rlst "prod_machineanim moebeltischlerei.standard; prod_call_method set_chips 0; prod_call_method set_dust 0"
 		} else {
 			// dummer Zwerg: Extraarbeit

			lappend rlst "prod_anim kickmachine"
	        lappend rlst "prod_machineanim moebeltischlerei.standard; prod_call_method set_chips 0; prod_call_method set_dust 0"

			if {[random 1.0] > 0.5} {
				// Zufällig Hacken ...
    	        lappend rlst "prod_changetool Axt"
        	    lappend rlst "prod_anim hammerstart"
        	    lappend rlst "prod_call_method set_dust 1; prod_anim_loop_expinfl hammerloopholz 2 5 $exp_infl"
        	    if {[random 1.0] > $exp_infl} {
    	            lappend rlst "prod_anim hammeraccidenta"
    	        }
           		lappend rlst "prod_anim_loop_expinfl hammerloopholz 2 5 $exp_infl"
        	    lappend rlst "prod_call_method set_dust 0; prod_anim hammerend"
            	lappend rlst "prod_changetool 0"
        	} else {
        		// ... oder Sägen
          	    lappend rlst "prod_anim foxtailstart"
        	    lappend rlst "prod_anim foxtailloop"
        	    lappend rlst "prod_call_method set_chips 1; prod_call_method set_dust 1"
    	        if {[random 1.0] < 0.4} {
        	    	lappend rlst "prod_anim_loop_expinfl foxtailloop 3 10 $exp_infl"
           		} else {
            		lappend rlst "prod_anim_loop_expinfl foxtailloop 2 5 $exp_infl"
            		lappend rlst "prod_anim_loop_expinfl foxtailloop 2 5 $exp_infl"
            	}
        	    lappend rlst "prod_call_method set_chips 0; prod_call_method set_dust 0"
            	lappend rlst "prod_anim foxtailstop"
        	}
			// Extraarbeit Ende
    	}

		lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
       	lappend rlst "prod_anim putb"

        lappend rlst "prod_anim tired"
        return $rlst
    }



// Stein

	method prod_actions_Stein {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"
        set itemtype Halbzeug_stein
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
        lappend rlst "prod_go_near_workdummy 2 0 0 -1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 14"
        lappend rlst "prod_anim putb"

        lappend rlst "prod_anim kickmachine"							;// Maschine einschalten
        if {[random 1.0] > $exp_infl} {
			lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_anim kickmachine"
		}
        lappend rlst "prod_machineanim moebeltischlerei.anim; prod_call_method set_dust 1"
        lappend rlst "prod_anim_loop_expinfl workholz 1 5 $exp_infl"
        lappend rlst "prod_itemtype_change_look $itemtype mauer"

		lappend rlst "prod_anim kickmachine"
        lappend rlst "prod_machineanim moebeltischlerei.standard; prod_call_method set_dust 0"

        lappend rlst "prod_changetool Hammer"
   	    lappend rlst "prod_anim hammerstart"
   	    lappend rlst "prod_call_method set_dust 1; prod_anim_loop_expinfl hammerloopstein 1 3 $exp_infl"
   	    if {[random 1.0] > $exp_infl} {
            lappend rlst "prod_anim hammeraccidenta"
        }
   		lappend rlst "prod_anim_loop_expinfl hammerloopstein 0 3 $exp_infl"
   	    lappend rlst "prod_call_method set_dust 0; prod_anim hammerend"
       	lappend rlst "prod_changetool 0"

		lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
       	lappend rlst "prod_anim putb"

        lappend rlst "prod_anim tired"
        return $rlst
    }


// Eisen

	method prod_actions_Eisen {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Eisen holen
        set itemtype Halbzeug_eisen
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
        lappend rlst "prod_go_near_workdummy 2 0 0 -1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 14"
        lappend rlst "prod_anim putb"

        lappend rlst "prod_anim kickmachine"							;// Maschine einschalten
        if {[random 1.0] > $exp_infl} {
			lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_anim kickmachine"
		}
        lappend rlst "prod_machineanim moebeltischlerei.anim; prod_call_method set_sparks 1; prod_call_method set_dust 1"
        lappend rlst "prod_anim_loop_expinfl workmetall 1 5 $exp_infl"
		if {[random 1.0] < $exp_infl} {
	        lappend rlst "prod_itemtype_change_look $itemtype rad"
			lappend rlst "prod_anim kickmachine"
	        lappend rlst "prod_machineanim moebeltischlerei.standard; prod_call_method set_sparks 0; prod_call_method set_dust 0"
 		} else {
			lappend rlst "prod_itemtype_change_look $itemtype blech"		;// dummer Zwerg: Extraarbeit
			lappend rlst "prod_anim kickmachine"
	        lappend rlst "prod_machineanim moebeltischlerei.standard; prod_call_method set_sparks 0; prod_call_method set_dust 0"
	        lappend rlst "prod_changetool Hammer"
    	    lappend rlst "prod_anim hammerstart"
    	    lappend rlst "prod_call_method set_dust 1; prod_anim_loop_expinfl hammerloopmetall 2 5 $exp_infl"
       		lappend rlst "prod_itemtype_change_look $itemtype rad"
    	    if {[random 1.0] > $exp_infl} {
	            lappend rlst "prod_anim hammeraccidenta"
	        }
       		lappend rlst "prod_anim_loop_expinfl hammerloopmetall 2 5 $exp_infl"
    	    lappend rlst "prod_call_method set_dust 0; prod_anim hammerend"
        	lappend rlst "prod_changetool 0"
    	}

        if {[random 1.5] > $exp_infl} {
	        lappend rlst "prod_go_near_workdummy 2 0 0 -1"
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

		lappend rlst "prod_turnback"
		lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
       	lappend rlst "prod_anim putb"

        lappend rlst "prod_anim tired"
        return $rlst
    }


// Eisenerz

	method prod_actions_Eisenerz {itemtype exp_infl} {
        return [call_method this prod_actions_Eisen $itemtype $exp_infl]
	}


// Kristall

	method prod_actions_Kristall {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_hide_itemtype $itemtype"
        lappend rlst "prod_go_near_workdummy 2 0 0 -1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 14"
        lappend rlst "prod_anim putb"

        lappend rlst "prod_anim kickmachine"							;// Maschine einschalten
        if {[random 1.0] > $exp_infl} {
			lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_anim kickmachine"
		}
        lappend rlst "prod_machineanim moebeltischlerei.anim; prod_call_method set_sparks 1; prod_call_method set_dust 1"
        lappend rlst "prod_anim_loop_expinfl workmetall 1 5 $exp_infl"
		if {[random 1.0] > $exp_infl} {
			lappend rlst "prod_anim kickmachine"
	        lappend rlst "prod_machineanim moebeltischlerei.standard; prod_call_method set_sparks 0; prod_call_method set_dust 0"
 		} else {
			lappend rlst "prod_anim kickmachine"
	        lappend rlst "prod_machineanim moebeltischlerei.standard; prod_call_method set_sparks 0; prod_call_method set_dust 0"
	        lappend rlst "prod_changetool Hammer"
    	    lappend rlst "prod_anim hammerstart"
    	    lappend rlst "prod_call_method set_dust 1; prod_anim_loop_expinfl hammerloopmetall 2 5 $exp_infl"
       		lappend rlst "prod_itemtype_change_look $itemtype rad"
    	    if {[random 1.0] > $exp_infl} {
	            lappend rlst "prod_anim hammeraccidenta"
	        }
       		lappend rlst "prod_anim_loop_expinfl hammerloopmetall 2 5 $exp_infl"
    	    lappend rlst "prod_call_method set_dust 0; prod_anim hammerend"
        	lappend rlst "prod_changetool 0"
    	}

		lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
       	lappend rlst "prod_anim putb"

        lappend rlst "prod_anim tired"
        return $rlst
    }


// Gold

	method prod_actions_Kristall {itemtype exp_infl} {
        return [call_method this prod_actions_Eisen $itemtype $exp_infl]
	}


// Hamster

	method prod_actions_Hamster {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"
		if {$exp_infl < [random 1.0]} {
			lappend rlst "prod_anim scratchhead"
		}
        return $rlst
    }


// default

	method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Hamster $itemtype $exp_infl]
	}


	method set_dust {value} {
		set_particlesource this 0 $value
	}

	method set_chips {value} {
		set_particlesource this 1 $value
	}


	method set_sparks {value} {
		set_particlesource this 2 $value
	}


	method set_welding {value} {
		set_particlesource this 2 $value
		set_particlesource this 3 $value
	}

	method deinit_production {} {
		call_method this set_chips   0
		call_method this set_dust    0
		call_method this set_welding 0
	}


    method init {} {
    	set_collision this 1

		change_particlesource this 0 19 {0 0 0.5} {0.5 0.5 0.5} 64 4 0 14   	;// staub
		set_particlesource this 0 0
		change_particlesource this 1 17 {0 0 0} {-0.2 -0.3 0} 256 4 0 14	   	;// Späne Säge
		set_particlesource this 1 0
    	change_particlesource this 2 18 {0 0 0} {-0.07 -0.07 0} 256 24 0 14		;// Funken
    	set_particlesource    this 2 0
    	change_particlesource this 3 18 {0 0 0} { 0.07 -0.07 0} 256 24 0 14		;// Funken
    	set_particlesource    this 3 0


    }

	class_defaultanim moebeltischlerei.standard
	class_flagoffset 2.1 4.0

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this moebeltischlerei.standard 0 $ANIM_LOOP
		set standard_anim moebeltischlerei.standard
		set_energyclass this $tttenergyclass_Tischlerei
		set_energyconsumption this $tttenergycons_Tischlerei
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 16 17 18 19 19 20 20 21 22 22]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_linksholz oben_linksholz oben_rechtsholz unten_rechtsholz unten_linksholz unten_linksholz unten_rechtsholz oben_linksholz unten_rechtsholz unten_rechtsholz}
		set damage_dummys {23 31}
	}
}


