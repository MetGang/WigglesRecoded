call scripts/debug.tcl

# Used in: Bar
proc prod_setworkdummy {dummy} {
	global current_workplace
	set pos [vector_add [get_pos $current_workplace] [get_linkpos $current_workplace $dummy]]
	set_pos this $pos
	return true
}

# Used in: Schule
proc prod_switch_schedule {status} {
	global current_workplace
	call_method $current_workplace announce_worker [expr {!$status * [get_ref this]}]
	set_prod_schedule $current_workplace $status
	return true
}

# Used in: Labor
proc prod_putdown {itemtype} {
	set idx [inv_find this $itemtype]
	if { $idx != -1 } {
		putdown [inv_get this $idx]
	} else {
		log WARN "prod_putdown $itemtype fails ([inv_list this])"
		return false
	}
	return true
}

# Unused!
proc prod_putdown_obj {obj} {
	set idx [inv_find this $itemtype]
	if { $idx != -1 } {
		set obj [inv_get this $idx]
		putdown $obj
		return $obj
	} else {
		log WARN "prod_putdown_obj $itemtype fails ([inv_list this])"
		return false
	}
	return 0;
}

# Used in: Farm
proc prod_pickup_item {item} {
	pickup $item
	return true
}

# Unused!
proc prod_putdown_item {item} {
	putdown $item
	return true
}

# Used in many
proc prod_goworkdummy {dummyid {speed 0}} {
	global current_workplace
	walk_dummy $current_workplace $dummyid $speed
	return true
}

# Used in many
proc prod_goworkdummy_with_box {dummyid {speed 0}} {
	global current_workplace
	walk_dummy_with_box $current_workplace $dummyid $speed
	return true
}

# Used in: Wachhaus
proc prod_gopos {pos} {
	walk_pos $pos
	return true
}

# Used in many
proc prod_anim {animname} {
	play_anim $animname
	return true
}

# Unused!
proc prod_setanim {animname} {
	global ANIM_LOOP
	set_anim this $animname 0 $ANIM_LOOP
	return true
}

# Used in: Bar
proc prod_anim_exp {animnames exp_infls minreps maxreps args} {
	if {1==[llength $args]} {
		set exper [get_attrib this $exp_infls]
		set exp_incrs [list [list $exp_infls $args]]
		set part 1.0
	} {
		set exp_incrs [lindex $args 0]
		set part [lindex $args 1]
		set exper 1.0
		foreach exp_infl $exp_infls {
			if {[get_attrib this [lindex $exp_infl 0]]<[lindex $exp_infl 1]} {
				set exper [expr {($exper*([get_attrib this [lindex $exp_infl 0]]/[lindex $exp_infl 1]))}]
			}
		}
		if {[llength $exp_infls]>0} {
			set exper [expr {pow($exper,1/[llength $exp_infls])}]
		}
	}
	set reps [expr {$maxreps - ($maxreps - $minreps) * $exper - 0.1}]
	log PROCS "prod_anim_exp: exp_infls($exp_infls) min($minreps) max($maxreps) exper($exper) reps($reps) exp_incrs($exp_incrs)"
	for {set i 0} {$i<$reps} {incr i} {
		foreach animname $animnames {
			if [string match "blow*" $animname] {
				tasklist_add this "prod_$animname"
			} elseif [string match "*.*" $animname] {
				tasklist_add this "prod_machineanim $animname"
			} else {
				tasklist_add this "play_anim $animname"
			}
		}
		if {[llength $args]>0} {
			foreach exp_incr $exp_incrs {
				set genre [lindex $exp_incr 0]
				set increase [lindex $exp_incr 1]
				if {[get_attrib this $genre]<[expr {$increase*100}]} {
					set increase [expr {$increase * $part / ceil($reps)}]
					tasklist_add this "add_expattrib this $genre $increase"
				}
			}
		}
	}
	return true
}

# Unused!
proc prod_blowleft {} {
	global current_workplace
	blow_particlesource $current_workplace 0 {-0.1 0 0}
	return true
}

# Used in: Feuerstelle
proc prod_blowright {} {
	global current_workplace
	blow_particlesource $current_workplace 0 {0.1 0 0}
	return true
}

# Unused!
proc prod_blowback {} {
	global current_workplace
	blow_particlesource $current_workplace 0 {0 0 -0.1}
	return true
}

# Unused!
proc prod_blowfront {} {
	global current_workplace
	blow_particlesource $current_workplace 0 {0 0 0.1}
	return true
}

# Used in many
proc prod_turnleft {} {
	rotate_toleft
	return true
}

# Used in many
proc prod_turnright {} {
	rotate_toright
	return true
}

# Used in many
proc prod_turnfront {} {
	rotate_tofront
	return true
}

# Used in many
proc prod_turnback {} {
	rotate_toback
	return true
}

# Used in: Dampfhammer
proc prod_turnclock {clock} {
	rotate_toclock $clock
	return true
}

# Used in: Bar, Farm
proc prod_turnangle {angle {anim ""}} {
	rotate_toangle $angle $anim
	return true
}

# Used in: Labor
proc prod_createproduct_inv {type} {
	global current_workplace
	sel /obj
	set nob [new $type]
	set_owner $nob [get_owner this]
	if {[inv_check this $nob] == 1} {
		inv_add this $nob
	} else {
		set_posbottom $nob [get_pos this]					;// Notfall-Aktion: Gegenstand fallenlassen
	}
	return true
}

# Used in many
proc prod_createproduct_inv_boxed {type args} {
	global current_workplace
	sel /obj
	set item [new $type]
	if {$args!=""} {
		set_objname $item [lindex $args 0]
		call_method $item set_m_anim [lindex $args 1]
	}
	set_visibility $item 0
	set_owner $item [get_owner this]
	call_method $item packtobox
	set_visibility $item 0
	if {[inv_check this $item] == 1} {
		inv_add this $item
	} else {
		set_posbottom $item [get_pos this]				;// Notfall-Aktion: Gegenstand fallenlassen
		set_visibility $item true
	}
	call_method $current_workplace job_finished

	return true;
}

