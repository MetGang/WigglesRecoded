call scripts/misc/utility.tcl

def_class Energie energy material 1 {} {}

def_class Laufradhamster food tool 2 {} {
	call scripts/misc/autodef.tcl

	# Constructor
	obj_init {
		call scripts/misc/autodef.tcl
		set_anim this hamster.stand_anim 0 $ANIM_LOOP
		set_physic this 0
		set_hoverable this 0
	}
}

def_class Laufrad wood energy 2 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 1.5

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
            	log WARN "laufrad.tcl: No prod_actions method for $material"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }
        }

		return $rlst
	}

	#
	method prod_actions_Pilzhut {itemtype exp_infl} {
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"
		lappend rlst "prod_go_near_workdummy 2 -0.3 0.0 0.0"
		lappend rlst "prod_turnback"
        lappend rlst "prod_anim_loop_expinfl workatfire 1 3 $exp_infl"
		lappend rlst "energy_inc_energystore [get_energy_fuel_yield] [get_energy_max_store]"

		return $rlst
	}

	#
    method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Pilzhut $itemtype $exp_infl]
    }

	#
	def_event evt_timer0
	handle_event evt_timer0 {
		global active hamsterid

		set_energymaxstore this [get_energy_max_store]
		set_energyclass this [get_energy_class]
		set_energyrange this [get_energy_range]

		if { [get_boxed this] } { return }

		# When stored energy is low, enable tasks for restoring it
		if { [get_energy_stored] < [get_energy_max_store] } {
			set i [expr {[get_energy_max_store] - [get_energystore this]}]
			set i [expr {int($i / [get_energy_fuel_yield])}]
			if { [get_prod_slot_cnt this Energie] < $i } {
				log INFO "[get_objname this] asks for $i fuel unit(s)"
			}
			set_prod_slot_cnt this Energie $i
		}

		# Turn on animation when energy is consumed
		if { [get_energy_consumed] > 0 && $active == 0 } {
			set_anim this laufrad.drehen 0 $ANIM_LOOP
			if { [obj_valid $hamsterid] } {
				set_anim $hamsterid hamster.laufrad_loop 0 $ANIM_LOOP
			}
			set active 1
		}

		# Turn off animation when no energy is consumed
		if { [get_energy_consumed] == 0 && $active == 1 } {
			set_anim this laufrad.standard 0 $ANIM_STILL
			if { [obj_valid $hamsterid] } {
				set_anim $hamsterid hamster.stand_anim 0 $ANIM_LOOP
			}
			set active 0
		}
	}

	#
	method deinit_production {} { }

	#
    method init {} {
    	global active hamsterid

		if { $hamsterid <= 0 } {
			set hamsterid [new Laufradhamster]
			set_pos $hamsterid [vector_add [get_pos this] {0 -0.35 0}]
			set_rot $hamsterid {0 1.157 0}
			set_anim $hamsterid hamster.stand_anim 0 $ANIM_LOOP
		}

    	set_collision this 1
		set active 0
    }

	#
    method prepare_packtobox {} {
		global hamsterid

		set_light this 0
		for { set index 0 } { $index < 16 } { incr index } {
			free_particlesource this $index
		}

		if { $hamsterid > 0 } {
			if { [obj_valid $hamsterid] } {
				del $hamsterid
			}
		}
		set hamsterid -1
    }

	class_defaultanim laufrad.standard
	class_flagoffset 1.2 1.5

	# Constructor
	obj_init {
		call scripts/debug.tcl
		call scripts/misc/genericprod.tcl

		# Override!
		proc get_energy_max_store {} {
			return 400
		}

		# Override!
		proc get_energy_fuel_yield {} {
			return 200
		}

		# Override!
		proc get_energy_class {} {
			return 1
		}

		# Override!
		proc get_energy_range {} {
			return 20
		}

		# Override!
		proc get_build_dummies {} {
			return {12 13 14 15 16}
		}

		# Override!
		proc get_buildup_anis {} {
			return {unten_rechtsholz unten_linksholz unten_linksholz oben_rechtsholz oben_linksholz}
		}

		# Override!
		proc get_damage_dummies {} {
			return {20 24}
		}

		# Override!
		proc get_object_groups {} {
			return {power}
		}

		set active 0
		set hamsterid -1

		set_anim this laufrad.standard 0 $ANIM_LOOP
		set_energystore this [get_energy_max_store]
		set_energymaxstore this [get_energy_max_store]
		set_energyclass this [get_energy_class]
		set_energyrange this [get_energy_range]
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr {[gettime] + 1}]
		timer_event this evt_timer0 -repeat -1 -interval 1 -userid 0

	}
}
