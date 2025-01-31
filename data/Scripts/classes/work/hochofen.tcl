//# STOPIFNOT FULL
call scripts/misc/utility.tcl

def_class Eisen_ metal material 1 {} {}

def_class Hochofen metal production 3 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 2.0

	method prod_item_actions item {
		global current_worker BOXED_CLASSES
		set exp_incr [call_method this prod_item_exp_incr $item]
		set exp_infls [call_method this prod_item_exp_infl $item]
		set exp_infl [prod_getgnomeexper $current_worker $exp_infls]
		set materiallist [call_method this prod_item_materials $item]
		set numtoproduce [call_method this prod_item_number2produce $item]
		set rlst [list]

		if {$item == "Eisen_"} {
			set item Eisen
		}


		// zuerst die gesamte Kohle

        foreach material $materiallist {
			if {$material == "Kohle"} {
        	    if {[check_method [get_objclass this] "prod_actions_$material"]} {
    	            set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
	                lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
           		} else {
        	    	log "WARNING: Hochofen.tcl: no prod_actions method for $material (calling prod_actions_default)"
    	            set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
	            }
            }
        }

        // jetzt den Rest, vorher die Offenklappe aufmachen

		lappend rlst "prod_goworkdummy 1"
		lappend rlst "prod_turnback"
		lappend rlst "prod_anim pressbutton"
       	lappend rlst "prod_machineanim hochofen.tuer_oeffnen once"
       	lappend rlst "prod_waittime 1.3"
       	lappend rlst "prod_machineanim	hochofen.tuer_auf"

        foreach material $materiallist {
        	if {$material != "Kohle"} {
	            if {[check_method [get_objclass this] "prod_actions_$material"]} {
    	            set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
        	        lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
	            } else {
            		log "WARNING: Hochofen.tcl: no prod_actions method for $material (calling prod_actions_default)"
        	        set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
    	        }
			}
        }

		// Klappe zu

		lappend rlst "prod_goworkdummy 1"
		lappend rlst "prod_turnback"
		lappend rlst "prod_anim pressbutton"
       	lappend rlst "prod_machineanim hochofen.tuer_schliess once"
       	lappend rlst "prod_goworkdummy 2"					;// Maschinen an
       	lappend rlst "prod_turnback"
       	lappend rlst "prod_anim kickmachine"
       	lappend rlst "prod_machineanim hochofen.anim"
       	lappend rlst "prod_call_method set_smoke 1; prod_call_method set_steam 1"

		// jetzt heißt es warten

		set i [expr int (4 * (1.0 - $exp_infl))]
		log "Hochofen: $i Wartezyklen"
		while {$i > 0} {
			if {[random 1.0] > 0.5} {
				lappend rlst "prod_goworkdummy 2"
			} else {
				lappend rlst "prod_goworkdummy 0"
			}
			lappend rlst "prod_anim wait"
			lappend rlst "prod_goworkdummy 1"
			lappend rlst "prod_turnback"
			set i [expr $i - 1]
			if {$i != 0} {
				lappend rlst "prod_turnright"
				lappend rlst "prod_anim dontknow"
			}
		}

       	lappend rlst "prod_goworkdummy 2"						;// Maschinen aus
       	lappend rlst "prod_turnback"
       	lappend rlst "prod_anim kickmachine"
       	lappend rlst "prod_machineanim hochofen.standard"
       	lappend rlst "prod_call_method set_smoke 0; prod_call_method set_steam 0"


		lappend rlst "prod_goworkdummy 0"						;// oder das Metall in die Wanne lassen
		lappend rlst "prod_turnright"
		lappend rlst "prod_anim pullrope"
       	lappend rlst "prod_machineanim hochofen.rad_dreh"		;// Seil gezogen
		lappend rlst "prod_call_method set_melting 1; prod_call_method set_steam 1"
		lappend rlst "prod_create_itemtype_ppinv_hidden Halbzeug_eisen; prod_beam_itemtype_to_dummypos Halbzeug_eisen 12"
		if {$item == "Eisen"} {
			lappend rlst "prod_itemtype_change_look Halbzeug_eisen roh"
		} elseif {$item == "Gold"} {
			lappend rlst "prod_itemtype_change_look Halbzeug_eisen gold"
		}
       	lappend rlst "prod_goworkdummy 0"						;// Maschinen aus
		lappend rlst "prod_turnback"
       	lappend rlst "prod_machineanim hochofen.standard"
		lappend rlst "prod_call_method set_melting 0; prod_call_method set_steam 0"
		lappend rlst "prod_anim_loop_expinfl wait 1 3 $exp_infl"
		lappend rlst "prod_anim puta"							;// fertiges Metall abholen
        lappend rlst "prod_consume_from_workplace Halbzeug_eisen"
		lappend rlst "prod_goworkdummy 1"

		for {set i 0} {$i < $numtoproduce} {incr i} {
		    lappend rlst "prod_createproduct_rndrot $item"
		}
		    
		lappend rlst "prod_anim tired"

		return $rlst
	}


