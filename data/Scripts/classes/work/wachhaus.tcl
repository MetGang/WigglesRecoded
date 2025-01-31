call scripts/misc/utility.tcl

def_class Grenzstein stone production 1 {} {

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 1.0

	class_defaultanim grenzstein.standard
	class_flagoffset 0.0 0.0

	obj_init {
		call scripts/misc/genericprod.tcl
		set_anim this grenzstein.standard 0 $ANIM_LOOP
		set_collision this 1
		set build_dummys [list]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {}
		set damage_dummys {0 0}
	}
}
//# STOPIFNOT FULL

def_class _Bewachen_nah fight material 1 {} {}
def_class _Bewachen_mittel fight material 1 {} {}
def_class _Bewachen_weit fight material 1 {} {}


def_class Wachhaus wood production 3 {} {

	class_fightdist 1.5

	method prod_item_actions item {
		global current_worker
		set rlst [list]
		if {$item == "_Bewachen_nah"} {
			lappend rlst "prod_goworkdummy [get_switched_dummy]"
			for {set i 0} {$i < 10} {incr i} {
				lappend rlst "prod_bewachen_nah [get_switched_richtung]"
			}
		}
		if {$item == "_Bewachen_mittel"} {
			log "BEWACHEN_MITTEL_ACTION"
			lappend rlst "prod_goworkdummy 0"
			lappend rlst "prod_bewachen_trigger"
			for {set i 0} {$i < 10} {incr i} {
				set vector [getnextvector 5]
				log "Wachhaus-mittel: vector = $vector"
				if { [vector_equal $vector "-1 -1 -1"] } {
					lappend rlst "prod_goworkdummy [get_switched_dummy]"
				} else {
					lappend rlst "prod_gopos \{$vector\}"
				}

				lappend rlst "prod_check_wall"
				lappend rlst "prod_anim scout"
				lappend rlst "prod_feind_suchen [get_switched_richtung]"
			}
			lappend rlst "prod_delete_trigger"
		}
		if {$item == "_Bewachen_weit"} {
			log "BEWACHEN_WEIT_ACTION"
			lappend rlst "prod_goworkdummy 0"
			lappend rlst "prod_bewachen_trigger"
			for {set i 0} {$i < 10} {incr i} {
				//set vector [get_place -center [get_pos this] -rect -40 0 40 5 -mindist 3 -random 5]
				set vector [getnextvector 10]
				log "Wachhaus-mittel: vector = $vector"
				if { [vector_equal $vector "-1 -1 -1"] } {
					lappend rlst "prod_goworkdummy [get_switched_dummy]"
				} else {
					lappend rlst "prod_gopos \{$vector\}"
				}

				lappend rlst "prod_check_wall"
				lappend rlst "prod_anim scout"
				lappend rlst "prod_feind_suchen [get_switched_richtung]"
			}
			lappend rlst "prod_delete_trigger"
		}
		return $rlst
	}

	method prod_preinvented {} {
		return {_Bewachen_nah _Bewachen_mittel _Bewachen_weit}
	}

	method pack_plant {} {
	}

	method test {dist} {
		getnextvector $dist
	}

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_defaultanim wachhaus.standard
	class_flagoffset -1.0 1.7

	obj_init {
		global richtung dummy_punkt
		set dummy_punkt 1
		set richtung left
		set vorzeichen -
		call scripts/misc/genericprod.tcl
		set_anim this wachhaus.standard 0 $ANIM_LOOP
		set_collision this 1

		set build_dummys [list 16 17 18]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_linksholz unten_rechtsholz oben_rechtsholz}
		set damage_dummys {20 22}

		set_prod_switchmode this 1
		set_prod_schedule this 1
		set_prod_exclusivemode this 1

		proc get_switched_dummy {} {
			global dummy_punkt
			if {$dummy_punkt == 1} {
				set dummy_punkt 0
			} else {
				set dummy_punkt 1
			}
			return $dummy_punkt
		}
		proc get_switched_richtung {} {
			global richtung
			if {$richtung == "left"} {
				set richtung right
			} else {
				set richtung left
			}
			return $richtung
		}

		proc getnextvector {dist} {
			global vorzeichen
			//[get_place -center [get_pos this] -rect -$dist 0 $dist 5 -mindist 3 -random 5]
			set wachhaus_pos [get_pos this]
			if {$vorzeichen == "-"} {set vorzeichen +} else {set vorzeichen -}
			set z 14
			set x [expr [lindex $wachhaus_pos 0] + $vorzeichen$dist]
			set y [lindex $wachhaus_pos 1]
			set next_point [list $x $y $z]

			log "Next_Point: $next_point"
			set result [get_place -center $next_point -circle 4 -random 2]
            //set result [get_place -center $next_point -random 5]
            log "NEXT_VECTOR: $result"
            return $result
		}
	}
}
