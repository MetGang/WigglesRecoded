call scripts/misc/utility.tcl

def_class Energie__ energy material 3 {} {}

def_class Dampfmaschine metal energy 3 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 2.0

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
            	log WARN "dampfmaschine.tcl: No prod_actions method for $material"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }
        }

		return $rlst
	}

	#
	method prod_actions_Kohle {itemtype exp_infl} {
        set rlst [list]

	    lappend rlst "prod_walk_and_consume_itemtype $itemtype"
		lappend rlst "prod_goworkdummy 0"
		lappend rlst "prod_turnback"
		lappend rlst "prod_anim bend"
		lappend rlst "prod_anim_loop_expinfl workatfloor 1 5 $exp_infl"
		if { $exp_infl < 0.4 } {
			if { [random 1.0] < 0.2 } {
				lappend rlst "prod_fireaccident 10"
			} else {
				lappend rlst "prod_anim scratchhead"
				lappend rlst "prod_anim kickmachine"
			}
		}
		lappend rlst "energy_inc_energystore [get_energy_fuel_yield] [get_energy_max_store]"
		lappend rlst "prod_turnfront"
		lappend rlst "prod_anim tired"

		return $rlst
	}

	#
	method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Kohle $itemtype $exp_infl]
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
			if { [get_prod_slot_cnt this Energie__] < $i } {
				log INFO "[get_objname this] asks for $i fuel unit(s)"
			}
			set_prod_slot_cnt this Energie__ $i
		}

		# Turn on animation when energy is consumed
		if { [get_energy_consumed] > 0 && $active == 0 } {
			call_method this set_steam 1
			set_anim this dampfmaschine.anim 0 $ANIM_LOOP
			set active 1
		}

		# Turn off animation when no energy is consumed
		if { [get_energy_consumed] == 0 && $active == 1 } {
			call_method this set_steam 0
			set_anim this dampfmaschine.standard 0 $ANIM_STILL
			set active 0
		}
	}

	#
	method set_steam {flag} {
		if { $flag == 1 } {
			change_particlesource this 0 3  {0 0 0} 	{0 0 0} 		128 	4 	0 15 0.8
			change_particlesource this 1 6  {0 -0.3 0} 	{0 -0.15 0}		256		32 	0 12

			set_particlesource this 0 1
			set_particlesource this 1 1
			set_particlesource this 2 1
			set_particlesource this 3 1
			set_particlesource this 4 1
			set_particlesource this 5 1
		} else {
			change_particlesource this 0 3  {0 0 0} 	{0 0 0} 			128 	4 	0 13 0.8
			change_particlesource this 1 6  {0 -0.3 0} 	{0 0 0} 			16 		1 	0 10 2

			set_particlesource this 0 1
			set_particlesource this 1 1
			set_particlesource this 2 0
			set_particlesource this 3 0
			set_particlesource this 4 0
			set_particlesource this 5 0
		}
	}

	#
	method deinit_production {} { }

	#
    method init {} {
		global active

		change_particlesource this 0 3  {0 0 0} 	{0 0 0} 			128 	4 	0 13 0.8
		change_particlesource this 1 6  {0 -0.3 0} 	{0 0 0} 			16 		1 	0 10 2
		change_particlesource this 2 11 {0 0 0} 	{0 -0.04 0.02} 		32 		2 	0 10 1.5
		change_particlesource this 3 11 {0 0 0}		{0 -0.04 0.02}		16 		1 	0 11  2
		change_particlesource this 4 11 {0 0 0}		{0 0 0}		 		32  	2 	0 13  1.5
		change_particlesource this 5 12 {0 0 0}		{0 0 0}				16		1 	0 14 1.5

		set_particlesource this 0 1
		set_particlesource this 1 1
		set_particlesource this 2 0
		set_particlesource this 3 0
		set_particlesource this 4 0
		set_particlesource this 5 0

    	set_collision this 1
		set active 0
    }

	class_defaultanim dampfmaschine.standard
	class_flagoffset 2.1 4.1

	# Constructor
	obj_init {
		call scripts/misc/genericprod.tcl

		# Override!
		proc get_energy_max_store {} {
			return 2000
		}

		# Override!
		proc get_energy_fuel_yield {} {
			return 400
		}

		# Override!
		proc get_energy_class {} {
			return 2
		}

		# Override!
		proc get_energy_range {} {
			return 60
		}

		# Override!
		proc get_build_dummies {} {
			return {14 15 16 17 18 19 20 21 22}
		}

		# Override!
		proc get_buildup_anis {} {
			return {unten_linksmetall unten_rechtsmetall unten_rechtsmetall oben_rechtsmetall oben_linksmetall unten_rechtsstein unten_rechtsholz oben_rechtsstein oben_linksstein}
		}

		# Override!
		proc get_damage_dummies {} {
			return {23 31}
		}

		# Override!
		proc get_object_groups {} {
			return {power}
		}

		set active 0

		set_anim this dampfmaschine.standard 0 $ANIM_LOOP
		set_energystore this [get_energy_max_store]
		set_energymaxstore this [get_energy_max_store]
		set_energyclass this [get_energy_class]
		set_energyrange this [get_energy_range]
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr {[gettime] + 1}]
		timer_event this evt_timer0 -repeat -1 -interval 1 -userid 0
	}
}
