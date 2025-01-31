//# STOPIFNOT FULL
call scripts/misc/utility.tcl


def_class Kristallschmiede stone production 4 {} {
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
	        lappend rlst "prod_turnright"
	        lappend rlst "prod_anim benda"
	     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 3 0.7 0 0"
	        lappend rlst "prod_anim bendb"
		}

        foreach material $materiallist {
    		lappend rlst "prod_goworkdummy 11"
    		lappend rlst "prod_turnback"

           	lappend rlst "prod_anim pressbutton"						;// Zum Kran laufen, Knopf drücken
           	if {$exp_infl < 0.5  &&  [random 1.0] < 0.2} {				;// Knopf drücken klappt nicht immer
           	    lappend rlst "prod_anim wait"
           	    lappend rlst "prod_anim scratchhead"
           	    lappend rlst "prod_anim kickmachine"
           	}

           	lappend rlst "prod_machineanim kristallschmiede.heben_runter once"
           	lappend rlst "prod_waittime 1"
           	lappend rlst "prod_machineanim kristallschmiede.heben_unten"
           	lappend rlst "prod_link_itemtype_to_dummy $material 30" 	;// item an den Kran anhängen
           	lappend rlst "prod_machineanim kristallschmiede.heben_rauf once"
           	lappend rlst "prod_waittime 1"
           	lappend rlst "prod_machineanim kristallschmiede.einschwenk once"
           	lappend rlst "prod_waittime 1.4"
           	lappend rlst "prod_machineanim kristallschmiede.heb_innen_runter once"
           	lappend rlst "prod_waittime 1"
           	lappend rlst "prod_machineanim kristallschmiede.heb_innen_unten"
           	lappend rlst "prod_beam_itemtype_to_dummypos $material 7"
           	lappend rlst "prod_machineanim kristallschmiede.heb_innen_rauf once"
           	lappend rlst "prod_waittime 1"
           	lappend rlst "prod_machineanim kristallschmiede.heb_innen"

            if {[check_method [get_objclass this] "prod_actions_$material"]} {
                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
                lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
            } else {
            	log "WARNING: Kristallschmiede.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }

			// Kran zurück nach aussen fahren

			lappend rlst "prod_anim pressbutton"
          	lappend rlst "prod_machineanim kristallschmiede.ausschwenk once"
           	lappend rlst "prod_waittime 1.4"
           	lappend rlst "prod_machineanim kristallschmiede.standard"

			// Gegenstand wieder einsammeln

        	lappend rlst "prod_go_near_workdummy 7 0 0 1.3"
        	lappend rlst "prod_turnback"
        	lappend rlst "prod_anim benda"
        	lappend rlst "prod_consume_from_workplace $material"
        	lappend rlst "prod_anim bendb"

			// jedes Werkstück zur leeren Kiste bringen

	        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
        	 	lappend rlst "prod_goworkdummy 3"
            	lappend rlst "prod_turnright"
            	lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
			}
        }

        if {[lsearch $BOXED_CLASSES [get_class_type $item]] != -1} {
	        lappend rlst "prod_goworkdummy 3"		;// Kiste holen
    	    lappend rlst "prod_turnright"
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
        }

        lappend rlst "prod_turnfront"
		lappend rlst "prod_anim tired"

		return $rlst
	}


// default

	method prod_actions_default {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_machineanim kristallschmiede.anim start; prod_call_method set_steam 1"
        lappend rlst "prod_waittime [expr {10 - (8 * $exp_infl)}]"
        lappend rlst "prod_machineanim kristallschmiede.heb_innen stop; prod_call_method set_steam 0"

        return $rlst
	}


	method activate_anim_timer {animname} {
		set anim_timer_active 1
		switch $animname {
			"kristallschmiede.anim" {
				set anim_timer_action1 "set_particlesource this 3 5; set_particlesource this 4 5"
				timer_event this anim_timer1 -repeat 0 -attime [expr [gettime]+0.8]
				set anim_timer_interval 1.1
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


	method get_deliverypos {} {
		return [vector_add [get_pos this] [get_linkpos this 12]]
	}

	method set_steam {bool} {
        set_particlesource this 0 $bool
        set_particlesource this 1 $bool
        set_particlesource this 2 $bool
	}

	method deinit_production {} {
		call_method this set_steam 0
	}


    method init {} {
    	set_collision this 1

    	change_particlesource this 0 11 {0 0 0} {0 0 0} 32 1 0 8				;// Dampf
    	change_particlesource this 1 11 {0 0 0} {0 0 0} 32 1 0 9
    	change_particlesource this 2 11 {0 0 0} {0 0 0} 32 1 0 10
        set_particlesource this 0 0
        set_particlesource this 1 0
        set_particlesource this 2 0

    	change_particlesource this 3 18 {0 0 0} { 0.1 -0.1 0} 256 32 0 6		;// Funken
    	change_particlesource this 4 18 {0 0 0} {-0.1 -0.1 0} 256 32 0 7
        set_particlesource this 3 0
        set_particlesource this 4 0
    }

	class_defaultanim kristallschmiede.standard
	class_flagoffset 2.5 4.8

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this kristallschmiede.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Kristallschmiede
		set_energyconsumption this $tttenergycons_Kristallschmiede
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 13 14 15 16 17 18 19 20 21]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {oben_linksmetall unten_rechtsmetall oben_rechtsmetall oben_linksmetall unten_rechtsholz unten_rechtsholz unten_linksmetall oben_rechtsmetall oben_rechtsmetall}
		set damage_dummys {22 30}
	}
}

