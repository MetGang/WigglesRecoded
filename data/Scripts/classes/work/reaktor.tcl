call scripts/misc/utility.tcl

def_class Energie___ energy material 3 {} {}

def_class Reaktor stone energy 3 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 3.0

	#
	method prod_item_actions item {
		global current_worker
		set exp_incr [call_method this prod_item_exp_incr $item]
		set exp_infls [call_method this prod_item_exp_infl $item]
		set exp_infl [prod_getgnomeexper $current_worker $exp_infls]
		set materiallist [call_method this prod_item_materials $item]
		set rlst [list]

        foreach material $materiallist {
            if { [check_method [get_objclass this] "prod_actions_$material"] } {
                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl"]]
                lappend rlst "prod_exp $exp_incr [expr {1.0 / [llength $materiallist]}]"
            } else {
            	log WARN "reaktor.tcl: No prod_actions method for $material"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }
        }

		return $rlst
	}

	#
	method prod_actions_Kristall {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"
        lappend rlst "prod_goworkdummy 2"
        lappend rlst "prod_turnback"
        lappend rlst "prod_anim_loop_expinfl workatfloor 1 3 $exp_infl"
        lappend rlst "prod_turnleft"
        lappend rlst "prod_anim switchup"
        if { $exp_infl < [random 1.0] } {
        	lappend rlst "prod_anim scratchhead"
	        lappend rlst "prod_anim switchup"
	        lappend rlst "prod_turnright"
	        lappend rlst "prod_anim kontrol"
        }
		lappend rlst "energy_inc_energystore [get_energy_fuel_yield] [get_energy_max_store]"
		lappend rlst "prod_goworkdummy 0"

		return $rlst
	}

	#
    method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Kristall $itemtype $exp_infl]
    }

	#
	def_event evt_timer0
	handle_event evt_timer0 {
		global active

		set_energymaxstore this [get_energy_max_store]
		set_energyclass this [get_energy_class]
		set_energyrange this [get_energy_range]

		if { [get_boxed this] } { return }

		# When stored energy is low, enable tasks for restoring it
		if { [get_energy_stored] < [get_energy_max_store] } {
			set i [expr {[get_energy_max_store] - [get_energystore this]}]
			set i [expr {int($i / [get_energy_fuel_yield])}]
			if { [get_prod_slot_cnt this Energie___] < $i } {
				log INFO "[get_objname this] asks for $i fuel unit(s)"
			}
			set_prod_slot_cnt this Energie___ $i
		}

		# Turn on animation when energy is consumed
		if { [get_energy_consumed] > 0 && $active == 0 } {
			set_anim this reaktor.anim 0 $ANIM_LOOP
			set active 1
		}

		# Turn off animation when no energy is consumed
		if { [get_energy_consumed] == 0 && $active == 1 } {
			set_anim this reaktor.standard 0 $ANIM_STILL
			set active 0
		}
	}

	#
	method deinit_production {} { }

	#
    method init {} {
    	global active

		change_particlesource this 0 0 {0 0 0.1} {0 0 0} 32 1 0
		set_particlesource this 0 1

    	set_collision this 1
		set active 0
    }

	class_defaultanim reaktor.standard
	class_flagoffset 1.3 3.9

	# Constructor
	obj_init {
		call scripts/misc/genericprod.tcl

		# Override!
		proc get_energy_max_store {} {
			return 4000
		}

		# Override!
		proc get_energy_fuel_yield {} {
			return 500
		}

		# Override!
		proc get_energy_class {} {
			return 3
		}

		# Override!
		proc get_energy_range {} {
			return 100
		}

		# Override!
		proc get_build_dummies {} {
			return {16 17 18 19 20 21 22 23}
		}

		# Override!
		proc get_buildup_anis {} {
			return {unten_linksmetall unten_rechtsmetall oben_rechtsmetall oben_rechtsmetall unten_rechtsmetall oben_rechtsmetall oben_linksmetall unten_rechtsmetall}
		}

		# Override!
		proc get_damage_dummies {} {
			return {24 31}
		}

		# Override!
		proc get_object_groups {} {
			return {power}
		}

		set active 0

		set_anim this reaktor.standard 0 $ANIM_LOOP
		set_energystore this [get_energy_max_store]
		set_energymaxstore this [get_energy_max_store]
		set_energyclass this [get_energy_class]
		set_energyrange this [get_energy_range]
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr {[gettime] + 1}]
		timer_event this evt_timer0 -repeat -1 -interval 1 -userid 0

	}
}
