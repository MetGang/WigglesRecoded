//# STOPIFNOT FULL
call scripts/misc/utility.tcl


def_class Schleiferei stone production 3 {} {

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

        foreach material $materiallist {
            if {[check_method [get_objclass this] "prod_actions_$material"]} {
                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
                lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
            } else {
            	log "WARNING: schleiferei.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }
        }

        lappend rlst "prod_goworkdummy 2"		;// ... und Produkt ablegen!
        lappend rlst "prod_turnfront"
        if {[lsearch $BOXED_CLASSES [get_class_type $item]] == -1} {
            lappend rlst "prod_createproduct_rndrot $item"
        } else {
    	    lappend rlst "prod_createproduct_box $item"
    	}
        lappend rlst "prod_turnfront"
		lappend rlst "prod_anim tired"

		return $rlst
	}


// Kristallerz

	method prod_actions_Kristallerz {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_goworkdummy 2"
        lappend rlst "prod_walk_and_consume_itemtype $itemtype"        ;// Kristallerz holen

        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim pressbutton"
		lappend rlst "prod_machineanim schleiferei.anim"			   ;// Maschine einschalten

        lappend rlst "prod_turnback"
        lappend rlst "prod_call_method sparks_on"
        lappend rlst "prod_call_method steam_on"
        lappend rlst "prod_anim planestart"
		lappend rlst "prod_anim_loop_expinfl planeloop 1 7 $exp_infl"	   ;// Schleifen

        if {[random 1.0] > $exp_infl} {
			lappend rlst "prod_anim planeaccident"						   ;// Unfall
        	lappend rlst "prod_anim planeend"
        	lappend rlst "prod_anim scratchhead"
        	lappend rlst "prod_anim planestart"
        }

		lappend rlst "prod_anim_loop_expinfl planeloop 1 7 $exp_infl"	   ;// Schleifen
		lappend rlst "prod_anim planeend"
        lappend rlst "prod_call_method steam_off"
        lappend rlst "prod_call_method sparks_off"
		lappend rlst "prod_anim tired"

        lappend rlst "prod_goworkdummy 1"							   ;// Maschine abschalten
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim pressbutton"
		lappend rlst "prod_machineanim schleiferei.standard"

		return $rlst
	}


// Kristall

    method prod_actions_Kristall {itemtype exp_infl} {
        return [call_method this prod_actions_Kristallerz $itemtype $exp_infl]
    }


// Eisen

    method prod_actions_Eisen {itemtype exp_infl} {
        return [call_method this prod_actions_Kristallerz $itemtype $exp_infl]
    }


// Eisenerz

    method prod_actions_Eisenerz {itemtype exp_infl} {
        return [call_method this prod_actions_Kristallerz $itemtype $exp_infl]
    }



// default

    method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Kristallerz $itemtype $exp_infl]
    }


    method sparks_on {} {
    	set_particlesource    this 0 1
    	set_particlesource    this 1 1
    	set_particlesource    this 6 1
    	set_particlesource    this 7 1

    }



    method sparks_off {} {
    	set_particlesource    this 0 0
    	set_particlesource    this 1 0
    	set_particlesource    this 6 0
    	set_particlesource    this 7 0
    }


	method steam_on {} {
    	set_particlesource    this 2 1
    	set_particlesource    this 3 1
    	set_particlesource    this 4 1
    	set_particlesource    this 5 1
   	}


	method steam_off {} {
    	set_particlesource    this 2 0
    	set_particlesource    this 3 0
    	set_particlesource    this 4 0
    	set_particlesource    this 5 0
   	}


	method deinit_production {} {
		call_method this steam_off
		call_method this sparks_off
	}


    method init {} {
    	set_collision this 1

		// Funken
    	change_particlesource this 0 18 {0 0 0} { 0.1 -0.1 0} 256 24 0 14
    	change_particlesource this 1 18 {0 0 0} {-0.1 -0.1 0} 256 24 0 15
    	change_particlesource this 6 18 {0 0 0} { 0.07 -0.07 0} 256 24 0 14
    	change_particlesource this 7 18 {0 0 0} {-0.07 -0.07 0} 256 24 0 15
    	set_particlesource    this 0 0
    	set_particlesource    this 1 0
    	set_particlesource    this 6 0
    	set_particlesource    this 7 0


		// Dampf
    	change_particlesource this 2 11 {0 0 0} { -0.07 -0.07 0} 32 2 0 12
    	change_particlesource this 3 11 {0 0 0} { -0.07 -0.07 0} 32 2 0 10
    	change_particlesource this 4 11 {0 0 0} {  0.07 -0.07 0} 32 2 0 11
    	change_particlesource this 5 11 {0 0 0} {  0.07 -0.07 0} 32 2 0 13
    	set_particlesource    this 2 0
    	set_particlesource    this 3 0
    	set_particlesource    this 4 0
    	set_particlesource    this 5 0
    }


	class_defaultanim schleiferei.standard
	class_flagoffset 2.1 4.2

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this schleiferei.standard 0 $ANIM_LOOP
		set_energyclass this $tttenergyclass_Schleiferei
		set_energyconsumption this $tttenergycons_Schleiferei
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]

		set build_dummys [list 16 17 18 19 20 21 21 1 23]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_linksmetall unten_linksmetall unten_rechtsmetall unten_rechtsmetall unten_rechtsmetall oben_linksmetall oben_rechtsmetall unten_rechtsmetall oben_rechtsmetall}
		set damage_dummys {24 30}
	}
}