# Used in: Schleiferei
proc prod_createproduct_box {type} {
	global current_workplace
	sel /obj
	set item [new $type]
	set_visibility $item 0
	set_owner $item [get_owner this]
	call_method $item packtobox
	set_visibility $item 0
	call_method $current_workplace job_finished
	if {[inv_check this $item] == 1} {
		inv_add this $item
	} else {
		set_posbottom $item [get_pos this]				;// Notfall-Aktion: Gegenstand fallenlassen
		set_visibility $item true
		return true
	}

	set itempos [get_place -center [get_pos $current_workplace] -rect -10 [hmin 1 [expr {11-[get_posz $current_workplace]}]] 10 [expr {13-[get_posz $current_workplace]}] -mindist 1.5 -random 2 -nearpos [get_pos this]]
	if {[lindex $itempos 0]<0} {
		set itempos [get_place -center [get_pos $current_workplace] -rect -10 [hmin 1 [expr {11-[get_posz $current_workplace]}]] 10 [expr {13-[get_posz $current_workplace]}] -mindist 1.5 -random 2 -nearpos [get_pos this] -materials false]
		if {[lindex $itempos 0]<0} {
			log "itempos not found! - createproduct_box"
			gnome_failed_work this
			stop_prod
			tasklist_clear this
			return true
		}
	}

	tasklist_addfront this "beam_from_inv_to_pos $item \{$itempos\};play_anim bendb"
	tasklist_addfront this "play_anim benda"
	tasklist_addfront this "rotate_towards \{$itempos\}"
	tasklist_addfront this "walk_near_item \{$itempos\} 0.7"

	return true
}

# Used in many
proc prod_createproduct_rndrot {type {relpos 0}} {
	global current_workplace
	sel /obj
	set item [new $type]
	set_visibility $item 0
	set_owner $item [get_owner this]
	set_roty $item [expr {[random 3.0] - 1.5}]
	call_method $current_workplace job_finished
	if {[inv_check this $item] == 1} {
		inv_add this $item
	} else {
		set_posbottom $item [get_pos this]				;// Notfall-Aktion: Gegenstand fallenlassen
		set_visibility $item true
		return true
	}

	if {$relpos == 0} {
		set itempos [get_place -center [get_pos $current_workplace] -rect -10 [hmin 1 [expr {11-[get_posz $current_workplace]}]] 10 [expr {13-[get_posz $current_workplace]}] -mindist 1.5 -random 2 -nearpos [get_pos this]]
		if {[lindex $itempos 0]<0} {
			set itempos [get_place -center [get_pos $current_workplace] -rect -10 [hmin 1 [expr {11-[get_posz $current_workplace]}]] 10 [expr {13-[get_posz $current_workplace]}] -mindist 1.5 -random 2 -nearpos [get_pos this] -materials false]
		}
	} else {
		set itempos [get_place -center [vector_add [get_pos $current_workplace] $relpos] -circle 10 -random 2 -nearpos [get_pos this]]
		if {[lindex $itempos 0]<0} {
			set itempos [get_place -center [vector_add [get_pos $current_workplace] $relpos] -circle 10 -random 2 -nearpos [get_pos this] -materials false]
		}
	}

	if {[lindex $itempos 0]<0} {
		set itempos [get_pos this]
		return true
	}

	tasklist_addfront this "beam_from_inv_to_pos $item \{$itempos\};play_anim bendb"
	tasklist_addfront this "play_anim benda"
	tasklist_addfront this "rotate_towards \{$itempos\}"
	tasklist_addfront this "walk_near_item \{$itempos\} 0.7"
	return true
}

# Used in: Farm
proc prod_laydown_infrontof_farm {item} {
	global current_workplace
	set cpos [vector_add [get_pos $current_workplace] {0 0 4}]
	set itempos [get_place -center $cpos -rect -3 -0.5 3 2 -mindist 1.2 -random 0.5]
	if {[lindex $itempos 0]<0} {
		set itempos [get_place -center $cpos -rect -3 -0.5 3 2 -mindist 1.2 -random 0.5 -materials false]
		if {[lindex $itempos 0]<0} {
			log "itempos not found! - laydown_infrontof_farm"
			gnome_failed_work this
			stop_prod
			tasklist_clear this
			return false
		}
	}
	tasklist_add this "walk_near_item \{$itempos\} 0.7"
	tasklist_add this "rotate_towards \{$itempos\}"
	tasklist_add this "play_anim benda" ;# prod_gnome_state this putdown $item
	tasklist_add this "beam_from_inv_to_pos $item \{$itempos\};set_roty $item [random 6.3];play_anim bendb"
	return true
}

# Used in: Farm
proc prod_sowparticles {type onoff} {
	switch $type {
		"Pilz" {set pt 17}
		"Hamster" {set pt 17}
		"Reithamster" {set pt 17}
		"Raupe" {set pt 17}
		default {set pt 17}
	}
	if {$onoff} {
		change_particlesource this 1 $pt {0 0 0} {0 0 0} 32 2 0 0
	}
	set_particlesource this 1 $onoff
	return true
}

# Unused!
proc prod_harvest {item} {
	harvest $item
	wait_time 0.5
	return true
}

# Used in many
proc prod_waittime {seconds} {
	wait_time $seconds
	return true
}

# Unused!
proc prod_workidle {} {
	wait_time 5
	return true
}

# Used in many
proc prod_changetool {tool {hand 0} {playanim 1}} {
	change_tool $tool $hand $playanim
	return true
}

# Used in: Bar
proc prod_changetoollook {look} {
	return [change_tool_look $look]
}

# Unused!
proc prod_set_materialneed_off {ref} {
	set_prod_materialneed $ref 0
	return true
}

# Unused!
proc prod_set_schedule_off {ref} {
	set_prod_schedule $ref 0
	return true
}

