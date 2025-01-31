//# STOPIFNOT FULL
call scripts/misc/utility.tcl

def_class _Kungfu fight material 1 {} {}
def_class _Schwertkampf fight material 1 {} {}
def_class _Zweihandkampf fight material 1 {} {}
def_class _Verteidigung fight material 1 {} {}
def_class _Schusswaffen fight material 1 {} {}

def_class Dojo wood production 3 {} {

	class_fightdist 2.0

	method prod_items {} {
		return { _Kungfu _Schwertkampf _Zweihandkampf _Schusswaffen _Verteidigung }
	}

	method prod_item_materials item {
		return [list]
	}

	method prod_item_tools item {
		return [list]
	}

	method prod_preinvented {} {
		return { _Kungfu _Schwertkampf _Zweihandkampf _Schusswaffen _Verteidigung }
	}

	method prod_item_blueprint item {
		return [list]
	}

	method prod_inventions {} {
		return [list]
	}

	method prod_item_actions item {
		global current_worker
		set rlst [list]
		set richtung_list [list front left right back]
		set richtung [lindex $richtung_list [expr round([random 0 [expr [llength $richtung_list] - 1]])]]

		set art [string map {_Kungfu Kungfu _Schwertkampf Sword _Zweihandkampf Twohanded _Verteidigung Defense _Schusswaffen Ballistic} $item]

		if {$art != "Ballistic"} {
			lappend rlst "prod_goworkdummy 0 2" ;#2 steht für Speed -> er rennt
			lappend rlst "prod_turn$richtung"
		} else {
			lappend rlst "prod_goworkdummy 2 2" ;#2 steht für Speed -> er rennt
			lappend rlst "prod_turnback"
		}

		switch $art {
			"Kungfu" {
						lappend rlst "prod_anim standtokungfu"
						lappend rlst "prod_anim kungfustillani"
					}
			"Sword" {lappend rlst "prod_changetool Trainierschwert"}
			"Twohanded" {lappend rlst "prod_changetool Trainier_2h_Schwert"}
			"Defense" {lappend rlst "prod_changetool Trainierschild 1"}
			//"Ballistic" {lappend rlst "prod_changetool Trainierbogen 1"}
		}

		set erfahrung [get_attrib $current_worker exp_F_$art]
		log "ART = $art   ----  ERFAHRUNG = $erfahrung"
		if {$erfahrung < 1.0} {
			lappend rlst "prod_Dojo_anfaenger $item"
		} else {
			lappend rlst "dojo_profi_training"
		}
		if {$item == "_Schusswaffen"} {
			lappend rlst "prod_goworkdummy 5"
			if {$erfahrung < 1.0} {
				set freude_liste [list bowllose cheer bowllose bowllose]
			} else {set freude_liste [list bowllose cheer cheer cheer]}
			set anim [lindex $freude_liste [expr round([random 0 [expr [llength $freude_liste] - 1]])]]
			lappend rlst "prod_anim $anim"
		}
		return $rlst
	}

	method pack_plant {} {
	}

	method announce_worker {ref} {
		set current_worker $ref
	}

	def_event evt_timer0

	handle_event evt_timer0 {
		if {(0==$current_worker)||(![obj_valid $current_worker])||([ref_get $current_worker current_workplace]!=[get_ref this])} {
			set_prod_schedule this 1
		}
	}

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_defaultanim dojo.standard
	class_flagoffset 1.9 5.1

	obj_init {
		call scripts/misc/genericprod.tcl
		set_anim this dojo.standard 0 $ANIM_LOOP
		set_collision this 1
		set_inventoryslotuse this 1
		set_prod_switchmode this 1
		set_prod_schedule this 1

		set current_worker 0
		set build_dummys [list 16 17 18 19 20 21 22 23]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsholz unten_linksholz oben_rechtsholz oben_linksholz oben_rechtsholz oben_rechtsholz oben_linksholz oben_rechtsholz}
		set damage_dummys {24 31}

		set_prod_exclusivemode this 1
		set_energyconsumption this 0
		timer_event this evt_timer0 -userid 0 -repeat -1 -interval 5
	}
}

