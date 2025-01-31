//# STOPIFNOT FULL
call scripts/misc/utility.tcl

def_class Energie_ energy material 1 {} {}

def_class Wasserrad wood energy 2 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 1.6

	method prod_item_actions item {
		set rlst [list]

		// sollte eigentlich nie aufgerufen werden, da das Wasserrad sich selbst versorgt

		return $rlst
	}

	def_event evt_timer_localinit 
	handle_event evt_timer_localinit {
		set_energystore this $tttenergymaxstore_Wasserrad
	}


	def_event evt_timer0

	handle_event evt_timer0 {
		global active

		if {[get_boxed this]} {
			return
		}

		// Wasserrad füllt automatisch auf, wenn es im Wasser steht
		if {[get_energystore this] < $tttenergymaxstore_Wasserrad  &&  [isunderwater [get_pos this]]} {
			set_energystore this [expr [get_energystore this] + $tttenergyyield_Wasserrad]
		}

		// wenn jemand von uns Strom zieht ODER wir im Wasser stehen - Animation ein
		if {([get_energysourceload this] > 0  ||  [isunderwater [get_pos this]]) &&  $active ==0} {
			set_anim this wasserrad.drehen 0 $ANIM_LOOP			;// work-anim
			set active 1
		}
		// sonst aus
		if {([get_energysourceload this] == 0  &&  ![isunderwater [get_pos this]]) &&  $active == 1} {
			set_anim this wasserrad.standard 0 $ANIM_STILL		;// idle-anim
			set active 0
		}
	}

	method deinit_production {} {
	}


    method init {} {
    	global active

    	set_collision this 1
		set active 0
    }


	class_defaultanim wasserrad.standard
	class_flagoffset 1.7 2.0

	obj_init {
		global energyyield
		call scripts/misc/genericprod.tcl

		set_anim this wasserrad.standard 0 $ANIM_LOOP
		set_energyrange this $tttenergyrange_Wasserrad
		set_energyclass this $tttenergyclass_Wasserrad
		set_energymaxstore this $tttenergymaxstore_Wasserrad
		set_inventoryslotuse this 1

		set active 0
		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]
		timer_event this evt_timer_localinit -repeat 1 -interval 1 -userid 0 -attime [expr [gettime]+1]
		timer_event this evt_timer0 -repeat -1 -interval 2 -userid 0

		set energyyield $tttenergyyield_Wasserrad
		
		set build_dummys [list 12 13 14 15 16 17 18]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsstein unten_rechtsstein unten_linksstein unten_linksstein oben_rechtsstein oben_linksstein oben_rechtsholz}
		set damage_dummys {20 26}

	}
}