# Used in: Dampfmaschine, Laufrad, Reaktor
proc energy_inc_energystore {incval maxvalue} {
	global current_workplace
	set e [expr {[get_energystore $current_workplace] + $incval}]
	if {$e > $maxvalue} {
		set e $maxvalue
	}
	set_energystore $current_workplace $e
	return true
}


// Hilfsfunktion: liefert n�chstes (oder: args'tes) Item vom Typ in der Produktionsst�tte
// oder -1 wenn nicht gefunden

proc get_next_item_of_itemtype {itemtype args} {
	global current_workplace
	if {$args == ""  ||  $args == "{}"} {
		set n 1
	} else {
		set n [lindex $args 0]
	}
	// log "getnextitem $itemtype ($args) ($n)"
	if {$n == 1} {
		set idx [inv_find $current_workplace $itemtype]
		if {$idx < 0} {
			return -1
		}

		set obj [inv_get  $current_workplace $idx]
		return $obj
	}

	set idx [inv_find $current_workplace $itemtype]
	if {$idx < 0} {
		return -1
	}

	set n [expr $n - 1]
	set maxidx [expr [inv_cnt $current_workplace] - 1]

	while {$n > 0  &&  $idx < $maxidx} {
		incr idx
		set obj [inv_get $current_workplace $idx]
		if {$obj < 0} {
			return -1
		}
		if {[get_objclass $obj] == $itemtype} {
			set n [expr $n - 1]
			if {$n == 0} {
				return $obj
			}
		}
	}

	return -1
}

# Used in: Saegewerk, Schmiede, Waffenschmiede
proc prod_walk_itemtype {itemtype args} {
	set obj [get_next_item_of_itemtype $itemtype $args]
	if {$obj < 0} {
		return true
	}

	tasklist_add this "walk_pos \{[get_pos $obj]\}"
	return true
}

# Unused!
proc prod_consume {itemtype} {
	set idx [inv_find this $itemtype]
	if { $idx != -1 } {
		set obj [inv_get this $idx]
		inv_rem this $idx
		set_visibility $obj 0
		del $obj
//		log "$obj [get_objname $obj] removed from gnomes inventory"
		return true
	}
	global current_workplace
	set idx [inv_find $current_workplace $itemtype]
	if { $idx != -1 } {
		set obj [inv_get $current_workplace $idx]
		inv_rem $current_workplace $idx
		set_visibility $obj 0
		del $obj
//		log "$obj [get_objname $obj] removed from workplaces inventory"
		return true
	}
	return true
}

# Used in: Tempel
proc next_item_of_itemtype {itemtype} {
	global current_workplace
	set idx [inv_find $current_workplace $itemtype]
	if {$idx != -1} {
		set obj [inv_get $current_workplace $idx]
		set pos [get_pos $obj]
		set vis [get_visibility $obj]
		inv_rem $current_workplace $idx
		inv_add $current_workplace $obj
		set_visibility $obj $vis
		set_pos $obj $pos
	}
	return true
}

# Used in many
proc prod_consume_from_workplace {itemtype} {
	global current_workplace
	set idx [inv_find $current_workplace $itemtype]
	if { $idx != -1 } {
		set obj [inv_get $current_workplace $idx]
		inv_rem $current_workplace $idx
//		set_visibility $obj 0
		del $obj
//		log "$obj [get_objname $obj] removed from workplaces inventory"
		return true
	}
	return true
}

# Used in many
proc prod_set_item_rotation {itemtype rx ry rz args} {
	set obj [get_next_item_of_itemtype $itemtype $args]
	if {$obj < 0} {
		return true
	}

	tasklist_add this "set_rot $obj $rx $ry $rz"
	return true
}

# Used in: Dampfhammer, Schmiede, Schreinerei
proc prod_hide_itemtype {itemtype args} {
	set obj [get_next_item_of_itemtype $itemtype $args]
	if {$obj < 0} {
		return true
	}

	set_visibility $obj 0
	return true
}

# Used in many
proc prod_walk_and_hide_itemtype {itemtype args} {
	set obj [get_next_item_of_itemtype $itemtype $args]
	if {$obj < 0} {
		return true
	}

	set walkpos [get_place -center [get_pos $obj] -circle 2 -mindist 0.7 -except this -nearpos [get_pos this] -materials false]
	//log "itempos: [get_pos $obj]"
	//log "walkpos: $walkpos"
	if {[lindex $walkpos 0]<0} {
		set walkpos [get_pos $obj]
		log "walkpos not found, using itempos"
	}
	tasklist_add this "walk_pos \{$walkpos\}"
	tasklist_add this "rotate_towards $obj"
	tasklist_add this "play_anim benda"
	tasklist_add this "set_visibility $obj 0; play_anim bendb"
	return true
}

# Used in many
proc prod_call_method {name args} {
	global current_workplace
	eval "call_method $current_workplace $name $args"
	return true;
}

# Used in many
proc prod_anim_loop_expinfl {animname minreps maxreps exp_infl} {
	set reps [expr round((($maxreps - $minreps) * (1.0 - $exp_infl)) + $minreps)]
	while {$reps > 0} {
		tasklist_add this "play_anim $animname"
		incr reps -1
	}
	return true;
}

# Unused!
proc prod_code_loop_expinfl {code minreps maxreps exp_infl} {
	set reps [expr round((($maxreps - $minreps) * (1.0 - $exp_infl)) + $minreps)]
	while {$reps > 0} {
		tasklist_add this "$code"
		incr reps -1
	}
	return true;
}

# Used in many
proc prod_exp {exp_incrs part} {
	foreach exp_incr $exp_incrs {
		set genre [lindex $exp_incr 0]
		set factor [clan_exp_factor $genre]
		set increase [expr {[lindex $exp_incr 1]*$factor}]
		if {[get_attrib this $genre]<[expr $increase*100]} {
			set increase [expr $increase * $part]
			add_expattrib this $genre $increase
		}
	}
	return true;
}

