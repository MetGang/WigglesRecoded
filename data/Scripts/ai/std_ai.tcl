call scripts/debug.tcl

log AI "Ai init starting"

ai_tickhandler {
	dotickhandler
}

set iTickCounter 0							;# AI Ticks seit Init
set iMyOwner 	 [ai_getownerid]			;# AI Owner
set iObjQueryCnt 0							;# Anzahl der Objquery-Aufrufe
set fCalculationTime 0.0					;# Verbrauchte Rechenzeit
log AI "My owner ist $iMyOwner."

set MyGnomesList			""				;# Liste aller meiner Zwerge
set MyProdsList				""				;# Liste aller meiner Geb�ude
set IntruderGnomesList    	""				;# Liste von fremden Zwergen
set IntruderProdList	  	""				;# Liste von fremden PS
set EnemyGnomesList		 	""				;# Liste von feindichen Zwergen
set EnemyProdList		  	"" 				;# Liste von feindichen PS
set TrapsList			  	""				;# Liste von Fallen (nicht feindlich)
set DoorsList			  	""				;# Liste von Tueren (nicht feindlich)
set EnemyTrapsList			""				;# Liste von feindichen Fallen
set EnemyDoorsList			""				;# Liste von feindlichen Tueren
set	UnavailableGnomesList 	""				;# Liste von Zwergen, die in diesem Tick schon verplant wurden

set bRaidInProgress			0				;# l�uft gerade ein Angriff?
set iLastRaidTime			0				;# Zeitpunkt meines letzten Angriffs
set RaidingPartyList		""				;# Liste der Angreifer (index 0 ist Anf�hrer)
set iRaidingTarget			0				;# Ziel des Angriffs
set iRaidState				""				;# Status des Angriffs
set iRaidingTimeOut			0				;# Time-Out-Counter f�r Angriff (z�hlt r�ckw�rts)
set RAIDINGTIMEOUT			[expr 12 * 5]	;# Standard-Timeout f�r Raid (5 Minuten)

set vBasePos 				"-1 -1 -1"		;# Position meiner Basis - selbst wenn dort keine Geb�ude mehr stehen
set fBasePerimeter			0.0				;# Perimeter-Entfernung
set vSafePos				"-1 -1 -1"		;# sichere Position, f�r Flucht z.B. (in jedem Tick neu berechnet)

set bIsDigging				1				;# AI graebt
set bIsBuilding				1				;# AI baut Gebaeude
set bIgnoreThieves			0				;# AI ignoriert Diebstahl
set bOpenDoors				1				;# AI oeffnet ihre Tueren
set bExpandBase				0				;# AI breitet sich aus oder nicht
set fExpandSpeed			0.0				;# Geschwindigkeit des Ausbreitens
set iNeutralGnomeStoleItem	-1				;# neutraler Zwerg stiehlt Eigentum
set rStolenItem				0
set vStolenPos				""
set ClansStoleCntList		{0 0 0 0 0 0 0 0}
set OwnerNTidList			{-1 -1 -1 -1 -1 -1 -1 -1}
set PreinventedList			""				;# Items, die die AI schon zu Beginn erfunden hat
set DontBuildList			""				;# Items, die die AI nicht bauen soll
set DontUseList				""				;# PS, wo die AI nicht produzieren soll
set DontPlaceArea			""				;# in diesem Bereich nix platzieren

// Symbolische Konstanten f�r Angriffs-FSM (iRaidState)

set RS_NONE					0				;# kein
set RS_GATHER				1				;# Angreifer werden versammelt
set RS_ONTHEWAY				2				;# Angreifer sind auf dem Weg
set RS_INTARGETZONE			3				;# Zielgebiet erreicht



// Beschreibung der AI - Parameter:
//
// bDefensive			spielt defensiv, d.h. greift Feinde und PS in der eigenen Basis an
// bAggressive			spielt aggressiv, d.h. f�hrt selbst Angriffe auf feindliche Basis durch
// fBaseDefenseRange	innerhalb dieser Entfernung um eigene PS ist "meine Basis" und wird wird verteidigt
// sBestMeleeWeapon		beste Nahkampfwaffe
// sBestRangedWeapon	beste Fernkampfwaffe
// sBestShield			bester Schild
// fRetreatHP			Prozentsatz Hitpoints, unter den ein Zwerg sinken muss, damit er sich zur�ckzieht


switch $iMyOwner {
	1		{	log AI "Init as: Voodoos"
				set bDefensive 			1
				set bAggressive			1
				set bStartWar			0
				set fBaseDefenseRange 	25.0
				set sBestMeleeWeapon	"Keule"
				set sBestRangedWeapon	"Steinschleuder"
				set sBestShield			"Schild"
				set iRaidingPartySize	2
				set iTimeBetweenRaids	[expr {120 * 60}]
				set fRetreatHP			0.35
				set bExpandBase			1
				set fExpandSpeed		0.2
				set PreinventedList		{Farm Holzkiepe Hauklotz Steinmetz Pilz Kleiner_Heiltrank Grillhamster}
				set DontBuildList		{Schreinerei Schmelze Schmiede}
			}
	2		{	log AI "Init as: Knockers"
				set bDefensive 			1
				set bAggressive			1
				set bStartWar			0
				set fBaseDefenseRange 	25.0
				set sBestMeleeWeapon	"Streitaxt"
				set sBestRangedWeapon	"Steinschleuder"
				set sBestShield			"Metallschild"
				set iRaidingPartySize	2
				set iTimeBetweenRaids	[expr {90 * 60}]
				set fRetreatHP			0.35
				set bExpandBase			1
				set fExpandSpeed		0.8
				set PreinventedList		{Hauklotz Grillhamster Farm Pilz Raupe Holzkiepe Steinmetz Keule Streitaxt PfeilUndBogen Reithamster Schild}
				set DontBuildList		{Dampfhammer Dampfmaschine Tischlerei Saegewerk}
			}
	3		{	log AI "Init as: Brains"
				set bDefensive 			1
				set bAggressive			1
				set bStartWar			1
				set fBaseDefenseRange 	35.0
				set sBestMeleeWeapon	"Schwert"
				set sBestRangedWeapon	"PfeilUndBogen"
				set sBestShield			"Metallschild"
				set iRaidingPartySize	3
				set iTimeBetweenRaids	[expr {60 * 60}]
				set fRetreatHP			0.35
				set bExpandBase			1
				set fExpandSpeed		0.3
				set PreinventedList		{Hauklotz Grillhamster Farm Pilz Raupe Holzkiepe Steinmetz Keule Streitaxt PfeilUndBogen Reithamster Schild Hoverboard Labor Bowlingbahn Raupensuppe Raupenschleimkuchen Pilzbrot Grosser_Heiltrank Unverwundbarkeitstrank Gold Grosse_Holzkiepe Kettensaege}
				set DontBuildList		{Disco Fitnessstudio}
				set DontUseList			{Tischlerei}
			}						
	4		{	log AI "Init as: Vampys"
				set bDefensive 			1
				set bAggressive			1
				set bStartWar			1
				set fBaseDefenseRange 	35.0
				set sBestMeleeWeapon	"Lichtschwerts"
				set sBestRangedWeapon	"Buechse"
				set sBestShield			"Kristallschild"
				set iRaidingPartySize	4
				set iTimeBetweenRaids	[expr {45 * 60}]
				set fRetreatHP			0.35
				set bExpandBase			1
				set fExpandSpeed		0.5
				set bOpenDoors			0
				set PreinventedList		{Hauklotz Grillhamster Farm Pilz Raupe Holzkiepe Steinmetz Keule Streitaxt PfeilUndBogen Schild Buechse Kristallschild Hoverboard Labor Raupensuppe Grosser_Heiltrank Unverwundbarkeitstrank Unsichtbarkeitstrank Gold}
				set DontBuildList		{Dreherei}
			}
	default	{ 	log AI "Init as: default"
				set bDefensive 			1
				set bAggressive			0
				set bStartWar			0
				set fBaseDefenseRange 	35.0
				set sBestMeleeWeapon	"Keule"
				set sBestRangedWeapon	"Steinschleuder"
				set sBestShield			"Schild"
				set iRaidingPartySize	1
				set iTimeBetweenRaids	[expr {100 * 60}]
				set fRetreatHP			0.35
				set bExpandBase			1
				set fExpandSpeed		0.6
				set bOpenDoors			0
			}
}


// diese proc kann von aussen mit "ai_exec <player> {set_ai_style <style>}" aufgerufen werden

proc set_ai_style {style} {
	global bDefensive bAggressive bStartWar fBaseDefenseRange sBestMeleeWeapon sBestRangedWeapon sBestShield
	global iRaidingPartySize iTimeBetweenRaids fRetreatHP
	global bOpenDoors bIsDigging bIsBuilding bExpandBase iMyOwner fExpandSpeed
	global PreinventedList DontBuildList DontUseList
	
	
	// ACHTUNG: nicht vergessen, neu hinzugef�gte Vars hier global zu machen :-)
	
	switch $style {

		aggressive {
			log AI "ai set to 'aggressive'"

			set bDefensive 			1
			set bAggressive			1
			set bStartWar			1			
			set fBaseDefenseRange 	35.0
			set sBestMeleeWeapon	"Keule"
			set sBestRangedWeapon	"Steinschleuder"
			set sBestShield			"Schild"
			set iRaidingPartySize	4
			set iTimeBetweenRaids	[expr {40 * 60}]
			set fRetreatHP			0.35					
		}
						
		defensive {
			log AI "ai set to 'defensive'"

			set bDefensive 			1
			set bAggressive			0
			set bStartWar			0
			set fBaseDefenseRange 	25.0
			set sBestMeleeWeapon	"Keule"
			set sBestRangedWeapon	"Steinschleuder"
			set sBestShield			"Schild"
			set iRaidingPartySize	2
			set iTimeBetweenRaids	[expr {100 * 60}]
			set fRetreatHP			0.6		
		}
	
		debug {
			log AI "ai set to 'debug'"

			set bDefensive 			1
			set bAggressive			1
			set bStartWar			1
			set fBaseDefenseRange 	35.0
			set sBestMeleeWeapon	"Keule"
			set sBestRangedWeapon	"Steinschleuder"
			set sBestShield			"Schild"
			set iRaidingPartySize	2
			set iTimeBetweenRaids	[expr {4 * 60}]
			set fRetreatHP			0.35			
		}
		
		default	{
			if {$style != "normal"} {
				log AI "illegal ai style, ai will play on 'normal'"
				set style normal
			} else {
				log AI "ai set to 'normal'"
			}
			
			set bDefensive 			1
			set bAggressive			1
			set bStartWar			0
			set fBaseDefenseRange 	15.0
			set sBestMeleeWeapon	"Keule"
			set sBestRangedWeapon	"Steinschleuder"
			set sBestShield			"Schild"
			set iRaidingPartySize	2
			set iTimeBetweenRaids	[expr {100 * 60}]
			set fRetreatHP			0.6						
		}
	}
	switch [get_ownerrace $iMyOwner] {
		0 {set fExpandSpeed 0.6}
		1 {set fExpandSpeed 0.4}
		2 {set fExpandSpeed 0.8}
		3 {set fExpandSpeed 0.5}
		4 {set fExpandSpeed 0.7}
	}
	set bOpenDoors 0
	set bIsDigging 1
	set bIsBuilding 1
	set bExpandBase 1
	set PreinventedList ""
	set DontBuildList ""
	set DontUseList ""
	return $style
}



proc dotickhandler {} {
	global iTickCounter iMyOwner MyGnomesList MyProdsList vSafePos vBasePos fCalculationTime
	global IntruderGnomesList IntruderProdList EnemyGnomesList EnemyProdList TrapsList DoorsList EnemyTrapsList 
	global EnemyDoorsList UnavailableGnomesList
		
	//set starttime [gettime]
	
	log AI "AI: $iMyOwner"
	
	ai_nprint "Ai Tick $iTickCounter\n"		;# AI Tick Count
	incr iTickCounter

	set popcnt [ai_gnomepopscount]
	set prodpopcnt [ai_prodpopscount]
	ai_nprint "gnome pops: $popcnt\n"
	if {$popcnt == 0} {
		return								;# keine Zwerge --> nichts zu tun!
	}

	set MyGnomesList		  ""
	set MyProdsList			  ""
	set	UnavailableGnomesList ""

	// Dinge, die nur ab und zu geupdatet werden m�ssen
	
	if {$iTickCounter % 25 == 0} {			
		set vSafePos			  "-1 -1 -1"
	}
	if {$iTickCounter % 80 == 0} {			
		set vBasePos "-1 -1 -1"
	}	

	for {set ipop 0} {$ipop < $popcnt} {incr ipop} {
		set MyGnomesList [concat $MyGnomesList [ai_gnomepop_getlist $ipop]]
	}
	ai_nprint "OGn 	: $MyGnomesList \n"
	
	for {set ipop 0} {$ipop < $prodpopcnt} {incr ipop} {
		set MyProdsList [concat $MyProdsList [ai_prodpop_getlist $ipop]]
	}
	ai_nprint "OPn 	: $MyProdsList \n"

	if { [vector_equal $vBasePos "-1 -1 -1"] } {				;# Position meiner Basis feststellen
		get_core_base_pos
	}


	set IntruderGnomesList	[ai_getintrudergnomes]
	set IntruderProdList	[ai_getintruderprods]
	ai_nprint "IGn 	: $IntruderGnomesList \n"
	ai_nprint "IPr	: $IntruderProdList  \n"

	filter_gnomes
	filter_prods
	ai_nprint "EGn 	: $EnemyGnomesList	 \n"
	ai_nprint "EPr	: $EnemyProdList 	 \n"
	ai_nprint "NTr	: $TrapsList		 \n"
	ai_nprint "NDo	: $DoorsList		 \n"
	ai_nprint "ETr	: $EnemyTrapsList	 \n"
	ai_nprint "EDo	: $EnemyDoorsList	 \n"

	check_for_thieves

	fight_ai

	set starttime [gettime]
	
	economy_ai
	
	set endtime [gettime]
	fincr fCalculationTime [expr {$endtime-$starttime}]
	
	return
}

//------------------------------------------------------------------------------------------------
// Allgemeine und n�tzliche Procs
//------------------------------------------------------------------------------------------------


// Ermittelt die Position meines Kernterritoriums

