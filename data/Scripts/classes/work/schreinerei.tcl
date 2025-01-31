call scripts/misc/utility.tcl


def_class Schreinerei wood production 1 {} {

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
	        lappend rlst "prod_goworkdummy 2"
	        lappend rlst "prod_goworkdummy 4"
	        lappend rlst "prod_turnright"
	        lappend rlst "prod_anim benda"
	     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 4 0.5 0 0"
	        lappend rlst "prod_anim bendb"
    	    lappend rlst "prod_goworkdummy 2"
		}

        foreach material $materiallist {
        	log "Processing $material"
            if {[check_method [get_objclass this] "prod_actions_$material"]} {
                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
                lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
            } else {
            	log "WARNING: schreinerei.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }

	        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
    	     	lappend rlst "prod_goworkdummy 2"
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
		lappend rlst "prod_anim tired"

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
            lappend rlst "prod_goworkdummy 3"
            lappend rlst "prod_turnright"
        } else {
    	    lappend rlst "prod_goworkdummy 4"
    	    lappend rlst "prod_turnleft"
    	}

        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_near_dummypos $itemtype 22 0.35 -0.1 -0.5"
        lappend rlst "prod_anim putb"

   	    lappend rlst "prod_anim foxtailstart"
   	    lappend rlst "prod_anim foxtailloop"
   	    lappend rlst "prod_call_method set_chips 1"
   		lappend rlst "prod_anim_loop_expinfl foxtailloop 2 5 $exp_infl"
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
        lappend rlst "prod_beam_itemtype_near_dummypos $itemtype 22 0.45 -0.1 -0.5 2; prod_itemtype_change_look $itemtype brett; prod_itemtype_change_look $itemtype brett 2"
  		lappend rlst "prod_anim_loop_expinfl foxtailloop 3 6 $exp_infl"
   	    lappend rlst "prod_call_method set_chips 0"
       	lappend rlst "prod_anim foxtailstop"

        // beim Sägen sind 2 Bretter entstanden, eins davon legen wir vorn ab:

        lappend rlst "prod_anim puta"
        lappend rlst "prod_hide_itemtype $itemtype 2"
        lappend rlst "prod_anim putb"
        lappend rlst "prod_goworkdummy 2"
        lappend rlst "prod_turnfront"
        lappend rlst "prod_anim benda"
        lappend rlst "prod_beam_itemtype_near_dummypos $itemtype 2 0 0 1.2 2"
        lappend rlst "prod_anim bendb"

        if {[random 1.0] < 0.5} {								;// zufällig...
    	    lappend rlst "prod_changetool Akkuschrauber"		;// ...bohren oder
    	    lappend rlst "prod_anim scewstart"
    	    lappend rlst "prod_anim_loop_expinfl scewloop 3 10 $exp_infl"
    	    lappend rlst "prod_anim scewstop"
    	    lappend rlst "prod_changetool 0"

    	} else {

	       	if {$rnd < 1} {							;// ... zurück an ursprüngliche Pos
   		        lappend rlst "prod_turnback"		;// ... und werkeln
	      	} elseif {$rnd < 2} {
        	   	lappend rlst "prod_goworkdummy 1"
       	    	lappend rlst "prod_goworkdummy 0"
   	        	lappend rlst "prod_turnright"
        	} else {
   		    	lappend rlst "prod_goworkdummy 3"
    	    	lappend rlst "prod_goworkdummy 4"
    	    	lappend rlst "prod_turnleft"
    		}

			lappend rlst "prod_anim workholz"
    		lappend rlst "prod_call_method set_chips 1"
    		lappend rlst "prod_call_method set_dust 1"
    	    lappend rlst "prod_anim_loop_expinfl workholz 2 5 $exp_infl"
    	    lappend rlst "prod_itemtype_change_look $itemtype brett"
    	    lappend rlst "prod_anim_loop_expinfl workholz 2 6 $exp_infl"
    		lappend rlst "prod_call_method set_chips 0"
    		lappend rlst "prod_call_method set_dust 0"

    		if {[random 1.0] > $exp_infl} {				;// und evtl. sogar noch hämmern
    	    	lappend rlst "prod_changetool Hammer"
    	    	lappend rlst "prod_anim hammerstart"
    		    lappend rlst "prod_anim_loop_expinfl hammerloopholz 2 5 $exp_infl"
    		    lappend rlst "prod_anim hammeraccidenta"
    		    lappend rlst "prod_anim_loop_expinfl hammerloopholz 2 5 $exp_infl"
    		    lappend rlst "prod_anim hammerend"
	    	    lappend rlst "prod_changetool 0"
    		}
    	}

   	    // beide Teile einsammeln

		lappend rlst "prod_goworkdummy 2"
		lappend rlst "prod_turnback"
        lappend rlst "prod_anim puta"
        lappend rlst "prod_consume_from_workplace $itemtype"
        lappend rlst "prod_anim putb"
        lappend rlst "prod_turnfront"
        lappend rlst "prod_anim benda"
        lappend rlst "prod_consume_from_workplace $itemtype"
        lappend rlsr "prod_anim bendb"

		return $rlst
	}


