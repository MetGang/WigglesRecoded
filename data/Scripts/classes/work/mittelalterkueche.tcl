call scripts/misc/utility.tcl

def_class Grillpilz_ 			food material 1 {} {}
def_class Grillhamster_ 		food material 1 {} {}
def_class Pilzbrot_ 			food material 1 {} {}
def_class Raupensuppe_ 			food material 1 {} {}
def_class Raupenschleimkuchen_ 	food material 1 {} {}
def_class Gourmetsuppe_ 		food material 1 {} {}
def_class Hamstershake_ 		food material 1 {} {}

def_class Mittelalterkueche wood production 0 {} {

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

		set itemclassname $item
		set item [string trim $item "_"]

		if {$item == "Feuerstelle"} {

	        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {			;// leere Kiste hinstellen
		        lappend rlst "prod_create_itemtype_ppinv_hidden Halbzeug_kiste"
		        lappend rlst "prod_go_near_workdummy 21 0 0 1"
		        lappend rlst "prod_turnright"
		        lappend rlst "prod_anim benda"
		     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 21 0.7 0 1"
		        lappend rlst "prod_anim bendb"
	    	    lappend rlst "prod_goworkdummy 0"
			}

			foreach material $materiallist {
			    if {[check_method [get_objclass this] "prod_actions_$material"]} {
			        set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl" "$item"]]
			        lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
			    } else {
			    	log "WARNING: mittelalterkueche.tcl: no prod_actions method for $material (calling prod_actions_default)"
			        set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl" "$item"]]
			    }
			    if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
				 	lappend rlst "prod_go_near_workdummy 21 0 0 1"   ;// jedes Werkstück zur leeren Kiste bringen
			    	lappend rlst "prod_turnright"
			    	lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
				}
			}
			
			if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
			    lappend rlst "prod_go_near_workdummy 21 0 0 1"		;// Kiste holen
			    lappend rlst "prod_turnright"
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
				for {set i 0} {$i < [call_method this prod_item_number2produce $item]} {incr i} {
			        lappend rlst "prod_createproduct_rndrot $item"
			    }
			}
			
			lappend rlst "prod_turnfront"
			lappend rlst "prod_anim tired"
			
			return $rlst
	
		}

		// sonst: normaler Kochvorgang

        foreach material $materiallist {
        	// die Materialien werden erst etwas später wirklich verbraucht, damit man sie bei einem
        	// frühen Abbruch noch wiederbekommt
        	lappend rlst "prod_walk_and_hide_itemtype $material"
		}

        lappend rlst "prod_goworkdummy 3"
        lappend rlst "prod_turnfront"
        lappend rlst "prod_anim hungry"
        lappend rlst "prod_turnback"
   		lappend rlst "prod_call_method set_smoke 1"
        if {[lsearch "Raupensuppe Gourmetsuppe" $item] != -1} {
			set itemtype "Halbzeug_topf"
	        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
	        lappend rlst "prod_anim puta"
	     	lappend rlst "prod_beam_itemtype_near_dummypos $itemtype 6 0 -0.65 0"
	        lappend rlst "prod_anim putb"
	        lappend rlst "prod_anim_loop_expinfl stir 2 15 $exp_infl"
	    } else {
			set itemtype "Halbzeug_pfanne"
	        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
	        lappend rlst "prod_anim puta"
	     	lappend rlst "prod_beam_itemtype_near_dummypos $itemtype 6 0 -0.7 -1"
	        lappend rlst "prod_anim putb"
			lappend rlst "prod_anim cookmiddleastart"
	        lappend rlst "prod_anim_loop_expinfl cookmiddlealoop 4 30 $exp_infl"
			lappend rlst "prod_anim cookmiddleastop"
    	}
    	if {[random 1.0] >$exp_infl} {
    		lappend rlst "prod_call_method set_smokeaccident 1"
    		lappend rlst "prod_anim shock"
	        lappend rlst "prod_anim_loop_expinfl cookmiddlealoop 4 15 $exp_infl"
			lappend rlst "prod_turnleft"
    		lappend rlst "prod_anim dontknow"
    		lappend rlst "prod_call_method set_smokeaccident 0"
	    	lappend rlst "prod_turnback"
    	}
    	lappend rlst "prod_anim puta"
    	lappend rlst "prod_consume_from_workplace $itemtype"
    	lappend rlst "prod_anim putb"

        foreach material $materiallist {
        	lappend rlst "prod_consume_from_workplace $material"
        }
        lappend rlst "prod_exp $exp_incr 1.0"
   		lappend rlst "prod_call_method set_smoke 0"

		lappend rlst "prod_goworkdummy 4"
		lappend rlst "prod_turnback"
		lappend rlst "prod_anim cookmiddlebstart"
		lappend rlst "prod_anim cookmiddlebstop"

        lappend rlst "prod_turnfront"
		lappend rlst "prod_anim tired"

		lappend rlst "prod_goworkdummy 2"
		for {set i 0} {$i < [call_method this prod_item_number2produce $itemclassname]} {incr i} {
	        lappend rlst "prod_createproduct_rndrot $item"
	    }

		return $rlst
	}
	
	// Pilzstamm

	method prod_actions_Pilzstamm {itemtype exp_infl production} {
		set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Pilzstamm holen
        set itemtype Halbzeug_holz
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
        lappend rlst "prod_go_near_workdummy 0 -0.7 0 0"
        lappend rlst "prod_turnright"
       	lappend rlst "prod_anim benda"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 0"
       	lappend rlst "prod_anim bendb"

       	lappend rlst "prod_anim workfloorholz"
   	    lappend rlst "prod_call_method set_chips 1; prod_call_method set_dust 1"
       	lappend rlst "prod_anim_loop_expinfl workfloorholz 1 4 $exp_infl"
   	    if {[random 1.0] > $exp_infl} {
	   	    lappend rlst "prod_call_method set_chips 0; prod_call_method set_dust 0"
			lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_anim dontknow"
	   	    lappend rlst "prod_call_method set_chips 1; prod_call_method set_dust 1"
			lappend rlst "prod_anim_loop_expinfl workfloorholz 1 2 $exp_infl"
   	    }
		if {[random 1.0] < 0.5} {
       		lappend rlst "prod_itemtype_change_look $itemtype kant"
		} else {
       		lappend rlst "prod_itemtype_change_look $itemtype half"
		}
       	lappend rlst "prod_anim_loop_expinfl workfloorholz 1 4 $exp_infl"
   	    lappend rlst "prod_call_method set_chips 0; prod_call_method set_dust 0"
        lappend rlst "prod_walk_and_consume_itemtype $itemtype"

		return $rlst
	}


