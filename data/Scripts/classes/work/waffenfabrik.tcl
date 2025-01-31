//# STOPIFNOT FULL
call scripts/misc/utility.tcl


def_class Waffenfabrik metal production 3 {} {

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 2.5

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
            	log "WARNING: waffenfabrik.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }

	        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
        	 	lappend rlst "prod_goworkdummy 2"   ;// jedes Werkstück zur leeren Kiste bringen
            	lappend rlst "prod_turnleft"
            	lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
			}
        }

		// jetzt kommt die eigentliche Arbeit :-)

		if {[random 1.0] > 0.5} {
			lappend rlst "prod_go_near_workdummy 0 -[random 0.5] 0.0 0.0"
		} else {
			lappend rlst "prod_go_near_workdummy 6 [random 0.5 1.0] 0.0 0.0"
		}
		lappend rlst "prod_turnback"
       	lappend rlst "prod_anim pressbutton"
       	if {$exp_infl < 0.5  &&  [random 1.0] < 0.2} {				;// Knopf drücken klappt nicht immer
       	    lappend rlst "prod_anim wait"
       	    lappend rlst "prod_anim scratchhead"
       	    lappend rlst "prod_anim kickmachine"
       	}
       	lappend rlst "prod_machineanim waffenfabrik.anim; prod_call_method set_smoke 1"

		set j [expr {int ((1.1 - $exp_infl) * 20)}]
		log "$j iterations ... "
		for {set i 0} {$i < $j} {incr i} {
			set rnd [irandom 5]
			if {$rnd == 0} {
				if {[random 1.0] > 0.5} {
					lappend rlst "prod_go_near_workdummy 0 -[random 0.5] 0.0 0.0"
				} else {
					lappend rlst "prod_go_near_workdummy 6 [random 0.5 1.0]  0.0 0.0"
				}
				lappend rlst "prod_turnback"
			}
			if {$rnd == 1} {
				lappend $rlst "prod_anim wait"
				lappend $rlst "prod_anim wait"
			}
			if {$rnd == 2} {
				lappend rlst "prod_anim kontrol"
				lappend rlst "prod_anim scratchhead"
				lappend rlst "prod_anim pressbutton"
				lappend rlst "prod_anim kontrol"
				lappend rlst "prod_anim pressbutton"
			}
			if {$rnd == 3} {
				lappend rlst "prod_anim kontrol"
				lappend rlst "prod_anim scratchhead"
				lappend rlst "prod_anim leftright"
				lappend rlst "prod_anim kickmachine"
			}
			if {$rnd == 4} {
				lappend rlst "prod_anim bowllose"
			}
		}

		if {[random 1.0] > 0.5} {
			lappend rlst "prod_go_near_workdummy 0 -[random 0.5] 0.0 0.0"
		} else {
			lappend rlst "prod_go_near_workdummy 6 [random 0.5 1.0] 0.0 0.0"
		}
		lappend rlst "prod_turnback"
       	lappend rlst "prod_anim pressbutton"
       	if {$exp_infl < 0.5  &&  [random 1.0] < 0.2} {				;// Knopf drücken klappt nicht immer
       	    lappend rlst "prod_anim wait"
       	    lappend rlst "prod_anim scratchhead"
       	    lappend rlst "prod_anim kickmachine"
       	}
       	lappend rlst "prod_machineanim waffenfabrik.standard; prod_call_method set_smoke 0"

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
	        lappend rlst "prod_goworkdummy 2"		;// Kiste holen
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
	        lappend rlst "prod_goworkdummy 3"
	        lappend rlst "prod_turnfront"
	        lappend rlst "prod_anim weaponfactoryup"
	        lappend rlst "prod_anim weaponfactorydown"
			lappend rlst "prod_goworkdummy 3"
	        lappend rlst "prod_createproduct_rndrot $item"
        }

        lappend rlst "prod_turnfront"
		lappend rlst "prod_anim tired"

		return $rlst
	}