// Hamster

    method prod_actions_Hamster {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Hamster holen
        return $rlst
    }
    

// Stein

	method prod_actions_Stein {itemtype exp_infl} {
		set rlst [list]

		lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Stein holen
		set itemtype Halbzeug_stein
		lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
		lappend rlst "prod_goworkdummy 2"

        set rnd [random 3.0]
        if {$rnd < 1} {
            lappend rlst "prod_turnback"
        } elseif {$rnd < 2} {
            lappend rlst "prod_goworkdummy 3"
            lappend rlst "prod_turnright"
        } else {
    	    lappend rlst "prod_goworkdummy 4"
    	    lappend rlst "prod_turnleft"
    	}
		lappend rlst "prod_anim puta"
		lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 8"
		lappend rlst "prod_anim putb"    	

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
    
    
	// Pilzhut

	method prod_actions_Pilzhut {itemtype exp_infl} {
		set rlst [list]

		lappend rlst "prod_walk_and_hide_itemtype $itemtype"        ;// Stein holen
		lappend rlst "prod_goworkdummy 2"

        set rnd [random 3.0]
        if {$rnd < 1} {
            lappend rlst "prod_turnback"
        } elseif {$rnd < 2} {
            lappend rlst "prod_goworkdummy 3"
            lappend rlst "prod_turnright"
        } else {
    	    lappend rlst "prod_goworkdummy 4"
    	    lappend rlst "prod_turnleft"
    	}
		lappend rlst "prod_anim puta"
		lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 8"
		lappend rlst "prod_anim putb"    	

		// hämmern
		lappend rlst "prod_changetool Hammer"
		lappend rlst "prod_anim hammerstart"
		lappend rlst "prod_anim hammerloopholz"
		lappend rlst "prod_call_method set_chips 1"
		lappend rlst "prod_anim_loop_expinfl hammerloopholz 2 7 $exp_infl"
		lappend rlst "prod_itemtype_change_look $itemtype mauer"
		 lappend rlst "prod_anim_loop_expinfl hammerloopholz 1 3 $exp_infl"
			if {$exp_infl < 0.5} {
			lappend rlst "prod_anim hammeraccidenta"
		}
		lappend rlst "prod_anim_loop_expinfl hammerloopholz 1 3 $exp_infl"
		lappend rlst "prod_call_method set_chips 0"
		lappend rlst "prod_anim hammerend"

		lappend rlst "prod_changetool 0"

		lappend rlst "prod_anim puta"
		lappend rlst "prod_consume_from_workplace $itemtype"
		lappend rlst "prod_anim putb"

		return $rlst
	}    

// Eisen

    method prod_actions_Eisen {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Eisenstück holen
        set itemtype Halbzeug_eisen
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"

        set rnd [random 3.0]
        if {$rnd < 1} {
            lappend rlst "prod_goworkdummy 2"
            lappend rlst "prod_turnback"
        } elseif {$rnd < 2} {
            lappend rlst "prod_goworkdummy 3"
            lappend rlst "prod_turnright"
        } else {
    	    lappend rlst "prod_goworkdummy 4"
    	    lappend rlst "prod_turnleft"
    	}
        lappend rlst "prod_anim puta"
        lappend rlst "prod_beam_itemtype_near_dummypos $itemtype 22 0.35 -0.08 -0.5"
        lappend rlst "prod_anim putb"

        lappend rlst "prod_changetool Hammer"                       ;// drauf rumhämmern
        lappend rlst "prod_anim hammerstart"
        lappend rlst "prod_anim hammerloopmetall"
        lappend rlst "prod_call_method set_dust 1"
        set hammerstart [llength $rlst]
        lappend rlst "prod_anim_loop_expinfl hammerloopmetall 2 12 $exp_infl"
       	lappend rlst "prod_itemtype_change_look $itemtype blech"
        lappend rlst "prod_anim_loop_expinfl hammerloopmetall 2 15 $exp_infl"
        set hammerend [llength $rlst]
        set hammercnt [expr {$hammerend-$hammerstart}]
        for {set i 1} {$i<$hammercnt} {incr i 3} {
        	set where [irandom $hammerstart $hammerend]
        	incr hammerend
        	set rlst [lreplace $rlst $where $where "prod_call_method set_sparks 1" "prod_anim hammerloopmetall" "prod_call_method set_sparks 0"]
        }
        set rnd [expr {4.5-$exp_infl*10.0}]
        for {set i 0} {$i<$rnd} {incr i} {
        	set where [irandom $hammerstart $hammerend]
        	set rlst [linsert $rlst $where "prod_anim hammeraccidenta"]
        }
        lappend rlst "prod_call_method set_dust 0"
        lappend rlst "prod_anim hammerend"
        lappend rlst "prod_changetool 0"

        lappend rlst "prod_anim puta" 			       		        ;// Eisenstück ist weg
        lappend rlst "prod_consume_from_workplace $itemtype"
		lappend rlst "prod_anim putb"

		return $rlst
    }

// default

    method prod_actions_default {itemtype exp_infl} {
        set rlst [list]
        lappend rlst "prod_walk_and_consume_itemtype $itemtype"

        return $rlst
    }


    method set_chips {bool} {
        set_particlesource this 0 $bool
    }


    method set_dust {bool} {
        set_particlesource this 1 $bool
    }


    method set_sparks {bool} {
		set_particlesource this 2 $bool
		set_particlesource this 3 $bool
    }

	method prod_get_invention_dummy {} {
		return 2								;// immer an dummy 2 forschen!
	}


	method deinit_production {} {
		call_method this set_dust 0
		call_method this set_chips 0
	}


    method init {} {
    	set_collision this 1

	    change_particlesource this 0 17 {0 0 0} {0 -0.2 0} 32 1 0 22	   ;// Späne Werkbank
        set_particlesource this 0 0
	    change_particlesource this 1 19 {0.2 0 0} {0.5 0.5 0.5} 32 1 0 22   ;// Staub Werkbank
        set_particlesource this 1 0
	    change_particlesource this 2 18 {0 0 0} {-0.05 0} 32 2 0 22	   ;// Funken Werkbank
        set_particlesource this 2 0
	    change_particlesource this 3 18 {0 0 0} {0.05 0} 32 2 0 22	   ;// Funken Werkbank
        set_particlesource this 3 0
    }


	class_defaultanim schreinerei.standard
	class_flagoffset 1.2 3.25

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this schreinerei.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Schreinerei
		set_energyconsumption this $tttenergycons_Schreinerei
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 12 13 14 15 16 17 18 19]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsholz unten_linksholz unten_rechtsholz unten_rechtsholz oben_linksholz oben_rechtsholz oben_linksholz oben_rechtsholz}
		set damage_dummys {20 27}

	}
}

