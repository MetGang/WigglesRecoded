//# STOPIFNOT FULL
call scripts/misc/utility.tcl


def_class Dampfhammer metal production 2 {} {

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
	        lappend rlst "prod_go_near_workdummy 3 2.2 0 0"
	        lappend rlst "prod_turnleft"
	        lappend rlst "prod_anim benda"
	     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 3 1.5 0 0"
	        lappend rlst "prod_anim bendb"
		}

        foreach material $materiallist {
            if {[check_method [get_objclass this] "prod_actions_$material"]} {
                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
                lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
            } else {
            	log "WARNING: dampfhammer.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }
	        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1  &&  [lsearch "Pilzstamm Kohle" $material] == -1} {
        	 	lappend rlst "prod_go_near_workdummy 3 2.2 0 0"   ;// jedes Werkstück zur leeren Kiste bringen
            	lappend rlst "prod_turnleft"
            	lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
			}
        }

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
	        lappend rlst "prod_go_near_workdummy 3 2.2 0 0"		;// Kiste holen
    	    lappend rlst "prod_turnleft"
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

        lappend rlst "prod_turnfront"
		lappend rlst "prod_anim impatient"

		return $rlst
	}


// Eisen

	method prod_actions_Eisen {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        	;// Eisen holen
		set itemtype Halbzeug_eisen
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"

        lappend rlst "prod_goworkdummy 1"								;// plazieren
        lappend rlst "prod_turnback"
   	    lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 13"

    	lappend rlst "prod_changetool Hammer"            			 	;// rumhämmern
    	lappend rlst "prod_anim hammerstart"
    	lappend rlst "prod_anim_loop_expinfl hammerloopmetall 1 5 $exp_infl"
    	lappend rlst "prod_anim hammerend"
    	lappend rlst "prod_changetool 0"

    	lappend rlst "prod_go_near_workdummy 1 1 0 0"
    	lappend rlst "prod_turnback"
    	lappend rlst "prod_anim kickmachine"                         	;// Dampfhammer an
    	if {[random 1.0] > $exp_infl} {
    		lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_turnright"
			lappend rlst "prod_anim dontknow"
			lappend rlst "prod_turnback"
			lappend rlst "prod_anim kickmachine"
    	}
        lappend rlst "prod_machineanim dampfhammer.ani start"
        lappend rlst "prod_call_method dust 1"

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim_loop_expinfl workmetall 1 5 $exp_infl"
    	if {[random 1.0] > $exp_infl} {
        	lappend rlst "prod_anim kontrol"
        	lappend rlst "prod_anim scratchhead"
	    	lappend rlst "prod_changetool Hammer"            			 	;// rumhämmern
    		lappend rlst "prod_anim hammerstart"
    		lappend rlst "prod_anim_loop_expinfl hammerloopmetall 1 5 $exp_infl"
	    	lappend rlst "prod_anim hammerend"
    		lappend rlst "prod_changetool 0"
		}

    	lappend rlst "prod_go_near_workdummy 1 1 0 0"
    	lappend rlst "prod_turnback"
    	lappend rlst "prod_anim kickmachine"                         	;// Dampfhammer aus
        lappend rlst "prod_call_method dust 0"
        lappend rlst "prod_machineanim dampfhammer.standard stop"

    	lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"

    	lappend rlst "prod_anim puta"									;// Werkstück abkühlen
    	lappend rlst "prod_hide_itemtype $itemtype"
    	lappend rlst "prod_anim putb"
    	lappend rlst "prod_goworkdummy 0"
    	lappend rlst "prod_turnleft"

    	lappend rlst "prod_beam_itemtype_near_dummypos $itemtype 14 0 -0.1 0"
    	lappend rlst "prod_call_method smoke 1"
    	lappend rlst "prod_waittime 2"
    	lappend rlst "prod_call_method smoke 0"
    	lappend rlst "prod_anim puta"
    	lappend rlst "prod_consume_from_workplace $itemtype"
		lappend rlst "prod_anim putb"

		return $rlst
	}