// Stein

	method prod_actions_Stein {itemtype exp_infl production} {
		set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Stein holen
        set itemtype Halbzeug_stein
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
        lappend rlst "prod_go_near_workdummy 0 -0.7 0 0"
        lappend rlst "prod_turnright"
       	lappend rlst "prod_anim benda"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 0"
       	lappend rlst "prod_anim bendb"

       	lappend rlst "prod_anim workfloorstein"
   	    lappend rlst "prod_call_method set_dust 1"
       	lappend rlst "prod_anim_loop_expinfl workfloorstein 1 4 $exp_infl"
   	    if {[random 1.0] > $exp_infl} {
	   	    lappend rlst "prod_call_method set_dust 0"
			lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_anim dontknow"
	   	    lappend rlst "prod_call_method set_dust 1"
			lappend rlst "prod_anim_loop_expinfl workfloorstein 1 2 $exp_infl"
   	    }
   		lappend rlst "prod_itemtype_change_look $itemtype mauer"
       	lappend rlst "prod_anim_loop_expinfl workfloorstein 1 4 $exp_infl"
   	    lappend rlst "prod_call_method set_dust 0"
        lappend rlst "prod_walk_and_consume_itemtype $itemtype"

		return $rlst
	}


	method get_eat_objects {classlst} {
		return [get_eatobjects $classlst]
	}
	method get_certain_object {classname} {
		set item [obj_query this "-class $classname -range 8 -flagneg \{contained locked\} -limit 1"]
		if {[get_lock $item]} {log "Gefundenes Item Nr. $item ([get_objname $item]) war gelockt!"
		} {return $item}
	}
	method ask_for_seat {} {
		if {[prod_guest guestfree this]/$prod_guest_seats} {return 0} {return 1}
	}
	method reserve_seat {ref} {
		for {set i $prod_guest_seats} {$i<$prod_guest_waits} {incr i} {
			if {[prod_guest guestget this $i]==0} {
				prod_guest guestset this $i $ref
				return $i
			}
		}
		return 0
	}
	
	method get_dummy_rot {link} {
		return [lindex {4.71 1.57 3.14} $link]
	}
	
	method prod_get_invention_dummy {} {
		return 0								;// immer an dummy 0 forschen!
	}


	method set_smoke {bool} {
		if {$bool} {
			change_particlesource this 3 6 {0 0 0} {0 -0.1 0} 64 2 0 10         ;// Rauch
			set_particlesource this 3 1

		} else {
			free_particlesource this 3
		}
	}


	method set_smokeaccident {bool} {
		if {$bool} {
			change_particlesource this 4 6 {0 -0.7 0} {-0.3 0 0.2} 128 16 0 6	;// Rauch Kochunfall
			set_particlesource this 4 1
		} else {
			free_particlesource this 4
		}
	}
	
	method set_chips {bool} {
		if {$bool} {
			change_particlesource this 6 26 {0 -0.2 0.2} {0 0 0} 64 1 0 0      ;// späne
			set_particlesource this 6 1
		} else {
			free_particlesource this 6
		}
	}


	method set_dust {bool} {
		if {$bool} {
			change_particlesource this 5 19 {0 0 0.5} {0.5 0.5 0.5} 32 2 0 0   ;// staub
			set_particlesource this 5 1
		} else {
			free_particlesource this 5
		}
	}


	method deinit_production {} {
		call_method this set_smoke 0
		call_method this set_smokeaccident 0
		call_method this set_chips 0
		call_method this set_dust 0
	}


    method init {} {
    	set_collision this 1

		change_particlesource this 0 2 {0 -0.1 0.2} {0 0 0} 32 1 0 8		;// Fackel links
		set_particlesource this 0 1
		change_particlesource this 1 2 {0 -0.1 0.2} {0 0 0} 32 1 0 9		;// Fackel rechts
		set_particlesource this 1 1
		change_particlesource this 2 0 {0 -0.1 0} {0 0 0} 32 1 0 6			;// Feuerstelle
		set_particlesource this 2 1

		change_light this [get_linkpos this 6] 1 "1 0.9 0.8"
		set_light this 1
    }


	class_defaultanim mittel_kueche.standard
	class_flagoffset 1.8 2.5

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this mittel_kueche.standard 0 $ANIM_LOOP
		set standard_anim mittel_kueche.standard
		set_energyclass this $tttenergyclass_Mittelalterkueche
		set_energyconsumption this $tttenergycons_Mittelalterkueche
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		prod_guest addlink this 1
		prod_guest addlink this 2
		prod_guest addlink this 0
		set prod_guest_seats 3
		prod_guest addlink this 16
		prod_guest addlink this 17
		set prod_guest_waits 5

		set build_dummys [list 16 17 18 19 20 21 22]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_linksstein unten_rechtsholz oben_rechtsholz oben_rechtsholz oben_linksholz unten_rechtsholz oben_rechtsholz}
		set damage_dummys {23 30}

		proc get_eatobjects {classlst} {
			set rlst [list]
			foreach cn $classlst {
				set reflist [obj_query this "-class $cn -range 7 -flagneg \{contained locked\}"]
				if {$reflist!=0} {
					lappend rlst [llength $reflist]
				} else {
					lappend rlst 0
				}
			}
			return $rlst
		}

		sparetime this announce eat
	}
	
	obj_exit {
		sparetime this disannounce
	}
}