proc get_core_base_pos {} {
	global MyProdsList MyGnomesList vBasePos fBasePerimeter fBaseDefenseRange

	if {$MyProdsList != ""} {
		set l $MyProdsList
	} else {
		set l $MyGnomesList
	}
	set len [llength $l]
	
	// Mittelpunkt und Radius bestimmen
	
	set x 0
	set y 0
	foreach obj $l {
		set x [expr {$x + [get_posx $obj]}]
		set y [expr {$y + [get_posy $obj]}]
	}
	set x [expr {$x / $len}]
	set y [expr {$y / $len}]
	
	set vBasePos "$x $y 13"
	
	set d 0
	foreach obj $l {
		set d [expr {$d + [vector_dist $vBasePos [get_pos $obj]]}]
	}
	set fBasePerimeter [expr { (($d / $len) * 0.6) + $fBaseDefenseRange }]
	log AI "Calculated Base Center: \{$vBasePos\}, Perimeter Distance $fBasePerimeter"
}

// guckt nach, ob Zwerg in der UnavailableGnomesList ist

proc isGnomeAvailable {gnome} {
	global UnavailableGnomesList
	
	if {[lsearch $UnavailableGnomesList $gnome] < 0} {
		return 1
	} else {
		return 0
	}
}

proc incr_objquerycnt {} {
	global iObjQueryCnt
	incr iObjQueryCnt
}

// Stehlende Neutrale -> Diplomatie aendern

proc check_for_thieves {} {
	global iNeutralGnomeStoleItem rStolenItem vStolenPos ClansStoleCntList
	global bIgnoreThieves iMyOwner OwnerNTidList bOpenDoors
	if {$rStolenItem&&[obj_valid $rStolenItem]} {
		set boxed [get_boxed $rStolenItem]
	} else {
		set boxed 0
	}
	if {$bIgnoreThieves&&!$boxed} {
		set iNeutralGnomeStoleItem -1
		return
	}
	if {$iNeutralGnomeStoleItem!=-1} {
		set stolecnt [lindex $ClansStoleCntList $iNeutralGnomeStoleItem]
		set myrace [get_ownerrace $iMyOwner]
		if {$stolecnt>1||$boxed&&$stolecnt} {
			log AI "Diplomatie $iMyOwner $iNeutralGnomeStoleItem -> enemy"
			set_diplomacy $iMyOwner $iNeutralGnomeStoleItem "enemy"
			set_diplomacy $iNeutralGnomeStoleItem $iMyOwner "enemy"
			set nttext [lmsg Clantoenemy]
			set bOpenDoors 0
		} else {
			if {$stolecnt} {
				set nttext [lmsg Clanwarning1]
			} else {
				set nttext [lmsg Clanstealwarning]
			}
			incr stolecnt
			if {$boxed} {incr stolecnt}
			lrep ClansStoleCntList $iNeutralGnomeStoleItem $stolecnt
		}
		set nttext [string map "-clanname- [lmsg clanname$myrace]" $nttext]
		set ntID [lindex $OwnerNTidList $iNeutralGnomeStoleItem]
		if {$ntID!=-1} {
			newsticker delete $ntID
		}
		if {$vStolenPos!=""} {
			set clkhdl "set_view [lrange $vStolenPos 0 1] 1.5 -0.2 0.0"
		} else {
			set clkhdl ""
		}
		set ntID [newsticker new $iNeutralGnomeStoleItem -category fight -color {255 0 0} -text $nttext -priority 5.0 -time 50 -click $clkhdl]
		lrep OwnerNTidList $iNeutralGnomeStoleItem $ntID
		set iNeutralGnomeStoleItem -1
	}
}
	// Kriegserklaerung
	
proc declare_war {target} {
	global iMyOwner bOpenDoors
	
	set iOther [get_owner $target]
	set bOpenDoors 0
	
	if {[get_diplomacy $iMyOwner $iOther]=="enemy"} {
		return
	}
	set_diplomacy $iMyOwner $iOther "enemy"
	set_diplomacy $iOther $iMyOwner "enemy"
	set race [get_ownerrace $iMyOwner]
	set nttext [lmsg Clantoenemy]
	set nttext [string map "-clanname- [lmsg clanname$race]" $nttext]
	set clkhdl "set_view [lrange [get_pos $target] 0 1] 1.5 -0.2 0.0"
	newsticker new $iOther -category fight -color {255 0 0} -text $nttext -priority 5.0 -time 50 -click $clkhdl
}

// befiehlt Angriff auf Ziel, falls Zwerg noch nicht im Kampf ist

proc order_attack {gnome target} {
	if {[state_get $gnome] != "fight_dispatch"} {
		if {[vector_dist [get_pos $gnome] [get_pos $target]] < 8.0} {
			set_event $gnome evt_task_attack -target $gnome -subject1 $target
		} else {
			set_event $gnome evt_task_walk -target $gnome -pos1 [get_pos $target]
		}
	}
}


// liefert eine Liste der feindlichen Owner, wobei -1 nicht als feindlich angesehen wird

proc get_enemyownerlist {} {
	global iMyOwner

	set result ""
	for {set i 0} {$i < 8} {incr i} {
		if {[get_diplomacy $iMyOwner $i] == "enemy"} {
			lappend result $i
		}
	}
	return $result
}


// sucht ein m�gliches Angriffsziel

proc target_search {obj rangeparam {limitparam 1}} {

	set enemyownerlist [get_enemyownerlist]
	if {[llength $enemyownerlist] == 0} {
		return -1
	}

	// zerst�rte PS sind nicht mehr hoverable!
	set target [obj_query $obj "-type {production energy store protection gnome} -range $rangeparam -owner $enemyownerlist -flagpos hoverable -limit $limitparam"]
//	incr_objquerycnt
	return $target
}



// �berpr�ft, ob die Position eines Objektes (PS/Zwerg) sicher ist

proc is_objpos_safe {obj} {
	set enemy [obj_query $obj "-class Zwerg -owner enemy -range 20 -limit 1"]
	//incr_objquerycnt
	if {$enemy <= 0} {
		return 1
	}
	return 0 
}


// liefert einen sicheren Platz zur�ck

proc get_safe_pos {} {
	global vSafePos vBasePos iMyOwner 

	if {[lindex $vSafePos 0] <= 0} {

		// outdated: neu bestimmen
		set vSafePos $vBasePos 
		set ProdList [obj_query 0 -pos $vBasePos -type production -owner $iMyOwner -range 50]
		if {$ProdList != 0} {
			foreach obj $ProdList {
				log AI "looking at $obj"
				if {[is_objpos_safe $obj]} {
					log AI "$obj is safe"
					set vSafePos "[get_posx $obj] [get_posy $obj] 14"
					break
				} 
			}
		}
	}
	log AI "returning pos: $vSafePos"
	return $vSafePos
}

//------------------------------------------------------------------------------------------------
// K�mpferische Komponente der AI
//------------------------------------------------------------------------------------------------


// aggressives Verhalten der KI

proc fight_ai {} {
	global iTickCounter MyGnomesList bAggressive bDefensive bStartWar
	global bRaidInProgress iRaidingTarget RaidingPartyList iTimeBetweenRaids iLastRaidTime iRaidState iRaidingTimeOut RAIDINGTIMEOUT
	global IntruderGnomesList IntruderProdList EnemyGnomesList EnemyProdList TrapsList DoorsList 
	global EnemyTrapsList EnemyDoorsList UnavailableGnomesList
	global RS_NONE RS_GATHER RS_ONTHEWAY RS_INTARGETZONE

	// Agressives Verhalten - laufenden Angriff koordinieren
	
	if {$bAggressive && $bRaidInProgress} {
		log AI "RAID: in Progress (Timeout T minus $iRaidingTimeOut)"
		
		review_raidingparty
		log AI "Raiding Party: $RaidingPartyList"
		if {[llength $RaidingPartyList] == 0} {
			set bRaidInProgress 0
			set iRaidState $RS_NONE
			log AI "RAID: raiding party has broken up - operation terminated"
			send_raidingparty_home
		}
		review_raidingtarget
		if {$iRaidingTarget <= 0} {
			set bRaidInProgress 0
			set iRaidState $RS_NONE			
			log AI "RAID: no target - operation terminated"
			send_raidingparty_home
		}

		set iRaidingTimeOut [expr {$iRaidingTimeOut -1}]
		if {$iRaidingTimeOut <= 0} {
			set bRaidInProgress 0
			set iRaidState $RS_NONE			
			log AI "RAID: timed out - operation terminated"
			send_raidingparty_home			
		}
		
		if {$iRaidState == $RS_NONE} {
			set bRaidInProgress 0
			send_raidingparty_home
		}

		if {$iRaidState == $RS_GATHER} {
			log AI "RAID: gathering raiding party"
			if {[gather_raidingparty]} {
				set iRaidState $RS_ONTHEWAY
			}
		}
					
		if {$iRaidState == $RS_ONTHEWAY} {
			log AI "RAID: raiding party is on the way!"
			if {[approach_raidingtarget]} {
				set iRaidState $RS_INTARGETZONE
			}
		}
		
		if {$iRaidState == $RS_INTARGETZONE} {
			log AI "RAID: raiding party is in target zone!"
			set iRaidingTimeOut $RAIDINGTIMEOUT					;# Timeout auffrischen!
			attack_raidingtarget
		}

	}


	// Agressives Verhalten: wegen Tueren und Fallen in meiner Basis Streit anfangen

	set doorintercept 0

	if {$bAggressive &&  $bStartWar} {

		// neutrale Tueren in meiner Basis angreifen
		foreach obj $DoorsList {
			if {[is_in_my_base $obj]} {
				dispatch_interceptors $obj
				set doorintercept 1
			}
		}
	}

	// Notwehr: Basis spaltende Tueren als Affront werten
	
	if {!$doorintercept} {
		foreach obj $DoorsList {
			if {[is_splitting_my_base $obj]} {
				dispatch_interceptors $obj
			}
		}
	}
	
	// Defensives Verhalten - Angriff auf meine Basis?

	if {$bDefensive} {

		// alle feindlichen Fallen angreifen
		foreach obj $EnemyTrapsList {
			if {[is_in_my_base $obj]} {
				dispatch_shooters $obj
			}
		}

		// alle Feinde in meiner Basis angreifen
		foreach obj $EnemyGnomesList {
			if {[is_in_my_base $obj]} {
				dispatch_interceptors $obj
			}
		}

		// alle feindlichen Tueren in meiner Basis angreifen
		foreach obj $EnemyDoorsList {
			if {[is_in_my_base $obj]} {
				dispatch_interceptors $obj
			}
		}

		// danach m�gliche Produktionsst�tten in meiner Basis angreifen
		foreach obj $EnemyProdList {
			if {[is_in_my_base $obj]} {
				if {[get_objtype $obj] != "elevator"} {
					dispatch_interceptors $obj
				}
			}
		}
	}	 
	 
	 
	// Agressives Verhalten - Angriff einleiten
	 
	if {$bAggressive  &&  !$bRaidInProgress} {
		if {[gettime] >= [expr {$iLastRaidTime + $iTimeBetweenRaids}]} {
	
			log AI "Planning a raid..."
			set iLastRaidTime [gettime]
		
			if {[find_raiding_target]} {
				log AI "Raiding Target: $iRaidingTarget ([get_objname $iRaidingTarget])"
				
				if {[find_raidingparty]} {
					review_raidingparty
					log AI "Raiding Party: $RaidingPartyList"
				
					set bRaidInProgress 1
					set iRaidingTimeOut $RAIDINGTIMEOUT
					gather_raidingparty
					set iRaidState $RS_GATHER
				}
			}
		}
	}
		
	
	
	// �brige Zwerge: bei Gefahr nach Hause schicken!
	
	if {($iTickCounter % 6) == 0} {
		log AI "Looking for gnomes in danger..."
		foreach obj $MyGnomesList {
			if {[lsearch $UnavailableGnomesList $obj] < 0} {
				if {![is_objpos_safe $obj]} {
					if {![is_in_my_base $obj]} {
						set_event $obj evt_task_walk -target $obj -pos1 "[get_safe_pos]"
						log AI "[get_objname $obj] is in an unsafe location, sending her/him home"
					}
				}
			}
		}
	}
}


// filtert aus einer Zwergenliste nur die feindlichen heraus
// d.h. diplomacy == enemy

proc filter_gnomes {} {
	global iMyOwner IntruderGnomesList EnemyGnomesList
	set    EnemyGnomesList ""

	foreach obj $IntruderGnomesList {
		if {[get_diplomacy $iMyOwner [get_owner $obj]] == "enemy"  &&  [get_attrib $obj atr_Hitpoints] > 0.01  &&
			![get_cloaked $obj]} {

			lappend EnemyGnomesList $obj
		}
	}
}


// filtert die Intruder-PS-Liste nach
// * Fallen
// * Tueren
// * feindlichen, aber harmlosen PS

proc filter_prods {} {
	global iMyOwner IntruderProdList EnemyProdList TrapsList EnemyTrapsList DoorsList EnemyDoorsList
	set    	EnemyProdList 	""
	set		TrapsList 		""
	set		DoorsList		""
	set 	EnemyTrapsList	""
	set		EnemyDoorsList	""

	foreach obj $IntruderProdList {

		if {[get_attrib $obj atr_Hitpoints] < 0.01} {
			continue
		}
		
		if {[get_boxed $obj]} {
			continue
		}

		set class [get_objclass $obj]
		set owner [get_owner $obj]
		set diplomacy [get_diplomacy $iMyOwner $owner]
		
		if {$class == "Holztuer"    ||
			$class == "Metalltuer"  ||
			$class == "Kristalltuer"} {

			if {$diplomacy == "enemy"} {
				lappend EnemyDoorsList $obj
				continue
			} else {
				lappend DoorsList $obj
				continue
			}
		}

		if {$class == "Plattmachfalle"  ||
			$class == "SteinfalleMedusa"} {

			if {$diplomacy == "enemy"} {
				lappend EnemyTrapsList $obj
				continue
			} else {
				lappend TrapsList $obj
				continue
			}
		}

		//set iObjType [get_objtype $obj]
		set iObjOwner [get_owner $obj]

		if { $iObjOwner != -1 && [get_diplomacy $iMyOwner $iObjOwner] == "enemy"} {
			lappend EnemyProdList $obj
		}
	}
}


// liefert eine Bewertung eines Zwerges bez�glich seiner Nahkampfkraft
// 0.0 = unbewaffnet und tot bis open end

proc fight_evaluation {gnome} {
	set bestweapon [get_best_weapon $gnome]
	
	set astrength [lindex $bestweapon 2]
	if {$astrength == 0} {
		// keine Waffe --> normaler Nahkampf
		set astrength 0.5
	}

	set dstrength [lindex $bestweapon 3]
	if {$dstrength == 0} {
		// kein Schild  --> normale Verteidigung
		set dstrength 0.5
	}

	return [expr {($astrength + $dstrength) * [get_attrib $gnome atr_Hitpoints]}]
}



