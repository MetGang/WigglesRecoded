//# STOPIFNOT FULL
call scripts/misc/utility.tcl


def_class Waffenschmiede metal production 3 {} {

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
	        lappend rlst "prod_goworkdummy 4"
	        lappend rlst "prod_turnleft"
	        lappend rlst "prod_anim benda"
	     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 4 -0.7 0 0"
	        lappend rlst "prod_anim bendb"
		}

        foreach material $materiallist {
            if {[check_method [get_objclass this] "prod_actions_$material"]} {
                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
                lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
            } else {
            	log "WARNING: waffenschmiede.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }

	        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
        	 	lappend rlst "prod_goworkdummy 4"   ;// jedes Werkstück zur leeren Kiste bringen
            	lappend rlst "prod_turnleft"
            	lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
			}
        }

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
	        lappend rlst "prod_goworkdummy 4"		;// Kiste holen
    	    lappend rlst "prod_turnleft"
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


// Kohle

	method prod_actions_Kohle {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_hide_itemtype $itemtype"        ;// Kohle holen & verbrennen
        lappend rlst "prod_goworkdummy 2"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim benda"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 15"
        lappend rlst "prod_anim bendb"
        if {[random 0.5] > $exp_infl  &&  [random 1.0] > 0.9} {
			lappend rlst "prod_fireaccident 1"
        } else {
            lappend rlst "prod_goworkdummy 1"
            lappend rlst "prod_turnfront"
            lappend rlst "prod_waittime 1"
            lappend rlst "prod_call_method set_fireburst 1"
            lappend rlst "prod_anim impatient"
            lappend rlst "prod_waittime 2"
        }
        lappend rlst "prod_consume_from_workplace $itemtype"
        lappend rlst "prod_waittime 2"
        lappend rlst "prod_call_method set_fireburst 0"

		return $rlst
	}


// Pilzstamm

    method prod_actions_Pilzstamm {itemtype exp_infl} {
        if {[random 1.0] > 0.5 } {
            return [call_method this prod_actions_Kohle $itemtype $exp_infl]
        } else {
            set rlst [list]

            lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Pilzstamm holen
            set itemtype Halbzeug_holz
            lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
            lappend rlst "prod_goworkdummy 1"
            lappend rlst "prod_turnleft"
            lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 2"
            lappend rlst "prod_call_method set_chips 1; prod_call_method set_dust 1; prod_anim_loop_expinfl workholz 1 5 $exp_infl"
            if {[random 1.0] > 0.5} {
                lappend rlst "prod_itemtype_change_look $itemtype kant"
            } else {
                lappend rlst "prod_itemtype_change_look $itemtype brett"
            }
            lappend rlst "prod_anim_loop_expinfl workholz 1 5 $exp_infl"
            lappend rlst "prod_call_method set_chips 0; prod_call_method set_dust 0"
            lappend rlst "prod_walk_and_consume_itemtype $itemtype"

       		return $rlst
        }
    }


// Eisen

	method prod_actions_Eisen {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Eisen holen
        lappend rlst "prod_goworkdummy 2"
        lappend rlst "prod_turnback"
        lappend rlst "prod_machineanim waffenschmiede.anim"
        lappend rlst "prod_call_method set_steam 1"
        lappend rlst "prod_anim_loop_expinfl workmetall 2 6 $exp_infl"
        lappend rlst "prod_call_method set_steam 0"
        lappend rlst "prod_machineanim waffenschmiede.standard"
        lappend rlst "prod_turnfront"
        lappend rlst "prod_anim tired"

        return $rlst
    }


// Eisenerz

    method prod_actions_Eisenerz {itemtype exp_infl} {
        return [call_method this prod_actions_Eisen $itemtype $exp_infl]
    }


// Stein

    method prod_actions_Stein {itemtype exp_infl} {
        return [call_method this prod_actions_Eisen $itemtype $exp_infl]
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
		return 2								;// immer an dummy 2 forschen!
	}

    method set_fireburst {bool} {
    	if {$bool > 0} {
			change_particlesource this 0 3 {0 0 0} {0 0 0} 256 8 0 15
			change_particlesource this 1 6 {0 -1 0} {0 -0.1 0} 128 8 0 15
		} else {
			change_particlesource this 0 0 {0 0 0} {0 0 0} 256 1 0 15
			change_particlesource this 1 6 {0 -1 0} {0 -0.1 0} 128 1 0 15
		}
    }

    method set_steam {bool} {
		set_particlesource this 2 $bool
		set_particlesource this 3 $bool
		set_particlesource this 6 $bool
    }


	method set_dust {bool} {
		set_particlesource this 4 $bool
	}


	method set_chips {bool} {
		set_particlesource this 5 $bool
	}


	method deinit_production {} {
		call_method this set_steam 0
		call_method this set_dust  0
		call_method this set_chips 0
	}


    method init {} {
    	set_collision this 1
		set_inventoryslotuse this 1

		// Feuer und Rauch an der Feuerstelle
		change_particlesource this 0 0 {0 0 0} {0 0 0} 256 1 0 15
		set_particlesource this 0 1

		change_particlesource this 1 6 {0 -1 0} {0 -0.1 0} 128 1 0 15
		set_particlesource this 1 1

		change_light this [get_linkpos this 15] 4 "1 0.9 0.8"
		set_light this 1

		// Dampf für die Seiten

		change_particlesource this 2 11 {0 0 0} {-0.2 -0.2 0} 32 1 0 7
		change_particlesource this 3 11 {0 0 0} { 0.2 -0.2 0} 32 1 0 13
		change_particlesource this 6 11 {0 0 0} { 0 0 0} 32 1 0
		set_particlesource this 2 0
		set_particlesource this 3 0
		set_particlesource this 6 0

		change_particlesource this 4 19 {0 -0.1 0} {0.5 0.5 0.5} 64 4 0 2   ;// staub
		set_particlesource this 4 0
		change_particlesource this 5 26 {0 -0.1 0.2} {0 0 0} 64 1 0 2      	;// späne
		set_particlesource this 5 0
	}


	class_defaultanim waffenschmiede.standard
	class_flagoffset 2.0 1.2

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this waffenschmiede.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Waffenschmiede
		set_energyconsumption this $tttenergycons_Waffenschmiede
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 16 17 18 19 20 21 22]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsholz unten_linksholz oben_rechtsmetall oben_rechtsmetall oben_rechtsmetall unten_rechtsmetall unten_linksmetall}
		set damage_dummys {23 29}
	}
}