# Used in: Saegewerk
proc prod_move_item {itemtype vx vy vz args} {
	global current_workplace
	set obj [get_next_item_of_itemtype $itemtype $args]
	if {$obj < 0} {
		return true
	}

	set newpos [vector_add [get_pos $obj] [vector_pack $vx $vy $vz]]
//	log "prod_move_item: newpos: $newpos"
	set_pos $obj $newpos
	set_visibility $obj 1
	set_physic $obj 0
	return true
}

# Used in: Kristallschmiede, Labor
proc prod_link_itemtype_to_dummy {itemtype dummy args} {
	global current_workplace
	set obj [get_next_item_of_itemtype $itemtype $args]
	if {$obj < 0} {
		return true
	}

	link_obj $obj $current_workplace $dummy
	set_visibility $obj 1
	return true
}

# Used in many
proc prod_beam_itemtype_to_dummypos {itemtype dummy args} {
	global current_workplace
	set obj [get_next_item_of_itemtype $itemtype $args]
	if {$obj < 0} {
		return true
	}

	set newpos [vector_add [get_linkpos $current_workplace $dummy] [get_pos $current_workplace]]
//  log "prod_beam_itemtype_to_dummypos: obj: $obj newpos: $newpos"
	set_physic $obj 0
	link_obj $obj
	set_pos $obj $newpos
	set_visibility $obj 1
	return true
}

# Used in many
proc prod_beam_itemtype_near_dummypos {itemtype dummy rx ry rz args} {
	global current_workplace
	if {[string first "." $args]!=-1} {
		set roty $args
		set args ""
		set rotate 1
	} else {
		set rotate 0
	}

	set obj [get_next_item_of_itemtype $itemtype $args]
	if {$obj < 0} {
		return true
	}

	set newpos [vector_add [get_linkpos $current_workplace $dummy] [get_pos $current_workplace]]
	set newpos [vector_add $newpos "$rx $ry $rz"]
//  log "prod_beam_itemtype_near_dummypos: obj: $obj newpos: $newpos"
	set_physic $obj 0
	link_obj $obj
	set_pos $obj $newpos
	if {$rotate} {set_roty $obj $roty}
	set_visibility $obj 1
	return true
}

# Used in many
proc prod_walk_and_consume_itemtype {itemtype args} {
	set obj [get_next_item_of_itemtype $itemtype $args]
	if {$obj < 0} {
		return true
	}

	set walkpos [get_place -center [get_pos $obj] -circle 2 -mindist 0.7 -except this -nearpos [get_pos this] -materials false]
	//log "walkpos: $walkpos"
	if {[lindex $walkpos 0]<0} {
		set walkpos [get_pos $obj]
		log "walkpos not found, using itempos"
	}
	tasklist_add this "walk_pos \{$walkpos\}"
	tasklist_add this "rotate_towards $obj"
	tasklist_add this "play_anim benda"
	tasklist_add this "set_visibility $obj 0"   // schneller
	tasklist_add this "del $obj"
	tasklist_add this "play_anim bendb"
	return true
}

# Used in many
proc prod_machineanim {animname args} {
	global current_workplace
	global ANIM_ONCE
	global ANIM_LOOP
	if {[lsearch $args "once"] != -1} {
		set_anim $current_workplace $animname 0 $ANIM_ONCE
	} else {
		set_anim $current_workplace $animname 0 $ANIM_LOOP
	}

	if {[lsearch $args "stop"] != -1} {
		call_method $current_workplace stop_anim_timer
	}
	if {[lsearch $args "start"] != -1} {
		call_method $current_workplace activate_anim_timer $animname
	}
	return true
}

# Used in many
proc prod_create_itemtype_ppinv_hidden {itemtype} {
	global current_workplace
	set obj [new $itemtype]
	set_hoverable $obj 0
	set_selectable $obj 0
	set_visibility $obj 0
	set_roty $obj [expr [random 3.0] - 1.5]
	inv_add $current_workplace $obj
	return true
}

# Used in many
proc prod_itemtype_change_look {itemtype look args} {
	set obj [get_next_item_of_itemtype $itemtype $args]
	if {$obj < 0} {
		return true
	}

	if {[check_method $itemtype change_look]} {
		call_method $obj change_look $look
	}
	return true
}

# Unused!
proc prod_turn_towards_itemtype {itemtype args} {
	set obj [get_next_item_of_itemtype $itemtype $args]
	if {$obj < 0} {
		return true
	}

	tasklist_add this "rotate_towards $obj"
}

# Used in many
proc prod_go_near_workdummy {dummyid dx dy dz} {
	global current_workplace

	set newpos [vector_add [get_linkpos $current_workplace $dummyid] [get_pos $current_workplace]]
	set newpos [vector_add $newpos "$dx $dy $dz"]
//    log "prod_go_near_workdummy: $newpos"
	walk_pos $newpos;

	return true
}

# Used in many
proc prod_link_itemtype_to_hand {itemtype args} {
	set obj [get_next_item_of_itemtype $itemtype $args]
	if {$obj < 0} {
		return true
	}

	link_obj $obj this 0
	return true
}