// liefert den besten verf�gbaren K�mpfer
// 0, wenn keiner mehr da ist

proc get_best_available_fighter {} {
	global UnavailableGnomesList MyGnomesList
	
	set best   0
	set bestfe 1.0 		;// niemals einen Zwerg unter 1.0 zur�ckliefern! 
	foreach obj $MyGnomesList {
		if {[lsearch $UnavailableGnomesList $obj] < 0} {
			set fe [fight_evaluation $obj]
			log AI "[get_objname $obj] has fight_evaluation of $fe"
			if {$fe >= $bestfe} {
				set bestfe $fe
				set best $obj
			}
		}
	}

	log AI "best fighter: $best $bestfe"
	return $best
}


// liefert eine Bewertung eines Zwerges bez�glich seiner Fernkampfkraft
// 0.0 = keine Fernwaffe bis open end

proc ballistic_evaluation {gnome} {
	set strength [lindex [get_best_weapon $gnome 1] 2]

	return [expr $strength * [get_attrib $gnome atr_Hitpoints]]
}



// liefert 1, wenn das Objekt nahe an meiner Basis ist

proc is_in_my_base {target} {
	global iMyOwner fBaseDefenseRange vBasePos fBasePerimeter
	
	if {[vector_dist [get_pos $target] $vBasePos] <= $fBasePerimeter} {
		log AI "in inner base!"
		return 1
	}
	
	//incr_objquerycnt
	if {[obj_query $target "-type {production energy store protection} -owner $iMyOwner -range $fBaseDefenseRange -limit 1"] == 0} {
		return 0
	}
	return 1
}

// liefert 1, wenn das Objekt zwischen 2 nahen PS liegt

proc is_splitting_my_base {target} {
	global iMyOwner
	set leftprod [obj_query $target "-type {production energy store protection} -owner $iMyOwner -boundingbox \{-15 -10 -10 0 10 10\} -limit 1"]
	if { $leftprod == 0 } { return 0 }
	set rightprod [obj_query $target "-type {production energy store protection} -owner $iMyOwner -boundingbox \{0 -10 -10 15 10 10\} -limit 1"]
	if { $rightprod } {
		return 1
	} else {
		return 0
	}
}

// sucht in der N�he eines Zieles (feindlicher Zwerg od. PS) nach eigenen Zwergen (d.h. ausreichend vielen)
// und schickt sie zum Angriff

proc dispatch_interceptors {target} {
	global iMyOwner UnavailableGnomesList

	set possibleattackers [obj_query $target "-class Zwerg -owner $iMyOwner -range 70.0"]
	//incr_objquerycnt
	if {$possibleattackers == 0} {
		return
	}
	set attackers ""
	set targetstrength [fight_evaluation $target]
	set targetpos [get_pos $target]
	
	declare_war $target
	
	// solange Zwerge als Angreifer hinzuf�gen, bis die Summe der Kampfkraft >= der des Zieles

	foreach obj $possibleattackers {
		if {[isGnomeAvailable $obj]} {
			lappend attackers $obj
			 set targetstrength [expr {$targetstrength - [fight_evaluation $obj]}]
			 if {$targetstrength <= 0} {
			 	break
			 }
		}
	}

	foreach obj $attackers {
		lappend UnavailableGnomesList $obj

		if {[state_get $obj] == "fight_dispatch"} {
			continue
		}
		if {[vector_dist [get_pos $obj] $targetpos] < 8.0} {
			set_event $obj evt_task_attack -target $obj -subject1 $target
			log AI "FIGHT: ordered [get_objname $obj] to attack [get_objname $target] (total [llength $attackers])"
		} else {
			set_event $obj evt_task_walk -target $obj -pos1 [get_pos $target]
			log AI "FIGHT: sent [get_objname $obj] to intercept [get_objname $target] (total [llength $attackers])"
		}
	}
}


// sucht in der N�he eines Zieles (feindlicher Zwerg od. PS) nach eigenen Zwergen
// die einen Fernangriff f�hren k�nnen und l�st diesen aus

proc dispatch_shooters {target {cheat 0}} {
	global iMyOwner UnavailableGnomesList sBestRangedWeapon

	set possibleattackers [obj_query $target "-class Zwerg -owner $iMyOwner -range 70.0"]
	//incr_objquerycnt
	if {$possibleattackers == 0} {
		return
	}
	set attackers ""
	set targetpos [get_pos $target]

	// Zwerge mit Fernkampfkraft suchen

	declare_war $target
	
	foreach obj $possibleattackers {
		if {[ballistic_evaluation $obj] > 0.0  &&
			[isGnomeAvailable $obj] < 0} {

			lappend attackers $obj
		 	break
		}
	}

	// falls kein Sch�tze gefunden wurde und cheaten erlaubt ist, machen wir uns einen Sch�tzen!
	if {[llength $attackers] == 0  &&  $cheat} {
		set gnome	[lindex $possibleattackers 0]
		if {[inv_find $gnome $sBestRangedWeapon] < 0} {
			set obj		[new $sBestRangedWeapon]
			if {[inv_check $gnome $obj]} {
				inv_add $gnome $obj
				log AI "FIGHT: Cheating... giving $sBestRangedWeapon to [get_objname [lindex $possibleattackers 0]]"
			} else {
				del $obj
			}
		}
	} else {
		// ansonsten schicken wir normale Angreifer
		dispatch_interceptors $target
	}

	foreach obj $attackers {
		lappend UnavailableGnomesList $obj

		if {[state_get $obj] == "fight_dispatch"} {
			continue
		}
		set_event $obj evt_task_attack -target $obj -subject1 $target
		log AI "FIGHT: ordered [get_objname $obj] to shoot [get_objname $target] (total [llength $attackers])"
	}
}



// sucht ein lohnendes Ziel f�r einen Angriff
// liefert: 1 - Erfolg   	0 - nichts gefunden

proc find_raiding_target {} {
	global iRaidingTarget MyGnomesList
	
	set mygnome [ lindex $MyGnomesList [irandom [llength $MyGnomesList]] ]
	set iRaidingTarget [target_search $mygnome 250]
	if {$iRaidingTarget > 0} {
		return 1
	}
	return 0
}


// sucht eine Gruppe von Angreifern 
// liefert 1 - Erfolg 	0 - nicht m�glich (weil z.B. Zwerge alle zu schwach etc.)

proc find_raidingparty {} {
	global iRaidingPartySize RaidingPartyList MyGnomesList UnavailableGnomesList
	
	set found 0
	set RaidingPartyList ""

	while {$found < $iRaidingPartySize} {
		set gnome [get_best_available_fighter]
		if {$gnome <= 0} {
			break
		}
		lappend UnavailableGnomesList $gnome
		lappend RaidingPartyList $gnome
		incr found
	}
	
	if {$found > 0} {
		return 1
	}
	
	return 0
}



// �berpr�ft die Angriffstruppe:
// - ob noch alle am Leben sind
// - ob es nicht Zeit w�re, jemanden nach Hause zu schicken
// meldet ausserdem alle Mitglieder als unavailable


proc review_raidingparty {} {
	global RaidingPartyList UnavailableGnomesList fRetreatHP
	
	for {set idx 0} {$idx < [llength $RaidingPartyList]} {incr idx} {
		set obj [lindex $RaidingPartyList $idx]

		if {![obj_valid $obj]} {				;# Zwerg ist wohl leider tot...
			lrem RaidingPartyList $idx
			continue
		}
		
		if {[get_attrib $obj atr_Hitpoints] <= $fRetreatHP} {		;# Zwerg f�hlt sich nicht gut, ab nach Hause!
			lrem RaidingPartyList $idx
			set_event $obj evt_task_walk -target $obj -pos1 "[get_safe_pos]"
			log AI "RAID: [get_objname $obj] is too weak, sending her/him home"
		}
	}
		
	foreach obj $RaidingPartyList {
		lappend UnavailableGnomesList $obj
	}
	
}


// �berpr�ft das aktuelle Angriffsziel und legt im Bedarfsfalle ein neues fest

proc review_raidingtarget {} {
	global iRaidingTarget RaidingPartyList
	
	if {![obj_valid $iRaidingTarget]  ||  [get_attrib $iRaidingTarget atr_Hitpoints] < 0.01} {
		set leader [lindex $RaidingPartyList 0]
		set iRaidingTarget [target_search $leader 20]
	}
}


// versammelt die Angriffsgruppe um den Anf�hrer
// liefert: 1 - Gruppe versammelt	0 - noch nicht versammelt 

proc gather_raidingparty {} {
	global RaidingPartyList
	
	set ready 1
	set leader [lindex $RaidingPartyList 0]
	set leaderpos [get_pos $leader]
	foreach obj $RaidingPartyList {
		if {[vector_dist [get_pos $obj] $leaderpos] > 3} {
			set ready 0
			set_event $obj evt_task_walk -target $obj -pos1 "$leaderpos"
			log AI "GATHERING RAIDINGPARTY: sent [get_objname $obj] to meet with [get_objname $leader]"		
		}
	}

	return $ready
}


// Angriffstruppe l�uft zum Ziel
// wenn unterwegs ein anderes Ziel gefunden wird, wird das statt dessen angegriffen
// liefert: 	1 - angekommen	0 - noch unterwegs

proc approach_raidingtarget {} {
	global RaidingPartyList iRaidingTarget
	
	set leader [lindex $RaidingPartyList 0]
	set leaderpos [get_pos $leader]
	set othertarget [target_search $leader 10]
	if {[vector_dist $leaderpos [get_pos $othertarget]] < [vector_dist $leaderpos [get_pos $iRaidingTarget]]} {
		set iRaidingTarget $othertarget
		log AI "RAID: target change during approach - new target is $othertarget"
	}

	set targetpos [get_pos $iRaidingTarget]
	if {[vector_dist $leaderpos $targetpos] < 4.0} {
		return 1
	}
	
	foreach obj $RaidingPartyList {
		set_event $obj evt_task_walk -target $obj -pos1 "$targetpos"
		log AI "RAID: sent [get_objname $obj] to target [get_objname $iRaidingTarget]"
	}
	
	return 0
}


// Angriffstruppe attackiert das Ziel

proc attack_raidingtarget {} {
	global RaidingPartyList iRaidingTarget

	foreach obj $RaidingPartyList {
		order_attack $obj $iRaidingTarget
		log AI "RAID: ordered [get_objname $obj] to attack [get_objname $iRaidingTarget]"
	}
}


// schickt die Angriffstruppe nach Hause

proc send_raidingparty_home {} {
	global RaidingPartyList

	foreach obj $RaidingPartyList {
		set_event $obj evt_task_walk -target $obj -pos1 "[get_safe_pos]"
		log AI "sending [get_objname $obj] home ([get_safe_pos])"
	}
}


//------------------------------------------------------------------------------------------------
// Wirtschaftliche Komponente der AI
//------------------------------------------------------------------------------------------------

// setzt automatisch Auftr�ge zur Produktion f�r einen bestimmten Pop


// Initialisierung
set eatclasses {Grillpilz Grillhamster Pilzbrot Raupensuppe Raupenschleimkuchen Hamstershake}
foreach item $eatclasses {
	set tttsection_tocall $item
	call data/scripts/misc/techtreetunes.tcl
}
set energyclasses {Laufrad Wasserrad Dampfmaschine Reaktor}
set energyranges ""
foreach item $energyclasses {
	set tttsection_tocall $item
	call data/scripts/misc/techtreetunes.tcl
	lappend energyranges [subst \$tttenergyrange_$item]
}
set inventcheat ""
set notinventlist ""
set gnometasklist ""
set gnomeitemlist ""
set pickuplist ""
set EconGnomesList ""
set proditem_classes ""
set proditem_classnames ""
set proditem_classcnt 0
// (wird unten definiert)
set putdownlist ""
set putdownboxes ""
set stealboxlist ""
set oldprodplacetasks ""
set failedbuilduptasks ""
set DesiredEnemyProdList ""
set aWorldStructure ""
set aDigField ""
set tDigFieldStart 0.0
set cave_skin_point ""
set vDigSendPoint ""

