call scripts/debug.tcl

def_class Zwerg none gnome 0 {reproduces lives moves} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/zwerg/z_anims.tcl
	call scripts/misc/obj_attribs.tcl
	call scripts/misc/genattribs.tcl
	call scripts/misc/generic_exp.tcl

	class_fightdist 1.0

	#
	obj_init {
		call scripts/debug.tcl
		call scripts/misc/generic_exp.tcl

		set info_string ""
		set logon 0
		set state_log 0
		set state_shell 0
		set event_log 0
		set workannounce_log 0
		set was_baby 0
		set is_campaign 0
		set is_tutorial 0
		set is_human 1
		set is_counterwiggle 0
		set myref [get_ref this]
		set gnome_initialized 0
		set gnome_gender "unset"
		set birthtime [expr {[gettime]-1200}]
		set_attrib this GnomeAge $birthtime
		set is_old 0
		set myhairs 0
		set myglasses 0
		set haircolor 0
		set hatcolor -1
		set info_string {}
		set clothes_changed 0

		set current_lock_obj 0
		set current_left_obj 0
		set current_workplace 0
		set last_workplace 0
		set current_worknum 0
		set current_worklist [list]
		set current_workdelay 0
		set current_worktask 0
		set current_workclass 0

		set current_tool_class 0
		set current_tool_item 0
		set current_lefttool_class 0
		set current_lefttool_item 0

		set current_weapon_out 0
		set current_weapon_item 0
		set current_shield_out 0
		set current_shield_item 0
		set died_in_fight 0							;# Zwerg ist im Kampf gestorben
		set is_dying 0								;# Zwerg stirbt
		set is_burning 0							;# Zwerg brennt
		set is_underwater 0							;# Zwerg ist unter Wasser
		set is_wearing_divingbell 0					;# Zwerg tr�gt eine Taucherglocke
		set is_wearing_divingbell_by_usercommand 0	;# Zwerg tr�gt Taucherglocke auf Befehl (= kein autom. Absetzen!)
		set out_of_water_timer 0					;# Zwerg ist soviel Zeit (events...) aus dem Wasser raus
		set MAX_AIR_UNDERWATER 15					;# Konstante: Luft f�r x Sekunden bevor Lebensabzug
		set remainingair $MAX_AIR_UNDERWATER		;# tats�chlich �brige Atemluft
		set love_potion_taken 0						;# Zwerg hat einen Liebestrank genommen
		set fertility_potion_taken 0				;# Zwerg hat einen Fruchtbarkeitstrank genommen
		set trap_mode 0								;# Zwerg ist in Falle
		set medusa_stoned 0							;# Zwerg ist versteinert

		set beam_backto 0

		set current_plan "work"
		set current_time_plan "sparetime"

		set current_occupation "idle"
		set current_wish_occupation "idle"

		set attack_behaviour "none"

		set idletimeout 0
		set prod_failurecount 0
		set current_digpos ""
		set current_digpose ""

		set last_disturb [gettime]
		set event_repeat 0
		set last_event ""
		set last_userevent_time 0
		set objghostlist 	 ""
		set putdownitemslist ""
		set idle_action_list ""
		set dig_versuche 4

		set logoff_code ""

    	set at_Hi 1.0
    	set at_Nu 1.0
    	set at_Al 1.0
    	set at_Mo 1.0

		set current_muetze_name 0
		set current_muetze_ref 0
		set muetzen_counter_start 7
		set muetzen_counter $muetzen_counter_start

		set clothing xx
        set ntNutrMessage -1
        set ntHitMessage -1
        set ntAltMessage -1

		// Idle anims f�r Sequenzen (Statistenrollen)
		set seq_idle_anims [list]
		lappend seq_idle_anims {10 {stand_anim_a}}
		lappend seq_idle_anims {10 {stand_anim_b}}
		lappend seq_idle_anims {10 {stand_anim_c}}
		lappend seq_idle_anims {1 {spaehen}}
		lappend seq_idle_anims {1 {zeigen_rechts}}
		lappend seq_idle_anims {1 {strippe_ziehen}}
		// lappend seq_idle_anims {1 {handstand_start handstand_loop handstand_loop handstand_end}}
		lappend seq_idle_anims {1 {raeuspern}}
		lappend seq_idle_anims {3 {wippen}}
		lappend seq_idle_anims {1 {verlegen}}
		lappend seq_idle_anims {5 {warten}}
		lappend seq_idle_anims {3 {kratzen}}
		lappend seq_idle_anims {1 {kopf_kratzen}}
		lappend seq_idle_anims {2 {aufatmen}}
		lappend seq_idle_anims {1 {popo_waermen}}
		lappend seq_idle_anims {2 {hungrig}}
		lappend seq_idle_anims {w1 {kletterstand_anim}}
		lappend seq_idle_anims {3 {blicken_rechts_links}}

		call data/scripts/misc/seq_idle.tcl

		# This used to be in techtreetunes.tcl
		// Pilzf�llen
		set tttgain_Pilz					{{exp_Holz 0.01}}
		set tttinfluence_Pilz				10.0
		// Graben
		set tttgain_dig						{{exp_Stein 0.0008} {exp_Metall 0.00005}}
		set tttinfluence_dig				10.0
		set tttfailmax_dig					0.2
		set tttexp_digbrush2				0.15
		set tttexp_digbrush3				0.30
		set tttexp_digbrush4				0.70
		// bis zu diesem Wert der Steinerfahrung kann es zu Fehlschl�gen kommen
		// Transport
		set tttgain_buildup					0.0018
		set tttgain_supply					0.003
		// Claneinstellungen
		set ttt_clanexp						{}
		set ttt_Voodoo_clanexp				{{exp_Nahrung 1.3} {exp_Holz 1.1} {exp_Kampf 0.9}}
		set ttt_Knocker_clanexp				{{exp_Stein 1.2} {exp_Metall 1.1}}
		set ttt_Brain_clanexp				{{exp_Energie 1.2} {exp_Service 1.1}}
		set ttt_Vampir_clanexp				{{exp_Kampf 1.2} {exp_Nahrung 0.8}}

		# This used to be in sparetimetunes.tcl
		// St�rungen
		set stt_dst_pilz						-0.01
		set stt_dst_eatplace					0.05
		set stt_wait_forseat					-0.005
		set stt_dst_bett						-0.02
		set stt_dst_work						-0.005
		set stt_dst_idle						0.0
		set stt_dst_spare						-0.01
		set stt_dst_sex							-0.05
		set stt_dst_talk						-0.02
		// Schlafgewinne, 2-Sekunden-Abstand
		set stt_slpgain_0						0.004
		set stt_slpgain_Zelt					0.006
		set stt_slpgain_Mittelalterschlafzimmer	0.008
		set stt_slpgain_Industrieschlafzimmer	0.009
		set stt_slpgain_Luxusschlafzimmer		0.010
		// Startzivilisationsstufen
		set stt_slpciv_0						-0.1
		set stt_slpciv_Zelt						0.0
		set stt_slpciv_Mittelalterschlafzimmer	0.20
		set stt_slpciv_Industrieschlafzimmer	0.35
		set stt_slpciv_Luxusschlafzimmer		0.50
		set stt_eatciv_0						-0.1
		set stt_eatciv_Feuerstelle				0.10
		set stt_eatciv_Mittelalterkueche		0.30
		set stt_eatciv_Industriekueche			0.40
		set stt_eatciv_Luxuskueche				0.50
		set stt_bthciv_0						-0.1
		set stt_bthciv_Mittelalterbad			0.25
		set stt_bthciv_Industriebad				0.40
		set stt_bthciv_Luxusbad					0.55
		set stt_homciv_0						0.0
		set stt_homeciv_Mittelalterwohnzimmer	0.25
		set stt_homeciv_Industriewohnzimmer		0.40
		set stt_homeciv_Luxuswohnzimmer			0.55
		// Essgewinne
		set stt_eatgain_Grillpilz				0.19
		set stt_eatgain_Grillhamster			0.24
		set stt_eatgain_Raupensuppe				0.31
		set stt_eatgain_Pilzsuppe				0.15 ;# is raus
		set stt_eatgain_Raupenschleimkuchen		0.35
		set stt_eatgain_Goulaschsuppe			0.28 ;# is raus
		set stt_eatgain_Pilzbrot				0.14
		set stt_eatgain_Hamstershake			0.27
		set stt_eatgain_Gourmetsuppe			0.70
		set stt_eatgain_Bier					0.02
		// Geschmack							beefy	sweet	fluid	light
		set stt_eattaste_Grillpilz				{0.01	0.05	0.00	0.05} ;#0.11
		set stt_eattaste_Grillhamster			{0.10	0.00	0.02	0.00} ;#0.12
		set stt_eattaste_Raupensuppe			{0.03	0.02	0.10	0.02} ;#0.17
		set stt_eattaste_Pilzsuppe				{0.00	0.03	0.12	0.07} ;#0.22
		set stt_eattaste_Raupenschleimkuchen	{0.05	0.10	0.03	0.05} ;#0.21
		set stt_eattaste_Goulaschsuppe			{0.12	0.01	0.08	0.00} ;#0.21
		set stt_eattaste_Pilzbrot				{0.00	0.12	0.00	0.06} ;#0.18
		set stt_eattaste_Hamstershake			{0.08	0.04	0.05	0.05} ;#0.22
		set stt_eattaste_Gourmetsuppe			{0.05	0.03	0.07	0.05} ;#0.20
		// Fungewinne
		set stt_fungain_Grillpilz				0.01
		set stt_fungain_Grillhamster			0.03
		set stt_fungain_Pilzbrot				0.02
		set stt_fungain_Raupensuppe				0.00
		set stt_fungain_Raupenschleimkuchen		0.01
		set stt_fungain_Hamstershake			0.15
		set stt_fungain_Gourmetsuppe			0.12
		//
		set stt_maxsearch_range					160.0 ;#darf nicht null sein!
		set stt_disapp_factor					0.3
		set stt_disapp_max						0.2
		// Fun-Aktivit�ten
		// Vorz�ge
		set stt_exp_Nahrung						{dsc pub}
		set stt_exp_Holz						{pub bwl}
		set stt_exp_Stein						{pub fit}
		set stt_exp_Metall						{bwl dsc}
		set stt_exp_Transport					{dsc tht}
		set stt_exp_Energie						{tht pub}
		set stt_exp_Service						{tht fit}
		set stt_exp_Kampf						{fit bwl}
		// Gespr�chsthemengewichtung
		set stt_talk_issues						{wal asw ocw wtm npw fli ttp tlw ubw uqw wmm wti mnf}
		set stt_talkweight_wal					0.1
		set stt_talkweight_asw					0.05
		set stt_talkweight_ocw					1.5
		set stt_talkweight_wtm					0.02
		set stt_talkweight_npw					0.03
		set stt_talkweight_fli					0.2
		set stt_talkweight_ttp					0.02
		set stt_talkweight_tlw					0.05
		set stt_talkweight_ubw					0.1
		set stt_talkweight_uqw					0.2
		set stt_talkweight_wmm					0.2
		set stt_talkweight_wti					0.2
		set stt_talkweight_mnf					0.1
		// Fun-Absichten
		set stt_fun_idleloss					0.0001
		set stt_issue_relief					2.0
		set stt_issue_reduce					0.7
		set stt_fun_intentions					{str fli smo cmf tll lis dft snf cfc pub tht bth dsc fit bow brl}

		auto_choose_workingtime this
		set_weapon_class this 0
		set_shield_class this 0

		set_texturevariation this [hf2i [random 4]] 0

		set_anim this mann.standard 0 $ANIM_LOOP
		set_objinfo . EinZwerg
		set_fogofwar this 14 8
		set_autolight this 1
		set_collision this 1

		set_attrib this carrycap 1
		set_attrib this hitpoints 1

		call scripts/misc/genericfight.tcl
		call scripts/classes/zwerg/z_events.tcl
		call scripts/classes/zwerg/z_procs.tcl
		call scripts/classes/zwerg/z_dignwalk.tcl
		call scripts/classes/zwerg/z_faceanim.tcl
		call scripts/classes/zwerg/z_work_states.tcl
		call scripts/classes/zwerg/z_work_common.tcl
		call scripts/classes/zwerg/z_work_prod.tcl
		call scripts/classes/zwerg/z_work_prodfill.tcl
		call scripts/classes/zwerg/z_spare_main.tcl
		call scripts/classes/zwerg/z_spare_procs.tcl
		call scripts/classes/zwerg/z_spare_fun.tcl
		call scripts/classes/zwerg/z_spare_talk.tcl
		call scripts/classes/zwerg/z_spare_reprod.tcl
		call scripts/classes/zwerg/z_work_strike.tcl
		call scripts/classes/items/calls/takeitems.tcl

		state_reset this
		state_trigger this idle
		state_enable this

		timer_event this evt_timer0 -repeat 1 -interval 1 -userid 1 -attime 3
		timer_event this evt_zwerg_attribupdate -repeat -1 -interval 1 -userid 2
		timer_event this evt_zwerg_workannounce -repeat -1 -interval 1 -userid 3
		timer_event this evt_talkissue_update -repeat -1 -interval 5 -userid 4 -attime [expr {[gettime] + 2}]
		timer_event this evt_sparewish_update -repeat -1 -interval 10 -userid 5 -attime [expr {[gettime] + 3}]
	}

	call scripts/classes/items/calls/takeitems.tcl
	call scripts/classes/zwerg/z_events.tcl
	call scripts/classes/zwerg/z_methods.tcl
	call scripts/classes/zwerg/z_faceanim.tcl
	call scripts/classes/zwerg/z_work_states.tcl
	call scripts/classes/zwerg/z_work_prodfill.tcl
	call scripts/classes/zwerg/z_spare_main.tcl
	call scripts/classes/zwerg/z_spare_reprod.tcl
	call scripts/misc/genericfight.tcl
	call scripts/classes/zwerg/z_work_strike.tcl

	#
	handle_event evt_timer0 {
		call_method this init
	}

	#
	state trapped {
		log STATE "[get_objname this] passing state code TRAPPED"
		if {$trap_mode==0} {
			gnome_failed_work this
			tasklist_clear this
			hide_tools
			kill_all_ghosts
			set trap_mode 1
			if {$trap_type=="petrify"} {
				set_anim this medusa_dead 0 1
				state_disable this
				action this wait 0.6 {state_enable this}
			} else {
				state_disable this
				if {[get_attrib this atr_Hitpoints]>=0.01} {
					set_anim this trappedtostand 0 1
					action this wait 0.6 {state_enable this}
				} else {
					set_anim this gettrapped 0 1
					action this wait 1
				}
			}
			return
		}
		if {$trap_mode==1} {
			if {$trap_type=="petrify"} {
				set_anim this medusa_dead 6 0
				set_stoned_textures 1
				set_physic this 1
			} else {
				log STATE "trappedtostand still [gettime] $trap_time"
				set_anim this trappedtostand 6 0
			}
			set trap_mode 2
			state_disable this
			action this wait $trap_time {state_enable this}
			return
		}
		if {$trap_mode==2} {
			log STATE "trapped getup [gettime] $trap_time"
			set_stoned_textures 0
			set trap_mode 0
			state_trigger this idle
			if {$trap_type=="petrify"} {
				set_physic this 0
				state_disable this
				set_anim this medusa_survive 13 1
				action this wait 1.4 {state_enable this}
			} elseif {[get_attrib this atr_Hitpoints]>=0.01} {
				state_disable this
				set_anim this trappedtostand 7 1
				action this wait 1.0 {state_enable this}
			}
			return
		}
	}

	#
	state_leave trapped {
		set_physic this 0
		set trap_mode 0
		//if {$trap_mode} {state_trigger this trapped}
	}

	#
	state_enter idle {
		log STATE "[get_objname this] enters state idle"
		set idletimeout 0
		gnome_idle this 1
	}

	#
	state idle {
		log STATE "[get_objname this] is now idle"

		incr idletimeout

		if { $sparetime_current_place_ref > 0 } {
			prod_guest guestremove $sparetime_current_place_ref [get_ref this]
			set sparetime_current_place_ref 0
			set sparetime_current_place 0
		}

		if { !$died_in_fight } {
			# Hide weapon/shield if present
			if { $current_weapon_out != 0 || $current_shield_out != 0 } {
				weapon_putin
				shield_putin
				return
			}

			# SHRUG
			if { [act_when_idle] } { return }

			# Sparetime is over, go to work
			if { [get_remaining_sparetime this] == 0.0 } {
				state_triggerfresh this work_dispatch
				return
			}

			# SHRUG
			if { $idletimeout > 5 } {
				log STATE "[get_objname this] = idletimeout = $idletimeout"
				if { [get_remaining_sparetime this] > 0.0 } {
					log STATE "[get_objname this] = change to sparetime----zwerg.tcl"
					state_enable this
					state_triggerfresh this sparetime_dispatch
					return
				} else {
					if { $sparetime_is_on } {
						sparetime_state_end
					}
					if { [get_gnomeposition this] && [get_prodautoschedule this] } {
						walk_down_from_wall
					}
				}
			}
		}

		set_idle_anim
		state_disable this
		action this wait 1 { state_enable this }
	}

	#
	state_leave idle {
		log STATE "[get_objname this] leaves state idle"
		gnome_idle this 0
	}

	# Invoked when gnome attempts to execute a task
	state task {
		if { [tasklist_cnt this] == 0 } {
			state_trigger this idle
		} else {
			set current_occupation "work"
			set command [tasklist_get this 0]
			tasklist_rem this 0
			log STATE "[get_objname this] executes task \"$command\""
			eval $command
		}
	}

	# Invoked when all tasks from the tasklist are completed
	state_leave task {
		log STATE "[get_objname this] finished task(s)"
		unlock_item
	}
}
