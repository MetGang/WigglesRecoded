//# STOPIFNOT FULL
call scripts/misc/utility.tcl


def_class Schmelze metal production 2 {} {
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
	     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 5 0.5 0 0"
	        lappend rlst "prod_anim bendb"
		}

		// zuerst alle Pilzstämme & Kohlestücken
		foreach material $materiallist {
			if {$material == "Pilzstamm"  ||  $material == "Kohle"} {
	            if {[check_method [get_objclass this] "prod_actions_$material"]} {
	                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
					lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
   	    	     } else {
    	        	log "WARNING: Schmelze.tcl: no prod_actions method for $material (calling prod_actions_default)"
            	    set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
           		 }
           	}
		}

		lappend rlst "prod_goworkdummy 0"						;// Maschine einschalten
		lappend rlst "prod_turnback"
		lappend rlst "prod_anim kickmachine"
		lappend rlst "prod_machineanim schmelze.ani start"

		// dann den Rest
        foreach material $materiallist {
			if {$material != "Pilzstamm"  &&  $material != "Kohle"} {
            	if {[check_method [get_objclass this] "prod_actions_$material"]} {
                	set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
                	lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
            	} else {
            		log "WARNING: Schmelze.tcl: no prod_actions method for $material (calling prod_actions_default)"
                	set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            	}
		        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
    	    	 	lappend rlst "prod_goworkdummy 5"   ;// jedes Werkstück zur leeren Kiste bringen
        	    	lappend rlst "prod_turnright"
            		lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
				}
			}
        }

		lappend rlst "prod_goworkdummy 0"							;// Maschine ausschalten
		lappend rlst "prod_turnback"
		lappend rlst "prod_anim bend"
		lappend rlst "prod_machineanim schmelze.standard stop"
		lappend rlst "prod_anim bend"
		lappend rlst "prod_goworkdummy 2"
		lappend rlst "prod_turnfront"
		lappend rlst "prod_anim leftright"

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
        lappend rlst "prod_call_method set_firesize 0"
		lappend rlst "prod_anim tired"

		return $rlst
	}


// Pilzstamm

	method prod_actions_Pilzstamm {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"
        set itemtype Halbzeug_holz
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
        lappend rlst "prod_goworkdummy 4"
        lappend rlst "prod_turnleft"
        lappend rlst "prod_anim benda"
        lappend rlst "prod_beam_itemtype_near_dummypos $itemtype 4 -1.0 0 0"
        lappend rlst "prod_anim bendb"
        lappend rlst "prod_waittime [expr int(4 - ($exp_infl * 4))]"
        lappend rlst "prod_call_method set_firesize \"+1\""

        if {[random 0.5] > $exp_infl} {
			if {[random 1.0] > 0.9} {
				lappend rlst "prod_fireaccident 3"
			}
        }
        lappend rlst "prod_consume_from_workplace $itemtype"
        return $rlst
    }

// Eisenerz

	method prod_actions_Eisenerz {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_hide_itemtype $itemtype"

		lappend rlst "prod_goworkdummy 2"
		lappend rlst "prod_turnback"
		lappend rlst "prod_anim benda"
        lappend rlst "prod_beam_itemtype_near_dummypos $itemtype 4 -1.0 0 0"
		lappend rlst "prod_anim bendb"
		lappend rlst "prod_waittime 1"
		lappend rlst "prod_anim wait"
		lappend rlst "prod_anim_loop_expinfl workfloormetall 1 5 $exp_infl"
        lappend rlst "prod_consume_from_workplace $itemtype"
        return $rlst
    }

// Kohle

	method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Pilzstamm $itemtype $exp_infl]
	}

// default

	method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Eisenerz $itemtype $exp_infl]
	}


	// setzt die Größe des Feuers
	// 0 - klein bis 3 groß
	// oder: +1 und -1 für erhöhen und senken

	method set_firesize {newval} {
		global firesize

		// nur, wenn PS aufgebaut ist, sonst schaltet evtl. eine Kiste Partikel ein...
		if {[get_buildupstate this] == 0} {
			return
		}

		if {$newval == "+1"} {
			log "Feuer vergrößern"
			if {$firesize < 3} {incr firesize}
		} elseif {$newval == "-1"} {
			log "Feuer vergleinern"
			if {$firesize > 0} {set firesize [expr $firesize -1]}
		} else {
			set firesize $newval
		}

		switch $firesize {
		  1       {	change_particlesource this 1 6 {1.14 -3.5 0} {0 0 0} 256 8  0
					set_particlesource this 1 1
					change_particlesource this 0 3 {1.15 -0.2 0.5} {0 0 0} 128 2 0
					set_particlesource this 0 1
				  }
		  2       {	change_particlesource this 1 6 {1.14 -3.5 0} {0 0 0} 256 12 0
					set_particlesource this 1 1
					change_particlesource this 0 3 {1.15 -0.2 0.5} {0 0 0} 128 3 0
					set_particlesource this 0 1
				  }
		  3 	  {	change_particlesource this 1 6 {1.14 -3.5 0} {0 0 0} 256 16 0
					set_particlesource this 1 1
					change_particlesource this 0 3 {1.15 -0.2 0.5} {0 0 0} 128 4 0
					set_particlesource this 0 1
				  }
		  default { change_particlesource this 1 6 {1.14 -3.5 0} {0 0 0} 256 4 0
					set_particlesource this 1 1
					change_particlesource this 0 3 {1.15 -0.2 0.5} {0 0 0} 128 1 0
					set_particlesource this 0 1
				  }
		}
	}


	method activate_anim_timer {animname} {
		set anim_timer_active 1
		switch $animname {
			"schmelze.ani" {
				set anim_timer_action1 "blow_particlesource this 0 \{0.15 0 0\}"
				set anim_timer_action2 "blow_particlesource this 1 \{0.001 0.005 -0.002\}"
				timer_event this anim_timer1 -repeat 0 -attime [expr [gettime]+0.9]
				timer_event this anim_timer2 -repeat 0 -attime [expr [gettime]+1.5]
				set anim_timer_interval 1.5
			}
			default {log "no such animname for this wp"}
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
		call_method this set_firesize 0
	}


    method init {} {
    	global firesize
    	set_collision this 1

		change_particlesource this 0 3 {1.15 -0.2 0.5} {0 0 0} 128 1 0
		set_particlesource this 0 1
		change_particlesource this 1 6 {1.14 -3.5 0} {0 0 0} 256 4 0
		set_particlesource this 1 1

		change_light this {1.15 -0.2 0.5} 4 "1 0.9 0.8"
		set_light this 1

		set firesize 0
    }


	class_defaultanim schmelze.standard
	class_flagoffset 2.1 2.6

	obj_init {
		call scripts/misc/genericprod.tcl
		set_anim this schmelze.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Schmelze
		set_energyconsumption this $tttenergycons_Schmelze
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 12 13 14 15 16 17 18]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsstein unten_rechtsstein unten_linksstein oben_rechtsholz oben_rechtsholz oben_linksholz oben_linksholz}
		set damage_dummys {20 28}
	}
}

