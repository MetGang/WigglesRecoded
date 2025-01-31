call scripts/misc/utility.tcl

def_class Grillpilz__ 				food material 1 {} {}
def_class Grillhamster__ 			food material 1 {} {}
def_class Pilzbrot__ 				food material 1 {} {}
def_class Raupensuppe__ 			food material 1 {} {}
def_class Raupenschleimkuchen__ 	food material 1 {} {}
def_class Gourmetsuppe__ 			food material 1 {} {}
def_class Hamstershake__ 			food material 1 {} {}

def_class Industriekueche wood production 0 {} {

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

        foreach material $materiallist {
        	// die Materialien werden erst etwas später wirklich verbraucht, damit man sie bei einem
        	// frühen Abbruch noch wiederbekommt
        	lappend rlst "prod_walk_and_hide_itemtype $material"
		}

        lappend rlst "prod_goworkdummy 9"
        lappend rlst "prod_turnfront"
        lappend rlst "prod_anim hungry"
        lappend rlst "prod_turnback"
   		lappend rlst "prod_call_method set_smoke 1"
        if {[lsearch "Raupensuppe Gourmetsuppe" $item] != -1} {
	        lappend rlst "prod_anim_loop_expinfl stir 2 15 $exp_infl"
	    } else {
			lappend rlst "prod_anim cookindustastart"
	        lappend rlst "prod_anim_loop_expinfl cookindustaloop 4 30 $exp_infl"
			lappend rlst "prod_anim cookindustastop"
    	}
    	if {[random 1.0] >$exp_infl} {
    		lappend rlst "prod_call_method set_smokeaccident 1"
    		lappend rlst "prod_anim shock"
	        lappend rlst "prod_anim_loop_expinfl cookindustaloop 4 15 $exp_infl"
			lappend rlst "prod_turnleft"
    		lappend rlst "prod_anim dontknow"
    		lappend rlst "prod_call_method set_smokeaccident 0"
	    	lappend rlst "prod_turnback"
    	}

        foreach material $materiallist {
        	lappend rlst "prod_consume_from_workplace $material"
        }
        lappend rlst "prod_exp $exp_incr 1.0"
   		lappend rlst "prod_call_method set_smoke 0"

		lappend rlst "prod_goworkdummy 7"
		lappend rlst "prod_turnback"
		lappend rlst "prod_anim cookindustbstart"
        lappend rlst "prod_anim_loop_expinfl cookindustbloop 4 8 $exp_infl"
		lappend rlst "prod_anim cookindustbstop"

        lappend rlst "prod_turnfront"
		lappend rlst "prod_anim tired"

		lappend rlst "prod_goworkdummy 19"
		for {set i 0} {$i < [call_method this prod_item_number2produce $itemclassname]} {incr i} {
	        lappend rlst "prod_createproduct_rndrot $item \{[vector_add [get_linkpos this 19] {0.5 0 2}]\}"
	    }

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
		if {$link>2} {
			return 3.14
		} else {
			return 0.0
		}
	}
	

	method set_smoke {bool} {
		set_particlesource this 0 $bool
	}


	method set_smokeaccident {bool} {
		set_particlesource this 1 $bool
	}



	method deinit_production {} {
		call_method this set_smoke 0
		call_method this set_smokeaccident 0
	}


    method init {} {
    	set_collision this 1

		change_particlesource this 0 6 {0 0 0} {0 -0.1 0} 64 2 0 8         ;// Rauch
		set_particlesource this 0 0
		change_particlesource this 1 6 {0 -0.7 -1.5} {0.3 0 0.2} 128 16 0 9	;// Rauch Kochunfall
		set_particlesource this 1 0

		change_particlesource this 2 2 {0 -0.1 0.2} {0 0 0} 32 1 0 12		;// Fackel
		set_particlesource this 2 1
		change_particlesource this 3 2 {0 -0.1 0.2} {0 0 0} 32 1 0 13		;// Fackel
		set_particlesource this 3 1
		change_particlesource this 4 2 {0 -0.1 0.2} {0 0 0} 32 1 0 14		;// Fackel
		set_particlesource this 4 1
		change_particlesource this 5 2 {0 -0.1 0.2} {0 0 0} 32 1 0 15		;// Fackel
		set_particlesource this 5 1
    }


	class_defaultanim indust_kueche.standard
	class_flagoffset 2.5 3.8

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this indust_kueche.standard 0 $ANIM_STILL
		set standard_anim indust_kueche.standard
		set_energyclass this $tttenergyclass_Industriekueche
		set_energyconsumption this $tttenergycons_Industriekueche
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		prod_guest addlink this 6
		prod_guest addlink this 5
		prod_guest addlink this 4
		prod_guest addlink this 1
		prod_guest addlink this 2
		prod_guest addlink this 3
		set prod_guest_seats 3
		prod_guest addlink this 0
		prod_guest addlink this 17
		set prod_guest_waits 8

		set build_dummys [list 16 17 18 19 20 21 22]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsstein unten_linksstein oben_linksstein unten_linksstein oben_rechtsstein unten_rechtsstein unten_rechtsstein}
		set damage_dummys {21 30}

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

