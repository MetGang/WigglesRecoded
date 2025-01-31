//# STOPIFNOT FULL
call scripts/misc/utility.tcl


def_class Labor metal production 4 {} {

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
	        lappend rlst "prod_goworkdummy 3"
	        lappend rlst "prod_turnleft"
	        lappend rlst "prod_anim benda"
	     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 4 -0.5 0 0"
	        lappend rlst "prod_anim bendb"
		}

        foreach material $materiallist {
            if {[check_method [get_objclass this] "prod_actions_$material"]} {
                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
                lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
            } else {
            	log "WARNING: labor.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }
			if {[random 1.0] > $exp_infl} {				;// ab und zu witzige Anims einstreuen
				switch [irandom 5] {
					0 { lappend rlst "prod_goworkdummy 3"
						lappend rlst "prod_turnback"
						lappend rlst "prod_anim calculator"
						lappend rlst "prod_anim scratchhead"
						lappend rlst "prod_turnright"
						lappend rlst "prod_anim dontknow"
					  }
					1 { lappend rlst "prod_goworkdummy 6"
					    lappend rlst "prod_turnback"
					    lappend rlst "prod_anim put"
					    lappend rlst "prod_turnfront"
					    lappend rlst "prod_anim leftright"
					    lappend rlst "prod_anim takedrugs"
					    lappend rlst "prod_anim cheer"
					  }
				}
			}

	        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
        	 	lappend rlst "prod_goworkdummy 3"   ;// jedes Werkstück zur leeren Kiste bringen
            	lappend rlst "prod_turnleft"
            	lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
			}
        }

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
	        lappend rlst "prod_goworkdummy 3"						;// entweder die Kiste holen
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
			lappend rlst "prod_goworkdummy 0"						;// oder den fertigen Trank abholen
			lappend rlst "prod_turnback"
			lappend rlst "prod_call_method magicdust2_burst"
			lappend rlst "prod_create_itemtype_ppinv_hidden Halbzeug_trank"
			lappend rslt "prod_change_look Halbzeug_trank $item"
			lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_trank 14 0 0.3 0"
            lappend rlst "prod_goworkdummy 6"
            lappend rlst "prod_turnback"
           	lappend rlst "prod_anim puta"
	        lappend rlst "prod_consume_from_workplace Halbzeug_trank; prod_createproduct_inv $item"
			lappend rlst "prod_anim putb"
			lappend rlst "prod_goworkdummy 0"
	        lappend rlst "prod_putdown $item"
        }

        lappend rlst "prod_turnfront"
		lappend rlst "prod_anim impatient"

		return $rlst
	}


	// default
	// In dieser Produktionsstätte ist die default-action die wichtigste:
	// Gegenstand per Kran in den Tubus werfen!

    method prod_actions_default {itemtype exp_infl} {
        set rlst [list]

       	lappend rlst "prod_goworkdummy 4"                      	;// Schaltpult laufen
       	lappend rlst "prod_turnback"
       	lappend rlst "prod_anim pressbutton"

       	if {$exp_infl < 0.5  &&  [random 1.0] < 0.2} {				;// Knopf drücken klappt nicht immer
       	    lappend rlst "prod_anim wait"
       	    lappend rlst "prod_anim scratchhead"
       	    lappend rlst "prod_anim kickmachine"
       	}

       	lappend rlst "prod_machineanim labor.ausschwenk once"  		;// kran kommt
       	lappend rlst "prod_waittime 2"
       	lappend rlst "prod_machineanim labor.kran_unten"       		;// kran ist unten
       	lappend rlst "prod_walk_and_hide_itemtype $itemtype"   		;// item holen
       	lappend rlst "prod_goworkdummy 0"
       	lappend rlst "prod_turnright"
       	lappend rlst "prod_anim benda"
       	lappend rlst "prod_link_itemtype_to_dummy $itemtype 31" 	;// item anhängen
       	lappend rlst "prod_anim bendb"
       	lappend rlst "prod_goworkdummy 4"
       	lappend rlst "prod_turnback"
       	lappend rlst "prod_anim pressbutton"
       	lappend rlst "prod_machineanim labor.einschwenk once"     	;// kran wieder hoch
        lappend rlst "prod_waittime 1.8"
        lappend rlst "prod_consume_from_workplace $itemtype"
        if {[random 1.0] > 0.5} {
	        lappend rlst "prod_call_method magicdust_burst"
	        lappend rlst "prod_call_method whitecloud_burst"
        } else {
	        lappend rlst "prod_call_method flame_burst"
	        lappend rlst "prod_call_method whitecloud_burst"
        }
        lappend rlst "prod_waittime 1"
       	lappend rlst "prod_machineanim labor.einschwenk_b once"   	;// kran wieder hoch
       	lappend rlst "prod_waittime 2"
       	lappend rlst "prod_machineanim labor.standard"   	      	;// kran ist ferig

        return $rlst
    }


    // Pilzstamm

    method prod_actions_Pilzstamm {itemtype exp_infl} {
        return [call_method this prod_actions_default $itemtype $exp_infl]
    }


    // Pilzhut

    method prod_actions_Pilzhut {itemtype exp_infl} {
        return [call_method this prod_actions_default $itemtype $exp_infl]
    }


    // Stein

    method prod_actions_Stein {itemtype exp_infl} {
        return [call_method this prod_actions_default $itemtype $exp_infl]
    }


    // Eisen

    method prod_actions_Eisen {itemtype exp_infl} {
        return [call_method this prod_actions_default $itemtype $exp_infl]
    }


    // Eisenerz

    method prod_actions_Eisenerz {itemtype exp_infl} {
        return [call_method this prod_actions_default $itemtype $exp_infl]
    }


    // Kristall

    method prod_actions_Kristall {itemtype exp_infl} {
        return [call_method this prod_actions_default $itemtype $exp_infl]
    }


    // Kristallerz

    method prod_actions_Kristallerz {itemtype exp_infl} {
        return [call_method this prod_actions_default $itemtype $exp_infl]
    }


    // Gold

    method prod_actions_Gold {itemtype exp_infl} {
        return [call_method this prod_actions_default $itemtype $exp_infl]
    }


    // Hamster

    method prod_actions_Hamster {itemtype exp_infl} {
        return [call_method this prod_actions_default $itemtype $exp_infl]
    }


    // Raupe

    method prod_actions_Raupe {itemtype exp_infl} {
        return [call_method this prod_actions_default $itemtype $exp_infl]
    }


    // Bier

    method prod_actions_Bier {itemtype exp_infl} {
        return [call_method this prod_actions_default $itemtype $exp_infl]
    }


	method magicdust_burst {} {
		set_particlesource this 2 5
	}

	method whitecloud_burst {} {
		set_particlesource this 3 5
	}

	method flame_burst {} {
		set_particlesource this 4 5
	}


	method magicdust2_burst {} {
		set_particlesource this 5 5
	}


	method deinit_production {} {
	}


    method init {} {
    	set_collision this 1

		change_particlesource this 1 0 {0 0 0} {0 0 0} 128 4 0 15				;// Feuer
		set_particlesource this 1 1

		change_particlesource this 0 6 {0 -2 0} {0 -0.3 0} 128 5 0 15
		set_particlesource this 0 1

		change_particlesource this 2 13 {0 -4.6 0} {0 -0.1 0} 256 128 0 15		;// "Magic Dust" oben
		set_particlesource this 2 0

		change_particlesource this 3 11 {0 -4.5 0} {0 0 0} 256 128 0 15			;// "White cloud" oben
		set_particlesource this 3 0

		change_particlesource this 4 3 {0 -4.5 0} {0 0 0} 256 128 0 15			;// "Flame" oben
		set_particlesource this 4 0

		change_particlesource this 5 13 {0 0.3 0} {0 -0.06 0} 64 64 0 14		;// "Magic Dust" unten
		set_particlesource this 5 0

		change_light this [get_linkpos this 15] 4 "1 0.9 0.8"
		set_light this 1
    }


	class_defaultanim labor.standard
	class_flagoffset 2.1 3.0


	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this labor.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Labor
		set_energyconsumption this $tttenergycons_Labor
		set_inventoryslotuse this 1

        timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 16 17 18 19 20 21 22 22]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsstein oben_rechtsstein oben_rechtsholz oben_rechtsholz oben_linksmetall unten_linksmetall oben_rechtsholz oben_linksholz}
		set damage_dummys {14 15}
	}
}

