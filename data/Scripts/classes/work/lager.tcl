def_class _Nahrung_einlagern       service material 1 {} {}
def_class _Kisten_einlagern        service material 1 {} {}
def_class _Pilze_einlagern         service material 1 {} {}
def_class _Rohmineralien_einlagern service material 1 {} {}
def_class _Mineralien_einlagern    service material 1 {} {}

def_class Lager wood production 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/misc/genericprod.tcl

	def_event evt_takeitems
	handle_event evt_takeitems {
		set itemlist [lnand 0 [obj_query this -type material -boundingbox {-1 -1 -1 1 1 1}]]
		foreach item $itemlist {
			set idx [find_slot_for_storing [get_objclass $item]]
			if { $idx != -1 } {
				store_item $idx $item
			}
		}
	}

	def_event evt_btn_on
    handle_event evt_btn_on {
		global store_food store_boxes store_mushrooms store_minerals store_rawminerals current_worker current_itemtype

		if { $current_itemtype != 0 && $current_worker != 0 } {
			if { ![obj_valid $current_worker] } {
				set current_worker 0
				return
			}
			if { [get_prod_pack this] == 1 } {
				set_event $current_worker evt_zwerg_break -target $current_worker
				set_prod_pack this 1
			}
		}

		set store_food [expr {[get_prod_slot_cnt this _Nahrung_einlagern] > 0}]
		set store_boxes [expr {[get_prod_slot_cnt this _Kisten_einlagern] > 0}]
		set store_mushrooms [expr {[get_prod_slot_cnt this _Pilze_einlagern] > 0}]
		set store_rawminerals [expr {[get_prod_slot_cnt this _Rohmineralien_einlagern] > 0}]
		set store_minerals [expr {[get_prod_slot_cnt this _Mineralien_einlagern] > 0}]

		# Update store state
		call_method this find_items_to_store
	}

	# Look for nearby items, enable production if any item is found
    def_event evt_timer_search
    handle_event evt_timer_search {
		global items_list old_items_list storable_items_list

		validate_store_content

		set old_items_list $items_list			;// items der letzen Suche sind jetzt alte Items und k�nnen gelagert werden
		set items_list [list]

		# First, look for boxes
   		set boxes [query_boxes]
		if { $boxes != 0 } {
			foreach item $boxes {
				set pos [get_pos $item]
				if { ![isunderwater $pos] } {
					lappend items_list "$item $pos"
				}
			}
		}

		# Look for items by class
		set items [query_items]
    	if { $items != 0 } {
    		foreach item $items {
    			set pos [get_pos $item]
    			if { ![isunderwater $pos] } {
	    			lappend items_list "$item $pos"
    			}
    		}
    	}

    	// Liste von items erstellen, die in der eben erfolgten und der letzen Umgebungssuche vorhanden waren
    	// und tats�chlich ins Lager passen w�rden
    	set storable_items_list [list]
    	foreach item [land $old_items_list $items_list] {
			set itemref [lindex $item 0]
    		if {[is_storable_itemtypelist [get_objclass $itemref]]} {
				lappend storable_items_list $itemref
    		} else {
//    			log "item $itemref ist alt, aber kein Platz zum Lagern"
    		}
    	}

		// find_items_to_store liefert jetzt eine Liste von items, die tats�chlich gelagert werden sollen
		// unter Ber�cksichtigung der Buttons am Lager und der eben erstellten Liste von lagerbaren items
		// nur wenn diese Liste etwas enth�lt, wird das Lager eingeschaltet

    	if {[llength $storable_items_list] > 0} {
    		set l [find_items_to_store]
			if {[llength $l] > 0} {
 	   			set_prod_enabled this 1
    			return
	    	}
		}

		// ansonsten lager abschalten und auf den n�chsten Timer warten :-)
		set_prod_enabled this 0
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


	// liefert 1, wenn alle schon gesammelten items und das angegebenen Platz im Lager finden w�rden

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


	// liefert die Animation, die beim Ablegen/Aufnehmen f�r diesen Slot gespielt werden muss

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

	#
	method find_items_to_store {} {
		global storage_list

		set storage_list [find_items_to_store]

		if {$storage_list == 0} {
			set storage_list [list]
		}

		if { [llength $storage_list] == 0 } {
			set_prod_enabled this 0
		} else {
			set_prod_enabled this 1
		}
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


	// h�ngt einen Gegenstand an die Liste bereits gesammelter Gegenst�nde an

	method add_collected_item {item} {
		global collected_items
		lappend collected_items $item
	}


	// liefert die aktuelle Liste von Gegenst�nden, die zur Produktionsst�tte gebracht werden sollen

	method get_storage_list {} {
		global storage_list
		return $storage_list
	}


	// setzt die aktuelle Liste von Gegenst�nden, die zur Produktionsst�tte gebracht werden sollen

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

	method get_storable_classes {} {
		return [get_storable_classes]
	}

	method drop_all_items {} {
		foreach item [inv_list this] {
			set npos [vector_add [get_pos $item] {0 0 5}]
			inv_rem this $item
			set_pos $item $npos
			set_physic $item 1
			set_instore $item 0
		}

		set slotlist [list]
		set slottypes [list]
	}

	// packtobox aus genericprod.tcl �berschreiben mit einer spezialisieren Lagerroutine,
	// die alle Gegenst�nde rauswirft

    method prepare_packtobox {} {
		set_light this 0
		for { set i 0 } { $i < 16 } { incr i } {
			free_particlesource this $i
		}

		if { [get_attrib this atr_Hitpoints] < 0.01 } { return }

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

	method local_packtobox {} {}

    method init {} {
		global slotlist
		ensure_slotlist_valid

		validate_store_content

    	set_collision this 1

		for { set i 0 } { $i < [get_slot_count] } { incr i } {
			set pos [get_slot_pos $i]
			set slot [lindex $slotlist $i]
			if { $slot != 0 } {
				for { set j 0 } { $j < [llength $slot] } { incr j } {
				    set item [lindex $slot $j]
					set_pos $item $pos
					set_visibility $item 1
				}
			}
		}
    }

	class_defaultanim lager.standard
	class_fightdist 2.0
	class_flagoffset 3.8 3.9

	obj_init {
		call scripts/misc/genericprod.tcl

		set_anim this lager.standard 0 $ANIM_LOOP
		set_collision this 1
		set_prod_switchmode this 1

		set_prod_schedule this 1

		set store_food        0
		set store_boxes       0
		set store_mushrooms   0
		set store_rawminerals 0
		set store_minerals    0

		set_prod_slot_cnt this _Kisten_einlagern        0
		set_prod_slot_cnt this _Nahrung_einlagern       0
		set_prod_slot_cnt this _Pilze_einlagern         0
		set_prod_slot_cnt this _Mineralien_einlagern    0
		set_prod_slot_cnt this _Rohmineralien_einlagern 0

		set slotlist [list]
		set slottypes [list]

		set storage_list 0				;// Liste der Items die der Zwerg aufnehmen um zum Lager bringen soll
		set items_list [list]		    ;// Liste von Items und Pos, die in der Umgebung der Produktionsstelle gefunden wurden
		set old_items_list [list]		;// Liste von items und Pos, die bei der letzen Umgebungsuche schon dalagen
		set storable_items_list [list]	;// Liste von Items, die tats�chlich gelagert werden k�nnen (= sind alt und passen ins Lager)
		set collected_items [list]		;// Liste der Items die gesammelt wurden

		timer_event this evt_timer_search -repeat -1 -interval 60 -userid 0
		timer_event this evt_takeitems -repeat 0 -attime [expr {[gettime] + 5}]

		# Override!
		proc get_build_dummies {} {
			return {12 13 14 15 16 17 18 19}
		}

		# Override!
		proc get_buildup_anis {} {
			return {unten_rechtsholz unten_linksholz unten_linksholz unten_rechtsholz oben_rechtsholz unten_rechtsholz oben_linksholz oben_rechtsholz}
		}

		# Override!
		proc get_damage_dummies {} {
			return {20 27}
		}

		# Override!
		proc get_object_groups {} {
			return {storage}
		}

		#
		proc get_slot_count {} {
			# 4 rows (+1 modded), 6 columns
			return 30
		}

		#
		proc get_slot_capacity {} {
			return 3
		}

		#
		proc get_slot_xshift {idx} {
			# 6 columns
			set shifts {-2.67 -1.84 -0.9 0.98 1.81 2.73}
			return [lindex $shifts [expr {$idx % 6}]]
		}

		#
		proc get_slot_yshift {idx} {
			# 4 rows (+1 modded)
			set shifts {-0.4 -1.15 -1.9 -2.6 -3.3}
			return [lindex $shifts [expr {$idx / 6}]]
		}

		#
		proc get_slot_pos {idx} {
			set x [expr [get_slot_xshift $idx] + [random -0.15 0.15]]
			set y [get_slot_yshift $idx]
			set z 0
			return [vector_add [get_pos this] "$x $y $z"]
		}

		#
		proc get_slot_dummy {idx} {
			return [lindex {30 6 8 9 4 10} [expr {$idx % 6}]]
		}

		#
		proc find_slot_for_storing {itemtype} {
			for { set idx 0 } { $idx < [get_slot_count] } { incr idx } {
				if { [get_slot_itemtype $idx] == $itemtype } {
					if { [is_slot_full $idx] == 0 } {
						return $idx
					}
				}
				if { [get_slot_itemtype $idx] == 0 } {
					return $idx
				}
			}

			return -1
		}

		#
		proc find_slot_for_retrieving {itemtype} {
			for { set idx 0 } { $idx < [get_slot_count] } { incr idx } {
				if { [get_slot_itemtype $idx] == $itemtype } {
					return $idx
				}
			}

			return -1
		}

		#
		proc get_slot_itemtype {idx} {
			global slottypes
			ensure_slottypes_valid

			return [lindex $slottypes $idx]
		}

		#
		proc get_slot_itemcount {idx} {
			global slotlist
			ensure_slotlist_valid

			set slot [lindex $slotlist $idx]

			if { $slot == 0 } {
				return 0
			} else {
				return [llength $slot]
			}
		}

		# Return 1 if given slot is empty
		proc is_slot_empty {idx} {
			return [expr [get_slot_itemcount $idx] == 0]
		}

		# Return 1 if given slot is full
		proc is_slot_full {idx} {
			global slotlist
			ensure_slotlist_valid

			if { [get_slot_itemcount $idx] < [get_slot_capacity] } {
				if { [get_boxed [lindex [lindex $slotlist $idx] 0]] } {
					return 1
				}
				return 0
			}

			return 1
		}

		#
		proc find_slot_of_item {item} {
			global slotlist
			ensure_slotlist_valid

			for { set idx 0 } { $idx < [get_slot_count] } { incr idx } {
				set slot [lindex $slotlist $idx]
				foreach stored_item $slot {
					if { $stored_item == $item } {
						return $idx
					}
				}
			}
		}

		#
		proc get_slot_anim {idx} {
			set row [expr {int($idx / 6)}]
			switch $row {
				0 { return "put" }
				1 { return "putjump" }
				2 { return "putjumphigh" }
				default { return "putjumphighest" }
			}
		}

		#
	    proc is_storable {newitem {itemlist ""}} {
			set itemtypelist [list $newitem]

			foreach item $itemlist {
				if { [get_boxed $item] == 1 } {
					lappend itemtypelist "Box"
				} else {
					lappend itemtypelist [get_objclass $item]
				}
			}

			return [is_storable_itemtypelist $itemtypelist]
		}

		#
		proc is_storable_itemtypelist {itemtypelist} {
			for { set i 0 } { $i < [get_slot_count] } { incr i } {
				# No more items to distribute, break
				if { [llength $itemtypelist] == 0 } { break }

				# Current slot is full, continue
				if { [is_slot_full $i] } { continue }

				# Slot is empty, try to store box
				if { [is_slot_empty $i] } {
					set idx [lsearch $itemtypelist "Box"]
					if { $idx != -1 } {
						lrem itemtypelist $idx
						continue
					}
				}

				# Handle remaining items
				set j [expr {[get_slot_capacity] - [get_slot_itemcount $i]}]
				if {$j == [get_slot_capacity]} {
					set itemtype [lindex $itemtypelist 0]
				} else {
					set itemtype [get_slot_itemtype $i]
				}
				while {$j > 0}  {
					set idx [lsearch $itemtypelist $itemtype]
					if {$idx == -1} { break }
					lrem itemtypelist $idx
					incr j -1
				}
			}

			return [expr {[llength $itemtypelist] == 0}]
    	}

		#
		proc get_storable_classes {} {
			set classes [list]

			# Food
			lappend classes Grillpilz Grillhamster Pilzbrot Raupensuppe Raupenschleimkuchen Gourmetsuppe Hamstershake Bier
			# Mushroom parts
			lappend classes Pilzstamm Pilzhut
			# Ores
			lappend classes Eisenerz Golderz Kristallerz
			# Minerals
			lappend classes Eisen Gold Kristall Stein Kohle
			# Tools
			lappend classes Kettensaege Presslufthammer Kristallstrahl
			# Means of transport
			lappend classes Reithamster Hoverboard
			# Transport containers
			lappend classes Holzkiepe Grosse_Holzkiepe Schubkarren
			# Potions
			lappend classes Kleiner_Heiltrank Heiltrank Grosser_Heiltrank

			return $classes
		}

		#
		proc get_classes_to_store {} {
			global store_food store_mushrooms store_rawminerals store_minerals

			set classes [list]

			# Food
			if { $store_food } {
				lappend classes Grillpilz Grillhamster Pilzbrot Raupensuppe Raupenschleimkuchen Gourmetsuppe Hamstershake Bier
			}
			# Mushroom parts
			if { $store_mushrooms } {
				lappend classes Pilzstamm Pilzhut
			}
			# Ores
			if { $store_rawminerals } {
				lappend classes Eisenerz Golderz Kristallerz
			}
			# Minerals
			if { $store_minerals } {
				lappend classes Eisen Gold Kristall Stein Kohle
			}

			return $classes
		}

		#
		proc query_boxes {} {
			return [obj_query this -flagpos boxed -flagneg {contained locked instore} -owner [get_owner this] -range 200 -visibility playervisible -alloc -1]
		}

		#
		proc query_items {} {
			set classes [get_classes_to_store]
			if { [llength $classes] == 0 } { return 0 }
			return [obj_query this -class $classes -flagpos storable -flagneg {contained locked instore} -owner {[get_owner this] -1} -range 200 -visibility playervisible -alloc -1]
		}

		#
		proc find_items_to_store {} {
			global storable_items_list store_boxes

			set close_items [list]

			# First, look for boxes
			if { $store_boxes } {
	    		set boxes [query_boxes]
				if { $boxes != 0 } {
					set close_items $boxes
				}
			}

			# Look for items by class
			set items [query_items]
			if { $items != 0 } {
				set close_items [concat $close_items $items]
			}

			return [land $close_items $storable_items_list]
		}

		#
		proc store_item {slotidx item} {
			global slotlist slottypes
			ensure_slotlist_valid
			ensure_slottypes_valid

			if { $slotidx == -1 } {
				set_pos $item [vector_add [get_pos this] {3 0 2}]
				return
			}

			inv_add this $item
			set_visibility $item 1
			set_pos $item [get_slot_pos $slotidx]

			if { ![get_boxed $item] } {
				set_roty $item [random 3.141]
			} else {
				set_roty $item 0
			}

			set_physic $item 0
			set_instore $item 1

			set slot [lindex $slotlist $slotidx]
			if { $slot == 0 } {
				set slot $item
				set slottypes [lreplace $slottypes $slotidx $slotidx [get_objclass $item]]
			} else {
				if { [lsearch $slot $item] == -1 } {
					lappend slot $item
				}
			}

			set slotlist [lreplace $slotlist $slotidx $slotidx $slot]

			set slot [lindex $slotlist $slotidx]
			if { $slot == 0 } {
				return 0
			} else {
				return [get_objclass [lindex $slot 0]]
			}
		}

		#
		proc retrieve_item {slotidx item} {
			global slotlist slottypes
			ensure_slotlist_valid
			ensure_slottypes_valid

			set slot [lindex $slotlist $slotidx]
			set itemidx [lsearch $slot $item]
			if { $itemidx == -1 } {
				return 0
			}

			lrem slot $itemidx
			if { [llength $slot] == 0 } {
				set slot 0
			}

			set slotlist [lreplace $slotlist $slotidx $slotidx $slot]
			if { $slot == 0 } {
				set slottypes [lreplace $slottypes $slotidx $slotidx 0]
			}

			set_physic $item 1
			set_instore $item 0
			inv_rem this $item

			return 1
		}

		# Sanity check whether every stored item is actually valid
		proc validate_store_content {} {
			global slotlist slottypes
			ensure_slotlist_valid
			ensure_slottypes_valid

			set slotidx 0
			foreach slot $slotlist {
				foreach item $slot {
					if { [obj_valid $item] } {
						# Everything is okay
						continue
					}

					log ERROR "[get_objname $item] ($item) listed in [get_objname this] but it does not exist anymore"

					# Remove item from the slot (its copy) and then replace old slot with the new one
					set itemidx [lsearch $slot $item]
					lrem slot $itemidx
					if { [llength $slot] == 0 } {
						set slot 0
						set slottypes [lreplace $slottypes $slotidx $slotidx 0]
					}
					set slotlist [lreplace $slotlist $slotidx $slotidx $slot]
				}
				incr slotidx
			}
		}

		# Expand slotlist to make sure it has enough entries (assures backwards compatiblity with vanilla)
		proc ensure_slotlist_valid {} {
			global slotlist
			set diff [expr {[get_slot_count] - [llength $slotlist]}]
			if { $diff > 0 } {
				for { set i 0 } { $i < $diff } { incr i } {
    				lappend slotlist 0
				}
			}
		}

		# Expand slottypes to make sure it has enough entries (assures backwards compatiblity with vanilla)
		proc ensure_slottypes_valid {} {
			global slottypes
			set diff [expr {[get_slot_count] - [llength $slottypes]}]
			if { $diff > 0 } {
				for { set i 0 } { $i < $diff } { incr i } {
    				lappend slottypes 0
				}
			}
		}
	}
}