proc economy_ai {} {
	global UnavailableGnomesList MyGnomesList MyProdsList iMyOwner iTickCounter
	global bIsDigging bIsBuilding bOpenDoors fExpandSpeed
	global EconGnomesList DesiredEnemyProdList vDigSendPoint
	global PreinventedList DontBuildList DontUseList
	global eatclasses inventcheat notinventlist gnometasklist gnomeitemlist pickuplist
	global proditem_classes proditem_classnames proditem_classcnt oldprodplacetasks
	global putdownlist putdownboxes stealboxlist failedbuilduptasks
	global energyclasses energyranges
	set newlist ""
	foreach gnome $EconGnomesList {
		if {[ref_get $gnome last_event]!=""} {
			lappend $newlist $gnome
		}
	}
	set EconGnomesList $newlist
	log AI "invent_cheat: $inventcheat"
	log AI "notinvented: $notinventlist"
	if {0} {return}
	if {$iTickCounter%4} {return}
	if {$iTickCounter%120==4} {
		set worktiming 1
	} else {
		set worktiming 0
	}
	set firstgnomeofpop [lindex $MyGnomesList 0]
	set sizeofpop 		[llength $MyGnomesList]
	set populationowner $iMyOwner
	set ctime [gettime]
	log AI "locate: [ai_getprodlocation Zelt {120 35 11}]"
	
	// Zivilisationsstufe
	set civ_state [expr {([gamestats attribsum $populationowner expsum]+[gamestats numbuiltprodclasses $populationowner])*0.01}]
	// Zwergendurchiterieren
	set lborder 10000
	set rborder 0
	set uborder 10000
	set dborder 0
	set hunger 0.0
	set fullstomach 0.0
	set workgnomes 0
	set workershunger 0.0
	set sparegnomes 0
	set recentfood {}
	set idlegnomes 0
	set idlegnomelist {}
	set worktimelist {}
	set greathunger 0
	set invboxlist {}
	set buildupinprogress 0
	// Erfindecheat vorbereiten
	set inventablelist [ai_getpossibleinventions]
	if {$PreinventedList!=""} {
		foreach item $PreinventedList {
			log AI "PREINVENTING $iMyOwner: $item"
			set_owner_attrib $iMyOwner Bp$item 1.0
		}
		set PreinventedList ""
	}
	log AI "inventablelist $inventablelist"
	set itemcnts [string repeat "0 " $proditem_classcnt]
	set nearestinvention ""
	if {$iTickCounter%30==0&&$inventcheat==""} {
		if {$notinventlist!=""} {
			log AI "checking to cheat"
			set minlack 1000
			set cheatclass "none"
			foreach item $notinventlist {
				set classname [lindex $item 0]
				set priority [lindex $item 1]
				set instance [lindex $item 2]
				if {[obj_valid $instance]} {
					set attribs [call_method $instance prod_item_attribs $classname]
					set attrlen [llength $attribs]
					set attrlack 0.0
					foreach entry $attribs {
						set lack [expr {[lindex $entry 1]-[gamestats attribmax $populationowner [lindex $entry 0]]+0.05}]
						if {$lack>0.0} {
							fincr attrlack $lack
						} elseif {$attrlen>1} {
							incr attrlen -1
						}
					}
					set attrlack [expr {$attrlack*($attrlen+1)*0.5-$priority*0.2}]
					if {$attrlack<$minlack} {
						set nearestinvention $attribs
						set minlack $attrlack
						set cheatclass $classname
					}
				}
			}
			log AI "INVENTCHEAT GESETZT: $cheatclass ($nearestinvention)"
		}
		set nearestgnome 0
		set nearestattrs 100
	} elseif {$iTickCounter%8==0&&$inventcheat!=""} {
		set gnome [lindex $inventcheat 0]
		if {[obj_valid $gnome]} {
			set attrs [lindex $inventcheat 1]
			set maxlack -1
			set lowestattr ""
			foreach attr $attrs {
				set attrname [lindex $attr 0]
				set lack [expr {[lindex $attr 1]-[get_attrib $gnome $attrname]}]
				if {$lack>$maxlack&&$lack>0.0} {
					set lowestattr $attrname
					set maxlack $lack
				}
			}
			if {$lowestattr==""} {
				log AI "INVENTCHEAT ENDE: $inventcheat"
				set inventcheat ""
			} else {
				if {$lowestattr=="exp_Kampf"} {
					set lowestattr [get_gnomes_best_fight_attr $gnome]
					set increase 0.0005
				} else {
					set increase 0.001
				}
				if {$iTickCounter%80==0} {log AI "cheatin' $gnome $lowestattr [get_attrib $gnome $lowestattr] + [expr {$increase*10.0}] ($attrs)"}
				add_expattrib $gnome $lowestattr $increase
			}
		} else {
			log AI "INVENTCHEAT ENDE: $gnome gestorben"
			set inventcheat ""
		}
	}
	// Aufhebezuteilung vorbereiten
	set gnomebestdistribution ""
	set distributeitemslength [llength $pickuplist]
	// Zwerge iterieren fuer verschiedene Zwecke
	foreach gnome $MyGnomesList {
		// Ausdehnungsgebiet
		set gx [get_posx $gnome]
		set gy [get_posy $gnome]
		set lborder [hmin $gx $lborder]
		set rborder [hmax $gx $rborder]
		set uborder [hmin $gy $uborder]
		set dborder [hmax $gy $dborder]
		// aufgenommene Items zaehlen
		set inventory_classes {}
		set upgradecounter 0
		for {set i 0} {$i<$proditem_classcnt} {incr i} {
			set entry [lindex $proditem_classes $i]
			set itemclassname [lindex $entry 0]
			if {$upgradecounter} {
				set found 1
				incr upgradecounter -1
			} else {
				if {[inv_find $gnome $itemclassname]==-1} {set found 0} {
					set found 1
					set upgradecounter [lindex $entry 1]
				}
			}
			if {$found} {
				lappend inventory_classes $itemclassname
				set cnt [lindex $itemcnts $i]
				lrep itemcnts $i [expr {$cnt+1}]
			}
		}
		// Zwerg suchen fuer Inventcheat
		if {$nearestinvention!=""} {
			set attrlack 0.0
			foreach attr $nearestinvention {
				set lack [expr {[lindex $attr 1]-[get_attrib $gnome [lindex $attr 0]]}]
				if {$lack>0.0} {fincr attrlack $lack}
			}
			if {$attrlack<$nearestattrs} {
				set nearestgnome $gnome
				set nearestattrs $attrlack
			}
		}
		set newdistribution ""
		set newpickuplist ""
		for {set i 0} {$i<$distributeitemslength} {incr i} {
			set sublist [lindex $pickuplist $i]
			set newsublist ""
			set itemclass ""
			foreach item [lindex $sublist 0] {
				if {[obj_valid $item]} {
					set itemclass [get_objclass $item]
					lappend newsublist $item
				}
			}
			lappend newpickuplist $newsublist
			if {$itemclass==""} {
				lappend newdistribution ""
				continue
			}
			set currentlist [lindex $gnomebestdistribution $i]
			if {[lsearch $inventory_classes $itemclass]==-1} {
				set attrs [lindex $sublist 1]
				set attrsum 0.0
				foreach attr $attrs {
					if {[string index $attr 0]=="-"} {
						set attr [string range $attr 1 end]
						set factor -1
					} else {
						set factor 1
					}
					fincr attrsum [expr {[get_attrib $gnome $attr]*$factor}]
				}
				set newentry [list $gnome $attrsum]
				if {$currentlist==""} {
					set currentlist [list $newentry]
				} else {
					lappend currentlist $newentry
				}
			}
			lappend newdistribution $currentlist
		}
		set gnomebestdistribution $newdistribution
		// Produktionskisten im Inventory?
		log AI "([inv_list $gnome]) ($stealboxlist)"
		foreach item [inv_list $gnome] {
			if {[land $item $stealboxlist]!=""||[get_boxed $item]} {
				if {[get_prod_unpack $item]} {
					set buildupinprogress 1
				} else {
					set pdentry [list $gnome $item]
					log AI "Found: $item ($gnome)"
					if {[lsearch $putdownlist $pdentry]==-1} {
						lappend putdownlist $pdentry
					}
				}
			}
		}
		// Aufteilung spare-work-idle, Hunger zaehlen
		set isspare [expr {[get_remaining_sparetime $gnome]>0.2||[get_worktime $gnome nextend]>$ctime-100}]
		set nutri [get_attrib $gnome atr_Nutrition]
		if {$isspare} {
			incr sparegnomes
			fincr fullstomach 1.0
			if {$nutri<0.9} {
				fincr hunger $nutri
				eval "lappend recentfood [call_method $gnome get_recent_food]"
				if {$nutri<0.1} {set greathunger 1}
			} else {
				fincr hunger 1.0
			}
		} else {
			incr workgnomes
			fincr workershunger [expr {1.0-$nutri}]
			set gnomestate [state_get $gnome]
			if {$gnomestate=="work_idle"||$gnomestate=="prodfill_dispatch"} {
				if {[land $gnome $UnavailableGnomesList]==""} {
					lappend idlegnomelist $gnome
					incr idlegnomes
				}
			}
		}
		// Worktime-Verteilung erneuern alle 3 Stunden
		if {$worktiming} {
			set alert [get_attrib $gnome atr_Alertness]
			set mood [get_attrib $gnome atr_Mood]
			set hitp [get_attrib $gnome atr_Hitpoints]
			set sfc [call_method $gnome get_sparetime_futurecnt]
			set attrs [expr {(4-$nutri-$nutri-$alert-$mood)*(2-$hitp)+$sfc*0.5}]
			set partner [call_method $gnome get_reprodpartner]
			if {$partner} {
				set widx [lsearch -glob $worktimelist "$partner *"]
				if {$widx==-1} {
					lappend worktimelist [list $gnome $attrs]
				} else {
					set wentry [lindex $worktimelist $widx]
					set attrs [expr {($attrs+[lindex $wentry 1])*0.5}]
					lrep worktimelist $widx [list $partner $gnome $attrs]
				}
			} else {
				lappend worktimelist [list $gnome [get_objgender $gnome] $attrs]
			}
		}
	}
	if {$worktiming} {
		log AI "worktimelist: $worktimelist"
		// finde Singles
		set malelist ""
		set femalelist ""
		set widx 0
		foreach entry $worktimelist {
			set gender [lindex $entry 1]
			if {$gender=="male"} {
				lappend malelist $entry
				lrem worktimelist $widx
			} elseif {$gender=="female"} {
				lappend femalelist $entry
				lrem worktimelist $widx
			} else {
				incr widx
			}
		}
		set malelist [lsort -index 2 -real -decreasing $malelist]
		set femalelist [lsort -index 2 -real -decreasing $femalelist]
		foreach entry $malelist {
			set firstlady [lindex $femalelist 0]
			if {$firstlady!=""} {
				set attrs [expr {([lindex $entry 2]+[lindex $firstlady 2])*0.5}]
				lappend worktimelist [list [lindex $entry 0] [lindex $firstlady 0] $attrs]
				lrem femalelist 0
				lrem malelist 0
			} else {
				break
			}
		}
		set worktimelist [lsort -index 2 -real -decreasing $worktimelist]
		set worktimelist [concat $worktimelist [lsort -index 2 -real -decreasing [concat $malelist $femalelist]]]
		set worktimelen [llength $worktimelist]
		log AI "worktimelist: $worktimelist"
		if {$worktimelen>1} {
			switch $worktimelen {
				2 {set hours {6}}
				3 {set hours {6 3}}
				4 {set hours {6 3 6}}
				5 {set hours {6 3 6 3}}
				6 {set hours {4 4 2 4 4}}
				7 {set hours {4 4 2 4 4 2}}
				default {set hours {4 4 2 4 4 2 4 4 2 4 4 2 4 4 2}}
			}
			set nexthour [expr {int([gethours])%12+7}]
			foreach entry $worktimelist {
				if {$nexthour>11} {incr nexthour -12}
				foreach gnome [lrange $entry 0 1] {
					if {[string is integer $gnome]} {
						log AI "setting $gnome to: $nexthour 6.0"
						set_worktime $gnome $nexthour 6.0
					}
				}
				set nextdiff [lindex $hours 0]
				if {$nextdiff==""} {
					set nextdiff 2
				} else {
					lrem hours 0
				}
				incr nexthour $nextdiff
			}
		}
	}
	// Erfindecheat einrichten
	if {$nearestinvention!=""} {
		log AI "INVENTCHEAT GNOME: $nearestgnome [get_objname $nearestgnome] $nearestinvention"
		set inventcheat [list $nearestgnome $nearestinvention]
	}
	// Hungersituation
	if {$sparegnomes} {
		if {$hunger/$sparegnomes<0.4} {set greathunger 1}
	}
	set hunger [expr {$fullstomach-$hunger+$workershunger*0.5}]
	log AI "$sparegnomes $hunger $greathunger $workershunger"
	log AI "GBD: $gnomebestdistribution"
	set possiblenewtasks $idlegnomes
	fincr lborder -30.0
	fincr rborder  30.0
	fincr uborder -20.0
	fincr dborder  20.0
	set xdim [expr {($rborder-$lborder)*0.5}]
	set ydim [expr {($dborder-$uborder)*0.5}]
	set center [vector_add "$lborder $uborder 0" "$xdim $ydim 0"]
	set maxcenterdist [vector_dist [get_pos $firstgnomeofpop] $center]
	set centergnome [obj_query $firstgnomeofpop -pos $center -class Zwerg -owner own -range $maxcenterdist -limit 1]
	if {$centergnome==0} {set centergnome $firstgnomeofpop}
	set searchparams "-pos \{$center\} -boundingbox \{-$xdim -$ydim -10 $xdim $ydim 15\}"
	// --------------------------------------
	// Graben und so
	set DigFrequency [expr {int(50-$fExpandSpeed*35)*4}]
	log AI "DigFrequency: $DigFrequency"
	if {$bIsDigging&&($iTickCounter%$DigFrequency)==20} {
		log AI "analyzing world for digging: $iTickCounter ($DigFrequency $fExpandSpeed)"
		set placeneed 0
		foreach entry $failedbuilduptasks {
			incr placeneed [lindex $entry 1]
		}
		analyze_world $center $xdim $ydim $populationowner $placeneed $idlegnomes
	} else {
		log AI "naw $iTickCounter"
	}
	// --------------------------------------
	//set kitchens {Feuerstelle Mittelalterkueche Industriekueche Luxuskueche}
	//set kitchenlist [lnand 0 [obj_query $firstgnomeofpop "-class \{$kitchens\} $searchparams -owner own -flagpos build"]]
	incr_objquerycnt
	log AI "(-type production $searchparams -owner own -flagpos build)"
	// --------------------------------------------------
	// Hier werden die Produktionsstellen zusammengesucht
	// --------------------------------------------------
	set prodlist [lnand 0 [obj_query $firstgnomeofpop "-type \{production elevator energy store protection\} $searchparams -owner own"]]
	//set prodlist [lor $prodlist [lnand 0 [obj_query $firstgnomeofpop "-type \{production elevator energy store protection\} -pos \{-100 -100 0\} -range 10 -owner own -flagpos \{boxed contained\}"]]]
	incr_objquerycnt
	set prodlist [lor $prodlist $MyProdsList]
	log AI "pl: $prodlist"
	set prodclasses {}
	set prodreadylist {}
	foreach item $prodlist {
		if {[get_prodautoschedule $item]==0} {
			continue
		}
		set prodclass [get_objclass $item]
		lappend prodclasses $prodclass
		set prodtype [get_objtype $item]
		if {$prodtype=="production"&&[check_energy $item]} {
			lappend prodreadylist $item
		}
		econ_handle_prods $item $prodclass $prodtype
	}
	set prodlength [llength $prodclasses]
	log AI "pp found: $prodlist ($center)"
	// Fremde
	set prodenemylist [lnand 0 [obj_query $firstgnomeofpop "-type \{production elevator energy store protection\} $searchparams -owner enemy -flagneg \{boxed contained\}"]]
	incr_objquerycnt
	set prodenemyclasses {}
	foreach item $prodenemylist {
		lappend prodenemyclasses [get_objclass $item]
	}
	set prodenemyboxlist [lnand 0 [obj_query $firstgnomeofpop "-owner \{neutral enemy\} -flagpos boxed -flagneg contained"]]
	incr_objquerycnt
	set prodenemyboxes {}
	foreach item $prodenemyboxlist {
		lappend prodenemyboxes [get_objclass $item]
	}
	
	// --------------------------------------------------
	// dasselbe fuer Produktklassen
	// --------------------------------------------------
	set itemexistlist [lnand 0 [obj_query $firstgnomeofpop "-class \{$proditem_classnames $eatclasses\} $searchparams"]]
	log AI "found items: $itemexistlist"
	set itemclassexists {}
	foreach item $itemexistlist {
		lappend itemclassexists [get_objclass $item]
	}
	log AI "found itemclasses: $itemclassexists"
	
	
	// Produktwuensche zusammenstellen
	set product_values [get_prodplace_ratio $civ_state $sizeofpop $populationowner]
	if {$bIsBuilding} {
		foreach entry $oldprodplacetasks {
			set idx [lsearch -glob $product_values "$entry *"]
			if {$idx==-1} {
				lappend product_values [list $entry 0 0.0 1.0]
			} else {
				set oldentry [lindex $product_values $idx]
				set cnt [lindex $oldentry 1]
				incr cnt
				if {$cnt==0} {
					set cnt 1
				}
				lrep oldentry 1 $cnt
				lrep product_values $idx $oldentry
			}
		}
	} else {
		set product_values ""
	}
	set item_values [get_proditem_ratio]
	set builduplist {}
	set repairlist {}
	set pickuplist {}
	set steallist {}
	set producelist {}
	set inventlist {}
	set notinventlist {}
	set desiredlist {}
	set outofenergylist {}
	set DesiredEnemyProdList ""
	log AI "-------------------------------------------------"
	log AI "inventable: ($inventablelist)"
	log AI "Popcount: $sizeofpop Civstate: $civ_state GH: $greathunger ($hunger)"
	log AI $prodlist
	log AI $prodclasses
	foreach entry $product_values {
		set classname [lindex $entry 0]
		set desiredcnt [lindex $entry 1]
		if {$desiredcnt<0} {
			set desiredcnt [lindex $entry 2]
			set desiredcnt [expr {int(round($sizeofpop*$desiredcnt))}]
		}
		if {$desiredcnt&&$DontBuildList!=""} {
			if {[lsearch $DontBuildList $classname]!=-1} {
				set desiredcnt 0
			}
		}
		if {$desiredcnt} {
			lappend desiredlist [list $classname $desiredcnt]
		}
		log AI "$classname gew�nscht: $desiredcnt"
		set priority [lindex $entry 3]
		// vorhandene eigene
		set currentinst {}
		for {set i 0} {$i<$prodlength} {incr i} {
			if {[lindex $prodclasses $i]==$classname} {
				lappend currentinst [lindex $prodlist $i]
			}
		}
		//set currentcnt [llength $currentinst]
		log AI "$classname vorhanden: $currentinst"
		//if {$currentinst!=""} {log AI "($currentinst) ($stealboxlist)"}
		set searchforit [lcount $oldprodplacetasks $classname]
		foreach pp $currentinst {
			//if {$classname=="Zelt"} {log AI "$desiredcnt $searchforit"}
			if {$desiredcnt==0&&!$searchforit} {break}
			if {[get_boxed $pp]} {
				if {![get_prod_unpack $pp]} {
					if {![is_contained $pp]} {
						lappend builduplist [list $pp $priority]
					} else {
						log AI "found box in inv: $pp"
						//set stealboxlist [lor $stealboxlist $pp]
					}
					set desiredcnt 1
				} else {
					set buildupinprogress 1
				}
			} else {
				if {$desiredcnt==0&&$searchforit} {
					set opptidx [lsearch $oldprodplacetasks $classname]
					if {$opptidx!=-1} {
						lrem oldprodplacetasks $opptidx
						incr searchforit -1
					}
				}
				if {[get_buildupstate $pp]} {
					if {[get_objtype $pp]=="production"&&[check_energy $pp]} {
						//lappend prodreadylist $pp
					} else {
						set eclass [call_method $pp get_energyclass]
						if {$eclass==1} {set eclass 0}
						set found 0
						for {set i $eclass} {$i<4} {incr i} {
							set esupply [lindex $energyclasses $i]
							set erange [lindex $energyranges $i]
							incr_objquerycnt
							if {[obj_query $item -class $esupply -range $erange -owner own -flagpos build -limit 1]} {
								set found 1
								break
							}
						}
						if {$found} {continue}
						lappend outofenergylist [list $item $eclass $priority]
					}
				} else {
					lappend repairlist [list $pp $priority]
				}
			}
			incr desiredcnt -1
		}
		if {$searchforit} {
			incr desiredcnt -$searchforit
			set desiredcnt [hmax 0 $desiredcnt]
		}
		log AI "$classname gew�nscht: $desiredcnt"
		if {$desiredcnt} {
			// erreichbare fremde Kisten
			set others {}
			set iinst 0
			foreach oentry $prodenemyboxes {
				if {$oentry==$classname} {
					lappend others [lindex $prodenemyboxlist $iinst]
				}
				incr iinst
			}
			log AI "other $classname: $others"
			foreach pp $others {
				// bewacht?
				set gl [obj_query $pp -class Zwerg -owner own -range 15]
				incr_objquerycnt
				if {$gl==0} {
					lappend steallist [list $pp $priority]
					incr desiredcnt -1
				}
			}
		}
		if {$desiredcnt} {
			// erreichbare fremde zum Uebernehmen
			set iinst 0
			foreach oentry $prodenemyclasses {
				if {$oentry==$classname} {
					lappend DesiredEnemyProdList [lindex $prodenemylist $iinst]
				}
				incr iinst
			}
		}
		// zu erfinden
		if {[get_owner_attrib $populationowner Bp$classname]<0.5} {
			if {[lsearch $inventablelist $classname]!=-1} {
				lappend inventlist [list $classname $priority]
				log AI "$classname kann von $populationowner erfunden werden"
			} else {
				set places [prod_get_task_all_places $populationowner $classname]
				if {$places!=""} {
					lappend notinventlist [list $classname $priority [lindex $places 0]]
				}
				log AI "$classname kann noch nicht von $populationowner erfunden werden"
			}
		} else {
			// noch zu bauen
			if {$desiredcnt} {
				fincr priority [expr {($desiredcnt-1)*0.5}]
				lappend producelist [list $classname $desiredcnt $priority]
			}
		}
	}
	for {set i 0} {$i<$proditem_classcnt} {incr i} {
		set entry [lindex $item_values $i]
		set classname [lindex $entry 0]
		set desiredcnt [lindex $entry 1]
		set itempickuplist {}
		if {$desiredcnt<0} {
			set desiredcnt [lindex $entry 2]
			set desiredcnt [expr {int(round($sizeofpop*$desiredcnt))}]
		}
		if {$desiredcnt&&$DontBuildList!=""} {
			if {[lsearch $DontBuildList $classname]!=-1} {
				set desiredcnt 0
			}
		}
		set currentcnt [lindex $itemcnts $i]
		log AI "$classname $currentcnt mal vorhanden"
		incr desiredcnt -$currentcnt
		if {$desiredcnt>0} {
			lappend desiredlist [list $classname $desiredcnt]
		}
		set priority [lindex $entry 3]
		set currentinst ""
		set iinst 0
		foreach itclassentry $itemclassexists {
			if {$classname==$itclassentry} {
				lappend currentinst [lindex $itemexistlist $iinst]
			}
			incr iinst
		}
		foreach item [lrange $currentinst 0 [expr {$desiredcnt-1}]] {
			if {[lsearch {Eisen Bier Kristall} $classname]==-1} {
				lappend itempickuplist $item
			}
			incr desiredcnt -1
		}
		if {$itempickuplist!=""} {
			lappend pickuplist [list $itempickuplist [lindex $entry 4]]
		}
		if {[get_owner_attrib $populationowner Bp$classname]<0.5} {
			if {[lsearch $inventablelist $classname]!=-1} {
				lappend inventlist [list $classname $priority]
				log AI "$classname kann von $populationowner erfunden werden"
			} else {
				set places [prod_get_task_all_places $populationowner $classname]
				if {$places!=""} {
					lappend notinventlist [list $classname $priority [lindex $places 0]]
				}
				log AI "$classname kann noch nicht von $populationowner erfunden werden"
			}
		} else {
			if {$desiredcnt>0} {
				fincr priority [expr {($desiredcnt-1)*0.5}]
				lappend producelist [list $classname $desiredcnt $priority]
			}
		}
	}
	log AI "gew�nscht: $desiredlist"
	
	// Farmregeln
	set farms [land $prodlist [prod_get_task_all_places $populationowner Hamster]]
	set farmcount [llength $farms]
	set farmedwood 0
	set farmitems {Pilz Pilz}
	//if {$civ_state<0.1} {lappend farmitems Pilz}
	append farmitems [string repeat " Hamster Raupe Pilz" [expr {$farmcount/3+1}]]
	set farmitems [lrange $farmitems 0 [expr {$farmcount-1}]]
	log AI "Farms: $farms , $farmitems"
	set forbidden {}
	if {[get_owner_attrib $populationowner BpPilz]>0.0} {
		set pilzfarms [land $farms [prod_get_task_active_places $populationowner Pilz]]
		set mneed 1
		foreach pf $pilzfarms {
			log AI "found Pilzfarm: $pf"
			set idx [lsearch $farmitems Pilz]
			if {$idx==-1} {break}
			lrem farmitems $idx
			set farms [lnand $pf $farms]
			if {[get_prod_materialneed $pf]==0} {
				set farmedwood 1
				set mneed 0
				//break
			}
		}
		if {$mneed} {
			lappend forbidden Pilzhut
		}
	} else {
		set farmitems [lnand Pilz $farmitems]
		if {[lsearch $inventablelist Pilz]!=-1} {
			lappend forbidden Pilzhut
			lappend inventlist {Pilz 1.0}
		}
	}
	foreach farmclass {Hamster Raupe} {
		if {[get_owner_attrib $populationowner Bp$farmclass]>0.0} {
			set cfarms [land $farms [prod_get_task_active_places $populationowner $farmclass]]
			set mneed 1
			foreach f $cfarms {
				set idx [lsearch $farmitems $farmclass]
				log AI "found ${farmclass}farm: $f ($idx)"
				if {$idx!=-1} {
					lrem farmitems $idx
					set farms [lnand $f $farms]
				}
				log AI "checking mneed"
				if {[get_prod_materialneed $f]==0} {
					set mneed 0
					break
				}
			}
			if {$mneed} {
				lappend forbidden $farmclass
			}
		} else {
			set farmitems [lnand $farmclass $farmitems]
			lappend forbidden $farmclass
			if {[lsearch $inventablelist $farmclass]!=-1} {
				lappend inventlist [list $farmclass 0.6]
			}
		}
	}
	log AI "remaining farmitems: $farmitems ($farms)"
	foreach farmclass $farmitems {
		set found 0
		while {$farms!=""&&$found==0} {
			set nf [lindex $farms 0]
			set invent 0
			foreach item {Pilz Hamster Raupe} {
				if {[get_prod_slot_cnt $nf $item]==1} {
					log AI "Found Invention at $nf: $item"
					set invent 1
				}
			}
			if {$invent==0} {
				set found 1
				break
			} else {
				lrem farms 0
			}
		}
		if {$found==0} {break}
		log AI "$farmclass buildable at $nf: [get_prod_slot_buildable $nf $farmclass]"
		if {[get_prod_slot_buildable $nf $farmclass]} {
			if {[get_prod_slot_cnt $nf $farmclass]==0} {
				foreach item [lnand $item {Pilz Hamster Raupe}] {
					set_prod_slot_cnt $nf $item 0
				}
				log AI "BEAUFTRAGUNG: $nf -> $farmclass 10"
				set_prod_slot_cnt $nf $farmclass 10
			}
			lrem farms 0
		}
	}
	foreach farm $farms {
		set invent 0
		foreach item {Pilz Hamster Raupe} {
			if {[get_prod_slot_cnt $farm $item]==1} {
				set invent 1
			}
		}
		if {$invent} {continue}
		foreach item {Pilz Hamster Raupe} {
			if {[get_owner_attrib $populationowner Bp$item]>0.5&&[get_prod_slot_buildable $farm $item]&&[get_prod_slot_cnt $farm $item]==0} {
				foreach nitem [lnand $item {Pilz Hamster Raupe}] {
					set_prod_slot_cnt $farm $nitem 0
				}
				log AI "BEAUFTRAGUNG: $farm -> $item 10"
				set_prod_slot_cnt $farm $item 10
				break
			}
		}
	}
	log AI "forbidden: $forbidden"
	
	// Nahrung
	set allowed {}
	set reducelist {}
	foreach item $eatclasses {
		if {[get_owner_attrib $populationowner Bp$item]>0.5} {
			global tttmaterial_$item
			set mitems [subst \$tttmaterial_$item]
			if {[land $forbidden $mitems]==""} {
				set recentcount [lcount $recentfood $item]
				lappend allowed [list $item $recentcount]
			} else {
				lappend reducelist $item
			}
		} else {
			if {[string first $item $inventablelist]!=-1} {
				for {set i 0} {$i<4} {incr i} {
					lappend inventlist [list $item 0.9]
					append item "_"
				}
			}
		}
	}
	//set foodlist [lnand 0 [obj_query $firstgnomeofpop "-class \{$eatclasses\} $searchparams -visibility own -flagpos visible -flagneg \{locked contained\}"]]
	set foodcount 0
	foreach ecn $eatclasses {
		incr foodcount [lcount $itemclassexists $ecn]
	}
	log AI "allowed: $allowed ($foodcount)"
	//incr_objquerycnt
	fincr hunger [expr {-0.2*$foodcount}]
	set foodlist {}
	set whilecounter 0
	while {$hunger>0.05&&$allowed!=""&&$whilecounter<100} {
		incr whilecounter
		log AI "$hunger $foodlist $allowed"
		set allowed [lsort -integer -index 1 $allowed]
		set nextitem [lindex $allowed 0]
		set item [lindex $nextitem 0]
		set rc [lindex $nextitem 1]
		set idx [lsearch -glob $foodlist "$item *"]
		if {$idx==-1} {
			lappend foodlist [list $item 1 1.0]
		} else {
			set cc [lindex [lindex $foodlist $idx] 1]
			incr cc
			lrep foodlist $idx [list $item $cc [expr {0.5+$cc*0.5}]]
		}
		fincr hunger -0.2
		incr rc 2
		lrep allowed 0 [list $item $rc]
	}
	log AI "foodlist: $foodlist"
	if {$greathunger} {
		set producelist $foodlist
	} else {
		set producelist [concat $foodlist $producelist]
	}
	
	// Produktion
	//if {$producelist!=""} {log AI "to produce: $producelist"}
	//if {$builduplist!=""} {log AI "to buildup: $builduplist"}
	//if {$pickuplist!=""} {log AI "to pickup: $pickuplist"}
	//if {$outofenergylist!=""} {log AI "out of energy: $outofenergylist"}
	if {$steallist!=""} {log AI "to steal: $steallist"}
	if {$inventlist!=""} {
		log AI "to invent: $inventlist"
		set notinventlist ""
	}
	if {$repairlist!=""} {log AI "to repair: $repairlist"}
	
	// Fremde Kisten klauen
	if {!$greathunger&&$idlegnomes} {
		if {$steallist!=""} {
			set steallist [lsort -real -decreasing -index 1 $steallist]
			foreach item $steallist {
				set box [lindex $item 0]
				set gnomes [lnand 0 [obj_query $box "-class Zwerg -owner $populationowner $searchparams"]]
				incr_objquerycnt
				set gnomes [land $gnomes $idlegnomelist]
				if {$gnomes!=""} {
					set nearest [lindex $gnomes 0]
					timer_event $nearest evt_task_pickup -subject1 $box -pos1 [get_pos $box] -attime [expr {$ctime+0.01}]
					log AI "AUFHEBEN: $nearest [get_objname $nearest] $box [get_objname $box]"
					lappend EconGnomesList $nearest
					set stealboxlist [lor $stealboxlist $box]
					incr idlegnomes -1
					set idlegnomelist [lnand $nearest $idlegnomelist]
				}
			}
		}
	}
	
	// Zu Digmarkierung laufen
	log AI "vDSP: $vDigSendPoint ($idlegnomelist) $idlegnomes"
	if {$vDigSendPoint!=""&&$idlegnomes} {
		set mindist 1000
		set bestgnome 0
		foreach gnome $idlegnomelist {
			set dist [vector_dist [get_pos $gnome] $vDigSendPoint]
			if {$dist<$mindist} {
				set bestgnome $gnome
				set mindist $dist
			}
		}
		if {$bestgnome} {
			timer_event $bestgnome evt_task_walk -pos1 $vDigSendPoint -attime [expr {$ctime+0.01}]
			log AI "HINLAUFEN: $bestgnome ($vDigSendPoint)"
			set idlegnomelist [lnand $bestgnome $idlegnomelist]
			incr idlegnomes -1
			set vDigSendPoint ""
		}
	}
	
	// Aufhebauftraege ausstellen
	log AI "GH $greathunger IG $idlegnomes"
	if {!$greathunger&&$idlegnomes} {
		for {set i 0} {$i<$distributeitemslength} {incr i} {
			set items [lindex $newpickuplist $i]
			set gnomeslist [lindex $gnomebestdistribution $i]
			set gnomeslist [lsort -real -decreasing -index 1 $gnomeslist]
			log AI $gnomeslist
			set gnomeslist [lrange $gnomeslist 0 [expr {[llength $items]-1}]]
			log AI "checkin $items | $gnomeslist"
			foreach gnomeentry $gnomeslist {
				log AI "checking $gnomeentry ($idlegnomelist)"
				set gnome [lindex $gnomeentry 0]
				if {[land $gnome $idlegnomelist]==""} {
					continue
				}
				set nearestitem 0
				set mindist 1000
				foreach item $items {
					set dist [dist_between $gnome $item]
					if {$dist<$mindist} {
						set nearestitem $item
						set mindist $dist
					}
				}
				set items [lnand $nearestitem $items]
				timer_event $gnome evt_task_pickup -subject1 $item -pos1 [get_pos $item] -attime [expr {$ctime+0.01}]
				log AI "AUFHEBEN: $gnome [get_objname $gnome] $item [get_objname $item]"
				lappend EconGnomesList $gnome
				incr idlegnomes -1
				set idlegnomelist [lnand $gnome $idlegnomelist]
				set putdownitems [get_downgrades $gnome $item]
				log AI "pdi [get_objname $gnome]: $putdownitems"
				if {$putdownitems!=""} {
					lappend putdownlist [list $gnome $putdownitems]
				}
			}
		}
	}
	
	// Items ablegen
	set newpdlist ""
	log AI "PDL: $putdownlist"
	foreach entry $putdownlist {
		set gnome [lindex $entry 0]
		if {![obj_valid $gnome]} {continue}
		set invlist [inv_list $gnome]
		if {[land $gnome $idlegnomelist]!=""} {
			set newlist ""
			set found 0
			foreach item [lindex $entry 1] {
				if {[obj_valid $item]} {
					if {$found||[land $item $invlist]==""} {
						lappend newlist $item
					} else {
						set safe_pos [get_safe_pos]
						set place [get_place -center $safe_pos -rect -4 -3 4 1 -nearpos [get_pos $gnome]]
						if {[lindex $place 0]>0} {
							set safe_pos $place
						}
						set found 1
						timer_event $gnome evt_task_putdown -subject1 $item -pos1 $safe_pos -attime [expr {$ctime+0.01}]
						lappend EconGnomesList $gnome
						set stealboxlist [lnand $item $stealboxlist]
						log AI "ABLEGEN: $gnome [get_objname $gnome] $item [get_objname $item]"
					}
				}
			}
			if {$newlist!=""} {
				lappend newpdlist [list $gnome $newlist]
			}
		} else {
			lappend newpdlist $entry
		}
	}
	set putdownlist $newpdlist
	
	// Erfindungen einschalten
	set inventlist [lsort -real -decreasing -index 1 $inventlist]
	if {$greathunger} {
		set possibleinvtasks 0
	} else {
		set possibleinvtasks 2
	}
	if {$inventlist!=""} {
		set inventcheat ""
	}
	foreach entry $inventlist {
		if {$possibleinvtasks} {
			set classname [lindex $entry 0]
			if {[prod_get_task_total_cnt $populationowner $classname]==0} {
				set places [prod_get_task_all_places $populationowner $classname]
				log AI "possibleplaces $places"
				set places [land $prodlist $places]
				if {$places!=""} {
					set chosen [lindex $places 0]
					if {[get_prod_switchmode $chosen]} {
						foreach item [call_method $chosen prod_items] {
							set_prod_slot_cnt $chosen $item 0
						}
					}
					set_prod_slot_cnt $chosen $classname 1
					log AI "BEAUFTRAGUNG: $chosen -> $classname 1 (Erfinden)"
					incr possibleinvtasks -1
					incr possiblenewtasks -1
				}
			} else {
				log AI "Invention im Gange: $classname [prod_get_task_total_cnt $populationowner $classname]"
				incr possibleinvtasks -1
				incr possiblenewtasks -1
			}
		} else {
			break
		}
	}
	
	// Aufbauauftraege
	if {!$buildupinprogress} {
		foreach entry [lsort -index 1 -decreasing $builduplist] {
			log AI "placesearch foreach $entry"
			set entryitem [lindex $entry 0]
			set failidx [lsearch -glob $failedbuilduptasks "$entryitem *"]
			set failentry [lindex $failedbuilduptasks $failidx]
			if {$failidx!=-1} {
				set nexttick [lindex $failentry 2]
				if {$iTickCounter!=$nexttick} {
					continue
				}
			}
			set entryclass [get_objclass $entryitem]
			if {$entryclass=="Leiter"} {continue}
			set testrange [expr {[hmax $xdim $ydim]*1.2}]
			log AI "testrange for $entryclass: $testrange ($xdim $ydim)"
			set startrange [hmax [expr {int($testrange-25)}] 10]
			set whilecounter 0
			set found 0
			while {$startrange<$testrange&&$whilecounter<100} {
				log AI "placesearch $whilecounter"
				incr whilecounter
				set bestplace [get_best_buildup_place $entryclass $center $centergnome $startrange]
				incr startrange 20
				log AI "looping placesearch $whilecounter: $entryclass $startrange"
			}
			if {$bestplace!=""} {
				log AI "BEAUFTRAGUNG: $entryitem -> $entryclass buildup at $bestplace"
				ai_setbuildup $entryitem $bestplace
				set found 1
				if {$failidx!=-1} {
					lrem failedbuilduptasks $failidx
				}
				break
			} else {
				log AI "found no place for $entryclass ($entryitem)"
				if {$failidx==-1} {
					lappend failedbuilduptasks [list $entryitem 1 [expr {$iTickCounter+8}]]
				} else {
					set ccnt [lindex $failentry 1]
					if {$ccnt<7} {incr ccnt}
					set nexttime [expr {$ccnt*$ccnt*4}]
					lrep failedbuilduptasks $failidx [list $entryitem $ccnt [expr {$iTickCounter+$nexttime}]]
				}
			}
			if {$found} {log AI "leaving placesearch foreach";break}
		}
	}
	
	// Produktionsauftraege
	set whilecounter 0
	set alreadytaskedlist ""
	log AI "zu vergeben: $possiblenewtasks"
	while {$possiblenewtasks>0&&$producelist!=""&&$whilecounter<20} {
		incr whilecounter
		set producelist [lsort -real -decreasing -index 2 $producelist]
		log AI "pl: $producelist"
		set nextitem [lindex $producelist 0]
		set classname [lindex $nextitem 0]
		set cc [lindex $nextitem 1]
		set pr [lindex $nextitem 2]
		set alreadytasked 0
		for {set i 0} {$i<4} {incr i} {
			if {[ClassID $classname]==-1} {
				break
			}
			set totalcnt [prod_get_task_total_cnt $populationowner $classname]
			incr alreadytasked $totalcnt
			log AI "incr at by $totalcnt -> $alreadytasked $classname"
			if {$totalcnt&&[lsearch $alreadytaskedlist $classname]==-1} {
				lappend alreadytaskedlist $classname
				incr possiblenewtasks -1
			}
			append classname "_"
		}
		set deleteclass 0
		set found 0
		log AI "at: $alreadytasked cc $cc"
		if {$alreadytasked-$cc<0} {
			for {set i 0} {$i<4} {incr i} {
				set classname [string replace $classname end end]
				set places [land $prodlist [prod_get_task_all_places $populationowner $classname]]
				foreach pp $places {
					if {$DontUseList!=""} {
						if {[lsearch $DontUseList [get_objclass $pp]]!=-1} {
							set deleteclass 1
							log AI "Forbidden PS: $pp"
							break
						}
					}
					set tasks 0
					set mitems [call_method $pp prod_item_materials $classname]
					if {[land $forbidden $mitems]!=""} {
						log AI "Forbidden: $mitems ($pp) $forbidden ($classname)"
						set deleteclass 1
						break
					}
					foreach item [call_method $pp prod_items] {
						incr tasks [get_prod_slot_cnt $pp $item]
					}
					if {$tasks>$possiblenewtasks} {continue}
					if {[get_prod_slot_buildable $pp $classname]} {
						set taskcnt [get_prod_slot_cnt $pp $classname]
						incr taskcnt
						set_prod_slot_cnt $pp $classname $taskcnt
						if {$taskcnt==1} {incr possiblenewtasks -1}
						incr cc -1
						if {$cc} {
							fincr pr -0.5
							lrep producelist 0 [list [lindex $nextitem 0] $cc $pr]
						} else {
							set deleteclass 1
						}
						set found 1
						log AI "BEAUFTRAGUNG: $pp -> $classname $taskcnt [get_prod_slot_buildable $pp $classname]"
						if {[lsearch {production store elevator energy} [get_class_type $classname]]!=-1} {
							lappend oldprodplacetasks $classname
						}
						break
					} else {
						if {[lnand {Pilzhut Pilzstamm} $mitems]==""} {
							set forbidden [lor $forbidden "Pilzstamm"]
						}
					}
				}
				if {$deleteclass||$found} {
					break
				}
				if {[string index $classname end]!="_"} {
					break
				}
			}
			if {$deleteclass||!$found} {
				lrem producelist 0
			}
		}
	}
}