# Used in many
proc prod_createproduct_box_with_dummybox {type} {
	global current_workplace
	sel /obj
	set idx [inv_find this $type]
	if {$idx == -1}	{
		// wahrscheinlich vorher fallen gelassen worden, weil Inventory voll
		return true
	}
	set item [inv_get this $idx]
	//log "found in inventory: $item"

	set dummybox [inv_get $current_workplace [inv_find $current_workplace Halbzeug_kiste]]

	set itempos [get_place -center [get_pos $current_workplace] -rect -10 [hmin 1 [expr 11-[get_posz $current_workplace]]] 10 [expr 13-[get_posz $current_workplace]] -mindist 1.5 -random 2 -nearpos [get_pos this]]
	if {[lindex $itempos 0]<0} {
		set itempos [get_place -center [get_pos $current_workplace] -rect -10 [hmin 1 [expr 11-[get_posz $current_workplace]]] 10 [expr 13-[get_posz $current_workplace]] -mindist 1.5 -random 2 -nearpos [get_pos this] -materials false]
		if {[lindex $itempos 0]<0} {
			log "itempos not found! - createproduct_box_with_dummybox"
			gnome_failed_work this
			stop_prod
			tasklist_clear this
			return true
		}
	}
	set walkpos [get_place -center $itempos -circle 2 -mindist 0.7 -except this -nearpos [get_pos this] -materials false]
	if {[lindex $walkpos 0]<0} {
		log "walkpos not found!  - createproduct_box_with_dummybox"
		gnome_failed_work this
		stop_prod
		tasklist_clear this
		return true
	}

	tasklist_addfront this "play_anim bendb"
	tasklist_addfront this "play_anim putboxb; beam_from_inv_to_pos $item \{$itempos\}; link_obj $dummybox; set_visibility $dummybox 0; del $dummybox"
	tasklist_addfront this "play_anim putboxa"
	tasklist_addfront this "rotate_towards_with_box \{$itempos\}"
	tasklist_addfront this "walk_pos_with_box \{$walkpos\}"

	return true
}

# Used in: Dampfhammer, Dampfmaschine, Hochofen, Schmelze, Waffenschmiede
proc prod_fireaccident {dummyid} {
	global current_workplace
	tasklist_add this "change_particlesource this 4 27 {0 0 0} {0 0 0} 256 16 0 0 0 1; set_particlesource this 4 1"
	tasklist_add this "change_particlesource this 5 6  {0 0 0} {0 0 0} 32  1  0 0 0 1; set_particlesource this 5 0"
	tasklist_add this "set_particlesource this 5 0"
	tasklist_add this "play_anim wait"
	tasklist_add this "play_anim shock"
	tasklist_add this "walk_dummy $current_workplace $dummyid 2"
	tasklist_add this "play_anim fireaccident_start"
	for {set i 1} {$i<5} {incr i} {
		tasklist_add this "play_anim fireaccident_loop"
	}
	tasklist_add this "set_particlesource this 4 0; free_particlesource this 4; set_particlesource this 5 1"
	tasklist_add this "play_anim fireaccident_loop"
	tasklist_add this "play_anim fireaccident_end"
	tasklist_add this "set_particlesource this 5 0"
	tasklist_add this "play_anim tired"
	tasklist_add this "free_particlesource this 5"
	return true
}

# Used in: Dreherei, Moebeltischlerei
proc prod_sunglasses {bool} {
	if { $bool == 0 } {
		enable_auto_fanim
	} else {
		set_fanim {eyes 11}
		disable_auto_fanim 100
	}
	return true
}

// ----------------------------------------------------------------------------------
//								        Dojo - Training
// ----------------------------------------------------------------------------------


// liefert ein zuf�lliges Element der �bergebenen Liste

proc get_random_element {liste} {
	set max [expr [llength $liste] - 1]
	set id [expr round([random 0 $max])]
	;#log "ID = $id"
	return [lindex $liste $id]
}


proc profi_training {} {
	global current_tool_item
	state_disable this
	set wpn_id [get_weapon_id $current_tool_item true]
	set_weapon_class this $wpn_id
	fight_setactions_training this true {state_enable this}
	return true
}

proc dojo_profi_training {} {
	for {set i 0} {$i < 6} {incr i} {
		tasklist_add this "profi_training"
	}
	return true
}

proc prod_Dojo_anfaenger {item } {
	set _Kungfu_anims [list kungfumiddleblo kungfuheadblo kungfubottomblo kungfuskip kungfujump kungfuside kungfuback]
	set _Schwertkampf_anims [list swordduck swordjump swordback swordmiddleblo swordmidstroke swordmidstab swordheadblo swordheadstroke swordheadstab swordupstroke sworddownstroke swordbottomblo swordbotstroke]
	set _Zweihandkampf_anims [list twohandjump twohandmiddleblo twohandmidstroke twohandheadblo twohandheadstroke twohandheaddownblo twohandupstroke twohanddownstroke twohandbottomblo twohandbotstroke]
	set _Verteidigung_anims [list standshieldblo shieldmiddleblo shieldheadblo shieldbottomblo]

	if {$item != "_Schusswaffen"} {
		set id [subst $item]_anims
		set anim [get_random_element [subst $$id]]
	} else {set anim shootbow}
	set art [string map {_Kungfu Kungfu _Schwertkampf Sword _Zweihandkampf Twohanded _Verteidigung Defense _Schusswaffen Ballistic} $item]

	for {set i 0} {$i<6} {incr i} {
		tasklist_add this "prod_anim $anim"
	}

	tasklist_add this "add_expattrib this exp_F_$art 0.002"
	return true
}


// ----------------------------------------------------------------------------------
//								        	Schule
// ----------------------------------------------------------------------------------

proc prod_school_seat {seat side} {
	global current_workplace
	if [set babe [prod_guest guestget $current_workplace $seat]] {
		switch $side {
			left {
				set anims {talkk talkm}
				set angle 0.79
			}
			right {
				set anims {kontrol}
				set angle 2.35
			}
		}
		set anims [concat $anims talkb talke talkf invent_b invent_c teeter_w breathe]
		tasklist_add this "rotate_toangle $angle"
		tasklist_add this "play_anim [lindex $anims [irandom [llength $anims]]]"
		tasklist_add this "school_knowledge_transfer $babe"
	}
	return true
}

