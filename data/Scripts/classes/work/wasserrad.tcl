call scripts/misc/utility.tcl

def_class Energie_ energy material 1 {} {}

def_class Wasserrad wood energy 2 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 1.6

	#
	method prod_item_actions item {
		return [list]
	}

	#
	def_event evt_timer0
	handle_event evt_timer0 {
		global active

		set_energymaxstore this [get_energy_max_store]
		set_energyclass this [get_energy_class]
		set_energyrange this [get_energy_range]

		if { [get_boxed this] } { return }

		# When stored energy is low, restore it when in water
		if { [get_energy_stored] < [get_energy_max_store] && [isunderwater [get_pos this]] } {
			set_energystore this [expr {[get_energy_stored] + [get_energy_fuel_yield]}]
		}

		# Turn on animation when energy is consumed or when in water
		if { ([get_energy_consumed] > 0 || [isunderwater [get_pos this]]) && $active == 0 } {
			set_anim this wasserrad.drehen 0 $ANIM_LOOP
			set active 1
		}

		# Turn off animation when no energy is consumed
		if { ([get_energy_consumed] == 0 && ![isunderwater [get_pos this]]) && $active == 1 } {
			set_anim this wasserrad.standard 0 $ANIM_STILL
			set active 0
		}
	}

	#
	method deinit_production {} { }

	#
    method init {} {
    	global active

    	set_collision this 1
		set active 0
    }

	class_defaultanim wasserrad.standard
	class_flagoffset 1.7 2.0

	# Constructor
	obj_init {
		call scripts/misc/genericprod.tcl

		# Override!
		proc get_energy_max_store {} {
			return 400
		}

		# Override!
		proc get_energy_fuel_yield {} {
			return 0.5
		}

		# Override!
		proc get_energy_class {} {
			return 1
		}

		# Override!
		proc get_energy_range {} {
			return 60
		}

		# Override!
		proc get_build_dummies {} {
			return {12 13 14 15 16 17 18}
		}

		# Override!
		proc get_buildup_anis {} {
			return {unten_rechtsstein unten_rechtsstein unten_linksstein unten_linksstein oben_rechtsstein oben_linksstein oben_rechtsholz}
		}

		# Override!
		proc get_damage_dummies {} {
			return {20 26}
		}

		# Override!
		proc get_object_groups {} {
			return {power}
		}

		set active 0

		set_anim this wasserrad.standard 0 $ANIM_LOOP
		set_energystore this [get_energy_max_store]
		set_energymaxstore this [get_energy_max_store]
		set_energyclass this [get_energy_class]
		set_energyrange this [get_energy_range]
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr {[gettime] + 1}]
		timer_event this evt_timer0 -repeat -1 -interval 1 -userid 0
	}
}
