//# IFNOT FULL
def_class Krankenhaus none dummy 0 {} {}
//# ENDIF
//# STOPIFNOT FULL
call scripts/misc/utility.tcl

def_class _Heilen service material 1 {} {}

def_class Krankenhaus wood production 3 {} {

	class_fightdist 2.0

	method prod_item_actions item {
		global current_worker
		set rlst [list]

		if {[call_method this get_patient] == 0} {lappend rlst "prod_goworkdummy 0"}
		lappend rlst "prod_heilen $current_worker [get_ref this]"


		return $rlst
	}

	method pack_plant {} {
	}

	method get_worker {} {
		return [call_method this get_current_worker]
	}

	method get_patient {} {
		global patient
		return $patient
	}

	method set_patient {ref} {
		global patient
		set patient $ref
	}

	method set_current_todo {wert} {
		global current_todo
		set current_todo $wert
	}

	method get_current_todo {} {
		global current_todo
		return $current_todo
	}

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl


	class_defaultanim krankenhaus.standard
	class_flagoffset 2.3 3.8


	obj_init {
		call scripts/misc/genericprod.tcl
		set_anim this krankenhaus.standard 0 $ANIM_LOOP
		set_collision this 1
		set_energyconsumption this 2
		set_prod_switchmode this 1

		set_prod_schedule this 1
		set_prod_exclusivemode this 1
		set build_dummys [list 12 13 14 15 16 17 18 19]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_linksstein unten_rechtsstein unten_rechtsmetall oben_rechtsmetall oben_rechtsholz oben_linksholz unten_linksmetall unten_rechtsstein}
		set damage_dummys {20 27}

		prod_guest addlink this 7
		prod_guest addlink this 8
		prod_guest addlink this 9
		prod_guest addlink this 10

		set patient 0
		set current_todo 0
	}
}

