//# STOPIFNOT FULL
// lager.tcl

def_class _Nahrung_einlagern 						service material 1 {} {}
def_class _Kisten_einlagern 						service material 1 {} {}
def_class _Pilze_einlagern 							service material 1 {} {}
def_class _Rohmineralien_einlagern 					service material 1 {} {}
def_class _Mineralien_einlagern 					service material 1 {} {}
def_class _Waffen_Werkzeug_und_Traenke_einlagern	service material 1 {} {}

def_class Lager wood production 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	class_fightdist 2.0

	def_event evt_takeitems
	handle_event evt_takeitems {
		set itemlist [lnand 0 [obj_query this -type material -boundingbox {-1 -1 -1 1 1 1}]]
		foreach item $itemlist {
			set slidx [find_slot_for_storing [get_objclass $item]]
			if {$slidx!=-1} {
				store_item $slidx $item
			}
		}
	}
	
	def_event evt_btn_on
    handle_event evt_btn_on {
		global store_food store_boxes store_mushrooms store_minerals store_rawminerals store_misc storage_list current_worker current_itemtype

		if {$current_itemtype != 0  &&  $current_worker != 0} {
			if {![obj_valid $current_worker]} {
				log "WARNING: genericprod.tcl : current_worker is != 0 but object invalid!"
				set current_worker 0
				return
			}
			if {[get_prod_pack this] == 1} {
				log "genericprod.tcl : packing scheduled, breaking production; current worker is [get_objname $current_worker]"
				set_event $current_worker evt_zwerg_break -target $current_worker
				set_prod_pack this 1 		;// weil der Zwerg stop_prod sagt :-)
			}
		}

		if {[get_prod_slot_cnt this _Nahrung_einlagern] != 0} {
				set store_food 1
		}  else {
				set store_food 0
		}

		if {[get_prod_slot_cnt this _Kisten_einlagern] != 0} {
				set store_boxes 1
		}  else {
				set store_boxes 0
		}

		if {[get_prod_slot_cnt this _Pilze_einlagern] != 0} {
				set store_mushrooms 1
		}  else {
				set store_mushrooms 0
		}

		if {[get_prod_slot_cnt this _Rohmineralien_einlagern] != 0} {
				set store_rawminerals 1
		}  else {
				set store_rawminerals 0
		}

		if {[get_prod_slot_cnt this _Mineralien_einlagern] != 0} {
				set store_minerals 1
		}  else {
				set store_minerals 0
		}

//		if {[get_prod_slot_cnt this _Waffen_Werkzeug_und_Traenke_einlagern] != 0} {
//				set store_misc 1
//		}  else {
				set store_misc 0
//		}

		// Status des Lagers updaten
		call_method this find_items_to_store
    }


	// Timer-Tick: sucht nach Items, die schon beim letzten Tick lagen (also wahrscheinlich nicht benötigt werden)

    def_event evt_timer_search
    handle_event evt_timer_search {
		global items_list old_items_list storable_items_list store_range
//    	log "lager.tcl: Event evt_timer_search"

		validate_store_content

		set old_items_list $items_list			;// items der letzen Suche sind jetzt alte Items und können gelagert werden
		set items_list [list]

		// Kisten suchen
   		set boxes [obj_query this "-flagpos boxed -flagneg {contained locked instore} -owner [get_owner this] -range $store_range -visibility playervisible -alloc -1"]
		if {$boxes != 0} {
			foreach item $boxes {
				set pos [get_pos $item]
				if {![isunderwater $pos]} {
					lappend items_list "$item $pos"
				}
			}
		}

		set classes "Grillpilz Grillhamster Pilzbrot Raupensuppe Raupenschleimkuchen Gourmetsuppe Hamstershake Bier Pilzstamm Pilzhut Eisenerz Golderz Kristallerz Eisen Gold Kristall Stein Kohle"

		// andere items suche
		set otheritems [obj_query this "-flagpos storable -flagneg {contained locked instore} -range $store_range -class \{$classes\} -visibility playervisible -owner \{[get_owner this] -1\} -alloc -1"]
//		log "otheritems: $otheritems"
    	if {$otheritems != 0} {
    		foreach item $otheritems {
    			set pos [get_pos $item]
    			if {![isunderwater $pos]} {
	    			lappend items_list "$item $pos"
    			}
    		}
    	}

//    	log "old_items_list: $old_items_list"
//    	log "items_list: $items_list"

    	// Liste von items erstellen, die in der eben erfolgten und der letzen Umgebungssuche vorhanden waren
    	// und tatsächlich ins Lager passen würden
    	set storable_items_list [list]
    	foreach item [land $old_items_list $items_list] {
			set itemref [lindex $item 0]
    		if {[is_storable_itemtypelist [get_objclass $itemref]]} {
				lappend storable_items_list $itemref
    		} else {
//    			log "item $itemref ist alt, aber kein Platz zum Lagern"
    		}
    	}

		// find_items_to_store liefert jetzt eine Liste von items, die tatsächlich gelagert werden sollen
		// unter Berücksichtigung der Buttons am Lager und der eben erstellten Liste von lagerbaren items
		// nur wenn diese Liste etwas enthält, wird das Lager eingeschaltet

    	if {[llength $storable_items_list] > 0} {
    		set l [find_items_to_store]
			if {[llength $l] > 0} {
 	   			set_prod_enabled this 1
//    			log "storabable_items_list: $storable_items_list"
//    			log "find_items_to_store : $l"
//    			log "LAGER AKTIVIERT!"
    			return
	    	}
		}

		// ansonsten lager abschalten und auf den nächsten Timer warten :-)
		set_prod_enabled this 0
// 		log "LAGER DEAKTIVIERT!"
	}

  	method prod_item_actions item {
		global collected_items
		set exp_incr [call_method this prod_item_exp_incr $item]
		log "lager.tcl exp_incr = $exp_incr"

		set collected_items [list]

		set rlst [list]
		lappend rlst "prod_goworkdummy 7"
		lappend rlst "prod_turnfront"
		lappend rlst "prod_anim read"
		lappend rlst "prod_find_items"
		lappend rlst "prod_store_collect_all_items"
		lappend rlst "prod_goworkdummy 0"
		lappend rlst "prod_store_collected_items \{$exp_incr\}"

		return $rlst
	}


	// liefert 1, wenn alle schon gesammelten items und das angegebenen Platz im Lager finden würden

	method is_storable {item} {
		global collected_items
		return [is_storable $item $collected_items]
	}


	// holt das item aus dem Lager

	method retrieve_item {slotidx item} {
		retrieve_item $slotidx $item
	}


	// liefert den Slot, in dem sich ein konkretes Item befindet

	method find_slot_of_item {item} {
		return [find_slot_of_item $item]
	}


	// lagert das Item ein

	method store_item {slotidx item} {
		store_item $slotidx $item
	}


	// liefert die Animation, die beim Ablegen/Aufnehmen für diesen Slot gespielt werden muss

	method get_slot_anim {slotidx} {
		return [get_slot_anim $slotidx]
	}


	// liefert den Dummy, der sich am Boden vor dem Slot befindet

	method get_slot_dummy {slotidx} {
		return [get_slot_dummy $slotidx]
	}


	// liefert einen Slot, um einen Gegenstand eines bestimmten Typs zu lagern

	method find_slot_for_storing {itemtype} {
		return [find_slot_for_storing $itemtype]
	}


	// liefert einen Slot, aus dem ein Gegenstand eines bestimmten Typs entnommen werden kann

	method find_slot_for_retrieving {itemtype} {
		return [find_slot_for_retrieving $itemtype]
	}


	// liefert die Koordinaten eines Slots

	method get_slot_pos {slotidx} {
		return [get_slot_pos $slotidx]
	}


	// sucht Gegenstände, die gelagert werden sollten; anschließendes Abfragen der Liste mit get_storage_list
	// aktiviert das Lager, wenn etwas gefunden wurde, deaktiviert sonst

	method find_items_to_store {} {
		global storage_list
		set storage_list [find_items_to_store]
		if {$storage_list == 0} {
			set storage_list [list]
		}
//		log "lager.tcl : find_items_to_store: $storage_list"

		if {[llength $storage_list] == 0} {
			set_prod_enabled this 0
// 			log "LAGER DEAKTIVIERT!"
		} else {
			set_prod_enabled this 1
// 			log "LAGER AKTIVIERT!"
		}
	}


	// liefert den kompletten Lagerinhalt

	method get_slotlist {} {
		global slotlist
		return $slotlist
	}


	// liefert die Anzahl slots dieses Lagers

	method get_slots {} {
		global max_slots
		return $max_slots
	}


	// liefert die Größe eines Slots, d.h. die maximale Anzahl items, die hineinpassen

	method get_slot_size {} {
		global slot_size
		return $slot_size
	}


	// liefert Liste von Items, die der Zwerg bereits gesammelt hat

	method get_collected_items {} {
		global collected_items
		return $collected_items
	}


	// liefert Liste von Items, die der Zwerg bereits gesammelt hat

	method set_collected_items {value} {
		global collected_items
		set collected_items $value
	}


	// hängt einen Gegenstand an die Liste bereits gesammelter Gegenstände an

	method add_collected_item {item} {
		global collected_items
		lappend collected_items $item
	}


	// liefert die aktuelle Liste von Gegenständen, die zur Produktionsstätte gebracht werden sollen

	method get_storage_list {} {
		global storage_list
		return $storage_list
	}


	// setzt die aktuelle Liste von Gegenständen, die zur Produktionsstätte gebracht werden sollen

	method set_storage_list {wert} {
		global storage_list
		set storage_list $wert

		if {[llength $storage_list] == 0} {
			set_prod_enabled this 0
// 			log "LAGER DEAKTIVIERT!"
		} else {
			set_prod_enabled this 1
// 			log "LAGER AKTIVIERT!"
		}
	}


	// packtobox aus genericprod.tcl überschreiben mit einer spezialisieren Lagerroutine,
	// die alle Gegenstände rauswirft

    method prepare_packtobox {} {
		set_light this 0			;# abschalten eventuell vorhandener lichtquellen
		;# gib alle partikelquellen frei
		for {set index 0} {$index<16} {incr index} { free_particlesource this $index }


		// falls prepare_packtobox aufgerufen wurde, weil das Lager zerstört ist --> nicht ums Inventory kümmern
	
		if {[get_attrib this atr_Hitpoints] < 0.01} {
			return
		}

		// 2 Möglichkeiten, mit dem Abbau des Lagers umzugehen:

		// 1. Alle Gegenstände rauswerfen
//		foreach item [inv_list this] {
//			set newitempos [vector_add [get_pos $item] {0 0 1.5}]
//			inv_rem this $item
//			set_pos $item $newitempos			;// weil inv_rem die Position auch nochmal verändert
//			set_physic $item 1
//			set_instore $item 0
//		}
//		set slotlist  [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
//		set slottypes [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]


		// 2. alle Gegenstände behalten und unsichtbar machen
		foreach item [inv_list this] {
			set_pos $item {-100 -100 -100}
			set_visibility $item 0
			set itemtype [get_objtype $item]

			// falls eine PS aus dem Lager aufgebaut werden soll --> ab jetzt jedenfalls nicht mehr :-)
			if {$itemtype == "production"  ||  $itemtype == "energy"  ||  $itemtype == "store"  ||
			    $itemtype == "protection"  ||  $itemtype == "elevator" } {
				
				if {[get_prod_unpack $item]} {
					set_prod_unpack $item 0
					hide_obj_ghost $item
				}
			}
		}
    }


	// packtobox aus genericprod überschreiben, um das rauswerfen des Inventories zu verhindern

	method local_packtobox {} {}


    method init {} {
    	set_collision this 1

		// alle Items wieder einsortieren
		global slotlist max_slots slot_size slotx sloty

		validate_store_content

		for {set i 0} {$i < $max_slots} {incr i} {
			set pos [vector_add [get_pos this] "[expr {[lindex $slotx [expr {$i % 6}]] + [random -0.15 0.15]}] [lindex $sloty [expr {$i / 6}]] 0"]
			set slot [lindex $slotlist $i]
			if {$slot != 0} {
				for {set j 0} {$j < [llength $slot]} {incr j} {
				    set item [lindex $slot $j]
					set_pos $item $pos
					set_visibility $item 1
				}
			}
		}
    }

	class_defaultanim lager.standard
	class_flagoffset 3.8 3.9

	obj_init {
		set_anim this lager.standard 0 $ANIM_LOOP
		call scripts/misc/genericprod.tcl
		set_collision this 1
		set_prod_switchmode this 1

		set_prod_schedule this 1

		set build_dummys [list 12 13 14 15 16 17 18 19]
		set max_buildup_step [llength $build_dummys]
		set buidup_anis {unten_rechtsholz unten_linksholz unten_linksholz unten_rechtsholz oben_rechtsholz unten_rechtsholz oben_linksholz oben_rechtsholz}
		set damage_dummys {20 27}

		set store_food   	   0	  ;// Nahrung lagern
		set store_boxes 	   0      ;// Kisten lagern
		set store_mushrooms    0      ;// Pilzstämme und -hüte lagern
		set store_rawminerals  0      ;// Eisenerz Golzerz Kristallerz
		set store_minerals     0	  ;// Stein Eisen Gold Kristall Kohle
		set store_misc		   0	  ;// Waffen, Werkzeug & Tränke

		set_prod_slot_cnt this _Kisten_einlagern 		0
		set_prod_slot_cnt this _Nahrung_einlagern		0
		set_prod_slot_cnt this _Pilze_einlagern	 		0
		set_prod_slot_cnt this _Mineralien_einlagern 	0
		set_prod_slot_cnt this _Rohmineralien_einlagern 0


		set slot_dummys [list 30 6 8 9 4 10]				;// 6 Dummys, je einer am Boden vor der entspr. Spalte im Regal
		set max_slots 24									;// 4 Zeilen * 6 Spalten
		set slot_size 3										;// maximal Gegenstände pro Slot
		set store_range 200									;// Reichweite des Lagers

		set slotx {-2.67 -1.84 -0.9 0.98 1.81 2.73}			;// Liste der x bzw. y-Koordinaten der Slots
		set sloty {-0.4 -1.15 -1.9 -2.6}

		set slotlist  [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]	;// Liste von Listen von Items in den Slots
		set slottypes [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]    ;// Liste der Klassen der Slots

		set storage_list 0				;// Liste der Items die der Zwerg aufnehmen um zum Lager bringen soll
		set items_list     [list]		;// Liste von Items und Pos, die in der Umgebung der Produktionsstelle gefunden wurden
		set old_items_list [list]		;// Liste von items und Pos, die bei der letzen Umgebungsuche schon dalagen
		set storable_items_list [list]	;// Liste von Items, die tatsächlich gelagert werden können (= sind alt und passen ins Lager)
		set collected_items [list]		;// Liste der Items die gesammelt wurden

		// alle 60 sek. ein Timer, der Nach Gegenständen sucht und mit denen Vergleicht, die vor 2 Min. da waren
		timer_event this evt_timer_search -repeat -1 -interval 120 -userid 0
		timer_event this evt_takeitems -repeat 0 -attime [expr {[gettime]+5}]


		// liefert die Nummer des Slots, in dem ein Items des übergebenen Typs gelagert werden kann
		// es wird ein Slot gesucht, in dem bereits Items dieses Typs liegen und der noch Platz hat
		// bzw. wird alternativ ein freier Slot gesucht - je nachdem, was zuerst gefunden wird (Suche von unten nach oben)
		// falls auch kein freier Slots existiert, wird -1 geliefert

		proc find_slot_for_storing {itemtype} {
			global max_slots
			for {set i 0} {$i < $max_slots} {incr i} {
				if {[get_slot_itemtype $i] == $itemtype} {
					if {[is_slot_full $i] == 0} {
						return $i
					}
				}
				if {[get_slot_itemtype $i] == 0} {
					return $i
				}
			}
			return -1
		}


		// liefert die Nummer eines Slots, aus dem ein Item des übergebenen Typs entnommen werden kann
		// falls keine freien Slots existieren wird -1 geliefert

		proc find_slot_for_retrieving {itemtype} {
			global max_slots
			for {set i 0} {$i < $max_slots} {incr i} {
				if {[get_slot_itemtype $i] == $itemtype} {
					return $i
				}
			}
			return -1
		}


		// liefert zurück, welchen Typ von Gegenständen (Klassenname) der Slot speichert
		// liefert 0, falls der Slot nicht genutzt wird

		proc get_slot_itemtype {slotidx} {
			global slottypes

			return [lindex $slottypes $slotidx]
		}


		// liefert zurück, wieviele Items momentan im Slot sind
		// ACHTUNG: um zu überprüfen, ob ein Slot voll ist sollte immer is_slot_full benutzt werden!!!

		proc get_slot_itemcount {slotidx} {
			global slotlist
			set slot [lindex $slotlist $slotidx]
			if {$slot == 0} {
				return 0
			} else {
				return [llength $slot]
			}
		}


		// liefert true, wenn im Slot kein Platz mehr ist

		proc is_slot_full {slotidx} {
			global slot_size slotlist
			set i [get_slot_itemcount $slotidx]
			if {$i >= $slot_size} {												// >= max items drin --> ist voll
				return 1
			} elseif {$i == 0} {												// 0 items drin --> ist leer
				return 0
			} elseif {[get_boxed [lindex [lindex $slotlist $slotidx] 0]]} {		// eine Kiste drin --> ist voll
				return 1
			} else {
				return 0
			}
		}


		// liefert die Koordinaten eines Slots

		proc get_slot_pos {slotidx} {
			global slotx sloty
			return "[lindex $slotx [expr {$slotidx % 6}]] [lindex $sloty [expr {$slotidx / 6}]] 0"
		}


		// liefert den Dummy, der sich vor der entsprechenden Spalte des Regals befindet

		proc get_slot_dummy {slotidx} {
			global slot_dummys
			return [lindex $slot_dummys [expr {$slotidx%6}]]
		}


		// findet den Slot, in dem ein (konkretes) Item liegt
		// liefert -1, falls das Item nicht im Lager ist

		proc find_slot_of_item {item} {
			global slotlist max_slots slot_size
			set slotidx -1
			for {set i 0} {$i < $max_slots} {incr i} {
				set slot [lindex $slotlist $i]
				for {set j 0} {$j < [llength $slot]} {incr j} {
					if {[lindex $slot $j] == $item} {
						set slotidx $i
						break;
					}
				}
			}
//			log "lager.tcl : find_slot_of_item : item $item befindet sich im slot $slotidx"
			return $slotidx
		}


		// liefert die Animation, die der Zwerg beim ein- oder auslagern in diesen Slot abspielen muss

		proc get_slot_anim {slotidx} {
			set i [expr {int ($slotidx / 6)}]
			if {$i == 0} {return put}
			if {$i == 1} {return putjump}
			if {$i == 2} {return putjumphigh}
			if {$i == 3} {return putjumphighest}
		}


		// liefert 1 falls das item hier gelagert werden kann (d.h. es wäre ein Platz da)
		// es kann zusätzlich noch eine Liste von Items angegeben werden, die noch vorher gelagert werden müssen
		// in diesem Fall liefert die proc nur dann 1, wenn sich die gesamte itemlist UND das item lagern ließen
		//
		// diese proc wird benötigt, wenn der Zwerg mehrere items sammeln und ins Lager bringen will; bevor er ein item
		// aufnimmt, sollte überprüft werden, ob dieses item noch Platz hat, wenn er alle schon vorher gesammelten unterbringt


	    proc is_storable {newitem {itemlist ""}} {
			// zuerst die gesamte (konkrete) itemliste und das einzelne item in eine Liste von Typen umwandeln

			set itemtypelist [list]
			lappend itemlist $newitem
//			log "lager.tcl : is_storable : itemlist - $itemlist"

			foreach item $itemlist {
				if {[get_boxed $item] == 1} {
					lappend itemtypelist "Box"
				} else {
					lappend itemtypelist [get_objclass $item]
				}
			}
//			log "lager.tcl : is_storable : itemtypelist - $itemtypelist"
			return [is_storable_itemtypelist $itemtypelist]
		}


		// liefert 1, wenn die Liste von Klassen (z.B. {Pilzstamm Pilzstamm Box Stein}) sich komplett einlagern ließe

		proc is_storable_itemtypelist {itemtypelist} {
			global max_slots slot_size slotlist

			// systematisch slots durchgehen und dabei itemtypelist stückweise einlagern
			// am Ende muß sie leer sein, sonst passt sie nicht ins Lager

//			log "lager.tcl : is_storable_itemtypelist - $itemtypelist"
//			log "lager.tcl : is_storable_itemtypelist slots: $slotlist"
			for {set i 0} {$i < $max_slots} {incr i} {

				if {[llength $itemtypelist] == 0} { break }				;// keine items mehr zu verteilen --> fertig

				if {[is_slot_full $i] == 1} { continue }				;// slot ist voll --> nächster Slot

				if {[get_slot_itemcount $i] == 0} {						;// slot ist leer --> versuche, Kiste einzulagern
					set idx [lsearch $itemtypelist "Box"]
					if {$idx != -1} {									;// Kiste gefunden --> nächster slot
						lrem itemtypelist $idx
//						log "lager.tcl : is_storable_itemtypelist : Box in slot $i"
						continue
					}
				}

				set j [expr {$slot_size - [get_slot_itemcount $i]}]		;// bleiben normale items
				if {$j == $slot_size} {
					set itemtype [lindex $itemtypelist 0]				;// leerer slot: erstbesten itemtype auffüllen
				} else {
					set itemtype [get_slot_itemtype $i]					;// angefangener slot: mit gleichem typ auffüllen
				}
				while {$j > 0}  {
					set idx [lsearch $itemtypelist $itemtype]
					if {$idx == -1} { break }						;// keine items mehr für diesen slot --> nächster slot
					lrem itemtypelist $idx
//					log "lager.tcl : is_storable_itemtypelist : $itemtype in slot $i"
					set j [expr {$j - 1}]
				}
			}

//			log "lager.tcl : is_storable_itemtypelist : finished, remaining itemtypelist: $itemtypelist"
			if {[llength $itemtypelist] == 0} {
				return 1
			} else {
				return 0
			}
    	}


		// liefert Klassennamen zum Einlagern

		proc get_classes_to_store {} {
			global store_food store_boxes store_mushrooms store_rawminerals store_minerals store_misc

			set classes [list]
			if {$store_food} {
				lappend classes Grillpilz Grillhamster Pilzbrot Raupensuppe Raupenschleimkuchen Gourmetsuppe Hamstershake Bier
			}
			if {$store_mushrooms} {
				lappend classes Pilzstamm Pilzhut
			}
			if {$store_rawminerals} {
				lappend classes Eisenerz Golderz Kristallerz
			}
			if {$store_minerals} {
				lappend classes Eisen Gold Kristall Stein Kohle
			}

			if {$store_misc} {
				lappend classes Steinschleuder Schwert Kleiner_Heiltrank Heiltrank Grosser_Heiltrank
			}

			return $classes
		}


		// liefert eine Liste von Items, die das Lager gern haben möchte :-)

		proc find_items_to_store {} {
			global storable_items_list store_boxes store_range
			set close_items [list]

			// zuerst werden items in der Umgebung des Lagers gesucht, die auf die aktuellen Lagereinstellungen passen

			// Kisten suchen
			if {$store_boxes} {
	    		set boxes [obj_query this "-flagpos boxed -flagneg {contained locked} -owner [get_owner this] -range $store_range -visibility playervisible -alloc -1"]
				if {$boxes != 0} {
//					log "found boxes to store: $boxes"
					set close_items $boxes
				}
			}

			set classes [get_classes_to_store]

//			log "looking for classes: $classes"
			if {[llength $classes] > 0} {
				// andere items suchen
				set otheritems [obj_query this "-flagpos storable -flagneg {contained locked instore} -range $store_range -class \{$classes\} -visibility playervisible -owner \{[get_owner this] -1\} -alloc -1"]
		    	if {$otheritems != 0} {
		    		set close_items [concat $close_items $otheritems]
		    	}
		    }

//	    	return $close_items

			// nur items lagern, die zur Lagerung freigegeben worden sind
			return [land $close_items $storable_items_list]
		}


		// packt das übergebene Item ins Lagerregal und trägt es in die Lagerliste ein

		proc store_item {slotidx item} {
			global slotlist slottypes slotx sloty

			if { $slotidx == -1 } {
				// kein Slot gefunden - Gegenstand wird wieder freigegeben
				log "WARNING: lager.tcl : store_item :  no slot found for this item - dropping!"
				set_pos $item [vector_add [get_pos this] {3 0 2}]
				return
			}
//			log "lager.tcl : store_item : Storing $item in slot $slot"
			inv_add this $item
			set_visibility $item 1
//			log "lager.tcl : store_item : slot $slot, pos $xp $yp"
			set_pos $item [vector_add [get_pos this] "[expr {[lindex $slotx [expr {$slotidx % 6}]] + [random -0.15 0.15]}] [lindex $sloty [expr {$slotidx / 6}]] 0"]
			if {![get_boxed $item]} {
				set_roty $item [random 3.141]
			} else {
				set_roty $item 0
			}
			set_physic $item 0
			set_instore $item 1

			set slot [lindex $slotlist $slotidx]
			if {$slot == 0} {
				set slot $item
				set slottypes [lreplace $slottypes $slotidx $slotidx [get_objclass $item]]
//				log "slottypes: $slottypes"
			} else {
				if {[lsearch $slot $item] == -1} {
					lappend slot $item
				}
			}
//			log "lager.tcl: store_item: new slot is $slot"

			set slotlist [lreplace $slotlist $slotidx $slotidx $slot]
//			log "lager.tcl: store_item: new slotlist $slotlist"


			set slot [lindex $slotlist $slotidx]
			if {$slot == 0} {
				return 0
			} else {
				return [get_objclass [lindex $slot 0]]
			}

		}


		// holt das item aus dem Lager heraus

		proc retrieve_item {slotidx item} {
			global slotlist slottypes
			set slot [lindex $slotlist $slotidx]
			set itemidx [lsearch $slot $item]

			if {$itemidx == -1} {
				log "ERROR: lager.tcl : retrieve_item : item $item not found in slot $slotidx"
				return 0
			}

			lrem slot $itemidx
			if {[llength $slot] == 0} {
				set slot 0
			}
			set slotlist [lreplace $slotlist $slotidx $slotidx $slot]
			if {$slot == 0} {
				set slottypes [lreplace $slottypes $slotidx $slotidx 0]
//				log "slottypes: $slottypes"
			}

			set_physic $item 1
			set_instore $item 0
			inv_rem this $item
			log "item $item [get_objname $item] retrieved from lager"
			return 1
		}



	// testet alle im Lager befindlichen Items auf vorhandensein
	// reine Defensivmassnahme, eigentlich sollte sowas nie passierten

	proc validate_store_content {} {
		global slotlist slottypes

		set slotidx 0
		foreach slot $slotlist {
			foreach item $slot {
				if {[obj_valid $item]} {
					continue			;// alles okay
				}

				log "WARNING : store.tcl : validate_objects : $item listet as in store, but does not exist any more!"

				set itemidx [lsearch $slot $item]
				lrem slot $itemidx
				if {[llength $slot] == 0} {
					set slot 0
				}
				set slotlist [lreplace $slotlist $slotidx $slotidx $slot]

				if {$slot == 0} {
					set slottypes [lreplace $slottypes $slotidx $slotidx 0]
				}
			}
			incr slotidx
		}
	}

	}
}