proc school_knowledge_transfer {baby} {
	set globattrs [get_expattrib 0]
	set fightattrs [get_expattrib 1]
	set transfactor 0.2
	set cbsumme 0
	foreach attr $globattrs {
		set cbsumme [expr {$cbsumme + [get_attrib $baby $attr]}]
	}
	set verteilung {}
	log "CBSUMME: $cbsumme"
	if {$cbsumme<0.01} {set cbsumme 0.8}
	set nbsumme 0
	foreach attr $globattrs {
		set cbval [get_attrib $baby $attr]
		set nbval [hmax 0.1 [expr {$cbval/$cbsumme}]]
		lappend verteilung $nbval
		set nbsumme [expr {$nbsumme + $nbval}]
	}
	log "[get_objname $baby]:Verteilung $verteilung-->$nbsumme"
	set transum 0
	set teachcap 0
	set attrlog {}
	set fightfactor [lindex $verteilung end]
	foreach attr $fightattrs {
		add_attrib $baby $attr [set logg [expr {[get_attrib this $attr]*$transfactor*$fightfactor/$nbsumme}]]
		lappend attrlog [string range $attr 4 20] [string range $logg 0 6]
		set transum [expr {$transum + $logg}]
		set teachcap [expr {$teachcap + [get_attrib this $attr]}]
	}
	for {set i 0} {$i<[llength $globattrs]-2} {incr i} {
		set attr [lindex $globattrs $i]
		add_attrib $baby $attr [set logg [expr {[get_attrib this $attr]*$transfactor*[lindex $verteilung $i]/$nbsumme}]]
		lappend attrlog [string range $attr 4 20] [string range $logg 0 6]
		set transum [expr {$transum + $logg}]
		set teachcap [expr {$teachcap + [get_attrib this $attr]}]
	}
	set attr [lindex $globattrs $i]
	add_expattrib $baby $attr [set logg [expr {[get_attrib this $attr]*$transfactor*[lindex $verteilung $i]/$nbsumme}]]
	lappend attrlog [string range $attr 4 20] [string range $logg 0 6]
	set transum [expr {$transum + $logg}]
	set teachcap [expr {$teachcap + [get_attrib this $attr]}]
	log "[string range [expr {$transum*100/[hmax $teachcap 0.1]}] 0 3]\% von [get_objname this] auf [get_objname $baby] �bertragen."
	log $attrlog
}

proc prod_school_checkrows {slst taskcnt} {
	global current_workplace current_worklist
	set bed 1
	foreach s $slst {
		if [prod_guest guestget $current_workplace $s] {
			set bed 0
		}
	}
	if $bed {
		set current_worklist [lreplace $current_worklist 0 $taskcnt]
		call_method $current_workplace prod_progressjump $taskcnt
	}
	log [lindex $current_worklist 0]
	return true
}


// ----------------------------------------------------------------------------------
//								        	Lager
// ----------------------------------------------------------------------------------

# Makes store to look for items nearby
proc prod_find_items {} {
	global current_workplace
	call_method $current_workplace find_items_to_store
	return true
}


// sammelt alle Gegenst�nde, die das Lager angefordert hat
// bzw. sammelt jeweils einen Gegenstand auf und setzt sich selbst wieder in die Tasklist, falls noch mehr geht

proc prod_store_collect_all_items {} {
	global current_workplace
	set itemlist [call_method $current_workplace get_storage_list]

	if {[llength $itemlist] == 0} {
		return true
	}

	// n�chstgelegenes Item suchen

	set mypos [get_pos this]
	set next_item [lindex $itemlist 0]
	set next_item_dist 10000.0
	foreach item $itemlist {
		if {[obj_valid $item]} {
			set dist [vector_dist3d $mypos [get_pos $item]]
			if {$dist < $next_item_dist} {
				set next_item_dist $dist
				set next_item $item
			}
		}
	}

	if {![obj_valid $next_item]} {
		return true
	}

	// auf jeden Fall aus der Liste der zu sammelnden Items entfernen

	log "LAGER: take $next_item"
	lrem itemlist [lsearch $itemlist $next_item]
	call_method $current_workplace set_storage_list $itemlist

	if {[inv_check this $next_item] == 0} {
		// item passt nicht in die Tasche --> fertig
		return true
	}

	if {[call_method $current_workplace is_storable $next_item] == 0} {
		// item passt nicht ins Lager --> item ignorieren und weitermachen
//    		log "item $next_item passt nicht ins mehr ins Lager"
		tasklist_add this "prod_store_collect_all_items"
		return true
	}

	// erstmal hinlaufen und dann nochmal checken
	tasklist_add this "state_disable this; walk_action \"-target \{[get_pos $next_item]\} \" {state_enable this}"
	tasklist_add this "store_pickup_item $next_item"

	return true
}



// wird aufgerufen, nachdem der Zwerg zu einem aufzusammelnden Item hingelaufen ist
// hier wird nochmals gecheckt, sollte irgend etwas schiefgelaufen sein, wird
// beim n�chsten Item weitergemacht

proc store_pickup_item {item} {
	global current_workplace

	set ok 1

	if {![obj_valid $item]} {
		set ok 0
		set pos {-100 -100 -100}
	} else {
		set pos [get_pos $item]
	}

	if {$ok} {
		set objtype [get_objtype $item]
		if {$objtype == "production"  ||  $objtype == "energy"  ||  $objtype == "store"  ||
			$objtype == "protection"  ||  $objtype == "elevator" } {

			if {[get_prod_unpack $item]} {
				set ok 0
			}
		}
	}

	if {$ok} {
		if {[vector_dist3d [get_pos this] $pos] > 1.0} {
			set ok 0
		}
	}

	if {$ok} {
		set owner [get_owner $item]
		if {$owner != [get_owner this]  &&  $owner != -1} {
			set ok 0
		}
	}

	if {$ok == 0} {
		// Item existiert nicht mehr oder ist nicht erreicht worden oder sonstwas
		log "store: failed to pick up item $item, continuing with next item"
		tasklist_clear this
		tasklist_add this "prod_store_collect_all_items"
		return
	}

	// alles okay, weitermachen!
	pickup $item
	tasklist_add this "if {\[inv_find_obj this $item\] >= 0} {call_method $current_workplace add_collected_item $item}"
	tasklist_add this "prod_store_collect_all_items"
}

// transportiert das Item aus dem Inventar des Zwerges in den Slot des Lagers

