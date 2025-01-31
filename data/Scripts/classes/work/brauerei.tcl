call scripts/misc/utility.tcl


def_class Brauerei wood production 1 {} {

	class_fightdist 2.0

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	method prod_item_actions item {
		global current_worker BOXED_CLASSES
		set exp_incr [call_method this prod_item_exp_incr $item]
		set exp_infls [call_method this prod_item_exp_infl $item]
		set exp_infl [prod_getgnomeexper $current_worker $exp_infls]
		set materiallist [call_method this prod_item_materials $item]
		set rlst [list]

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {			;// leere Kiste hinstellen
	        lappend rlst "prod_create_itemtype_ppinv_hidden Halbzeug_kiste"
	        lappend rlst "prod_goworkdummy 6"
	        lappend rlst "prod_turnleft"
	        lappend rlst "prod_anim benda"
	     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 6 -0.5 0 0"
	        lappend rlst "prod_anim bendb"
    	    lappend rlst "prod_goworkdummy 1"
		}

        foreach material $materiallist {
            if {[check_method [get_objclass this] "prod_actions_$material"]} {
                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
                lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
            } else {
            	log "WARNING: Brauerei.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }
	        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
        	 	lappend rlst "prod_goworkdummy 6"   ;// jedes Werkstück zur leeren Kiste bringen
            	lappend rlst "prod_turnleft"
            	lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
			}
        }

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
	        lappend rlst "prod_goworkdummy 6"		;// Kiste holen
    	    lappend rlst "prod_turnleft"
    	    lappend rlst "prod_anim puta"
   	    	lappend rlst "prod_createproduct_inv_boxed $item; prod_itemtype_change_look Halbzeug_kiste geschlossen"
	        lappend rlst "prod_anim putb"
       		lappend rlst "prod_anim takeboxa"
       		lappend rlst "prod_itemtype_change_look Halbzeug_kiste tragen; prod_link_itemtype_to_hand Halbzeug_kiste"
            lappend rlst "prod_anim takeboxb"
 			lappend rlst "prod_goworkdummy_with_box 1"
			lappend rlst "prod_createproduct_box_with_dummybox $item"
		} else {
			lappend rlst "prod_goworkdummy 1"
	        lappend rlst "prod_createproduct_rndrot $item"
			if {$item=="Bier"} {
	        	lappend rlst "prod_createproduct_rndrot $item"
	        }
        }

        lappend rlst "prod_turnfront"
		lappend rlst "prod_anim tired"

		return $rlst
	}


// Pilzhut

	method prod_actions_Pilzhut {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Pilzstamm holen
		lappend rlst "prod_goworkdummy 1"

        set rnd [random 3.0]
        if {$rnd < 1} {
            lappend rlst "prod_turnback"
        } elseif {$rnd < 2} {
            lappend rlst "prod_goworkdummy 0"
            lappend rlst "prod_goworkdummy 3"
            lappend rlst "prod_turnright"
        } else {
    	    lappend rlst "prod_goworkdummy 13"
    	    lappend rlst "prod_goworkdummy 2"
    	    lappend rlst "prod_turnleft"
    	}

		lappend rlst "prod_anim put"
		lappend rlst "prod_anim stirstart"
        lappend rlst "prod_anim_loop_expinfl stirloop 3 15 $exp_infl"
		lappend rlst "prod_anim stirstop"

		if {[random 1.0] > $exp_infl} {
			lappend rlst "prod_goworkdummy 1"
			lappend rlst "prod_turnfront"
			lappend rlst "prod_anim hungry"
		}

		return $rlst
	}


	method prod_actions_Pilzstamm {itemtype exp_infl} {
		set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Pilzstamm holen
        set itemtype Halbzeug_holz
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnright"

       	lappend rlst "prod_anim benda"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 4"
       	lappend rlst "prod_anim bendb"

		lappend rlst "prod_call_method set_chips 1; prod_call_method set_dust 1"		;// zu Brett verarbeiten
        lappend rlst "prod_anim_loop_expinfl workfloorholz 1 6 $exp_infl"
        lappend rlst "prod_itemtype_change_look $itemtype brett"
        lappend rlst "prod_anim_loop_expinfl workfloorholz 1 6 $exp_infl"
		lappend rlst "prod_call_method set_chips 0; prod_call_method set_dust 0"
        lappend rlst "prod_walk_and_consume_itemtype $itemtype"

		return $rlst
	}


// Raupe

    method prod_actions_Raupe {itemtype exp_infl} {
        return [call_method this prod_actions_Pilzhut $itemtype $exp_infl]
    }


// default

    method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Pilzhut $itemtype $exp_infl]
    }


	method prod_get_invention_dummy {} {
		return 1								;// immer an dummy 1 forschen!
	}


	method set_dust {value} {
		set_particlesource this 4 $value
	}

	method set_chips {value} {
		set_particlesource this 5 $value
	}


	method deinit_production {} {
		call_method this set_chips 0
		call_method this set_dust  0
	}


    method init {} {
    	set_collision this 1

		change_particlesource this 0 0 {0 0 0} 		{0 0 0} 	32 	1 	0 9
		change_particlesource this 1 6 {0 -0.5 0} 	{0 0 0} 	255 16 	0 10
		change_particlesource this 2 6 {0 -0.6 0} 	{0 0 0} 	32 	2 	0 8
		change_particlesource this 3 11 {0 -0.3 0} 	{0 0 0} 	255	16 	0 11 2
		set_particlesource this 0 1
		set_particlesource this 1 1
		set_particlesource this 2 1
		set_particlesource this 3 1

		change_particlesource this 4 19 {0 0 0.5} {0.5 0.5 0.5} 32 2 0 4   ;// Staub auf dem Boden
		set_particlesource this 4 0
		change_particlesource this 5 26 {0 -0.1 0.2} {0 0 0} 64 1 0 4      ;// späne auf dem Boden
		set_particlesource this 5 0
    }


	class_defaultanim brauerei.standard
	class_flagoffset 1.8 1.5

	obj_init {
		call scripts/misc/genericprod.tcl
		
		set_anim this brauerei.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Brauerei
		set_energyconsumption this $tttenergycons_Brauerei
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 12 13 14 15 16 17 18]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_linksholz unten_rechtsholz unten_rechtsholz oben_rechtsholz oben_linksholz oben_rechtsholz unten_rechtsholz}
		set damage_dummys {20 28}
	}
}