proc econ_handle_prods {pitem pclass ptype} {
	global bOpenDoors iMyOwner
	if {$ptype=="protection"&&[string first "tuer" $pclass]>0} {
		if {$bOpenDoors} {
			set_doorproperties $pitem openforall
		} else {
			set_doorproperties $pitem openforfriends
		}
	} elseif {$pclass=="Bar"} {
		set nobeer 1
		if {[gamestats numitems $iMyOwner Brauerei]} {
			if {[gamestats numitems $iMyOwner Bier]>7} {
				set_prod_slot_cnt $pitem Barbetrieb 10
				set nobeer 0
			}
		}
		if {$nobeer&&[get_prod_materialneed $pitem]} {
			set_prod_slot_cnt $pitem Barbetrieb 0
		}
	} elseif {$pclass=="Disco"} {
		set_prod_slot_cnt $pitem _Auflegen 10
	} elseif {$pclass=="Theater"} {
		set_prod_slot_cnt $pitem _Theatervorstellung 10
	}
}

proc get_best_buildup_place {cn pos gnome range} {
	global DontPlaceArea
	set dolog 0
	//set pos [get_pos $gnome]
	log AI "bestplace enter $cn"
	set places [ai_getprodlocations $cn $pos $range]
	log AI "Found places for $cn : $places"
	if {$places==""} {log AI "no locations found for $cn $range";return ""}
	log AI "found locations: $places"
	set allplaces $places
	set bestplace ""
	set nextplace ""
	if {[lsearch {Feuerstelle Zelt Laufrad Grabstein} $cn]==-1} {
		set pilzx 4
		set pilzz 6
	} else {
		set pilzx 1.5
		set pilzz 5
	}
	set whilecounter 0
	if {$dolog} {log AI $places}
	if {$DontPlaceArea!=""} {
		log AI "Forbidden Area: $DontPlaceArea"
		set dpaxn [lindex $DontPlaceArea 0]
		set dpayn [lindex $DontPlaceArea 1]
		set dpaxp [lindex $DontPlaceArea 2]
		set dpayp [lindex $DontPlaceArea 3]
	}
	while {$bestplace==""&&$places!=""&&$whilecounter<200} {
		log AI "placewhile $whilecounter ($nextplace)"
		incr whilecounter
		if {$nextplace==""} {
			set nextplace [lrem places 0]
			log AI "new nextplace: $nextplace"
			set pilzlist [lnand 0 [obj_query $gnome -pos $nextplace -class PilzMyzel -boundingbox {-20 -1 -10 20 1 10}]]
			set pilzposlist ""
			foreach pilz $pilzlist {
				lappend pilzposlist [get_pos $pilz]
			}
		}
		set nx [lindex $nextplace 0]
		set ny [lindex $nextplace 1]
		if {$DontPlaceArea!=""} {
			if {$nx>$dpaxn||$nx<$dpaxp||$ny>$dpayn||$ny<$dpayp} {
				log AI "forbidden: $nextplace"
				set nextplace ""
				continue
			}
		}
		//set nz [lindex $nextplace 2]
		set ysort [lsort -index 1 -real $places]
		set lowestmyy [lsearch -glob $ysort "* $ny *"]
		set ysort [lrange $ysort $lowestmyy end]
		set xsort ""
		foreach ys $ysort {
			if {[lindex $ys 1]==$ny} {
				lappend xsort $ys
			} else {
				break
			}
		}
		log AI "ny: $ny"
		log AI "$ysort"
		log AI "$xsort"
		set xsort [lsort -index 0 -real $xsort]
		set zsort ""
		set cx -1.0
		set bestnear ""
		foreach nplace $ysort {
			//if {$ny<[lindex $nplace 1]} {break}
			set npx [lindex $nplace 0]
			if {$npx<$nx-2.5} {continue}
			if {$npx>$cx} {
				if {$zsort!=""} {
					log AI "found: [lsort -index 2 -real $zsort]"
					set bestnear [lindex [lsort -index 2 -real $zsort] 0]
					break
				}
			}
			if {$npx>$nx+2.5} {break}
			set npz [lindex $nplace 2]
			log AI "nplace foreach $nplace"
			set pilzfree 1
			foreach pilzpos $pilzposlist {
				if {abs($npx-[lindex $pilzpos 0])<$pilzx&&abs($npz-[lindex $pilzpos 2])<$pilzz} {
					set pilzfree 0
					break
				}
			}
			if {$pilzfree} {
				lappend zsort $nplace
			}
			set cx $npx
		}
		//set nearplaces [ai_getprodlocations $cn $nextplace 5]
		//set leftsort [lsort -index 0 -real $nearplaces]
		if {$whilecounter>100} {log AI "$whilecounter: $nextplace ($bestnear) $bestplace"}
		if {""==$bestnear} {
			set nextplace ""
		} elseif {$bestnear==$nextplace} {
			set bestplace $nextplace
		} else {
			set nextplace $bestnear
		}
	}
	if {$bestplace!=""&&[lsearch $allplaces $bestplace]==-1} {
		log AI "FOUND PLACE NOT IN LIST: $cn ($bestplace) - $allplaces"
	}
	log AI "Found place $cn: $bestplace"
	return $bestplace
}