proc prod_beam_to_store_slot {item slotidx} {
	global current_workplace
	if {[inv_find_obj this $item] < 0} {
		log "storing of item $item failed because I don't have it"
		return
	}
	inv_rem this $item
	call_method $current_workplace store_item $slotidx $item
}


// packt alle gesammelten Items ins Lager
// erh�ht ausserdem die Erfahrung des Zwerges

proc prod_store_collected_items {exp_incr {lastdummy -1}} {
	global current_workplace

	log "prod_store_collected_item exp_incr = $exp_incr"

	set itemlist [call_method $current_workplace get_collected_items]
	if {[llength $itemlist] == 0} {
		return true
	}

	set next_item [lindex $itemlist 0]
	lrem itemlist 0

	set slotidx [call_method $current_workplace find_slot_for_storing [get_objclass $next_item]]
	log "Lager: Bringe $next_item in Slot $slotidx"
	if {$slotidx == -1} {
		log "WARNING: prod_store_collected_items: Zwerg hat Gegenstand $next_item gesammelt, es ist aber kein Platz!"
		tasklist_add this "prod_beam_to_store_slot $next_item $slotidx"		;// Lager f�ngt Slotidx -1 selbst ab
		return true
	}

	set dummy [call_method $current_workplace get_slot_dummy $slotidx]
	set anim [call_method $current_workplace get_slot_anim $slotidx]

	if {$lastdummy != $dummy} {
		tasklist_add this "prod_goworkdummy $dummy"
		tasklist_add this "prod_turnback"
	}

	tasklist_add this "prod_anim $anim"
	tasklist_add this "prod_beam_to_store_slot $next_item $slotidx; prod_exp $exp_incr 1.0"

	if {[llength $itemlist] != 0} {
		tasklist_add this "prod_store_collected_items \{$exp_incr\} $dummy"
	}
	call_method $current_workplace set_collected_items $itemlist
	return true
}


// versucht, das item aus einem Lager aufzuheben

proc pickup_from_store {item} {
	if {[is_contained $item] == 0} {
		return true
	}
	set store [obj_query $item "-class Lager -range 5 -limit 1 -flagneg {boxed contained}"]
	log "pickup_from_store: attempt to pick up $item, found store: $store"
	if {$store == 0} {
		return false
	}

	set slotidx [call_method $store find_slot_of_item $item]
	if {$slotidx == -1} {
		return false
	}

	set dummy [call_method $store get_slot_dummy $slotidx]
	tasklist_add this "walk_dummy $store $dummy"
	tasklist_add this "prod_turnback"
	set anim [call_method $store get_slot_anim $slotidx]
	tasklist_add this "prod_anim $anim"

	tasklist_add this "call_method $store retrieve_item $slotidx $item; beamto_inv $item"
	return true
}


// ----------------------------------------------------------------------------------
//								            Krankenhaus
// ----------------------------------------------------------------------------------

proc prod_get_patient {k_haus_ref} {
#returned Zwergereferenz oder -1
///	;#der n�chste Patient soll zur�ckgegeben werden
	set nextindex [prod_guest nextorder $k_haus_ref]
	if {$nextindex == -1} {return -1}
	set nextorder [prod_guest getorder $k_haus_ref $nextindex]
	set zwerg [prod_guest guestget $k_haus_ref $nextindex]
	set hitpoints [get_attrib $zwerg atr_Hitpoints]
	//if {$hitpoints == 0} {??}
	set wert [expr $nextorder / $hitpoints]
	for {set i 0} {$i < 4} {incr i} {
		set tmp_order [prod_guest getorder $k_haus_ref $i]
		log "GET_PATIENT: TMP_ORDER = $tmp_order"
		if {$tmp_order == 0} {break}
		set tmp_zwerg [prod_guest guestget $k_haus_ref $i]
		set tmp_wert [expr $tmp_order / [get_attrib $tmp_zwerg atr_Hitpoints]]
		if {$tmp_wert > $wert} {
			set zwerg $tmp_zwerg
			set wert $tmp_wert
		}
	}
	return $zwerg
}

proc prod_heilen {artzt khaus_ref} {
	set patient [call_method $khaus_ref get_patient]
	if {$patient == 0} {
		set patient [prod_get_patient $khaus_ref]
		if {$patient == -1} {tasklist_add this "prod_leerlauf $khaus_ref"; return true}
		call_method $khaus_ref set_patient $patient
//		log "PATIENT WURDE GESETZT -> patient von [get_objname $khaus_ref] = [call_method $khaus_ref get_patient]"
	}
	set hitpoints [get_attrib $patient atr_Hitpoints]
	set erfahrung [get_attrib this exp_Service]
	set offset 5
	set zeit [expr round(10 + ((1-$hitpoints)* $offset)) - ($erfahrung * $offset)]
	set offset [expr (1 - $hitpoints) / $zeit]

	if {[call_method $khaus_ref get_current_todo] == 0} {
		if {$hitpoints > 0.5} {
			call_method $khaus_ref set_current_todo 3
		}
	}

	set todo [call_method $khaus_ref get_current_todo]
	switch $todo {
		0 {
			tasklist_add this "prod_machineanim krankenhaus.tisch_oben once"
			tasklist_add this "call_method $khaus_ref set_current_todo 1"
		}
		2 {
			tasklist_add this "walk_dummy $khaus_ref 3"
			tasklist_add this "prod_turnleft"
			tasklist_add this "prod_anim kickb"
			tasklist_add this "prod_machineanim krankenhaus.instr_rollrein once"
			tasklist_add this "prod_machineanim krankenhaus.instr_tisch"
			tasklist_add this "walk_dummy $khaus_ref 11"
			tasklist_add this "prod_turnback"
			for {set i 0} {$i < $zeit} {incr i} {
				tasklist_add this "prod_elektoschok $khaus_ref $offset";
			}
			;#an dieser Stelle Meldet sich der Patient schon ab
			tasklist_add this "prod_waittime 1"
			tasklist_add this "prod_anim tired"
			tasklist_add this "walk_dummy $khaus_ref 4"
			tasklist_add this "prod_turnright"
			tasklist_add this "prod_anim kickb"
			tasklist_add this "prod_machineanim krankenhaus.instr_rollraus once"
			tasklist_add this "prod_machineanim krankenhaus.tisch_runter once"
			tasklist_add this "call_method $khaus_ref set_current_todo 0"
			tasklist_add this "call_method $khaus_ref set_patient 0"
		}


		3 {
			tasklist_add this "walk_dummy $khaus_ref 11"
			tasklist_add this "prod_turnright"
			tasklist_add this "call_method $khaus_ref set_current_todo 4"
		}
		5 {
			tasklist_add this "play_anim healb"
		}
		6 {
			tasklist_add this "play_anim heala"
		}
		7 {
			tasklist_add this "change_tool Spritze"
			tasklist_add this "play_anim healshot"
			tasklist_add this "set_attrib $patient atr_Hitpoints 1"
			tasklist_add this "call_method $khaus_ref set_current_todo 0"
			tasklist_add this "call_method $khaus_ref set_patient 0"
		}
		default {
			state_disable this
			action this wait 1 {state_enable this} {}
		}
	}
	return true
}

