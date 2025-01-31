call scripts/misc/utility.tcl


def_class Farm wood production 1 {} {

	class_fightdist 2.0

	method prod_item_actions itemtype {
		if {0&&([get_prod_materialneed this]||![get_prod_schedule this])} {
			log "FEHLER: PCM ignores prodstates at [get_objname this] ([get_ref this]):"
			log "    prod_schedule [get_prod_schedule this] prod_materialneed [get_prod_materialneed this]"
			return {{prod_waittime 6}}
		}
		global rottencnt torotten current_worker current_slot
		set exp_infls [call_method this prod_item_exp_infl $itemtype]
		set exper [prod_getgnomeexper $current_worker $exp_infls]
		set exp_incrs [call_method this prod_item_exp_incr $itemtype]
		if {0&&$rottencnt&&$current_slot=="Pilz"} {
			set invsize [inv_getsize $current_worker]
			set invsize [hmax 1 [hmin $invsize [expr int($invsize*($exper+0.2)*1.5)]]]
			set i 1
			set il [list]
			foreach entry $torotten {
				set item [lindex $entry 0]
				lappend rlst "prod_pickup_item $item"
				lappend il $item
				if {$i%$invsize==0} {
					foreach item $il {
						lappend rlst "prod_laydown_infrontof_farm $item"
					}
					set il [list]
				}
				incr i
			}
			foreach item $il {
				lappend rlst "prod_laydown_infrontof_farm $item"
			}
			set torotten [list]
		}
		lappend rlst "prod_goworkdummy 3"
		set al [hmax [expr 6-int($exper*5.2)] 1]
		set oa [expr 3.6-$al*0.3]
		set as [expr (6.2-$oa)/$al]
		set parts [expr 1.0/$al]
		log "[get_objname $current_worker] working at Farm $exper ($al $oa $as)"
		lappend rlst "prod_sowparticles $itemtype 1"
		for {} {$oa<6.3} {fincr oa $as} {
			lappend rlst "prod_turnangle $oa"
			lappend rlst "prod_exp $exp_incrs $parts;prod_anim farmsow"
		}
		lappend rlst "prod_sowparticles $itemtype 0"
		lappend rlst "prod_call_method initiate $itemtype"
		lappend rlst "prod_goworkdummy 0"
		return $rlst
	}
	
	method init {} {
		global material gnomewashere
		if {[get_posy this]<31} {
			set material 2
		} else {
			set material [get_material [get_pos this]]
			if {$material==3} {set material 0}
		}
		flog "[get_objname this] init: material set to: $material"
		set gnomewashere 0
	}
	
	method initiate {itemtype} {
		set manure 0
		set hamsterfodder 0
		set wormfodder 0
		set gnomewashere 1
		set farmcounter 50
		return
		switch $itemtype {
			"Pilz" {set manure 100}
			"Hamster" {set hamsterfodder 100}
			"Raupe" {set wormfodder 100}
		}
	}
	
	method actualize_hamsters {} {
		set hlst [lnand 0 [obj_query this "-class Hamster -boundingbox \{-2 -0.5 -3 2 0.5 3\} -flagneg \{contained\}"]]
		actualize_parents $hlst
	}
	
	method prod_get_invention_dummy {} {
		return 3
	}
	
	method get_deliverypos {} {
		return [get_pos this]
	}
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	def_event evt_timer0    // pilze suchen
	//def_event evt_timer1    // pilze verrotten
	//def_event evt_timer2    // hamster suchen
	//def_event evt_timer3    // raupe suchen

	handle_event evt_timer0 {
		event0
	}

	class_defaultanim farm.standard
	class_flagoffset 1.3 3.7

	obj_init {
		set_anim this farm.standard 0 $ANIM_LOOP
		call scripts/misc/genericprod.tcl
		timer_event this evt_timer0 -repeat -1 -interval 3 -userid 1
		//timer_event this evt_timer2 -repeat -1 -interval 8 -userid 0
		//timer_event this evt_timer3 -repeat -1 -interval 8 -userid 0
		//timer_event this evt_timer1 -repeat -1 -interval 81 -userid 0

		set_prod_materialneed this 0
		set_prod_switchmode this 1
		set_prod_exclusivemode this 1
		set_collision this 1
		
		set f_log 0
		set material 1
		set torotten {}
		set rottencnt 0
		set pilzinitial 0
		set pilzplaces {{-0.5 0 -1.7} {0.8 0 -1.7} {-0.9 0 0.6} {1.2 0 0.6}}
		set mypilzes {}
		set usedpilzslots {}
		set farmcounter 0
		set parenthamsters ""
		set originalworm 0
		set manure 0
		set hamsterfodder 0
		set wormfodder 0
		set last_slot "none"
		set last_real_slot ""
		set myref [get_ref this]
		set lastcreation 0.0
		set gnomewashere 0
		
		set build_dummys [list 12 13 14 15 16 17]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_linksholz unten_rechtsholz unten_rechtsholz unten_rechtsholz unten_linksholz unten_rechtsholz}
		set damage_dummys {20 26}
		
		proc flog {string} {
			global f_log
			if {$f_log} {log $string}
		}
		
		proc event0 {} {
			global material torotten rottencnt farmcounter current_slot
			global pilzinitial parenthamster originalworm last_slot last_real_slot
			global manure hamsterfodder wormfodder mypilzes gnomewashere usedpilzslots
			if { [get_buildupstate this] } {
				set_prod_schedule this 0
				set_prod_materialneed this 0
				set current_slot "none"
				foreach slot {Pilz Hamster Raupe} {
					if {[get_prod_slot_cnt this $slot]} {
						if {[get_owner_attrib [get_owner this] Bp$slot]>0.0} {
							set current_slot $slot
						} else {
							set_prod_schedule this 1
							break
						}
					}
				}
				if {$last_slot!=$current_slot} {
					switch $last_slot {
						"Pilz"		{ set pilzinitial 0 }
						"Hamster"	{ free_parenthamsters }
						"Raupe"		{ free_originalworm }
					}
				}
				if {$last_real_slot!=$current_slot} {
					set gnomewashere 0
				}
				set last_slot $current_slot
				if {$slot!="none"} {set last_real_slot $current_slot}
				if {$farmcounter} {flog "Farmtimer: $material $current_slot $farmcounter"}
				set pl 0; set hl 0; set rl 0
				switch $current_slot {
					"Pilz" {
						check_mypilzes
						set pl [llength $mypilzes]
						if {$pilzinitial} {
							if {$pl<3} {
								if {$gnomewashere} {
									if {$farmcounter>70-$material*15+rand()*5} {
										if {[recreate_pilz]} {
											flog "Pilzrecreate erfolgreich: $farmcounter,$material"
											set farmcounter 0
										}
									} else {
										incr farmcounter
									}
								} else {
									flog "Farmscheduleon [get_objname this] (no gnome yet)"
									set_prod_schedule this 1
								}
							}
						} else {
							if {[try_pilzinitial]} {
								flog "Farminitial erfolgreich"
								set pilzinitial 1
								set farmcounter 50
							} else {
								set_prod_schedule this 1
								set_prod_materialneed this 1
								flog "Farmmaterialon [get_objname this] (no initial)"
							}
						}
					}
					"Hamster" {
						set hlst [obj_query this "-class Hamster -boundingbox \{-2 -0.5 -3 2 0.5 3\} -flagneg \{contained\}"]
						if {$hlst==0} {set hl 0;set hlst ""} {set hl [llength $hlst]}
						actualize_parents $hlst
						if {$hl<5} {
							if {$hl>1} {
								if {$gnomewashere} {
									if {$farmcounter>60-$material*10+rand()*5} {
										if {[recreate_hamster]} {
											flog "Hamsterrecreate erfolgreich: $farmcounter,$material"
											set farmcounter 0
										}
									} else {
										incr farmcounter
									}
								} else {
									flog "Farmscheduleon [get_objname this] (no gnome yet)"
									set_prod_schedule this 1
								}
							} else {
								set_prod_schedule this 1
								set_prod_materialneed this 1
								//log "Farmswitchon [get_objname this] (no parents) $parenthamsters"
							}
						}
					}
					"Raupe" {
						remove_from_inv_raupe
						set rlst [obj_query this "-class Raupe -boundingbox \{-2 -0.5 -3 2 0.5 3\} -flagneg \{contained\}"]
						if {$rlst==0} {set rl 0;set rlst ""} {set rl [llength $rlst]}
						actualize_worm $rlst
						if {$rl<6} {
							if {$rl} {
								if {$gnomewashere} {
									if {$farmcounter>60-$material*12+rand()*5} {
										if {[recreate_raupe]} {
											flog "Raupenkreation erfolgreich ($material,$farmcounter)"
											fincr wormfodder -30.0
											set farmcounter 0
										}
									} else {
										incr farmcounter
									}
								} else {
									flog "Farmscheduleon [get_objname this] (no gnome yet)"
									set_prod_schedule this 1
								}
							} else {
								set_prod_schedule this 1
								set_prod_materialneed this 1
								flog "Farmswitchon [get_objname this] (no worm) $originalworm"
							}
						}
					}
					default {
						set pilzinitial 0
						free_originalworm
						free_parenthamsters
					}
				}
				verrotten_pilz
				if {[get_prod_pack this]} {
					set pilzinitial 0
					free_parenthamsters
					free_originalworm
					set_prod_schedule this 1
				}
			} elseif {[get_boxed this]} {
				set mypilzes ""
				set usedpilzslots ""
			}
		}

		proc verrotten_pilz {} {
			global torotten rottencnt
			set pslst [lnand 0 [obj_query this "-class Pilzstamm -boundingbox \{-2 -0.5 -3 2 0.5 2.5\} -flagneg \{locked contained\}"]]
			set phlst [lnand 0 [obj_query this "-class Pilzhut   -boundingbox \{-2 -0.5 -3 2 0.5 2.5\} -flagneg \{locked contained\}"]]
			set lst [concat $pslst $phlst]
			
			set phcnt [llength $phlst]
			set pscnt [llength $pslst]
			flog "ph: $phcnt ps: $pscnt"
			
			set newrotten [list]
			set rottenallowed 1
			foreach entry $torotten {
				set item [lindex $entry 0]
				set cnt [lindex $entry 1]
				if {[set id [lsearch $lst $item]]!=-1} {
					incr cnt
					flog "rott $item ? $cnt ($phcnt $pscnt)"
					set ic [get_objclass $item]
					if {$ic=="Pilzhut"} {
						if {$rottenallowed&&$phcnt>9&&$cnt>40} {
							del $item
							set rottenallowed 0
						} else {
							lappend newrotten [list $item $cnt]
							incr rottencnt $cnt
						}
					} else {
						if {$rottenallowed&&$pscnt>9&&$cnt>60} {
							del $item
							set rottenallowed 0
						} else {
							lappend newrotten [list $item $cnt]
							incr rottencnt $cnt
						}
					}
					lrem lst $id
				}
			}
			foreach item $lst {
				lappend newrotten [list $item 0]
			}
			set torotten $newrotten
		}
		proc remove_from_inv_raupe {} {
			set idx [inv_find this "Raupe"]
			if {$idx!=-1} {
				set raupe [inv_get this $idx]
				inv_rem this $idx
				set rtyp [call_method $raupe get_type]
				del $raupe
				recreate_raupe $rtyp
			}
		}
		proc free_parenthamsters {} {
			global parenthamsters
			foreach ham [lnand 0 [obj_query this -class Hamster -boundingbox {-3 -1 -5 3 1 5}]] {
				call_method $ham set_farmhamster 0
			}
			foreach ham $parenthamsters {
				set_lock $ham 0
			}
			set parenthamsters ""
		}
		proc free_originalworm {} {
			global originalworm
			set_lock $originalworm 0
			set originalworm 0
		}
		proc reinitialize_pilz {} {
			global pilzplaces usedpilzslots mypilzes
		}
		proc check_mypilzes {} {
			global mypilzes usedpilzslots
			set idx 0
			foreach p $mypilzes {
				if {![obj_valid $p]||[get_objclass $p]!="Pilz"} {
					lrem mypilzes $idx
					lrem usedpilzslots $idx
				}
				incr idx
			}
		}
		proc recreate_pilz {} {
			global pilzplaces usedpilzslots mypilzes
			set opos [get_pos this]
			set pilzslots [lnand $usedpilzslots {0 1 2 3}]
			set slotid [lindex $pilzslots [irandom [llength $pilzslots]]]
			set ppos [vector_add $opos [lindex $pilzplaces $slotid]]
			set rnd [random 12.0]
			set angle [hf2i $rnd]
			set diff [expr {($rnd-$angle)*0.3}]
			set angle [expr {$angle*0.5}]
			set ppos [vector_add $ppos [get_vectorxz $angle $diff]]
			//log "new Pilzpos ([vector_sub $ppos $opos])"
			sel /obj
			set plz [new Pilz]
			set_pos $plz $ppos
			set_owner $plz [get_owner this]
			set_roty $plz [lindex {2.5 3.8 1.7 4.6} $slotid]
			call_method $plz has_myzel "farm"
			lappend usedpilzslots $slotid
			lappend mypilzes $plz
			return $plz
		}
		proc try_pilzinitial {} {
			if {[obj_query this "-class Pilz -boundingbox \{-2 -0.5 -3 2 0.5 3\} -limit 1 -flagneg \{contained locked\}"]} {return 1}
			if {[set plst [inv_find this Pilzhut]]!=-1} {
				del [inv_get this $plst]
				return 1
			}
			if {[set plst [obj_query this "-class Pilzhut -boundingbox \{-2 -0.5 -3 2 0.5 3\} -limit 1 -flagneg \{contained locked\}"]]} {
				del $plst
				return 1
			}
			if {[set plst [obj_query this "-class Pilzstamm -boundingbox \{-2 -0.5 -3 2 0.5 3\} -limit 1 -flagneg \{contained locked\}"]]} {
				del $plst
				return 1
			}
			return 0
		}
		proc actualize_parents {hlst} {
			global parenthamsters myref
			set parents ""
			set pl 0
			set ilst {}
			foreach item [inv_list this] {
				if {[get_objclass $item]=="Hamster"} {
					lappend ilst $item
				}
			}
			//log "actpar: hlst: [lor $ilst $hlst] ($ilst,$hlst)"
			set hlst [lor $ilst $hlst]
			foreach ham $parenthamsters {
				if {[obj_valid $ham]} {
					if {[lsearch $hlst $ham]!=-1} {
						if {[get_attrib $ham farmed]<1} {
							call_method $ham set_farmhamster $myref
						}
						lappend parents $ham
						incr pl
						set hlst [lnand $ham $hlst]
						set_lock $ham 1
					} else {
						if {![is_contained $ham]} {
							set_lock $ham 0
							call_method $ham set_farmhamster 0
						}
					}
				}
			}
			foreach ham $hlst {
				if {[get_attrib $ham farmed]<1} {
					call_method $ham set_farmhamster $myref
				}
				if {$pl>1} {
					break
				}
				if {[get_lock $ham]==0} {
					set_lock $ham 1
					lappend parents $ham
					incr pl
				}
			}
			if {$pl>1} {
				foreach item $ilst {
					set ipos [get_pos $item]
					inv_rem this $item
					set_pos $item $ipos
					set_visibility $item 1
					set_hoverable $item 1
					call_method $item set_farmhamster $myref
				}
			} else {
				foreach item $parents {
					set_lock $item 0
				}
			}
			set parenthamsters $parents	
		}
		proc actualize_worm {rlst} {
			global originalworm
			if {[lsearch $rlst $originalworm]!=-1} {set_lock $originalworm 1;return}
			set originalworm 0
			foreach r $rlst {
				if {[get_lock $r]==0} {
					set_lock $r 1
					set originalworm $r
					break
				}
			}
		}
		proc recreate_hamster {} {
			global myref lastcreation
			if {[gettime]-$lastcreation<50} {return 0}
			set opos [get_pos this]
			set hpos [get_place -center $opos -rect -1.7 -2.5 1.7 2.5 -random 2]
			//log "new Hamsterpos ([vector_sub $hpos $opos])"
			if { [lindex $hpos 0]>0 } {
				set lastcreation [gettime]
				sel /obj
				set ham [new Hamster]
				set_pos $ham $hpos
				call_method $ham set_farmhamster $myref
				return $ham
			}
			return 0
		}
		proc recreate_raupe {{typ 0}} {
			global lastcreation
			if {[gettime]-$lastcreation<50} {return 0}
			set opos [get_pos this]
			set rpos [get_place -center $opos -rect -1.7 -2.5 1.7 2.5 -random 2]
			//log "new Raupenpos ([vector_sub $rpos $opos])"
			if { [lindex $rpos 0]>0 } {
				set lastcreation [gettime]
				sel /obj
				set rau [new Raupe]
				if {$typ} {call_method $rau set_type $typ}
				set_pos $rau $rpos
				return $rau
			}
			return 0
		}

	}

}