// default

	method prod_actions_default {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Eisen holen
        lappend rlst "prod_goworkdummy 3"
        lappend rlst "prod_turnfront"
        lappend rlst "prod_anim weaponfactoryup"
        lappend rlst "prod_anim weaponfactorydown"
        return $rlst
    }


    method set_smoke {bool} {
		set_particlesource this 0 $bool
		set_particlesource this 1 $bool
		set_particlesource this 2 $bool

		set_particlesource this 3 $bool
		set_particlesource this 4 $bool
		set_particlesource this 5 $bool
		set_particlesource this 6 $bool
    }


	method deinit_production {} {
		call_method this set_smoke 0
	}


    method init {} {
    	set_collision this 1
		// grosse Schornsteine
		change_particlesource this 0 6 {0 0 0} {0 -0.1 0} 64 2 0 13
		set_particlesource this 0 0
		change_particlesource this 1 6 {0 0 0} {0 -0.1 0} 64 2 0 14
		set_particlesource this 1 0
		change_particlesource this 2 6 {0 0 0} {0 -0.1 0} 64 2 0 15
		set_particlesource this 2 0
		// kleine Schornsteine
		change_particlesource this 3 6 {0 0 0} {0 -0.05 0} 64 2 0 9
		set_particlesource this 3 0
		change_particlesource this 4 6 {0 0 0} {0 -0.05 0} 64 2 0 10
		set_particlesource this 4 0
		change_particlesource this 5 6 {0 0 0} {0 -0.05 0} 64 2 0 11
		set_particlesource this 5 0
		change_particlesource this 6 6 {0 0 0} {0 -0.05 0} 64 2 0 12
		set_particlesource this 6 0

		// Kollisionsboxen erzeugen, um des kaputte Mesh auszugleichen, das die blöden Graphiker versaut haben!!!

		if {$cbox1 == -1} {
			set cbox1 [new Info_Coll_d]
			set_pos $cbox1 [vector_add [get_pos this] { 3.230 0.0 -0.66}]
		}
		if {$cbox2 == -1} {
			set cbox2 [new Info_Coll_d]
			set_pos $cbox2 [vector_add [get_pos this] { 1.035 0.0 -0.56}]
		}
		if {$cbox3 == -1} {
			set cbox3 [new Info_Coll_d]
			set_pos $cbox3 [vector_add [get_pos this] {-1.156 0.0 -0.560}]
		}
		if {$cbox4 == -1} {
			set cbox4 [new Info_Coll_d]
			set_pos $cbox4 [vector_add [get_pos this] {-3.334 0.0 -0.720}]
		}
    }


	// Methode aus genericprod.tcl überlagern
    method prepare_packtobox {} {
		global cbox1 cbox2 cbox3 cbox4

		set_light this 0			;# abschalten eventuell vorhandener lichtquellen
		;# gib alle partikelquellen frei
		for {set index 0} {$index<16} {incr index} { free_particlesource this $index }

		if {$cbox1 != -1  &&  [obj_valid $cbox1]} { del $cbox1 }
		if {$cbox2 != -1  &&  [obj_valid $cbox2]} { del $cbox2 }
		if {$cbox3 != -1  &&  [obj_valid $cbox3]} { del $cbox3 }
		if {$cbox4 != -1  &&  [obj_valid $cbox4]} { del $cbox4 }
		set cbox1 -1
		set cbox2 -1
		set cbox3 -1
		set cbox4 -1
    }



	class_defaultanim waffenfabrik.standard
	class_flagoffset 3.0 3.2

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this waffenfabrik.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Waffenfabrik
		set_energyconsumption this $tttenergycons_Waffenfabrik
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set cbox1 -1
		set cbox2 -1
		set cbox3 -1
		set cbox4 -1

		set build_dummys [list 16 17 17 18 19 20 21 20 22 23]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsmetall unten_linksmetall unten_rechtsmetall unten_linksmetall unten_rechtsmetall unten_linksmetall oben_rechtsmetall oben_rechtsmetall unten_rechtsmetall unten_linksmetall}
		set damage_dummys {24 31}
	}
}