set worldlog 0
proc w_log {str} {
	global worldlog
	if {$worldlog} {log AI $str}
}
proc analyze_world {center xdim ydim owner placeneed igcount} {
	global bExpandBase fExpandRate vDigSendPoint
	global aWorldStructure aDigField tDigFieldStart cave_skin_point
	set mesh 2; set rmesh 0.5
	set avoid_field ""
	if {$aDigField!=""} {
		set begun 0
		set finished 1
		foreach entry $aDigField {
			if {$begun&&!$finished} {break}
			set point [lindex $entry 0]
			set high [lindex $entry 1]
			set low [lindex $entry 2]
			set current_h [get_hmap [lindex $point 0] [lindex $point 1]]
			if {$current_h<$high} {
				set begun 1
			}	
			if {$current_h>$low} {
				set finished 0
			}
		}
		if {!$begun} {
			w_log "field untouched -> deleting"
			// hier 500
			if {$tDigFieldStart<[gettime]-100} {
				delete_dig_field $aDigField $owner
				if {$cave_skin_point!=""} {
					eval "cave_skin rem $cave_skin_point"
				}
				set vDigSendPoint ""
				set avoid_field $aDigField
				set aDigField ""
			}
		} elseif {$finished} {
			set vDigSendPoint ""
			w_log "field finished"
			set aDigField ""
		} else {
			set vDigSendPoint ""
			w_log "field begun"
			return
		}
	}
	set minprior [expr {4.0-$placeneed}]
	if {!$bExpandBase} {
		set xdim [expr {$xdim*0.8}]
		set ydim [expr {$ydim*0.8}]
	}
	w_log "worldana: $center $xdim $ydim $minprior $placeneed"
	set corner0 [vector_add $center [list -$xdim -$ydim 0]]
	set corner1 [vector_add $center [list $xdim $ydim 0]]
	set xborder0 [expr {$mesh*int([lindex $corner0 0]*$rmesh)+5}]
	set yborder0 [expr {$mesh*int([lindex $corner0 1]*$rmesh)+5}]
	set xborder1 [expr {$mesh*int([lindex $corner1 0]*$rmesh)+1}]
	set yborder1 [expr {$mesh*int([lindex $corner1 1]*$rmesh)+1}]
	set broadth [expr {($xborder1-$xborder0)/$mesh+1}]
	set rows [expr {($yborder1-$yborder0)/$mesh+1}]
	w_log "worldana: $xborder0 $yborder0 $xborder1 $yborder1 $broadth $rows"
	set mapsize [expr {$broadth*$rows}]
	set worldmap [string trim [string repeat "0 " $mapsize]]
	//w_log $worldmap
	// bits: 1 - 11 here, 2 - 11 up, 4 - 11 down, 8 - 11 left, 16 - 11 right,
	// 32 - deeper, 64 - plain , 128 - rock
	set pointer [expr {$broadth+1}]
	set tunnelcnt 0
	set vertcnt 0
	set horicnt 0
	set cy [expr {$mesh+$yborder0+0.5}]
	for {set crow 2} {$crow<$rows} {incr crow} {
		set cx [expr {$mesh+$xborder0+0.5}]
		for {set cpnt 2} {$cpnt<$broadth} {incr cpnt} {
			set ch [get_hmap $cx $cy]
			set cp [list $cx $cy 0]
			set cm [get_material $cp]
			set ce [lindex $worldmap $pointer]
			if {$ch<10.5} {
				set ce [expr {$ce|32}]
			} elseif {$ch<12.5} {
				set ce [expr {$ce|1}]
				set bit 2
				incr tunnelcnt
				foreach diff "$broadth -$broadth 1 -1" {
					set idx [expr {$pointer+$diff}]
					set ne [lindex $worldmap $idx]
					if {$ne&1} {
						if {$bit==4} {
							incr vertcnt
							log AI "vert: $pointer $ce $ne"
						} elseif {$bit==16} {
							incr horicnt
							log AI "hori: $pointer $ce $ne"
						}
					}
					set ne [expr {$ne|$bit}]
					lrep worldmap $idx $ne
					set bit [expr {$bit<<1}]
				}
			} elseif {$ch==15.0} {
				set idx [expr {$pointer-$broadth}]
				set ne [lindex $worldmap $idx]
				if {$ne&32} {
					incr tunnelcnt
					set ne [expr {$ne|64}]
					lrep worldmap $idx $ne
					set idx [expr {$idx-1}]
					set ne [lindex $worldmap $idx]
					set ne [expr {$ne|16}]
					lrep worldmap $idx $ne
					set idx [expr {$idx+2}]
					set ne [lindex $worldmap $idx]
					if {$ne&1} {incr horicnt}
					set ne [expr {$ne|8}]
					lrep worldmap $idx $ne
				}
			}
			if {$cm==0||$cm==3} {
				set ce [expr {$ce|128}]
			}
			lrep worldmap $pointer $ce
			fincr cx $mesh
			incr pointer
		}
		incr pointer 2
		fincr cy $mesh
	}
	w_log "horizontal $horicnt vertikal $vertcnt tunnels $tunnelcnt"
	set aWorldStructure [concat [list $xborder0 $yborder0 $broadth $rows] $worldmap]
	print_worldmap
	set tunnelcnt [expr {$tunnelcnt*0.1}]
	set horivert [hmax [hmin [expr {$vertcnt-$horicnt}] 10] -10]
	set hori [expr {1+$horivert*0.03}]
	set vert [expr {1-$horivert*0.03}]
	set proposals ""
	set ladderpoints ""
	set spointer [expr {$broadth+1}]
	set epointer [expr {$mapsize-$broadth-2}]
	set pointer -1
	foreach entry $worldmap {
		incr pointer
		if {$pointer<$spointer} {continue}
		if {$pointer>$epointer} {break}
		set crow [expr {$pointer/$broadth}]
		if {$crow<2||$crow>$rows-3} {continue}
		set cpnt [expr {$pointer%$broadth}]
		if {$cpnt<2||$cpnt>$broadth-3} {continue}
		set centerdist [expr {(abs($broadth*0.5-$cpnt)+abs($rows*0.5-$crow))*-0.1}]
		if {($entry&25)==17&&($mesh*$crow+$yborder0)%4==1} {
			w_log "found: $pointer 17"
			set leftborder [expr {$pointer-$cpnt+1}]
			set type 0
			set len 0
			for {set i [expr {$pointer-1}]} {$i>$leftborder&&$len<6} {incr i -1} {
				set ne [lindex $worldmap $i]
				//w_log "searching left: $i - $ne"
				if {$ne&128} {break}
				if {$ne==9} {
					set type 12
					break
				}
				if {($ne&7)==7} {
					set type 6
					break
				}
				if {$ne>31} {break}
				set up [lindex $worldmap [expr {$i-$broadth*2}]]
				set do [lindex $worldmap [expr {$i+$broadth*2}]]
				if {$up!=""&&($up&1)||$do!=""&&($do&1)} {
					break
				}
				set type 2
				incr len
			}
			if {$type} {
				fincr type [expr {[hmin $len 6]*0.5}]
				set type [expr {$type*$hori}]
				fincr type $centerdist
				lappend proposals [list $pointer $i 1 $type]
			}
		}
		if {($entry&25)==9&&($mesh*$crow+$yborder0)%4==1} {
			w_log "found: $pointer 9"
			set rightborder [expr {$pointer-$cpnt+1}]
			set type 0
			set len 0
			for {set i [expr {$pointer+1}]} {$i<$rightborder&&$len<6} {incr i} {
				set ne [lindex $worldmap $i]
				//w_log "searching right: $i - $ne"
				if {$ne&128} {break}
				if {$ne==17} {
					set type 12
					break
				}
				if {($ne&7)==7} {
					set type 6
					break
				}
				if {$ne>31} {break}
				set up [lindex $worldmap [expr {$i-$broadth*2}]]
				set do [lindex $worldmap [expr {$i+$broadth*2}]]
				if {$up!=""&&($up&1)||$do!=""&&($do&1)} {
					break
				}
				set type 2
				incr len
			}
			if {$type} {
				fincr type [expr {[hmin $len 6]*0.5}]
				set type [expr {$type*$hori}]
				fincr type $centerdist
				lappend proposals [list $pointer $i 1 $type]
			}
		}
		if {($entry&7)==3&&$entry!=25&&($mesh*$cpnt+$xborder0)%4==1} {
			w_log "found: $pointer 3 ($entry) $tunnelcnt ($centerdist)"
			for {set i 1} {$i<12} {incr i} {
				set np [expr {$pointer-$i*$broadth}]
				set ne [lindex $worldmap $np]
				w_log "searching up: $np - $ne"
				if {($ne&1)==0} {break}
			}
			set len [expr {$i-1}]
			w_log "len up: $len"
			set downboarder [expr {$mapsize-$broadth*2}]
			set type 0
			set checkdown 0
			set lastpoint $pointer
			for {set i [expr {$pointer+$broadth}]} {$i<$downboarder&&$len<14} {incr i $broadth} {
				set ne [lindex $worldmap $i]
				w_log "searching down: $i - $ne"
				if {$checkdown} {
					if {($ne&5)==5||$ne>31} {
						w_log "skipping: $i $ne"
						set type 0
						break
					} else {
						continue
					}
				}
				if {$ne&128} {break}
				if {$ne==5} {
					set type 12
					break
				}
				if {($ne&25)==25} {
					set type 6
					break
				}
				if {$ne>31} {break}
				set le [lindex $worldmap [expr {$i-2}]]
				set ri [lindex $worldmap [expr {$i+2}]]
				if {$le!=""&&($le&1)||$ri!=""&&($ri&1)} {
					break
				}
				set type 2
				if {$len>10} {
					set checkdown 1
				} else {
					set lastpoint $i
				}
				incr len
			}
			w_log "finished $pointer ($i) $type $len $centerdist $vert"
			if {$type} {
				fincr type [expr {[hmin $len 10]*0.3}]
				if {$entry&8} {fincr type -2}
				if {$entry&16} {fincr type -2}
				set type [expr {$type*$vert}]
				fincr type $centerdist
				w_log "$pointer set to 2 $type"
				lappend proposals [list $pointer $lastpoint 2 $type]
			}
		}
		if {($entry&7)==5&&$entry!=25&&($mesh*$cpnt+$xborder0)%4==1} {
			w_log "found: $pointer 5 ($entry)"
			for {set i 1} {$i<12} {incr i} {
				set np [expr {$pointer+$i*$broadth}]
				set ne [lindex $worldmap $np]
				//w_log "searching down: $np - $ne"
				if {($ne&1)==0} {break}
			}
			set len [expr {$i-1}]
			set upboarder [expr {$broadth*2}]
			set type 0
			set checkup 0
			set lastpoint $pointer
			for {set i [expr {$pointer-$broadth}]} {$i>$upboarder&&$len<14} {incr i -$broadth} {
				set ne [lindex $worldmap $i]
				//w_log "searching up: $i - $ne"
				if {$checkup} {
					if {($ne&3)==3||$ne>31} {
						set type 0
						break
					} else {
						continue
					}
				}
				if {$ne&128} {break}
				if {$ne==3} {
					set type 12
					break
				}
				if {($ne&25)==25} {
					set type 6
					break
				}
				if {$ne>31} {break}
				set le [lindex $worldmap [expr {$i-2}]]
				set ri [lindex $worldmap [expr {$i+2}]]
				if {$le!=""&&($le&1)||$ri!=""&&($ri&1)} {
					break
				}
				set type 2
				incr len
				if {$len>10} {
					set checkup 1
				} else {
					set lastpoint $i
				}
			}
			w_log "finished $pointer ($i) $type $len $centerdist $vert"
			if {$type} {
				fincr type [expr {[hmin $len 10]*0.3}]
				if {$entry&8} {fincr type -2}
				if {$entry&16} {fincr type -2}
				set type [expr {$type*$vert}]
				fincr type $centerdist
				lappend proposals [list $pointer $lastpoint 2 $type]
			}
		}
		if {($entry==25)&&($mesh*$cpnt+$xborder0)%4==3} {
			w_log "found: $pointer 25 ($entry) ($centerdist)"
			set rightborder [expr {$pointer-$cpnt+$broadth}]
			set maxright [hmax $rightborder [expr {$pointer+8}]]
			set len 1
			for {set i [expr {$pointer+1}]} {$i<$maxright} {incr i} {
				set ne [lindex $worldmap $i]
				//w_log "searching tunnel: $i - $ne"
				if {$ne!=25&&$ne!=9} {break}
				incr len
			}
			set nosmall 1
			set nohigh 1
			set nobig 1
			if {$len>4} {
				set nosmall 0
				set nobig 0
				set nohigh 0
				if {$len>8} {set h 5;set b 9} {
					set nohigh 1
					if {$len>6} {set h 3;set b 7} {
						set nobig 1
						set h 3;set b 5
					}
				}
				for {set i 1} {$i<$h} {incr i} {
					for {set j 0} {$j<$b} {incr j} {
						set np [expr {$pointer-$i*$broadth+$j}]
						set ne [lindex $worldmap $np]
						if {$ne==""} {
							set nosmall 1
							break
						}
						w_log "searching cave: $np - ($ne) $pointer $i $j $broadth $cpnt $crow"
						if {($ne&30)^$ne} {
							if {$j<5&&$i<3} {
								set nosmall 1
								break
							} elseif {$j<7&&$i<3} {
								set nobig 1
								set h 3;set b 5
							} else {
								set nohigh 1
								set h 3;set b 7
							}
						}
					}
					if {$nosmall} {break}
				}
			}
			set tunnel [expr {$tunnelcnt+$centerdist+$placeneed}]
			if {$nosmall} {
				w_log "no cave possible: $pointer"
			} elseif {$nobig} {
				lappend proposals [list $pointer 0 3 $tunnel]
			} elseif {$nohigh} {
				fincr tunnel 1.0
				lappend proposals [list $pointer 1 3 $tunnel]
			} else {
				fincr tunnel 2.0
				lappend proposals [list $pointer 2 3 $tunnel]
			}
		}
	}
	w_log "found: $proposals"
	set proposals [lsort -index 3 -real -decreasing $proposals]
	set digpoints ""
	foreach prop $proposals {
		w_log "investigating $prop"
		if {[lindex $prop 3]<$minprior} {break}
		set type [lindex $prop 2]
		set points [lsort -integer [lrange $prop 0 1]]
		set p0 [lindex $points 0]
		set p1 [lindex $points 1]
		set rock 0
		switch $type {
			1 {
				set digpoints {}
				set digfield {}
				for {set i $p0} {$i<=$p1} {incr i} {
					set cx [expr {$mesh*($i%$broadth)+$xborder0}]
					set cy [expr {$mesh*($i/$broadth)+$yborder0}]
					for {set fx 0} {$fx<2} {incr fx} {
						for {set fy 0} {$fy<2} {incr fy} {
							set x [expr {$cx+$fx}]
							set y [expr {$cy+$fy}]
							//w_log "$x $y ($cx $cy $fx $fy) $xborder0 $yborder0"
							set h [get_hmap $x $y]
							set p [list $x $y 0]
							if {$h>11} {
								set m [get_material $p]
								if {$m==0||$m==3} {
									set rock 1
									w_log "ROCK at $x $y !!!"
									break
								}
							}
							lappend digpoints "$x $y -1"
							lappend digfield [list $p $h 11.0]
						}
						if {$rock} {break}
					}
					if {$rock} {
						set digpoints ""
						break
					}
				}
			}
			2 {
				set digpoints {}
				set digfield {}
				for {set i $p0} {$i<=$p1} {incr i $broadth} {
					set cx [expr {$mesh*($i%$broadth)+$xborder0}]
					set cy [expr {$mesh*($i/$broadth)+$yborder0}]
					for {set fx 0} {$fx<2} {incr fx} {
						for {set fy 0} {$fy<2} {incr fy} {
							set x [expr {$cx+$fx}]
							set y [expr {$cy+$fy}]
							//w_log "$x $y ($cx $cy $fx $fy) $xborder0"
							set h [get_hmap $x $y]
							set p [list $x $y 0]
							if {$h>11} {
								set m [get_material $p]
								if {$m==0||$m==3} {
									set rock 1
									w_log "ROCK at $x $y !!!"
									break
								}
							}
							lappend digpoints "$x $y -1"
							lappend digfield [list $p $h 11.0]
						}
						if {$rock} {break}
					}
					if {$rock} {
						set digpoints ""
						break
					}
				}
			}
			3 {
				set digpoints {}
				set digfield {}
				set depth [lindex {8 4 4} $p0]
				set layer [lindex {1 0 0} $p0]
				set cx [expr {$mesh*($p1%$broadth)+$xborder0}]
				set cy [expr {$mesh*($p1/$broadth)+$yborder0}]
				switch $p0 {
					0 {set linelist {{1 9} {1 9} {1 9} {2 8} {3 7}}}
					1 {set linelist {{1 13} {1 13} {1 13} {2 12} {3 11}}}
					2 {set linelist {{1 17} {1 17} {1 17} {1 17} {1 17} {1 17} {2 16} {3 15} {4 14}}}
				}
				set fy 1
				foreach line $linelist {
					set xp [lindex $line 1]
					for {set fx [lindex $line 0]} {$fx<$xp} {incr fx} {
						set x [expr {$cx+$fx}]
						set y [expr {$cy+$fy}]
						//w_log "$x $y ($cx $cy $fx $fy) $xborder0 $yborder0"
						set p [list $x $y 0]
						set m [get_material $p]
						set h [get_hmap $x $y]
						if {$m==0||$m==3} {
							set rock 1
							w_log "ROCK at $x $y !!!"
							break
						}
						lappend digpoints "$x $y $layer"
						lappend digfield [list $p $h $depth]
						if {$rock} {break}
					}
					if {$rock} {
						set digpoints ""
						break
					}
					incr fy -1
				}
			}
			if {$avoid_field!=""&&$avoid_field==$digfield} {
				w_log "We had this field!"
				set digpoints ""
			}
		}
		if {$digpoints!=""} {
			log AI "BEAUFTRAGUNG: graben Typ $type at [lindex $digfield 0] (priority [lindex $prop 3])"
			if {$type==3} {
				set cave_skin_x1 [expr {$cx+4.0+$p0*2}]
				set cave_skin_y2 $cy
				if {$p0==2} {fincr cave_skin_y2 -2.0}
				set cave_skin_x2 [expr {$cave_skin_x1+1.0}]
				set cave_skin_y1 [expr {$cave_skin_y2-1.0}]
				set cave_eval "cave_skin add $p0 $cave_skin_x1 $cave_skin_y1 $cave_skin_x2 $cave_skin_y2"
				fincr cave_skin_x1 0.5
				fincr cave_skin_y1 0.5
				set cave_skin_point [list $cave_skin_x1 $cave_skin_y1]
			} else {
				set cave_skin_point ""
				set cave_eval ""
			}
			break
		}
	}
	if {$digpoints!=""} {
		set vDigSendPoint [concat [lrange [lindex $digpoints 0] 0 1] 13]
		foreach point $digpoints {
			set digh [lindex $point 2]
			if {$digh==-1} {
				dig_mark $owner [lindex $point 0] [lindex $point 1] 1
			} else {
				dig_mark $owner [lindex $point 0] [lindex $point 1] 0 $digh
			}
		}
		eval $cave_eval
		set aDigField $digfield
		set tDigFieldStart [gettime]
	}
	//w_log $aWorldStructure
}

