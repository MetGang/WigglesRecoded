call scripts/misc/utility.tcl
call scripts/init/animinit.tcl

# Mushroom
def_class Pilz food material 0 {} {
	call scripts/misc/animclassinit.tcl

	set_class_anim phase0 pilz.wachsen01
	set_class_anim phase1 pilz.wachsen02
	set_class_anim phase2 pilz.wachsen03
	set_class_anim phase3 pilz.standard
	set_class_anim phase0_fell pilz.umfallen
	set_class_anim phase1_fell pilz.umfallen
	set_class_anim phase2_fell pilz.umfallen
	set_class_anim phase3_fell pilz.umfallen
	set_class_anim die pilz.standard

	obj_init {
		set phase_timer 170
		set_viewinfog this 1
		set_physic this 1

		set_lock this 1

		set info_string ""
		set agephase -1
		set its_myzel 0
		set is_farmed 0
		set is_dying 0

		;# set animation
		if { [get_mapedit] } {
			set_anim this pilz.standard 0 $ANIM_STILL
		} else {
			set_anim this pilz.wachsen01 0 $ANIM_STILL
		}

		set_collision this 1

		timer_event this evt_pilz_aging -userid 1 -repeat 3 -interval $phase_timer -attime [expr {[gettime] + $phase_timer}]
		timer_event this evt_timer0 -userid 0 -repeat 0 -attime [expr {[gettime] + 1}]

		call scripts/misc/aggr_events.tcl
	}

	call scripts/misc/aggr_events.tcl

	method Editor_Set_Info {ifo} {
		set info_string $ifo
		foreach entry $ifo {
			switch [lindex $entry 0] {
				"age" {
					if {[set agephase [lindex $entry 1]]} {
						incr agephase -1
						timer_event this evt_pilz_aging -userid 2 -repeat 0 -attime [expr {[gettime]+2}]
					}
				}
				"aggr" {set player_aggressivity [lindex $entry 1]}
				"aggrmax" {set aggr_max [lindex $entry 1]}
			}
		}
	}

	method has_myzel {myzel} {
		set agephase 0
		if { $myzel == "farm" } {
			set is_farmed 1
		} else {
			set its_myzel $myzel
		}
	}

	# Used only in harvesting for damaging
	method attr_add {attr val} {
		add_attrib this $attr $val
	}

	def_event evt_timer0
	def_event evt_pilz_aging
	handle_event evt_timer0 {
		if { $agephase == -1 } {
			if { rand() < 0.05 } { set agephase 1 } { set agephase 2 }
			timer_event this evt_pilz_aging -userid 2 -repeat 0 -attime [expr {[gettime] + 1}]
		}
	}

	handle_event evt_pilz_aging {
		global agephase

		if { $is_dying } { return }

		switch $agephase {
			0 {
				set agephase 1
				set_attrib this PilzAge 1
				action this anim "phase0" {
					set_anim this pilz.wachsen02 0 $ANIM_STILL
				}
			}
			1 {
				set agephase 2
				set_attrib this PilzAge 2
				action this anim "phase1" {
					set_anim this pilz.wachsen03 0 $ANIM_STILL
				}
			}
			2 {
				set_lock this 0
				timer_unset this 1
				set agephase 3
				set_attrib this PilzAge 3
				action this anim "phase2" {
					set_anim this pilz.standard 0 $ANIM_STILL
				}
			}
		}
	}

	method die {} {
		global agephase its_myzel is_dying

		set_selectable this 0
		set_hoverable this 0

		set is_dying 1

		switch $agephase {
			1 { set dieanim "pilz.klein_umfallen" }
			2 { set dieanim "pilz.mittel_umfallen" }
			3 { set dieanim "pilz.umfallen" }
		}

		sel /obj
		if { $its_myzel == 0 } {
			if { !$is_farmed } {
				set its_myzel [new PilzMyzel]
				set_pos $its_myzel [get_pos this]
				set_owner $its_myzel [get_owner this]
			}
		}

		if { $its_myzel != 0 } {
			timer_event $its_myzel evt_pilz_aging -userid 1 -repeat 0 -interval 1 -attime [expr [gettime]+[call_method $its_myzel get_plztimer]+[expr [call_method $its_myzel get_plzstarttimer]*(0.8+rand()*0.45)]]
			ref_set $its_myzel lastplz [gettime]
			call_method $its_myzel set_nopilz 1
		}

		if { $agephase != 0 } {
			action this anim $dieanim {
				global agephase

				switch $agephase {
					1 {
						set stem_cnt 0
						set hat_cnt 1
					}
					2 {
						set stem_cnt 1
						set hat_cnt 1
					}
					3 {
						set stem_cnt 1
						set hat_cnt 2
					}
				}
 
				set opos [get_pos this]
				set roty [get_roty this]
				set vec [list [expr {sin($roty)}] 0 [expr {-cos($roty)*2}]]

				for { set i 0 } { $i < $stem_cnt } { incr i } {
					set npos [vector_add $opos [vector_mul $vec 0.5]]
					sel /obj
					set stem [new Pilzstamm]
					set_pos $stem $npos
					set_owner $stem [get_owner this]
					set_roty $stem [expr [random -0.2 0.2] + [get_roty this]]
				}

				for { set i 0 } { $i < $hat_cnt } { incr i } {
					set npos [vector_add $opos [vector_add [vector_mul $vec 1.2] [vector_add {-0.25 0 -0.5} [vector_random 0.5 0 1.0]]]]
					sel /obj
					set hat [new Pilzhut]
					set_pos $hat $npos
					set_owner $hat [get_owner this]
					set_roty $hat [random 6.28318]
				}

				del this
			}
		} else {
			del this
		}
	}
}