proc prod_elektoschok {khaus_ref offset} {
	set patient [call_method $khaus_ref get_patient]
//	log "ELEKTROSCHOK: PATIENT = $patient"
	if {$patient == 0} {
//		log "PATIENT ist nicht auf der Liege. Action Elektroschok abgebrochen. "
		return false
	}
	prod_anim healelektro
	add_attrib $patient atr_Hitpoints $offset
	return true
}

proc prod_leerlauf {khaus_ref} {
	set dummys [list 2 3 4 0]
	set animliste [list scout leftright scratchhead cough teeter_w]
	set dummy [lindex $dummys [irandom [llength $dummys]]]
	set anim [lindex $animliste [irandom [llength $animliste]]]
	tasklist_add this "prod_goworkdummy $dummy"
	tasklist_add this "prod_anim $anim"
	return true
}

proc prod_ill_leicht {khaus_ref arzt} {
	set offset 0.1
	add_attrib this atr_Hitpoints $offset
	if {[get_attrib this atr_Hitpoints]>0.8} {
		tasklist_add this "call_method $khaus_ref set_current_todo 6"
	}
	return true
}


// ----------------------------------------------------------------------------------
//								            Wachhaus
// ----------------------------------------------------------------------------------

proc prod_bewachen_nah {richtung} {
	tasklist_add this "rotate_to $richtung"
	tasklist_add this "prod_anim scout"
	tasklist_add this "prod_feind_suchen $richtung"
	return true
}

proc prod_feind_suchen {richtung} {
	global attack_item attack_behaviour approach
	if {$richtung == "right"} {set negx 0; set posx 10} else {set negx -10; set posx 0}
	set findlist [obj_query this "-boundingbox \{$negx -1 -10 $posx 1 10\}  -type \{gnome monster\} -owner enemy -limit 1"]
	log "FINDLIST = $findlist"

	if {$findlist != 0} {
		log "FEINDE GEFUNDEN!!!!!!!!"
		set attack_item [lindex $findlist 0]
		set attack_behaviour "offensive"
		log "FEIND IST $attack_item"
		set approach 1
		fight_startfight
	}
	return true
}

proc prod_bewachen_trigger {} {
	trigger create this any_object "trigger_ausloeser_vernichten"
	trigger set_target_range this 6
	trigger set_target_type this {gnome monster}
	trigger set_target_owner this enemy
	return true
}

#Diese Proc geh�rt nur zu den "prod_bewachen_trigger" proc
proc trigger_ausloeser_vernichten {} {

//--------------
	set feind [trigger get_actuators this]
	if {[llength $feind] > 1} {set feind [lindex $feind 0]}
	set_event this evt_task_attack -target [get_ref this] -subject1 $feind
	return true
//---------------

	global attack_item attack_behaviour approach
	set feind [trigger get_actuators this]
	if {[llength $feind] > 1} {set feind [lindex $feind 0]}
	log "FEINDE GEFUNDEN!!!!!!!!"
	log "FEIND = $feind"
	stop_prod
	set attack_item $feind
	set attack_behaviour "offensive"
	set approach 1
	fight_startfight
	return true
}

proc prod_delete_trigger {} {
	tasklist_add this "trigger delete this"
	return true
}

proc prod_check_wall {} {
	set wand 0
	set check_point [get_point_in_direction this 4]
    set x [lindex $check_point 0]
    set y [expr [lindex $check_point 1] - 0.5]
    set z [lindex $check_point 2]
    set hmap [get_hmap $x $y]
    //log "HMAP = $hmap"
    if { $hmap > $z} {
    	set wand 1
    }

	if {$wand} {
		log "Wachhaus: Zwerg guckt gegen die Wand, wird umgedreht"
		tasklist_add this "prod_turnfront"
	}
	return true
}


// ----------------------------------------------------------------------------------
//								            Tempel
// ----------------------------------------------------------------------------------

// Wiederbelebung eines Zwerges (an Position $pos)
// damit das funktioniert, muss im inventar der Produktionsst�tte eine Zipfelm�tze sein, in der die
// Attribute des Zwerges gespeichert werden. Die M�tze wird NICHT gel�scht

proc prod_ressurection {pos} {
	set cap [get_next_item_of_itemtype Zipfelmuetze]
	if {$cap < 0} {
		return true
	}

	set zwerg [new Zwerg]

	set_owner $zwerg [get_owner this]
	call_method $zwerg ressurection [call_method $cap get_gender] [call_method $cap get_name] [call_method $cap get_worktime] [call_method $cap get_expmax] [call_method $cap get_attribs] [expr {[call_method $cap get_age]-900}]
	set_pos $zwerg $pos
	create_particlesource 14 $pos {0 -0.2 0} 3 3

	return true
}