proc delete_dig_field {df owner} {
	foreach entry $df {
		set entry [join $entry]
		set x [lindex $entry 0]
		set y [lindex $entry 1]
		//w_log "deleting: $x $y"
		dig_mark $owner $x $y 2
	}
}

proc print_worldmap {} {
	global aWorldStructure
	w_log [lrange $aWorldStructure 0 3]
	set xd [lindex $aWorldStructure 2]
	set m [lrange $aWorldStructure 4 end]
	set nextline ""
	set linelen 0
	foreach entry $m {
		append nextline [format "%4i" $entry]
		incr linelen
		if {$linelen==$xd} {
			w_log $nextline
			set nextline ""
			set linelen 0
		}
	}
}

proc get_gnomes_best_fight_attr {gnome} {
	set highestattr exp_F_Kungfu
	set highestvalue 0.0
	foreach attr {exp_F_Kungfu exp_F_Sword exp_F_Twohanded exp_F_Ballistic exp_F_Defense} {
		set value [get_attrib $gnome $attr]
		if {$value>$highestvalue} {
			set highestattr $attr
			set highestvalue $value
		}
	}
	return $highestattr
}

proc get_downgrades {gnome item} {
	global proditem_classes
	set classname [get_objclass $item]
	set putdownclasses {}
	set startid 0
	foreach entry $proditem_classes {
		if {$startid} {
			lappend putdownclasses [lindex $entry 0]
			if {[lindex $entry 1]==0} {
				break
			}
		} elseif {[lindex $entry 0]==$classname} {
			if {[lindex $entry 1]} {
				set startid 1
			} else {
				return ""
			}
		}
	}
	if {[lsearch {Streitaxt Lichtschwert} $classname]+1} {
		lappend putdownclasses Schild Metallschild Kristallschild Schwert Keule
	}
	set putdownitems {}
	foreach item [inv_list $gnome] {
		if {[lsearch $putdownclasses [get_objclass $item]]!=-1} {
			lappend putdownitems $item
		}
	}
	return $putdownitems
}



