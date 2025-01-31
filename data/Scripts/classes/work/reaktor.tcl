//# STOPIFNOT FULL
call scripts/misc/utility.tcl

def_class Energie___ energy material 3 {} {}

def_class Reaktor stone energy 3 {} {

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 3.0

	method prod_item_actions item {
		global current_worker
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
            	log "WARNING: Reaktor.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }
        }

		return $rlst
	}


// Kristall

	method prod_actions_Kristall {itemtype exp_infl} {
		global energyyield tttenergymaxstore_Reaktor
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"
        lappend rlst "prod_goworkdummy 2"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim_loop_expinfl workatfloor 1 3 $exp_infl"
        lappend rlst "prod_turnleft"
        lappend rlst "prod_anim switchup"
        if {$exp_infl < [random 1.0]} {
        	lappend rlst "prod_anim scratchhead"
	        lappend rlst "prod_anim switchup"
	        lappend rlst "prod_turnright"
	        lappend rlst "prod_anim kontrol"
        }
		lappend rlst "energy_inc_energystore $energyyield $tttenergymaxstore_Reaktor"
		lappend rlst "prod_goworkdummy 0"

		return $rlst
	}


// default

    method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Pilzstamm $itemtype $exp_infl]
    }


	def_event evt_timer_localinit 
	handle_event evt_timer_localinit {
		set_energystore this $tttenergymaxstore_Reaktor
	}
	

	def_event evt_timer0
	handle_event evt_timer0 {
		global active

		if {[get_boxed this]} {
			return
		}

		// neuen "Produktionsauftrag" erteilen, wenn Energievorrat knapp
		if {[get_energystore this] < $tttenergymaxstore_Reaktor} {
			set i [expr $tttenergymaxstore_Reaktor - [get_energystore this]]
			set i [expr int ($i / $tttenergyyield_Reaktor)]
			if {[get_prod_slot_cnt this Energie___] < $i} {
				log "Reaktor: erteilte Produktionsaufträge: $i"
			}
			set_prod_slot_cnt this Energie___ $i
		}

		// wenn jemand von uns Strom zieht - Animation ein
		if {[get_energysourceload this] > 0  &&  $active ==0} {
			set_anim this reaktor.anim 0 $ANIM_LOOP			;// work-anim
			set active 1
		}
		// sonst aus
		if {[get_energysourceload this] == 0 &&  $active ==1} {
			set_anim this reaktor.standard 0 $ANIM_STILL		;// idle-anim
			set active 0
		}
	}

	method deinit_production {} {
	}


    method init {} {
    	global active

    	set_collision this 1

		change_particlesource this 0 0 {0 0 0.1} {0 0 0} 32 1 0
		set_particlesource this 0 1

		set active 0
    }


	class_defaultanim reaktor.standard
	class_flagoffset 1.3 3.9

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this reaktor.standard 0 $ANIM_LOOP
		set_energyrange this $tttenergyrange_Reaktor
		set_energyclass this $tttenergyclass_Reaktor
		set_energymaxstore this	$tttenergymaxstore_Reaktor
		set_energystore this $tttenergymaxstore_Reaktor
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]
		timer_event this evt_timer_localinit -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]
		timer_event this evt_timer0 -repeat -1 -interval 2 -userid 0

		set active 0
		set energyyield $tttenergyyield_Reaktor

		set build_dummys [list 16 17 18 19 20 21 22 23]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_linksmetall unten_rechtsmetall oben_rechtsmetall oben_rechtsmetall unten_rechtsmetall oben_rechtsmetall oben_linksmetall unten_rechtsmetall}
		set damage_dummys {24 31}
	}
}