// Stein

	method prod_actions_Stein {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        	;// Stein holen
		set itemtype Halbzeug_stein
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"

        lappend rlst "prod_goworkdummy 1"								;// plazieren
        lappend rlst "prod_turnback"
   	    lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 13"

    	lappend rlst "prod_changetool Hammer"            			 	;// rumhämmern
    	lappend rlst "prod_anim hammerstart"
    	lappend rlst "prod_anim_loop_expinfl hammerloopmetall 1 5 $exp_infl"
    	lappend rlst "prod_anim hammerend"
    	lappend rlst "prod_changetool 0"

    	lappend rlst "prod_go_near_workdummy 1 1 0 0"
    	lappend rlst "prod_turnback"
    	lappend rlst "prod_anim kickmachine"                         	;// Dampfhammer an
    	if {[random 1.0] > $exp_infl} {
    		lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_turnright"
			lappend rlst "prod_anim dontknow"
			lappend rlst "prod_turnback"
			lappend rlst "prod_anim kickmachine"
    	}
        lappend rlst "prod_machineanim dampfhammer.ani start"
        lappend rlst "prod_call_method dust 1"

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim_loop_expinfl workstein 1 5 $exp_infl"
    	if {[random 1.0] > $exp_infl} {
        	lappend rlst "prod_anim kontrol"
        	lappend rlst "prod_anim scratchhead"
	    	lappend rlst "prod_changetool Hammer"            			 	;// rumhämmern
    		lappend rlst "prod_anim hammerstart"
    		lappend rlst "prod_anim_loop_expinfl hammerloopstein 1 5 $exp_infl"
	    	lappend rlst "prod_anim hammerend"
    		lappend rlst "prod_changetool 0"
		}

    	lappend rlst "prod_go_near_workdummy 1 1 0 0"
    	lappend rlst "prod_turnback"
    	lappend rlst "prod_anim kickmachine"                         	;// Dampfhammer aus
        lappend rlst "prod_call_method dust 0"
        lappend rlst "prod_machineanim dampfhammer.standard stop"

    	lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"

    	lappend rlst "prod_anim puta"									;// Werkstück abkühlen
    	lappend rlst "prod_hide_itemtype $itemtype"
    	lappend rlst "prod_anim putb"

		return $rlst
	}


// Kristall

	method prod_actions_Kristall {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_hide_itemtype $itemtype"        	;// Kristall holen

        lappend rlst "prod_goworkdummy 1"								;// plazieren
        lappend rlst "prod_turnback"
   	    lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 13"

    	lappend rlst "prod_changetool Hammer"            			 	;// rumhämmern
    	lappend rlst "prod_anim hammerstart"
    	lappend rlst "prod_anim_loop_expinfl hammerloopmetall 1 5 $exp_infl"
    	lappend rlst "prod_anim hammerend"
    	lappend rlst "prod_changetool 0"

    	lappend rlst "prod_go_near_workdummy 1 1 0 0"
    	lappend rlst "prod_turnback"
    	lappend rlst "prod_anim kickmachine"                         	;// Dampfhammer an
    	if {[random 1.0] > $exp_infl} {
    		lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_turnright"
			lappend rlst "prod_anim dontknow"
			lappend rlst "prod_turnback"
			lappend rlst "prod_anim kickmachine"
    	}
        lappend rlst "prod_machineanim dampfhammer.ani start"
        lappend rlst "prod_call_method dust 1"

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim_loop_expinfl workmetall 1 5 $exp_infl"
    	if {[random 1.0] > $exp_infl} {
        	lappend rlst "prod_anim kontrol"
        	lappend rlst "prod_anim scratchhead"
	    	lappend rlst "prod_changetool Hammer"            			 	;// rumhämmern
    		lappend rlst "prod_anim hammerstart"
    		lappend rlst "prod_anim_loop_expinfl hammerloopmetall 1 5 $exp_infl"
	    	lappend rlst "prod_anim hammerend"
    		lappend rlst "prod_changetool 0"
		}

    	lappend rlst "prod_go_near_workdummy 1 1 0 0"
    	lappend rlst "prod_turnback"
    	lappend rlst "prod_anim kickmachine"                         	;// Dampfhammer aus
        lappend rlst "prod_call_method dust 0"
        lappend rlst "prod_machineanim dampfhammer.standard stop"

    	lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"

    	lappend rlst "prod_anim puta"									;// Werkstück abkühlen
    	lappend rlst "prod_hide_itemtype $itemtype"
    	lappend rlst "prod_anim putb"
    	lappend rlst "prod_consume_from_workplace $itemtype"
       	lappend rlst "prod_turnleft"

		return $rlst
	}