// Produktion: Name Anzahl Anzahl/Zwerg Prioritaet
proc get_prodplace_ratio {civstate gnomes owner} {
	global MyGnomesList
	if {[llength $MyGnomesList]<3} {return {}}
	set productlist {}
	set kitchencnt 0
	foreach cn {Mittelalterkueche Industriekueche Luxuskueche} {
		if {[gamestats numitems $owner $cn]} {incr kitchencnt}
	}
	if {$kitchencnt} {
		lappend productlist {Feuerstelle	 1 0.00 1.0 }
	} else {
		lappend productlist {Feuerstelle	-1 0.20 1.0 }
	}
	set highcs 0.4
	set ratio 0.1
	foreach cn {Industrieschlafzimmer Mittelalterschlafzimmer Zelt} {
		if {$civstate>$highcs} {
			if {![gamestats numitems $owner $cn]} {
				lappend productlist "$cn	-1 $ratio 0.9 "
			} else {
				break
			}
		} else {
			fincr highcs -0.2
			set ratio 0.2
		}
	}
	if {$civstate>0.2} {
		foreach ct {bad wohnzimmer} {
			set highcs 0.5
			foreach cr {Luxus Industrie Mittelalter} {
				if {$civstate>$highcs} {
					set cn ${cr}$ct
					if {![gamestats numitems $owner $cn]} {
						lappend productlist "$cn 1 0.0 0.5"
					} else {
						break
					}
				} else {
					fincr highcs -0.15
				}
			}
		}
	}
	if {[get_owner_attrib $owner BpPilz]} {
		if {[get_owner_attrib $owner BpRaupe]} {
			set fc 4
		} else {
			set fc 3
		}
	} else {
		set fc 1
	}
	lappend productlist "Leiter [expr {[gamestats numitems $owner Leiter]+1}] 0.0 0.5"
	lappend productlist "Farm				$fc 0.0 0.9 "
	lappend productlist {Hauklotz			 1 0.00 0.6 }
	lappend productlist {Steinmetz			 1 0.00 0.4 }
	lappend productlist {Schreinerei		 1 0.00 0.7 }
	lappend productlist {Brauerei			 1 0.00 0.2 }
	lappend productlist {Schmelze			 1 0.00 0.4 }
	lappend productlist {Schmiede			 1 0.00 0.3 }
	lappend productlist {Tischlerei			 1 0.00 0.5 }
	lappend productlist {Saegewerk			 1 0.00 0.6 }
	//lappend productlist {Wachhaus			 0 0.00 0.1 }
	lappend productlist {Bar				 1 0.00 0.3 }
	lappend productlist {Waffenschmiede		 1 0.00 0.3 }
	lappend productlist {Waffenfabrik		 1 0.00 0.3 }
	lappend productlist {Dampfhammer		 1 0.00 0.4 }
	lappend productlist {Schleiferei		 1 0.00 0.6 }
	lappend productlist {Hochofen			 1 0.00 0.4 }
	lappend productlist {Kristallschmiede	 1 0.00 0.5 }
	lappend productlist {Theater			 1 0.00 0.3 }
	lappend productlist {Disco				 1 0.00 0.2 }
	lappend productlist {Fitnessstudio		 1 0.00 0.4 }
	lappend productlist {Bowlingbahn		 1 0.00 0.4 }
	lappend productlist {Labor				 1 0.00 0.1 }
	lappend productlist {Tempel				 1 0.00 0.1 }
	
	return $productlist
}
// Gegenstaende: Name Anzahl Ausstattungsquote Prioritaet Verteilung Upgrade
proc get_proditem_ratio {} {
	set productlist {}
	lappend productlist {Grosse_Holzkiepe	-1 0.50 0.2 exp_Transport 1 }
	lappend productlist {Holzkiepe			-1 0.50 0.2 exp_Transport 0 }
	lappend productlist {Buechse			-1 0.20 0.3 exp_F_Ballistic 1 }
	lappend productlist {PfeilUndBogen		-1 0.10 0.3 exp_F_Ballistic 0 }
	lappend productlist {Steinschleuder		-1 0.30 0.3 {exp_F_Ballistic exp_Transport} 0 }
	lappend productlist {Lichtschwert		-1 0.20 0.5 {exp_F_Twohanded exp_Kampf} 6 }
	lappend productlist {Streitaxt			-1 0.20 0.5 {exp_F_Twohanded exp_Kampf} 5 }
	lappend productlist {Schwert			-1 0.20 0.5 {exp_F_Sword exp_Kampf} 1 }
	lappend productlist {Keule				-1 0.40 0.4 {exp_F_Sword exp_Kampf} 0 }
	lappend productlist {Kristallschild		-1 0.70 0.1 {-exp_F_Twohanded exp_Kampf} 2 }
	lappend productlist {Metallschild		-1 0.70 0.1 {-exp_F_Twohanded exp_Kampf} 1 }
	lappend productlist {Schild				-1 0.70 0.1 {-exp_F_Twohanded exp_Kampf} 0 }
	lappend productlist {Hoverboard			-1 1.00 0.8 exp_Transport 1 }
	lappend productlist {Reithamster		-1 1.00 0.7 exp_Transport 0 }
	lappend productlist {Kettensaege		-1 0.10 0.4 exp_Holz 0 }
	lappend productlist {Kristallstrahl		-1 0.10 0.7 exp_Stein 1 }
	lappend productlist {Presslufthammer	-1 0.20 0.6 exp_Stein 0 }
	lappend productlist {Bier				6 0.00 0.8	{} 0}
	lappend productlist {Eisen				10 0.00 0.5	{} 0}
	lappend productlist {Gold				20 0.00 0.5	{-atr_Mood} 0}
	lappend productlist {Kristall			10 0.00 0.5	{} 0}
	return $productlist
}

// Produkteklassen zusammenstellen
foreach entry [get_proditem_ratio] {
	lappend proditem_classes [lreplace $entry 1 4]
	lappend proditem_classnames [lindex $entry 0]
	incr proditem_classcnt
}
		
log AI "Ai init done."

