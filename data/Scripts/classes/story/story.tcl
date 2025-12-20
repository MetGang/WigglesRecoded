def_class StoryMgr none info 0 {} {
	obj_init {

		set_undeletable this 1

		proc get_next_areas {} {
			global act_sort_x act_sort_y resolution
			set zlist [obj_query this "-class Zwerg"]
			set area_list [list]
			if { $zlist != 0 } {
				foreach item $zlist {
					set pos [get_pos $item]
					set x [expr int([lindex $pos 0] / $resolution)]
					set y [expr int([lindex $pos 1] / $resolution)]
					set setted [sm_map_get $x $y]
					#log "x:$x  y:$y setted:$setted"
					if { $setted != 1 } {
						set act_sort_x [lindex $pos 0]
						set act_sort_y [lindex $pos 1]

						set area_list "$x $y"
						break
					}
				}
				if { $area_list == "" } {
					return 0
				}
				return $area_list
			}
			return 0
		}

		proc obj_count {classes} {
			set ol [obj_query this "-class \{$classes\} -visibility playervisible"]
			if { $ol == 0 } {
				return 0
			}
			return [llength $ol]
		}

		proc define_obj_counts {} {
			//return;
			global oc_list zone mingen_list gencount
			foreach item $mingen_list {
				global mingen_$item
			}
			foreach item $oc_list {
				global $zone\_oc_$item
				set pref_oc [subst $$zone\_oc_$item]
				set act_oc [obj_count $item]
				if { $item == "Pilz" } {
					set oc_Pilzhut [obj_count "Pilzhut Pilzstamm"]
					set act_oc [expr $act_oc + ($oc_Pilzhut / 3)]
				}
				set diff_oc [expr $pref_oc - $act_oc]
				log "OC: $item  is $act_oc shoud be $pref_oc"

				set bOK 1
				if { [info vars mingen_$item] != "" } {
					if { $gencount < [subst $\mingen_$item] } {
						set bOK 0
					}
				}
				if { $diff_oc > 0 && $bOK } {
					catch { lg_set_objcount $item 0 $diff_oc 32 }
					log "-->lg_set_objcount $item 0 $diff_oc 32"
				} else {
					#log "-->lg_tp_objfilter $item"
					#lg_tp_objfilter $item
				}
			}
		}

		proc try_raw_level {xn yn xp yp} {
			global midx zone resolution
			lg_tp_clear
			lg_tp_addtemplatesets 	" $zone.Std "
			//lg_tp_objfilter 		{	Troll Zwerg	}
			lg_set_area $xn $yn $xp $yp
			set ratio 		[expr 1 - (abs($midx - ($xn / $resolution)) / $midx)]
			set optratio 	[expr $ratio / 2.8]
			lg_set_templateratio 0 $optratio $ratio
			lg_set_leveltype base
			lg_start
			set level [lg_get_level]
			fill_temp_buffer $level
		}

		proc fill_temp_buffer { level  } {
			global temp_buffer act_sort_x act_sort_y
			foreach item $level {
				lappend temp_buffer $item
			}
			set temp_buffer [lg_sort_level $act_sort_x $act_sort_y $temp_buffer]
		}

		proc special_props {} {
			global gencount

			switch $gencount {
				0	{
						lg_set_templatevalue urw_hol_027_a.tcl 0.2
					}
			}
		}

		proc generate_next {x y} {
			global zone midx temp_buffer failcount maxfailures gencount resolution act_sort_y act_sort_x

			set zone [sm_get_zone [expr $y * $resolution]]
			log "!! Zone: $zone"
			set orgx $x
			set orgy $y

			set act_sort_y [expr $y * $resolution]
			set act_sort_x [expr $x * $resolution]

			lg_tp_clear
			lg_tp_addtemplatesets 	" $zone.Std "
			lg_tp_objfilter 		{	Troll Zwerg	}


			switch $zone {
				"Urwald"	{lg_set_templategroupvalue $zone.Std.Hol 0.287;log "UUUU"}
				"Metall"    {lg_set_templategroupvalue $zone.Std.Hol 0.185;log "MMM"}
				"Kristall"  {lg_set_templategroupvalue $zone.Std.Hol 0.077;log "KKKK"}
				"Lava"      {lg_set_templategroupvalue $zone.Std.Hol 0.105;log "LLLL"}
			}
			//lg_set_templategroupvalue $zone.Std.Hol 0.36

			//special_props

			log "generate: $x $y"
			set linfo [sm_get_level_info $x $y]
			log "linfo1: $linfo"

			if { [expr [lindex $linfo 2] * $resolution] < 16 || [expr [lindex $linfo 3] * $resolution] < 16 } {
				log "too small !!!"
				sm_map_set $orgx $orgy 1 1
				set utemp ""
				return
			}

			//set linfo [lg_set_starttemplatepro 1 [expr $failcount < $maxfailures]]
			set linfo [lg_set_starttemplatepro 1 1]
			log "linfo2: $linfo"

			set utemp [lindex $linfo 4]
			set x [lindex $linfo 0]
			set y [lindex $linfo 1]
			set w [lindex $linfo 2]
			set h [lindex $linfo 3]

			set xn [expr $x * $resolution]
			set yn [expr $y * $resolution]
			set xp [expr $xn + ($w * $resolution)]
			set yp [expr $yn + ($h * $resolution)]


			log "generate area: $xn $yn $xp $yp"
			#lg_set_area $xn $yn $xp $yp

			if { [expr $xp - $xn] < 16 || [expr $yp - $yn] < 16 } {
				log "too small !!!"
				sm_map_set $orgx $orgy 1 1
				set utemp ""
				return
			}

			if { $utemp != "" } {
				lg_tp_setfilter " $zone.Std.Gsg "
			}
			if { $utemp == "nodigmark" } {
				sm_map_set $orgx $orgy 1 1
				set utemp ""
				return
			}

			define_obj_counts

			set ratio 		[expr 1 - (abs($midx - $x) / $midx)]
			set optratio 	[expr $ratio / 2.5]	;#	don't forget .0 !!!!!!!!!!!!!

			set optratio 0.10

			log "ratio: lg_set_templateratio 0 $optratio 1"

			lg_set_templateratio 0 $optratio 1.0
			lg_set_leveltype base
			lg_start
			set level [lg_get_level]

			###------ failure handling
			if { [llength $level] == 0 } {
				log "Warning Level Generating failed @ $x $x    $failcount  times !!!!"
				if { $failcount >= $maxfailures } {
					//try_raw_level $xn $yn $xp $yp
					//sm_map_set $x $y $w $h
					//lg_mark_area $xn $yn $xp $yp
					set failcount 0
				}
				incr failcount
				return
			}
			set failcount 0
			incr gencount
			###------ failure handling

			sm_draw_stone -exlimit
			sm_draw_stone -utmat
			sm_set_temp $level
			fill_temp_buffer $level
			log "lv: $level"

			set RealOffset [map getoffset]
			set iYOfs [lindex $RealOffset 1]



			foreach item $level {
				set x [lindex $item 1]
				set y [lindex $item 2]
				if { [lindex $item 0] == "urw_unq_metalltor.tcl"} {
					sm_set_zone 0 [expr $y + 8]
				} elseif { [lindex $item 0] == "swf_unq_bruecke.tcl"} {
					sm_set_zone 1 [expr $y + 8]
				} elseif { [lindex $item 0] == "lava_unq_start.tcl"} {
					sm_set_zone 2 [expr $y + 8]


				} elseif { [lindex $item 0] == "urw_unq_troll_012_a.tcl"} {
					sm_set_temp "{urw_unq_troll_014_a $x $y}"
				} elseif { [lindex $item 0] == "urw_unq_troll_014_a.tcl"} {
					sm_set_temp "{urw_unq_troll_012_a $x $y}"

				} elseif { [lindex $item 0] == "urw_unq_vodo_001_a.tcl"} {
					sm_set_temp "{urw_kif_1 $x $y} {urw_kif_2 $x $y} {urw_kif_3 $x $y} {urw_kif_4 $x $y}"

				} elseif { [lindex $item 0] == "urw_unq_troll_001_a.tcl"} {
					fill_temp_buffer "{lava_unq_fenris_001.tcl 4 [expr 50 + $iYOfs]}"
				} elseif { [lindex $item 0] == "swf_unq_tit_treppe.tcl"} {
					fill_temp_buffer "{lava_unq_fenris_002.tcl 4 [expr 8 + $iYOfs]}"
				} elseif { [lindex $item 0] == "kris_unq_altesandburg.tcl"} {
					fill_temp_buffer "{lava_unq_fenris_003.tcl 12 [expr 8 + $iYOfs]}"
					fill_temp_buffer "{lava_unq_fenris_001.tcl 44 [expr 8 + $iYOfs]}"
				} elseif { [lindex $item 0] == "lava_unq_4thring.tcl"} {

					set iDestX 12
					set oLorelei [obj_query 0 -class Lorelei -limit 1]
					if { $oLorelei } {
						set iLoreleiX [get_posx $oLorelei]
						if { $iLoreleiX < 275 } {
							set iDestX 380
						}
					}
					fill_temp_buffer "{lava_unq_fenris.tcl $iDestX [expr 8 + $iYOfs]}"
				}



                //urw_kif_1

				#if { [lindex $item 0] == urw_unq_metalltor} {
					#sm_set_zone 2 [expr $y + 8]
				#}
			}

			//sm_map_set $x $y $w $h true
			sm_map_set $orgx $orgy 1 1
		//	sm_log
		}

		proc load_next {} {
			global temp_buffer bSplit SplitX SplitY temppos
			if { [llength $temp_buffer] == 0 && ! $bSplit } {
				return 0
			}
			if { [get_ingame_loading] == 1 } {
				//log "already loading..."
				return 1
			}
			if { $bSplit } {
				load_next_split
				return 1
			}
			set nexttemp [lindex $temp_buffer 0]
			//set temp_buffer [lreplace $temp_buffer 0 0]
			lrem temp_buffer 0

			set template [lindex $nexttemp 0]
			set x [lindex $nexttemp 1]
			set y [lindex $nexttemp 2]

			set temppos 0
			//log "StoryMgr: loading template: $template"
			call "data/templates/tcl/$template"

			if { $bSplit } {
				set SplitX $x
				set SplitY $y
				return  1
			}

			set_ingame_loading 1
			catch { MapTemplateSet $x $y }
			set_ingame_loading 0

			return 1
		}

		proc load_next_split {} {
			global bSplit SplitTemplateList SplitPMPList SplitX SplitY
			if { [llength $SplitPMPList] > 0 } {
				set pmp [lindex $SplitPMPList 0]
				set x [lindex $pmp 0]
				set y [lindex $pmp 1]
				set pmpfile [lindex $pmp 2]

				set_ingame_loading 1
				//log "map_template data/templates/pmp/split/$pmpfile  $x + $SplitX : $y + $SplitY "
				map_template "data/templates/pmp/split/$pmpfile" [expr $x + $SplitX] [expr $y + $SplitY]
				set_ingame_loading 0

				//set SplitPMPList [lreplace $SplitPMPList 0 0]
				lrem SplitPMPList 0
				wait_time 0.2
				return
			}
			if { [llength $SplitTemplateList] > 0 } {
				set temp [lindex $SplitTemplateList 0]
				set x [lindex $temp 0]
				set y [lindex $temp 1]
				set temp [lindex $temp 2]

				//log "call data/templates/tcl/split/$temp $x + $SplitX : $y + $SplitY "
				call "data/templates/tcl/split/$temp"
				set_ingame_loading 1
				catch { MapTemplateSet [expr $x + $SplitX] [expr $y + $SplitY] }
				set_ingame_loading 0

				//set SplitTemplateList [lreplace $SplitTemplateList 0 0]
				lrem SplitTemplateList 0
				wait_time 0.2
				return
			}
			set bSplit 0
			set_split_load 0
		}

        proc split_template {orgname orgpmp iW iH templist} {
        	global bSplit SplitTemplateList SplitPMPList temppos
        	if { $temppos == 0 } {
        		set bSplit 1
        		set_split_load 1
        		set SplitTemplateList [list]
        		set SplitPMPList [list]
        		foreach item $templist {
        			set tmp [lindex $item 0]
        			set pmp [lindex $item 1]
        			set x [lindex $item 2]
        			set y [lindex $item 3]
        			lappend SplitTemplateList "$x $y $tmp"
        			lappend SplitPMPList "$x $y $pmp"
        		}
        	} else {
            	//log "SplitLoad: $orgname"
            	foreach item $templist {
            		set tmp [lindex $item 0]
            		set pmp [lindex $item 1]
            		set x [lindex $item 2]
            		set y [lindex $item 3]
            		map_template "data/templates/pmp/split/$pmp" [expr $x + [lindex $temppos 0]] [expr $y + [lindex $temppos 1]]
            		call "data/templates/tcl/split/$tmp"
            		MapTemplateSet [expr $x + [lindex $temppos 0]] [expr $y + [lindex $temppos 1]]
            	}
            	set temppos 0
            }
        }

		proc callback {cb_trg cb_msg cb_tid} {
			global newslist
			log "SMCallback trg: $cb_trg   ,msg: $cb_msg  ,tid: $cb_tid"
			// find trigger
			foreach news $newslist {
				set trg 	[lindex $news 0]
				set cmd 	[lindex $news 1]
				set params	[lindex $news 2]

				set trgname [lindex $trg 0]
				set trgmsg 	"shut"
				if { [llength $trg] > 1 } {
					set trgmsg [lindex $trg 1]
					set trg [lindex $trg 0]
				}
				//log "*+ $cb_trg == $trg && $trgmsg == $cb_msg"
				if { $cb_trg == $trg && $trgmsg == $cb_msg} {
					set subcmd 		[lindex $cmd 0]
					set entry 		[lindex $cmd 1]
					set QLEvent		[lindex $cmd 2]
					set QLNegEvents [lindex $cmd 3]
					set click   ""

					// nachsehen, ob events aus der Negativliste gesetzt sind
					set ok 1
					foreach event $QLNegEvents {
						catch {
							if {[sm_get_event $event]} {
								set ok 0
							}
						}
					}

					if {$ok} {
						if {$QLEvent != ""} {
							catch {sm_set_event $QLEvent}
							set click "textwin run diary_15.tcl"
						}

						log "*** newsticker_$subcmd $entry $params"
						newsticker_$subcmd $entry $params $cb_tid $click
					}
				}
			}
		}

		proc find_news {ent} {
			global newsdata
			set index 0
			foreach item $newsdata {
				if { [lindex $item 0] == $ent } {
					return $index
				}
				incr index
			}
			return -1
		}

		proc get_newsid {ent} {
			global newsdata
			set idx [find_news $ent]
			if { $idx == -1 } {
				return -1
			}
			return [lindex [lindex $newsdata $idx] 1]
		}

		proc newsticker_new {ent param trg {clickaction ""}} {
		    global newsdata
			if { [find_news $ent] != -1 } {
				log "Warning newsticker entry redefinition: $ent !"
				return
			}
			set color [getpar $param "-color" {255 255 255}]
			set prior [getpar $param "-priority" 1.0]
			set time  [getpar $param "-time" 7200]
			set text  [gettext $ent]

			set text [parse_text $text $trg]

			set newsid [newsticker new 0 -text $text -color $color -priority $prior -time $time]
			log "newsticker new 0 -text $text -color $color -priority $prior -time $time"
			set clickaction "newsticker delete $newsid; $clickaction"
			newsticker change $newsid -click $clickaction

			lappend newsdata [list $ent "$newsid"]
		}

		proc newsticker_upd {ent param trg {click ""}} {
			set id [get_newsid $ent]
			if { $id == -1 } {
				log "Warning newsticker entry not found: $ent !"
			}

			set text [gettext $ent]
			set text [parse_text $text $trg]
			newsticker change $id -text $text
			log "********newsticker change $id -text $text"
		}

		proc newsticker_del {ent param trg {click ""}} {
			set id [get_newsid $ent]
			if { $id == -1 } {
				log "Warning newsticker entry not found: $ent !"
			}
			newsticker delete $id
			log "******** newsticker delete $id"
		}

		proc newsticker_ful {ent param trg {click ""}} {
			set id [get_newsid $ent]
			if { $id == -1 } {
				log "Warning newsticker entry not found: $ent !"
			}
			set text [gettext $ent]
			set text "[parse_text $text $trg] [lmsg erfuellt]"

			newsticker delete $id
			log "******** newsticker delete fulfilled $id"
		}

/// �bergang Weltverschiebung
		proc newsticker_spec {ent param trg {click ""}} {
			global UR_WarningCnt_0 UR_WarningCnt_1 UR_WarningCnt_2 Generate_enabled UR_WarningTimer_0 UR_WarningTimer_1 UR_WarningTimer_2 last_newsticker_warning_id

            if { $ent == "Ueber_0" } {
                //sm_dig_message 1
                //set Generate_enabled 0
				set UR_WarningTimer_0 [expr [gettime] + 2400]
                log "Warning timer active!!!"

				if {$last_newsticker_warning_id != -1} {
					newsticker delete $last_newsticker_warning_id
				}
				set ntMessage [lmsg_param "Nur noch -1- Minuten Zeit zum Umzug!" "-1- [expr 1 + int(($UR_WarningTimer_0 - [gettime])/60)]"]
				set id [newsticker new 0 -text "$ntMessage" -time [expr {1 * 60}]]
				newsticker change $id -click "newsticker delete $id"
				set last_newsticker_warning_id $id

            }
            if { $ent == "Ueber_1" } {
                //sm_dig_message 1
                //set Generate_enabled 0
                set UR_WarningTimer_1 [expr [gettime] + 1800]
                log "Warning timer active!!!"


				if {$last_newsticker_warning_id != -1} {
					newsticker delete $last_newsticker_warning_id
				}
				set ntMessage [lmsg_param "Nur noch -1- Minuten Zeit zum Umzug!" "-1- [expr 1 + int(($UR_WarningTimer_1 - [gettime])/60)]"]
				set id [newsticker new 0 -text "$ntMessage" -time [expr {1 * 60}]]
				newsticker change $id -click "newsticker delete $id"
				set last_newsticker_warning_id $id

            }
            if { $ent == "Ueber_2" } {
                //sm_dig_message 1
                //set Generate_enabled 0
                set UR_WarningTimer_2 [expr [gettime] + 1200]
                log "Warning timer active!!!"

				if {$last_newsticker_warning_id != -1} {
					newsticker delete $last_newsticker_warning_id
				}
				set ntMessage [lmsg_param "Nur noch -1- Minuten Zeit zum Umzug!" "-1- [expr 1 + int(($UR_WarningTimer_2 - [gettime])/60)]"]
				set id [newsticker new 0 -text "$ntMessage" -time [expr {1 * 60}]]
				newsticker change $id -click "newsticker delete $id"
				set last_newsticker_warning_id $id

            }
            if { $ent == "Ueber_3"} {
            	log "Storymanager: Uebergang zum Endkampf!"
            	set teleporter [obj_query 0 "-class Dimensionstor -limit 1"]
            	if {$teleporter == 0} {
            		log "ERROR: Dimensionstor not found, unable to move on to final battle!"
            		return
            	}
            	set_pos $teleporter {-100 -100 0 }
            	set_roty $teleporter -0.7
            	call_method $teleporter deactivate

				set ofsx [lindex [map getoffset] 0]
				set ofsy [lindex [map getoffset] 1]

				send_trigger "Uebergang_Lava_Ende"

            	reset_map [expr 0 + $ofsx] [expr 0 + $ofsy] [expr $ofsx + 10000] [expr $ofsy + 10000]
				call templates/unq_ende.tcl
				MapTemplateSet [expr $ofsx + 16] [expr $ofsy + 16]

            	set_fow_begin [expr $ofsy + 150]
            	set_light_begin 0
            }
		}

		proc generate_pos {pos} {
			set place [get_place -center $pos -circle 8 -random 8]
			if {[lindex $place 0]>0} {
				return $place
			}
			return $pos
		}

		proc find_in_inv_of {obj ol} {
			foreach item $ol {
				if { [inv_find_obj $item $obj] != -1 } {
					return 1
				}
			}
			return 0
		}


		//  Uebergang_0  UR_WarningCnt_0 UR_WarningTimer_0 Uebergang_Urw_Met urw_uebergang_swf Info_Pos_Uebergang_UM_1 Info_Pos_Uebergang_UM_2 Trigger_urw_8100_elfe_warnt_a Trigger_urw_8101_elfe_warnt_b Trigger_urw_040_c
		proc check_uebergang {Uebergang UR_WarningCnt UR_WarningTimer  sm_ue_event zone_template info_marker_1 info_marker_2 trigger_warn_1 trigger_warn_2 trigger_warn_3 time_1 time_2 upos} {

			global $Uebergang $UR_WarningTimer $UR_WarningCnt Reloc_count MapOffset $upos DelList RelocList RTargetPos
			set Ueb  [subst $$Uebergang]
			set WTim [subst $$UR_WarningTimer]
			set WCnt [subst $$UR_WarningCnt]
			set actpos [subst $$upos]

    		if { $Ueb == 0 } {
    			set ue [sm_get_event $sm_ue_event]
    			if { $ue } {
                    set Marker_1 [obj_query this -class $info_marker_1]
                    set Marker_2 [obj_query this -class $info_marker_2]

                    set MPos1 [get_pos $Marker_1]
                    set MPos2 [get_pos $Marker_2]

    				set pos $MPos1

    				//log "+++++++++++++++ Markerpos: $MPos1"
    				set py [lindex $pos 1]

    				set $upos $py

    				set RealOffset [map getoffset]
//    				log "+++++++++++++++ RealOffset: $RealOffset"

    				set newy [expr $py - 32 - [lindex $RealOffset 1]]
    				set_view_begin [expr $py - 16]
    				fincr MapOffset $newy
    				set $Uebergang $MapOffset
    				set Reloc_count [expr int($newy / 4)]

					// Verschiebungskrempel
                    set zl [obj_query this -class { Zwerg Baby } -owner 0 -cloaked 1]

                    set rl [lnand 0 [obj_query this -class { Ring_Des_Lebens Ring_Des_Wassers Ring_Des_Feuers Ring_Der_Luft Ring_Der_Erde Ring_Der_Magie Drachenbaby Drachen_Ei } ]]
                    set pl [lnand 0 [obj_query this -type {production energy protection store elevator} -owner 0]]
                    set ml [lnand 0 [obj_query this -type material]]

                    if { $zl == 0 || $Marker_1 == 0 || $Marker_2 == 0 } {
                    	log "StoryMgr: Warning Object not found: (Zwerg Baby : $zl) ($info_marker_1 : $Marker_1) ($info_marker_2 : $Marker_2)"
                    	return 1
                    }

					set RelocList [list]
    				foreach item $zl {
    					set zy [get_posy $item]
    					if { $zy <= [lindex $MPos1 1] + 1 } {
    						// Zwerge verschieben, deren y <= Marker_y sind
    						lappend RelocList $item
    					}
    				}

    				foreach item $rl {
    					set ry [get_posy $item]
    					if { $ry <= [lindex $MPos1 1] + 1 && ![find_in_inv_of $item $zl] } {
    						// Ringe usw. verschieben, deren y <= Marker_y sind und nicht im Inventory der Zwerge
    						lappend RelocList $item
    					}
    				}

    				set DelList [list]
    				foreach item $pl {
    					set ry [get_posy $item]
    					if { $ry < [lindex $MPos1 1] && ![is_contained $item] } {
    						// Zur�ckgelassene PS -> Del
    						lappend DelList $item
    					} elseif { $ry == [lindex $MPos1 1] } {
    						// Gleiche H�he PS -> Verschieben
    						call_method $item packtobox
    						lappend RelocList $item
    					}
    				}

    				foreach item $ml {
    					set ry [get_posy $item]
    					if { $ry <= [lindex $MPos1 1] + 1 && ![is_contained $item] } {
    						// Zur�ckgelassene Materials -> Del
    						lappend DelList $item
    					}
    				}

					// Ruckelwarnung
                	//gamedelayannounce 100

					// Zwerg f�r Sequenz beamen
					foreach item $zl {
						if { [get_objclass $item] == "Zwerg" } {
							set_pos $item $MPos1
							break
						}
					}

					set RTargetPos $MPos2

    				sel /obj
    				set trg [new $trigger_warn_3]
    				set_pos $trg $MPos1
    				set_owner $trg 0

    				wait_time 2.0
    				return 1
    			}
    		}

    		if { $WTim > 0 } {
    			set ZAbove 0

				set Marker_1 [obj_query this -class $info_marker_1 -limit 1]

				if { $Marker_1 != 0 } {
					set pos [get_pos $Marker_1]
        			//set pos [sm_get_temppos $zone_template]
        			set py [lindex $pos 1]
                    set zl [obj_query this -class { Zwerg Baby } -owner 0 ]
                    if { $zl != 0 } {
            			foreach item $zl {
            				set zy [get_posy $item]
            				if { $zy <= $py + 1 } {
            					set ZAbove 1
            					break
            				}
            			}
            		}
            	}

    			if { !$ZAbove || [gettime] >= $WTim } {
    			// verschieben
    				set $UR_WarningTimer 0
    				sm_set_event $sm_ue_event
    				set $UR_WarningTimer 0
    				return 1
    			} else {
    				set rem [expr $WTim - [gettime]]
    				if { $rem <= $time_1 && $WCnt == 0 } {
    					incr $UR_WarningCnt
    					Warning_Seq $trigger_warn_1 $WTim
    					return 1
    				} elseif { $rem <= $time_2 && $WCnt == 1 } {
    					incr $UR_WarningCnt
    					Warning_Seq $trigger_warn_2 $WTim
    					return 1
    				}
    			}
    		}
    		return 0
    	}


		proc newsticker_dig {ent param trg {click ""}} {
			global UR_WarningCnt_0 UR_WarningCnt_1 UR_WarningCnt_2 Uebergang_0 Uebergang_1 Uebergang_2 Generate_enabled
			set UID 0
			if { $Uebergang_2 == 0 } {
				set UID 2
			}
			if { $Uebergang_1 == 0 } {
				set UID 1
			}
			if { $Uebergang_0 == 0 } {
				set UID 0
			}

			log "!!!!!!!dig"

			set actcnt [subst \$UR_WarningCnt_$UID]
			if { $actcnt == 1} {
			}
			if { $actcnt == 4} {
			}
			if { $actcnt == 10} {
			}

			if { $actcnt >= 20} {
				switch { $UID } {
					0 {sm_set_event Uebergang_Urw_Met}
					1 {sm_set_event Uebergang_Met_Kris}
					2 {sm_set_event Uebergang_Kris_Lava}
				}
				sm_dig_message 0
				set Generate_enabled 1
			}

			incr UR_WarningCnt_$UID 1
			log "!! Warncnt: [subst \$UR_WarningCnt_$UID]"
		}

    	proc getpar {param name {def "undefined"}} {
    		global undefined
    		if { $def == "undefined" } {
    			set def $undefined
    		}
    		foreach item $param {
    			set inam [lindex $item 0]
    			set ival [lindex $item 1]
    			if { $name == $inam } {
    				return $ival
    			}
    		}
    		return $def
    	}

    	proc parse_text {txt trg} {
    		if { ![obj_valid $trg] } {
    			log "Newsticker Invalid Trigger: $trg"
    			return
    		}
   			set startidx 0
    		while { 1 } {
    			set bropen [string first "\[" $txt $startidx]
    			if { $bropen == -1 } { break }
    			set startidx $bropen
 				set brclose [string first "\]" $txt $startidx]
 				if { $bropen == -1 } { break }

 				incr bropen
 				incr brclose -1

 				set prc [string range $txt $bropen $brclose]
 				#? $bropen $brclose $prc
 				set reptxt [call_method $trg eval_newsticker $prc]
 				if { $reptxt != "error" } {
 				    set txt [string replace $txt [expr $bropen -1] [expr $brclose + 1] $reptxt]
 				} else {
 					log "Newsticker Invalid Proc $prc in [get_objclass $trg]"
 				}
 				set startidx $bropen
     		}
    		return $txt
    	}

    	proc gettext {ent} {
    		set textfile "data/scripts/text/info/newsticker_[locale].txt"
    		if { ![file exists $textfile] } {
    			log "Newsticker Textfile not found: $textfile"
    			return "FileNotFound:$textfile"
    		}
    	    set pF [open $textfile]
			while {![eof $pF]} {
				gets $pF line
				if { $ent == [lindex $line 0] } {
					set txt [string trim [string range $line [string length $ent] end]]
					close $pF
					return $txt
				}
			}
			close $pF
			return "MissingEntry:$ent"
    	}

        proc wait_time {time} {
    		state_disable this
    		action this wait $time {state_enable this} {state_enable this}
        }


		proc lmsg_param {txt paramlist} {
			set text [lmsg $txt]
			set message [string map $paramlist $text]
			return $message
		}

        proc Warning_Seq { triggername endtime } {
        	global last_newsticker_warning_id

        	set zl [obj_query this "-class Zwerg -owner 0"]
        	if { $zl != 0 } {

        		set my 100000
        		set bz 0
        		foreach item $zl {
        			set iy [get_posy $item]
        			if { $iy < $my } {
        				set my $iy
        				set bz $item
        			}
        		}

        		if { $bz != 0 } {

        			set trg [new $triggername]
        			set_pos $trg [get_pos $bz]

					if {$last_newsticker_warning_id != -1} {
						newsticker delete $last_newsticker_warning_id
					}
					set ntMessage [lmsg_param "Nur noch -1- Minuten Zeit zum Umzug!" "-1- [expr 1 + int(($endtime - [gettime])/60)]"]
					set id [newsticker new 0 -text "$ntMessage" -time [expr {1 * 60}]]
					newsticker change $id -click "newsticker delete $id"
					set last_newsticker_warning_id $id
        		}
	        }
       }

        proc GameOver {} {
            show_loading 1

            set MapOffset [map getoffset]
            set iXN [lindex $MapOffset 0]
            set iYN [lindex $MapOffset 1]
            set iXP [expr $iXN + 100]
            set iYP [expr $iYN + 100]

            reset_map $iXN $iYN $iXP $iYP

            set iXMid [expr ($iXN + $iXP) / 2.0]
            set iYMid [expr ($iYN + $iYP) / 2.0]
            set_pos this "$iXMid $iYMid 15"
            log "************ $iXMid $iYMid 15"
            set_fogofwar this -50 -50

            sel /obj
            set_view 32.2 32.1 1.5 -0.3 0.0		;# set inital camera view (x y zoom)
            call templates/unq_tod.tcl
            MapTemplateSet [expr 16 + $iXN] [expr 16 + $iYN]
            show_loading no
            state_disable this
            state_trigger this disabled
        }

		state_reset this
		state_triggerfresh this idle

		set temp_buffer [list]
		set failcount 0
		set act_sort_x 0
		set act_sort_y 0
		set temppos 0

		set zone "Urwald"
		set midx 8
		set maxfailures 4
		set gencount 0

		set bSplit 0
		set SplitTemplateList [list]
		set SplitPMPList [list]
		set SplitX 0
		set SplitY 0

		set resolution [sm_get_resolution]

		set newslist [list]
		set newsdata [list]
		set undefined -10000

		# obj-count f�r Mateirialvorkommen !!
		set oc_list { Kohle Kristallerz Golderz Eisenerz Pilz }
		set mingen_list { Wuker }

		set mingen_Wuker 0

		set Urwald_oc_Kohle 0
		set Urwald_oc_Kristallerz 0
		set Urwald_oc_Golderz 0
		set Urwald_oc_Eisenerz 0
		set Urwald_oc_Pilz 12

		set Metall_oc_Kohle 5
		set Metall_oc_Kristallerz 0
		set Metall_oc_Golderz 2
		set Metall_oc_Eisenerz 15
		set Metall_oc_Pilz 5

		set Kristall_oc_Kohle 15
		set Kristall_oc_Kristallerz 20
		set Kristall_oc_Golderz 5
		set Kristall_oc_Eisenerz 20
		set Kristall_oc_Pilz 5

		set Lava_oc_Kohle 20
		set Lava_oc_Kristallerz 20
		set Lava_oc_Golderz 15
		set Lava_oc_Eisenerz 20
		set Lava_oc_Pilz 3
		# /obj-count

		set Uebergang_0	0
		set UR_WarningCnt_0 0
		set UR_WarningTimer_0 0
		set U_Pos_0 0

		set Uebergang_1	0
		set UR_WarningCnt_1 0
		set UR_WarningTimer_1 0
		set U_Pos_1 0

		set Uebergang_2	0
		set UR_WarningCnt_2 0
		set UR_WarningTimer_2 0
		set U_Pos_2 0

		set Reloc_count 0
		set last_newsticker_warning_id -1

		set MapOffset 0
		set Generate_enabled 1

		set StartCnt 5
		set CheckCnt 0

		set DelList   [list]
		set RelocList [list]
		set RTargetPos {0 0 0}

		set_owner this 0
		log "StoryMgr is [get_ref this]"
		sm_register this "callback"

		catch { sm_add_event GameOverCheck }
		sm_set_event GameOverCheck
	}

	state disabled {
		state_disable this
	}

	state idle {

		if { $StartCnt > 0 } {
			incr StartCnt -1
			wait_time 1.0
			return
		}

		// Savegame Kompatiblit�t
		catch { sm_add_event GameOverCheck }

		incr CheckCnt
		if { $CheckCnt > 6 && [sm_get_event GameOverCheck] } {
			set CheckCnt 0
			set gl [obj_query this -class { Zwerg Baby } -owner player -cloaked 1]
			if { $gl == 0 } {
				GameOver
			}
		}
		//GameOver

		if { $Reloc_count > 0 } {

			show_loading 1 0.0
			load_info "."

			// Ringe k�nnten in zur�ckgelassenen Schatzkisten sein ...
			global_inv_rem $RelocList

			foreach item $RelocList {
				// Break action
				if { [obj_valid $item] } {
    				action $item wait 0
    				link_obj $item
    				set_posbottom $item [generate_pos $RTargetPos]
    				log "StoryMgr:[get_objclass $item] verschoben ([get_objname $item])"
    			}
			}

			foreach item $DelList {
				if { [obj_valid $item] } {
					log "StoryMgr:[get_objclass $item] gel�scht ([get_objname $item])"
					del $item
				}
			}

			set DelList   [list]
			set RelocList [list]

			//set MoveAmmount [expr $Reloc_count * 4]
			//map move 0 $MoveAmmount

			set fLoad 0.0
			set fRelocFull $Reloc_count.0

			while { $Reloc_count > 0 } {
				map move 0 4
				incr Reloc_count -1

				set fLoad [expr ($fRelocFull - $Reloc_count)/$fRelocFull ]
				show_loading 1 $fLoad
			}
			set Reloc_count 0

			show_loading 1 1.0
			show_loading 0

			wait_time 0.8
			return
		}

		if { [check_uebergang Uebergang_0  UR_WarningCnt_0 UR_WarningTimer_0 Uebergang_Urw_Met urw_uebergang_swf Info_Pos_Uebergang_UM_1 Info_Pos_Uebergang_UM_2 Trigger_urw_8100_elfe_warnt_a Trigger_urw_8101_elfe_warnt_b Trigger_urw_040_c 600 300 U_Pos_0]} {
			elf texvar 1
			return
		}
		if { [check_uebergang Uebergang_1  UR_WarningCnt_1 UR_WarningTimer_1 Uebergang_Met_Kris swf_uebergang_kris Info_Pos_Uebergang_MK_1 Info_Pos_Uebergang_MK_2 Trigger_swf_8102_elfe_warnt_a Trigger_swf_8103_elfe_warnt_b Trigger_swf_704_Bruecke_Einsturz 600 300 U_Pos_1]} {
			elf texvar 2
			return
		}
		if { [check_uebergang Uebergang_2  UR_WarningCnt_2 UR_WarningTimer_2 Uebergang_Kris_Lava lava_unq_start Info_Pos_Uebergang_KL_1 Info_Pos_Uebergang_KL_2 Trigger_kri_8104_elfe_warnt_a Trigger_kri_8105_elfe_warnt_b Trigger_Crystal_160_Hol_Einsturz 600 300 U_Pos_2]} {
			elf texvar 3
			return
		}

		if { $Generate_enabled == 0 } {
			wait_time 0.5
			return
		}

		if { [load_next] } {
			gamedelayannounce 15
			return
		}
		set area_list [sm_scan]
		//set area_list "[expr [irandom 100] + 10] [expr [irandom 128] + 10]"

		if { $area_list != 0 } {
			log "area_list: $area_list"
			generate_next [lindex $area_list 0] [lindex $area_list 1]
			sm_log
		}

		wait_time 0.5
	}

	method generate_next {x y} {
		generate_next $x $y
	}

	method load_level {level} {
		call "scripts/gameplay/CampaignInit.tcl"
		call "scripts/gameplay/$level.tcl"
		sm_log
	}

	method load_sandbox {level} {

		net initplayers
		call "scripts/gameplay/SandboxInit.tcl"
		call "scripts/gameplay/$level.tcl"

		/// Gamedata
        set GameData [net gamedata]
        log "GameData: $GameData"

        set GameSave 	"Data/Gamesave/[lindex $GameData 0]"
        set GameType 	[lindex $GameData 1]
        set UseMap 		[lindex $GameData 2]
        set Density		[lindex $GameData 3]
        set Resources	[lindex $GameData 4]
        set Set			[lindex $GameData 5]
        set Size		[lindex $GameData 6]
        set NumGnomes	[lindex $GameData 7]
        ///

		set zl [obj_query this -class Zwerg]

		set iGnomesToDel [expr [llength $zl] - $NumGnomes]
		for {set i 0} {$i < $iGnomesToDel} {incr i} {
			call_method [lindex $zl $i] destroy
		}

		gametime factor 1.0
		gametime start
	}
}
