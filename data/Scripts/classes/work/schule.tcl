call scripts/misc/utility.tcl

def_class _Unterricht service material 2 {} {}

def_class Schule service production 2 {} {

	class_fightdist 2.0

	method prod_item_actions item {
		set rlst [list]
		lappend rlst "prod_switch_schedule 0"
		lappend rlst "prod_goworkdummy 0"
		lappend rlst "prod_turnright"
		set seatoccup 0
		for {set iseat 2} {$iseat<8} {incr iseat} {
			if [obj_valid [prod_guest guestget this $iseat]] {
				set seatoccup 1
			} else {
				prod_guest guestset this $iseat 0
			}
		}
		if $seatoccup {
			set schoolstopanims {cough bend scratch leftright breathe wipenose}
			set whichstopanimcodes [string range 00123456789 1 [llength $schoolstopanims]]
			for {set whichstopanims {}} {[llength $whichstopanims]<3} {} {
				set nextanim [irandom [string length $whichstopanimcodes]]
				lappend whichstopanims [lindex $schoolstopanims [string index $whichstopanimcodes $nextanim]]
				set whichstopanimcodes [string replace $whichstopanimcodes $nextanim $nextanim]
			}
			lappend rlst "prod_anim talkc"
			lappend rlst "prod_anim talkd"
			lappend rlst "prod_goworkdummy 1"
			lappend rlst "prod_turnright"
			lappend rlst "prod_anim talkc"
			lappend rlst "prod_turnback"
			lappend rlst "prod_anim boardwrite"
			lappend rlst "prod_anim boardwrite"
			lappend rlst "prod_anim boardwrite"
			lappend rlst "prod_turnright"
			lappend rlst "prod_anim talkd"
			lappend rlst "prod_goworkdummy 3"
			lappend rlst "prod_school_checkrows \{4 5 6 7\} 14"
			lappend rlst "prod_turnright"
			if {rand()<0.3} {
				lappend rlst "prod_waittime 0.2"
			} else {
				lappend rlst "prod_anim [lindex $whichstopanims 0]"
			}
			lappend rlst "prod_goworkdummy 5"
			lappend rlst "prod_school_checkrows \{6 7\} 7"
			lappend rlst "prod_turnright"
			if {rand()<0.3} {
				lappend rlst "prod_waittime 0.2"
			} else {
				lappend rlst "prod_anim [lindex $whichstopanims 1]"
			}
			lappend rlst "prod_goworkdummy 7"
			lappend rlst "prod_turnright"
			if {rand()<0.3} {
				lappend rlst "prod_waittime 0.2"
			} else {
				lappend rlst "prod_anim [lindex $whichstopanims 2]"
			}
			lappend rlst "prod_school_seat 7 right"
			lappend rlst "prod_school_seat 6 left"
			lappend rlst "prod_goworkdummy 5"
			lappend rlst "prod_school_seat 5 right"
			lappend rlst "prod_school_seat 4 left"
			lappend rlst "prod_goworkdummy 3"
			lappend rlst "prod_school_seat 3 right"
			lappend rlst "prod_school_seat 2 left"
			lappend rlst "prod_anim invent_b"
			lappend rlst "prod_goworkdummy 0"
			lappend rlst "prod_turnright"
			lappend rlst "prod_anim talki"
		} else {
			lappend rlst "prod_anim impatient"
		}
		lappend rlst "prod_anim standsleepstart"
		lappend rlst "prod_anim standsleeploop"
		lappend rlst "prod_anim standsleeploop"
		lappend rlst "prod_anim standsleeploop"
		lappend rlst "prod_anim standsleeploop"
		lappend rlst "prod_anim standsleepstop"
		lappend rlst "prod_switch_schedule 1"
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
		// Entfernen ungueltiger Schueler
		for {set is 2} {$is<8} {incr is} {
			set guest [prod_guest guestget this $is]
			if {$guest!=0} {
				if {[obj_valid $guest]} {
					if {[get_objclass $guest]!="Baby"} {
						prod_guest guestremove this $guest
						log "Schule [get_ref this]: removed $guest (no Baby)"
						prod_guest guestremove this 0
					}
				}
			}
		}
	}

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl


	class_defaultanim schule.standard
	class_flagoffset 3.5 4.5

	obj_init {
		set_anim this schule.standard 0 $ANIM_LOOP
		set_inventoryslotuse this 1
		set_collision this 1
		set_prod_switchmode this 1
		set_prod_schedule this 1
		set current_worker 0
		set_energyconsumption this 0

		call scripts/misc/genericprod.tcl
		timer_event this evt_timer0 -repeat -1 -interval 5 -userid 0

		prod_guest setlink this 2 2
		prod_guest setlink this 3 3
		prod_guest setlink this 4 4
		prod_guest setlink this 5 5
		prod_guest setlink this 6 6
		prod_guest setlink this 7 7

		set build_dummys [list 12 13 14 15 16 17 18]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsholz unten_rechtsholz oben_linksholz oben_linksholz unten_rechtsholz unten_rechtsholz unten_rechtsholz}
		set damage_dummys {20 26}

	}
}