# Mushroom mycelium
def_class PilzMyzel none info 0 {} {

	method get_plztimer {} {
		return $plztimer
	}

	method get_plzstarttimer {} {
		return $plzstarttimer
	}

	method set_nopilz {boole} {
		set nopilz $boole
	}

	obj_init {
		set plzstarttimer 200
		set nopilz 1
		set plzcnt 0
		set plztimer [expr sqrt($plzcnt)*$plzstarttimer*(0.8+rand()*0.45)]
		set lastplz [gettime]

		timer_event this evt_pilz_aging -userid 1 -repeat 0 -interval 1 -attime [expr [gettime] + [expr $plzstarttimer*(0.8+rand()*0.45)]]

		proc nachwuchs_pilz {} {
			global plzcnt nopilz lastplz plztimer plzstarttimer
			set abbruch 0
			set abfrage [obj_query this -type {production store energy} -boundingbox {-4 -1 -6 4 1 6} -flagneg boxed]
			if {$abfrage!=0} {
				foreach item $abfrage {
					set cn [get_objclass $item]
					if { [string first $cn "FeuerstelleZeltLaufradGrabsteinGrenzstein"] == -1 } {
						set abbruch 1
						break
					}
				}
				if {[obj_query this -class {Feuerstelle Zelt Laufrad Grabstein} -boundingbox {-1.5 -1 -4 1.5 1 5} -flagneg boxed -limit 1]} {set abbruch 1}
			}
			if {$nopilz && !$abbruch} {
				set plst [obj_query this "-range 5 -class Pilz"]
				if {[llength $plst] < 3} {
					set ppos [get_place -center [get_pos this] -circle 2 -random 1 -walldist 4 -rimdist 2]
					if { [lindex $ppos 0] > 0 } {
						sel /obj
						set plz [new Pilz]
						set_pos $plz $ppos
						set_owner $plz [get_owner this]
						call_method $plz has_myzel [get_ref this]
						if {$plztimer<20000} {
							incr plzcnt
							set plztimer [expr sqrt($plzcnt)*$plzstarttimer*(0.8+rand()*0.45)]
						}
						set nopilz 0
						return
					} else {
						set phlist [obj_query this "-class Pilzhut -range 3 -flagneg \{locked contained\}"]
						if {$phlist==0} {set phlist ""}
						set pslist [obj_query this "-class Pilzstamm -range 3 -flagneg \{locked contained\}"]
						if {$pslist==0} {set pslist ""}
						set phl [llength $phlist]
						set psl [llength $pslist]
						if {$psl+$phl>8} {
							if {$psl<$phl-5} {
								del [lindex $phlist [irandom $phl]]
							} elseif {$phl<$psl-2} {
								del [lindex $pslist [irandom $psl]]
							}
							//log "Something deleted near Pilz [get_ref this] ($psl,$phl)"
						}
					}
				}
			}
			timer_event this evt_pilz_aging -userid 1 -repeat 0 -interval 1 -attime [expr [gettime] + $plztimer+[expr $plzstarttimer*(0.8+rand()*0.45)]]
		}
	}

	handle_event evt_pilz_aging {
		nachwuchs_pilz
	}
}

# Mushroom stem
autodef_SimpleItem Pilzstamm pilzstamm.standard	1

# Mushroom hat
def_class Pilzhut food material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl

	class_defaultanim pilzhut.standard

	def_event evt_timer_destruction
	handle_event evt_timer_destruction {
		if { [is_contained this] } {
			timer_event this evt_timer_destruction -repeat 1 -interval 1 -userid 0 -attime [expr {[gettime] + 600}]
			return
		}

		set_forceipol this 1
		set_hoverable this 0
		set_physic this 0
		set_storable this 0

		set_vel this {0 0.03 0}

		timer_event this evt_timer_deletion -repeat 1 -interval 1 -userid 0 -attime [expr {[gettime] + 15}]
	}

	def_event evt_timer_deletion
	handle_event evt_timer_deletion {
		del this
	}

	obj_init {
		call scripts/classes/items/calls/resources.tcl

		set_anim this pilzhut.standard 0 $ANIM_STILL
		set_hoverable this 1
		set_physic this 1
		set_storable this 1

		timer_event this evt_timer_destruction -repeat 1 -interval 1 -userid 0 -attime [expr {[gettime] + 900}]
	}
}