// Eisenerz

	method prod_actions_Eisenerz {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Eisen holen
		lappend rlst "prod_goworkdummy 1"
		lappend rlst "prod_turnback"
		lappend rlst "prod_anim put"
        return $rlst
    }


// Kohle

	method prod_actions_Kohle {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Kohle holen & verfeuern
		lappend rlst "prod_go_near_workdummy 1 0 0 -0.5"
		lappend rlst "prod_turnback"
		if {[random 1.0] > $exp_infl} {
			lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_anim warmhands"
		}
		lappend rlst "prod_anim bend"
		lappend rlst "prod_anim_loop_expinfl workfloorholz 1 3 $exp_infl"
		if {[random 0.5] > $exp_infl} {
			if {[random 1.0] > 0.9} {
				lappend rlst "prod_fireaccident 1"
			}
		}
        return $rlst
    }


// Golderz

	method prod_actions_Golderz {itemtype exp_infl} {
        return [call_method this prod_actions_Eisenerz $itemtype $exp_infl]
	}


// default

	method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Eisenerz $itemtype $exp_infl]
	}


	method deinit_production {} {
		call_method this set_steam 0
		call_method this set_smoke 0
		call_method this set_melting 0
	}


	method set_steam {bool} {
		set_particlesource this 1 $bool
		set_particlesource this 2 $bool
	}

	method set_smoke {bool} {
		set_particlesource this 3 $bool
	}


	method set_melting {bool} {
		if {$bool == 1} {
			set_particlesource this 5 5
		}
		set_particlesource this 4 $bool
	}


    method init {} {
    	set_collision this 1

		change_particlesource this 0 0 {0 0 0.15} {0 0 0} 32 1 0 15			;// Feuer
		set_particlesource this 0 1
		change_particlesource this 1 11 {0 0 0} {0 0 0} 32 1 0 14			;// Dampf Ventil
		set_particlesource this 1 0
		change_particlesource this 2 11 {0 0 0} {0 0 0} 32 1 0 11			;// Dampf Ventil
		set_particlesource this 2 0
		change_particlesource this 3 6 {0 0 0} {0 0 0} 128 64 0 13			;// Rauch Schornstein
		set_particlesource this 3 0
		change_particlesource this 4 11 {0 0 0} {0 0 0} 32 1 0 12			;// Dampf Wanne
		set_particlesource this 4 0
		change_particlesource this 5 3 {0 0 0} {0 0 0} 32 32 0 12			;// Feuer beim Schmelzen in der Wanne
		set_particlesource this 5 0
    }


	class_defaultanim hochofen.standard
	class_flagoffset 2.1 3.8

	obj_init {
		call scripts/misc/genericprod.tcl
		
		set_anim this hochofen.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Hochofen
		set_energyconsumption this $tttenergycons_Hochofen
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 16 17 18 19 20 21 22 23]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {oben_rechtsstein oben_rechtsmetall unten_linksmetall oben_linksmetall unten_rechtsmetall unten_linksmetall oben_rechtsmetall unten_linksstein unten_rechtsmetall}
		set damage_dummys {23 29}

	}
}