// Kohle

	method prod_actions_Kohle {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_hide_itemtype $itemtype"        ;// Kohle holen

        lappend rlst "prod_go_near_workdummy 9 0 0 1.2"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim benda"
   	    lappend rlst "prod_beam_itemtype_near_dummypos $itemtype 9 0 0 0.3"
        lappend rlst "prod_anim bendb"
        lappend rlst "prod_go_near_workdummy 9 -1 0 1.2"
        lappend rlst "prod_turnclock 2"

    	lappend rlst "prod_waittime 1"
    	lappend rlst "prod_call_method fireburst 1"
    	lappend rlst "prod_waittime 2"
    	if {[random 0.5] > $exp_infl} {
    		if {[random 1.0] > 0.9} {
    			lappend rlst "prod_fireaccident 6"
    		}
    	}
	   	lappend rlst "prod_consume_from_workplace $itemtype"
    	lappend rlst "prod_waittime 1"
        lappend rlst "prod_call_method fireburst 0"

		return $rlst
	}


// Pilzstamm

    method prod_actions_Pilzstamm {itemtype exp_infl} {
        return [call_method this prod_actions_Kohle $itemtype $exp_infl]
    }


// default

	method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Eisen $itemtype $exp_infl]
	}



	method prod_get_invention_dummy {} {
		return 1								;// immer an dummy 1 forschen!
	}


    method fireburst {on} {
		if {$on == 1} {
			change_particlesource this 0 3 {0 0 0} {0 -0.03 0} 256 8 0 9
			change_particlesource this 1 6 {0 -1 0} {0 -0.1 0} 128 8 0 9
        } else {
			change_particlesource this 0 0 {0 0 0} 	{0 0 0} 	256 4 	0 9
			change_particlesource this 1 6 {0 -1 0} {0 -0.1 0} 	128 1 	0 9
		}
    }


    method smoke {on} {
		set_particlesource this 2 $on
    }


    method sparks {on} {
		set_particlesource this 3 $on
		set_particlesource this 4 $on
    }


    method dust {on} {
		set_particlesource this 5 $on
    }


	method activate_anim_timer {animname} {
		set anim_timer_active 1
		switch $animname {
			"dampfhammer.ani" {
				set anim_timer_action1 "set_particlesource this 3 5; set_particlesource this 4 5"
				set anim_timer_action2 "set_particlesource this 3 5; set_particlesource this 4 5"
				timer_event this anim_timer1 -repeat 0 -attime [expr [gettime]+1.6]
				timer_event this anim_timer2 -repeat 0 -attime [expr [gettime]+3.7]
				set anim_timer_interval 3.9
			}
			default {log "no such animname for this productionplace: $animname"}
		}
	}
	method stop_anim_timer {} {
		set anim_timer_active 0
	}
	def_event anim_timer1
	handle_event anim_timer1 {
		if {$anim_timer_active} {
			eval $anim_timer_action1
//			log "anim_action now1"
			timer_event this anim_timer1 -repeat 0 -attime [expr [gettime]+$anim_timer_interval]
		}
	}
	def_event anim_timer2
	handle_event anim_timer2 {
		if {$anim_timer_active} {
			eval $anim_timer_action2
//			log "anim_action now2"
			timer_event this anim_timer2 -repeat 0 -attime [expr [gettime]+$anim_timer_interval]
		}
	}


	method deinit_production {} {
		call_method this dust 0
		call_method this sparks 0
		call_method this fireburst 0
		call_method this smoke 0
	}


    method init {} {
    	set_collision this 1

		change_particlesource this 0 0 {0 0 0} 	{0 0 0} 	256 4 	0 9
		change_particlesource this 1 6 {0 -1 0} {0 -0.1 0} 	128 1 	0 9
		set_particlesource this 0 1
		set_particlesource this 1 1

		change_particlesource this 2 6 {0 0 0} {0 -0.1 0} 128 16 0 14     		;// Rauch Bottich
        set_particlesource this 2 0

		change_particlesource this 3 18 {0 0 0} {0.05 -0.04 0}  64 32 0 13     	;// Funken Amboss
		change_particlesource this 4 18 {0 0 0} {-0.05 -0.04 0} 64 32 0 13
        set_particlesource this 3 0
        set_particlesource this 4 0

		change_particlesource this 5 19 {0 0 0.5} {0.5 0.5 0.5} 32 4 0 13  		;// staub auf Amboss
		set_particlesource this 5 0

		change_light this [get_linkpos this 9] 4 "1 0.9 0.8"
		set_light this 1
    }

	class_defaultanim dampfhammer.standard
	class_flagoffset 2.8 3.5

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this dampfhammer.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Dampfhammer
		set_energyconsumption this $tttenergycons_Dampfhammer
        set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 12 13 14 15 16 17 18]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsstein unten_linksstein oben_rechtsmetall unten_rechtsstein oben_rechtsmetall oben_linksholz oben_linksholz}
		set damage_dummys {20 29}
	}
}

