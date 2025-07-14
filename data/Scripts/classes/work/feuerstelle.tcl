call scripts/debug.tcl

def_class Feuerstelle wood production 0 {} {

	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	#
	method prod_item_actions {item} {
		global BOXED_CLASSES
		set exp_incr [call_method this prod_item_exp_incr $item]
		set exp_infls [call_method this prod_item_exp_infl $item]
		set exp_infl [prod_getgnomeexper [get_current_worker] $exp_infls]
		set materiallist [call_method this prod_item_materials $item]
		set rlst [list]

        if { [lsearch $BOXED_CLASSES [get_class_type $item]] != -1 } {
	        lappend rlst "prod_create_itemtype_ppinv_hidden Halbzeug_kiste"
	        lappend rlst "prod_go_near_workdummy 3 0.5 0 0"
	        lappend rlst "prod_turnright"
	        lappend rlst "prod_anim benda"
	     	lappend rlst "prod_beam_itemtype_near_dummypos Halbzeug_kiste 3 1 0 0"
	        lappend rlst "prod_anim bendb"
    	    lappend rlst "prod_goworkdummy 2"
		}

        foreach material $materiallist {
            if { [check_method [get_objclass this] "prod_actions_$material"] } {
                set rlst [concat $rlst [call_method this "prod_actions_$material" "$material" "$exp_infl" "$item"]]
                lappend rlst "prod_exp $exp_incr [expr 1.0/[llength $materiallist]]"
            } else {
            	log WARN "[get_objname this] No prod_actions method for $material (calling prod_actions_default)"
                set rlst [concat $rlst [call_method this "prod_actions_default" "$material" "$exp_infl" "$item"]]
            }
	        if { [lsearch $BOXED_CLASSES [get_class_type $item]] != -1 } {
        	 	lappend rlst "prod_go_near_workdummy 3 0.5 0 0"
            	lappend rlst "prod_turnright"
            	lappend rlst "prod_anim_loop_expinfl put 1 2 $exp_infl"
			}
        }

        if { [lsearch $BOXED_CLASSES [get_class_type $item]] != -1 } {
	        lappend rlst "prod_go_near_workdummy 3 0.5 0 0"
    	    lappend rlst "prod_turnright"
    	    lappend rlst "prod_anim puta"
   	    	lappend rlst "prod_createproduct_inv_boxed $item; prod_itemtype_change_look Halbzeug_kiste geschlossen"
	        lappend rlst "prod_anim putb"
       		lappend rlst "prod_anim takeboxa"
       		lappend rlst "prod_itemtype_change_look Halbzeug_kiste tragen; prod_link_itemtype_to_hand Halbzeug_kiste"
            lappend rlst "prod_anim takeboxb"
 			lappend rlst "prod_goworkdummy_with_box 2"
			lappend rlst "prod_createproduct_box_with_dummybox $item"
		} else {
			lappend rlst "prod_goworkdummy 2"
			for { set i 0 } { $i < [call_method this prod_item_number2produce $item] } { incr i } {
		        lappend rlst "prod_createproduct_rndrot $item"
		    }
        }

        lappend rlst "prod_turnfront"
		lappend rlst "prod_anim tired"

		return $rlst
	}

	#
	method prod_actions_Pilzhut {itemtype exp_infl production} {
        set rlst [list]

		if { $item == "Grillpilz" } {
			lappend rlst "prod_goworkdummy 0"
			lappend rlst "prod_turnfront"
			lappend rlst "prod_anim hungry"
			lappend rlst "prod_turnright"
			if { $exp_infl < 0.1 } {
				set i 5
			} else {
				set i [expr {1 + int(0.5 / $exp_infl)}]
			}
			for { set j 0 } { $j < $i } { incr j } {
				lappend rlst "prod_blowright; prod_anim fire"
			}
    	    lappend rlst "prod_walk_and_consume_itemtype $itemtype"
			lappend rlst "prod_goworkdummy 2"
			lappend rlst "prod_turnback"
			lappend rlst "prod_machineanim feuerstelle.pilz; prod_anim_loop_expinfl workatfire 1 3 $exp_infl"
			lappend rlst "prod_goworkdummy 3"
			lappend rlst "prod_turnback"
			lappend rlst "prod_anim windstart"
			lappend rlst "prod_machineanim feuerstelle.pilzdreh; prod_anim_loop_expinfl windloop 3 9 $exp_infl"
			lappend rlst "prod_anim windend; prod_machineanim feuerstelle.pilz"
			lappend rlst "prod_goworkdummy 2"
			lappend rlst "prod_turnback"
			lappend rlst "prod_anim workatfire"
			lappend rlst "prod_machineanim feuerstelle.brennt"
			return $rlst
		}

        lappend rlst "prod_walk_and_hide_itemtype $itemtype"
        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnright"
       	lappend rlst "prod_anim benda"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 2"
       	lappend rlst "prod_anim bendb"
       	lappend rlst "prod_anim workfloorholz"
   	    lappend rlst "prod_call_method set_chips 1; prod_call_method set_dust 1"
       	lappend rlst "prod_anim_loop_expinfl workfloorholz 1 4 $exp_infl"
   	    lappend rlst "prod_call_method set_chips 0; prod_call_method set_dust 0"
        lappend rlst "prod_walk_and_consume_itemtype $itemtype"

		return $rlst
	}

	#
	method prod_actions_Hamster {itemtype exp_infl production} {
        set rlst [list]

		lappend rlst "prod_goworkdummy 0"
		lappend rlst "prod_turnfront"
		lappend rlst "prod_anim hungry"
		lappend rlst "prod_turnright"
		if { $exp_infl < 0.1 } {
			set i 5
		} else {
			set i [expr {1 + int(0.5 / $exp_infl)}]
		}
		for { set j 0 } { $j < $i } { incr j } {
			lappend rlst "prod_blowright; prod_anim fire"
		}
   	    lappend rlst "prod_walk_and_consume_itemtype $itemtype"
		lappend rlst "prod_goworkdummy 2"
		lappend rlst "prod_turnback"
		lappend rlst "prod_machineanim feuerstelle.hamster; prod_anim_loop_expinfl workatfire 1 3 $exp_infl"
		lappend rlst "prod_goworkdummy 3"
		lappend rlst "prod_turnback"
		lappend rlst "prod_anim windstart"
		lappend rlst "prod_machineanim feuerstelle.hamsterdreh; prod_anim_loop_expinfl windloop 3 9 $exp_infl"
		lappend rlst "prod_anim windend; prod_machineanim feuerstelle.hamster"
		lappend rlst "prod_goworkdummy 2"
		lappend rlst "prod_turnback"
		lappend rlst "prod_anim workatfire"
		lappend rlst "prod_machineanim feuerstelle.brennt"

		return $rlst
	}

	#
	method prod_actions_Pilzstamm {itemtype exp_infl production} {
		set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"
        set itemtype Halbzeug_holz
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnright"
       	lappend rlst "prod_anim benda"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 2"
       	lappend rlst "prod_anim bendb"

       	lappend rlst "prod_anim workfloorholz"
   	    lappend rlst "prod_call_method set_chips 1; prod_call_method set_dust 1"
       	lappend rlst "prod_anim_loop_expinfl workfloorholz 1 4 $exp_infl"
   	    if { [random 1.0] > $exp_infl } {
	   	    lappend rlst "prod_call_method set_chips 0; prod_call_method set_dust 0"
			lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_anim dontknow"
	   	    lappend rlst "prod_call_method set_chips 1; prod_call_method set_dust 1"
			lappend rlst "prod_anim_loop_expinfl workfloorholz 1 2 $exp_infl"
   	    }
		if { [random 1.0] < 0.5 } {
       		lappend rlst "prod_itemtype_change_look $itemtype kant"
		} else {
       		lappend rlst "prod_itemtype_change_look $itemtype half"
		}
       	lappend rlst "prod_anim_loop_expinfl workfloorholz 1 4 $exp_infl"
   	    lappend rlst "prod_call_method set_chips 0; prod_call_method set_dust 0"
        lappend rlst "prod_walk_and_consume_itemtype $itemtype"

		return $rlst
	}

	#
	method prod_actions_Stein {itemtype exp_infl production} {
		set rlst [list]

        lappend rlst "prod_walk_and_consume_itemtype $itemtype"
        set itemtype Halbzeug_stein
        lappend rlst "prod_create_itemtype_ppinv_hidden $itemtype"
        lappend rlst "prod_goworkdummy 1"
        lappend rlst "prod_turnright"
       	lappend rlst "prod_anim benda"
        lappend rlst "prod_beam_itemtype_to_dummypos $itemtype 2"
       	lappend rlst "prod_anim bendb"

       	lappend rlst "prod_anim workfloorstein"
   	    lappend rlst "prod_call_method set_dust 1"
       	lappend rlst "prod_anim_loop_expinfl workfloorstein 1 4 $exp_infl"
   	    if { [random 1.0] > $exp_infl } {
	   	    lappend rlst "prod_call_method set_dust 0"
			lappend rlst "prod_anim scratchhead"
			lappend rlst "prod_anim dontknow"
	   	    lappend rlst "prod_call_method set_dust 1"
			lappend rlst "prod_anim_loop_expinfl workfloorstein 1 2 $exp_infl"
   	    }
   		lappend rlst "prod_itemtype_change_look $itemtype mauer"
       	lappend rlst "prod_anim_loop_expinfl workfloorstein 1 4 $exp_infl"
   	    lappend rlst "prod_call_method set_dust 0"
        lappend rlst "prod_walk_and_consume_itemtype $itemtype"

		return $rlst
	}

	#
    method prod_actions_default {itemtype exp_infl production} {
        return [call_method this prod_actions_Pilzhut $itemtype $exp_infl $production]
    }

	#
	method get_eat_objects {classlst} {
		set rlst [list]
		foreach classname $classlst {
			set reflst [obj_query this -class $classname -range 7 -flagneg {contained locked}]
			if { $reflst != 0 } {
				lappend rlst [llength $reflst]
			} else {
				lappend rlst 0
			}
		}
		return $rlst
	}

	#
	method get_certain_object {classname} {
		set item [obj_query this -class $classname -range 8 -flagneg {contained locked} -limit 1]
		if { ![get_lock $item] } {
			return $item
		} else {
			log ERROR "Gefundenes Item Nr. $item ([get_objname $item]) war gelockt!"
			return 0
		}
	}

	#
	method ask_for_seat {} {
		if { [prod_guest guestfree this] / $prod_guest_seats } { return 0 } { return 1 }
	}

	#
	method reserve_seat {ref} {
		for { set i $prod_guest_seats } { $i < $prod_guest_waits } { incr i } {
			if { [prod_guest guestget this $i] == 0 } {
				prod_guest guestset this $i $ref
				return $i
			}
		}
		return 0
	}

	#
	method set_dust {flag} {
		set_particlesource this 1 $flag
	}

	#
	method set_chips {flag} {
		set_particlesource this 2 $flag
	}

	#
	method deinit_production {} {
		call_method this set_dust 0
		call_method this set_chips 0
	}

	#
    method init {} {
    	set_collision this 1

		change_particlesource this 0 0 {0 -0.1 0} {0 0 0} 32 1 0
		set_particlesource this 0 1
		change_particlesource this 1 19 {0 0 0.5} {0.5 0.5 0.5} 32 2 0 2
		set_particlesource this 1 0
		change_particlesource this 2 26 {0 -0.2 0.2} {0 0 0} 64 1 0 2
		set_particlesource this 2 0

		change_light this {0 -0.1 0} 4 "1 0.9 0.7"
		set_light this 1
    }

	class_defaultanim feuerstelle.brennt
	class_fightdist 1.5
	class_flagoffset -1.0 -1.0

	# Constructor
	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this feuerstelle.brennt 0 $ANIM_LOOP
		set_energyclass this $tttenergycons_Feuerstelle
		set_energyconsumption this $tttenergycons_Feuerstelle
		set_inventoryslotuse this 1

		# Delayed invoke of init
		timer_event this evt_timer_init -repeat 1 -interval 1 -userid 0 -attime [expr {[gettime] + 1}]

		# Seats to eat
		prod_guest addlink this 5
		prod_guest addlink this 6
		prod_guest addlink this 7
		set prod_guest_seats 3
		prod_guest addlink this 0
		prod_guest addlink this 1
		prod_guest addlink this 2
		prod_guest addlink this 3
		prod_guest addlink this 4
		set prod_guest_waits 8

		sparetime this announce eat

		# Override!
		proc get_build_dummies {} {
			return {16 16 17}
		}

		# Override!
		proc get_buildup_anis {} {
			return {unten_rechtsstein unten_rechtsholz unten_linksholz}
		}

		# Override!
		proc get_damage_dummies {} {
			return {20 28}
		}

		# Override!
		proc get_object_groups {} {
			return {culinary production}
		}
	}

	# Dtor
	obj_exit {
		sparetime this disannounce
	}
}
