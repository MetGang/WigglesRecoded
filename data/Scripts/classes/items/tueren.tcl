def_class _Offen fight material 1 {} {}
def_class _Verschlossen fight material 1 {} {}
def_class _Automatisch fight material 1 {} {}

def_class Holztuer metal protection 2 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl
	call scripts/misc/obj_attribs.tcl
	call scripts/classes/items/calls/tueren.tcl

	class_fightdist 1.5

	set_class_anim open_r		holztuer.rechts_offen
	set_class_anim opening_r	holztuer.rechts_oeffnen
	set_class_anim closing_r	holztuer.rechts_schliessen
	set_class_anim closed		holztuer.standard
	set_class_anim open_l		holztuer.links_offen
	set_class_anim opening_l	holztuer.links_oeffnen
	set_class_anim closing_l	holztuer.links_schliessen

    class_defaultanim holztuer.standard

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/misc/genericprod.tcl

		set_anim this holztuer.standard 0 0

		set_attrib this weight 0.3
		set_attrib this hitpoints 3

		set_prod_switchmode this 1
		set_prod_exclusivemode this 1
		set_prod_enabled this 0

		;// Fl�ssigkeitseinfluss
		set_fstopper this {0 -2} {0 1} 0

		;// verz�gerte Initialisierungen
		timer_event this evt_timer0 -repeat 0 -userid 0 -attime [expr [gettime]+1]

		set infostring ""
		set undefined undefined

		# Override!
		proc get_build_dummies {} {
			return {27 27 24 19}
		}

		# Override!
		proc get_buildup_anis {} {
			return {unten_rechtsholz unten_linksholz oben_linksholz oben_rechtsholz}
		}

		# Override!
		proc get_damage_dummies {} {
			return {26 16}
		}

		# Override!
		proc get_object_groups {} {
			return {door}
		}
	}
}

def_class Steintuer metal protection 2 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl
	call scripts/misc/obj_attribs.tcl
	call scripts/classes/items/calls/tueren.tcl

	class_fightdist 1.5

	set_class_anim open_r		steintuer.rechts_offen
	set_class_anim opening_r	steintuer.rechts_oeffnen
	set_class_anim closing_r	steintuer.rechts_schliessen
	set_class_anim closed		steintuer.standard
	set_class_anim open_l		steintuer.links_offen
	set_class_anim opening_l	steintuer.links_oeffnen
	set_class_anim closing_l	steintuer.links_schliessen

    class_defaultanim	steintuer.standard

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/misc/genericprod.tcl

		set_anim this steintuer.standard 0 0

		set_attrib this weight 0.3
		set_attrib this hitpoints 5

		set_prod_switchmode this 1
		set_prod_exclusivemode this 1
		set_prod_enabled this 0

		;// Fl�ssigkeitseinfluss
		set_fstopper this {0 -2} {0 1} 0

		;// verz�gerte Initialisierungen
		timer_event this evt_timer0 -repeat 0 -userid 0 -attime [expr [gettime]+1]

		set infostring ""
		set undefined undefined

		# Override!
		proc get_build_dummies {} {
			return {27 27 24 19}
		}

		# Override!
		proc get_buildup_anis {} {
			return {unten_rechtsstein unten_linksstein oben_linksstein oben_rechtsstein}
		}

		# Override!
		proc get_damage_dummies {} {
			return {26 16}
		}

		# Override!
		proc get_object_groups {} {
			return {door}
		}
	}
}

def_class Metalltuer metal protection 2 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl
	call scripts/misc/obj_attribs.tcl
	call scripts/classes/items/calls/tueren.tcl

	class_fightdist 1.5

	set_class_anim open_r		metalltuer.rechts_offen
	set_class_anim opening_r	metalltuer.rechts_oeffnen
	set_class_anim closing_r	metalltuer.rechts_schliessen
	set_class_anim closed		metalltuer.standard
	set_class_anim open_l		metalltuer.links_offen
	set_class_anim opening_l	metalltuer.links_oeffnen
	set_class_anim closing_l	metalltuer.links_schliessen

    class_defaultanim metalltuer.standard

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/misc/genericprod.tcl

		set_anim this metalltuer.standard 0 0

		set_attrib this weight 0.3
		set_attrib this hitpoints 7

		set_prod_switchmode this 1
		set_prod_exclusivemode this 1
		set_prod_enabled this 0

		;// Fl�ssigkeitseinfluss
		set_fstopper this {0 -2} {0 1} 0

		;// verz�gerte Initialisierungen
		timer_event this evt_timer0 -repeat 0 -userid 0 -attime [expr [gettime]+1]

		set infostring ""
		set undefined undefined

		# Override!
		proc get_build_dummies {} {
			return {27 27 24 19}
		}

		# Override!
		proc get_buildup_anis {} {
			return {unten_rechtsmetall unten_linksmetall oben_linksmetall oben_rechtsmetall}
		}

		# Override!
		proc get_damage_dummies {} {
			return {26 16}
		}

		# Override!
		proc get_object_groups {} {
			return {door}
		}
	}
}

def_class Kristalltuer metal protection 2 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl
	call scripts/misc/obj_attribs.tcl
	call scripts/classes/items/calls/tueren.tcl

	class_fightdist 1.5

	set_class_anim open_r		kristalltuer.rechts_offen
	set_class_anim opening_r	kristalltuer.rechts_oeffnen
	set_class_anim closing_r	kristalltuer.rechts_schliessen
	set_class_anim closed		kristalltuer.standard
	set_class_anim open_l		kristalltuer.links_offen
	set_class_anim opening_l	kristalltuer.links_oeffnen
	set_class_anim closing_l	kristalltuer.links_schliessen

    class_defaultanim kristalltuer.standard

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/misc/genericprod.tcl

		set_anim this kristalltuer.standard 0 0

		set_attrib this weight 0.3
		set_attrib this hitpoints 15

		set_prod_switchmode this 1
		set_prod_exclusivemode this 1
		set_prod_enabled this 0

		;// Fl�ssigkeitseinfluss
		set_fstopper this {0 -2} {0 1} 0

		;// verz�gerte Initialisierungen
		timer_event this evt_timer0 -repeat 0 -userid 0 -attime [expr [gettime]+1]

		set infostring ""
		set undefined undefined

		# Override!
		proc get_build_dummies {} {
			return {27 27 24 19}
		}

		# Override!
		proc get_buildup_anis {} {
			return {unten_rechtsstein unten_linksstein oben_linksstein oben_rechtsstein}
		}

		# Override!
		proc get_damage_dummies {} {
			return {26 16}
		}

		# Override!
		proc get_object_groups {} {
			return {door}
		}
	}
}
