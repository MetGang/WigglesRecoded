//# STOPIFNOT FULL
call scripts/misc/utility.tcl

def_class Energie energy material 1 {} {}


def_class Laufradhamster food tool 2 {} {
	call scripts/misc/autodef.tcl
	obj_init {
		call scripts/misc/autodef.tcl
		set_anim this hamster.stand_anim 0 $ANIM_LOOP
		set_physic    this 0
		set_hoverable this 0
	}
}

def_class Laufrad wood energy 2 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 1.5

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
            	log "WARNING: laufrad.tcl: no prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl"]]
            }
        }

		return $rlst
	}


	// Pilzhut

	method prod_actions_Pilzhut {itemtype exp_infl} {
		global energyyield tttenergymaxstore_Laufrad
        set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"
		lappend rlst "prod_go_near_workdummy 2 -0.3 0.0 0.0"
		lappend rlst "prod_turnback"
        lappend rlst "prod_anim_loop_expinfl workatfire 1 3 $exp_infl"
		lappend rlst "energy_inc_energystore $energyyield $tttenergymaxstore_Laufrad"

		return $rlst
	}


// default

    method prod_actions_default {itemtype exp_infl} {
        return [call_method this prod_actions_Pilzstamm $itemtype $exp_infl]
    }


	def_event evt_timer_localinit 
	handle_event evt_timer_localinit {
		set_energystore this $tttenergymaxstore_Laufrad
	}

	def_event evt_timer0
	handle_event evt_timer0 {
		global active hamsterid

		if {[get_boxed this]} {
			return
		}

		// neuen "Produktionsauftrag" erteilen, wenn Energievorrat knapp
		if {[get_energystore this] < $tttenergymaxstore_Laufrad} {
			set i [expr $tttenergymaxstore_Laufrad - [get_energystore this]]
			set i [expr int ($i / $tttenergyyield_Laufrad)]
			if {[get_prod_slot_cnt this Energie] < $i} {
				log "Laufrad: erteilte Produktionsaufträge: $i"
			}
			set_prod_slot_cnt this Energie $i
		}

		// wenn jemand von uns Strom zieht - Animation ein
		if {[get_energysourceload this] > 0  &&  $active ==0} {
			set_anim this laufrad.drehen 0 $ANIM_LOOP			;// work-anim
			if {[obj_valid $hamsterid]} {
				set_anim $hamsterid hamster.laufrad_loop 0 $ANIM_LOOP
			}
			set active 1
		}
		// sonst aus
		if {[get_energysourceload this] == 0 &&  $active ==1} {
			set_anim this laufrad.standard 0 $ANIM_STILL		;// idle-anim
			if {[obj_valid $hamsterid]} {
				set_anim $hamsterid hamster.stand_anim 0 $ANIM_LOOP
			}
			set active 0
		}
	}

	method deinit_production {} {
	}


    method init {} {
    	global active hamsterid

    	set_collision this 1
		if {$hamsterid <= 0} {
			set hamsterid [new Laufradhamster]
			set_pos $hamsterid [vector_add [get_pos this] {0 -0.35 0}]
			set_rot $hamsterid {0 1.157 0}
			set_anim $hamsterid hamster.stand_anim 0 $ANIM_LOOP
		}

		set active 0
    }


	// Methode aus genericprod.tcl überlagern
    method prepare_packtobox {} {
		global hamsterid

		set_light this 0			;# abschalten eventuell vorhandener lichtquellen
		;# gib alle partikelquellen frei
		for {set index 0} {$index<16} {incr index} { free_particlesource this $index }
		if {$hamsterid > 0} {
			if {[obj_valid $hamsterid]} {
				del $hamsterid
			}
		}
		set hamsterid -1
    }


	class_defaultanim laufrad.standard
	class_flagoffset 1.2 1.5

	obj_init {
		global active energyyield
		call scripts/misc/genericprod.tcl

		set_anim this laufrad.standard 0 $ANIM_LOOP
		set_energyrange this $tttenergyrange_Laufrad
		set_energyclass this $tttenergyclass_Laufrad
		set_energymaxstore this $tttenergymaxstore_Laufrad
		set_energystore this $tttenergymaxstore_Laufrad
		set_inventoryslotuse this 1

		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]
		timer_event this evt_timer_localinit -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]
		timer_event this evt_timer0 -repeat -1 -interval 2 -userid 0

		set active 0
		set hamsterid -1
		set energyyield $tttenergyyield_Laufrad

		set build_dummys [list 12 13 14 15 16]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsholz unten_linksholz unten_linksholz oben_rechtsholz oben_linksholz}
		set damage_dummys {20 24}
	}
}

