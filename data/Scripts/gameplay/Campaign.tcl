// ######################### Campaign load ##########################
map create 512 640
sm_draw_stone -border
sm_draw_stone -funnel

generate_color_variation 0 0 512 640 0
#set_fow_begin 133
set_light_begin 33
set_view_begin 23
set_view 246.7 28.8 1.478 -0.29 0.05		;# set inital camera view (x y zoom)

set temppos {208 0};call templates/tcl/urw_unq_start.tcl
set temppos {30 23};call templates/tcl/urw_unq_hoehlenmalerei.tcl
//MapTemplateSet 40 30
map_setlayer2 30 23 data/templates/urw_unq_hoehlenmalerei.l2m

//adaptive_sound marker start {294 30 10}
//adaptive_sound marker cave {294 45 10}

sm_set_temp {{urw_unq_start 208 0} {urw_unq_hoehlenmalerei 30 23}}

proc first_level {startx starty} {

	# Templates fuer Hoehlen
	set cavelist {}
	lappend cavelist {urw_hol_001_a 20 4}
	lappend cavelist {urw_hol_014_b 20 12}
	lappend cavelist {urw_hol_018_c 28 16}
	lappend cavelist {urw_hol_019_b 24 16}
	lappend cavelist {urw_hol_027_a 16 4}
	# Kombinationen von Hoehlen
	set comblist {}
	lappend comblist {0 1 {0}}
	lappend comblist {0 2 {0}}
	lappend comblist {0 4 {0}}
	lappend comblist {1 0 {4}}
	lappend comblist {1 3 {4}}
	#lappend comblist {2 0 {8}}
	#lappend comblist {2 3 {8}}
	#lappend comblist {2 4 {8}}
	#lappend comblist {3 1 {8}}
	#lappend comblist {3 2 {8}}
	#lappend comblist {3 4 {8}}
	lappend comblist {4 0 {0}}
	lappend comblist {4 2 {0}}
	lappend comblist {4 3 {0}}
	set comblen 8
	# Templates fuer Verbindung
	set tunnlist {}
	lappend tunnlist {urw_gng_013_ 4 0}
	lappend tunnlist {urw_gng_002_ 8 0}
	lappend tunnlist {urw_gng_003_ 12 0}
	# Kombinationen fuer Verbindung
	set conlist {}
	lappend conlist {0 0 1 2}
	lappend conlist {0 0 2 1}
	lappend conlist {0 1 0 2}
	lappend conlist {4 2 0 1}
	lappend conlist {4 2 1 0}
	lappend conlist {4 1 2 0}
	set conlen 6
	# Templates fuer Voodooanschluss
	set vodolist {}
	lappend vodolist {urw_gng_001_ ab }	;#  0
	lappend vodolist {urw_gng_007_ abcd }	;#  1
	lappend vodolist {urw_gng_008_ abc }	;#  2
	lappend vodolist {urw_gng_009_ abcd }	;#  3
	lappend vodolist {urw_gng_012_ abcd }	;#  4
	lappend vodolist {urw_gng_019_ abc }	;#  5
	lappend vodolist {urw_gng_022_ abdeg}	;#  6
	lappend vodolist {urw_gng_023_ abc}		;#  7
	lappend vodolist {urw_gng_026_ abc}		;#  8
	lappend vodolist {urw_gng_028_ bcd}		;#  9
	lappend vodolist {urw_gng_030_ a}		;# 10
	lappend vodolist {urw_gng_032_ ab}		;# 11
	lappend vodolist {urw_gng_034_ acdfhk}	;# 12
	lappend vodolist {urw_gng_039_ ab}		;# 13
	lappend vodolist {urw_gng_042_ ab}		;# 14
	lappend vodolist {urw_gng_045_ ab}		;# 15
	lappend vodolist {urw_unq_vodo_001_ a}	;# 16
	lappend vodolist {urw_gng_004_ ab}		;# 17
	lappend vodolist {urw_gng_027_ abc}		;# 18
	lappend vodolist {urw_gng_036_ ab}		;# 19
	lappend vodolist {urw_gng_043_ ab}		;# 20
	lappend vodolist {urw_gng_044_ ab}		;# 21
	# Kombinationen fuer Voodoos links und rechtsrum
	set voconlist1 {}
	lappend voconlist1 {{3 20 0} {8 8 12} {5 20 12} {6 24 12} {16 -24 12}}
	lappend voconlist1 {{1 20 0} {13 4 16} {7 4 28} {9 12 4} {16 -28 12}}
	lappend voconlist1 {{2 20 0} {5 20 8} {6 24 8} {15 8 8} {12 4 16} {6 16 24} {16 -28 12}}
	lappend voconlist1 {{2 20 0} {14 12 8} {4 8 12} {13 0 16} {7 0 28} {16 -32 12}}
	#lappend voconlist1 {{1 20 0} {9 12 4} {0 4 20} {12 8 16} {6 20 24} {16 -28 12}}
	#lappend voconlist1 {{1 20 0} {9 12 4} {11 4 16} {7 12 28} {16 -28 12}}
	lappend voconlist1 {{2 20 0} {11 0 16} {15 8 8} {5 20 8} {6 24 8} {7 8 28} {16 -32 12}}
	lappend voconlist1 {{1 20 0} {6 16 20} {4 8 8} {14 12 4} {10 4 12} {16 -28 12}}
	#lappend voconlist1 {{9 12 0} {6 20 20} {10 8 12} {0 4 20} {16 -28 12}}
	set voconlist2 {}
	lappend voconlist2 {{18 20 0} {0 20 20} {10 24 12} {6 36 20} {16 -12 12}}
	lappend voconlist2 {{20 20 0} {21 32 4} {17 20 20} {10 36 12} {6 48 20} {16 -12 12}}
	lappend voconlist2 {{19 20 0} {1 24 12} {14 16 16} {6 32 8} {16 -16 12}}
	set present_side [irandom 2]
	set left_letters [lindex {abdef cgih} $present_side]
	set right_letters [lindex {cfkh abdeg} $present_side]
	set std_x [expr {$startx+36}]
	set std_y [expr {$starty+40}]

	# Auswahlen treffen
	set temp_list {}
	set comb [lindex $comblist [irandom $comblen]]
	set ylist [lindex $comb 2]
	incr std_y [lindex $ylist [irandom [llength $ylist]]]
	set conn_idx [irandom $conlen]
	set conn [lindex $conlist $conn_idx]
	incr std_x [lrem conn 0]
	if {$conn_idx<2} {
		set voconlist $voconlist2
		set voconlen 3
	} elseif {$conn_idx<4} {
		set voconlist [concat $voconlist1 $voconlist2]
		set voconlen 9
	} else {
		set voconlist $voconlist1
		set voconlen 6
	}
	set vodo [lindex $voconlist [irandom $voconlen]]

	# linkes Template plus Ende
	set tempvals [lindex $cavelist [lindex $comb 0]]
	set tempname [lindex $tempvals 0]
	set xoffset [lindex $tempvals 1]
	set yoffset [lindex $tempvals 2]
	lappend temp_list [list $tempname [expr {$std_x-$xoffset}] [expr {$std_y-$yoffset}]]
	set letter [string index $left_letters [irandom [string length $left_letters]]]
	lappend temp_list [list urw_gng_021_$letter [expr {$std_x-$xoffset-4}] $std_y]

	# rechtes Template plus Ende
	set tempvals [lindex $cavelist [lindex $comb 1]]
	set tempname [lindex $tempvals 0]
	set xoffset [lindex $tempvals 1]
	set yoffset [lindex $tempvals 2]
	lappend temp_list [list $tempname [expr {$std_x+24}] [expr {$std_y-$yoffset}]]
	set letter [string index $right_letters [irandom [string length $right_letters]]]
	lappend temp_list [list urw_gng_022_$letter [expr {$std_x+$xoffset+24}] $std_y]

	# Verbindung
	set x $std_x
	foreach itemp $conn {
		if {$itemp==0} {
			set vodo_x [expr {$x-20}]
			set vodo_y [expr {$std_y+4}]
		}
		set tempvals [lindex $tunnlist $itemp]
		set tempname [lindex $tempvals 0]
		set xoffset [lindex $tempvals 1]
		set yoffset [lindex $tempvals 2]
		if {$tempname=="urw_gng_002_"} {
			append tempname [string index ab [irandom 2]]
		} else {
			append tempname [string index abc [irandom 3]]
		}
		lappend temp_list [list $tempname $x [expr {$std_y+$yoffset}]]
		incr x $xoffset
	}

	# Voodoos
	foreach itemp $vodo {
		set tempvals [lindex $vodolist [lindex $itemp 0]]
		set tempname [lindex $tempvals 0]
		set tempext [lindex $tempvals 1]
		append tempname [string index $tempext [irandom [string length $tempext]]]
		set xoffset [lindex $itemp 1]
		set yoffset [lindex $itemp 2]
		lappend temp_list [list $tempname [expr {$vodo_x+$xoffset}] [expr {$vodo_y+$yoffset}]]
	}

	log $temp_list

	foreach nexttemp $temp_list {

    	set template [lindex $nexttemp 0]
    	set x [lindex $nexttemp 1]
    	set y [lindex $nexttemp 2]

		sm_mark_temparea $x $y $template

		call "data/templates/$template.tcl"

		MapTemplateSet $x $y

    }
}



first_level 208 0
//sm_map_set

set wl [obj_query 0 -class Wuker]
if { $wl != 0 } {
	foreach item $wl {
		del $item
	}
}

sel /obj
set FR [new FogRemover]
set_undeletable $FR 1
set_pos $FR {239 14 15}
call_method $FR fog_remove 0 46 22


show_loading 0

#set_brightness 2

log "Campaign.tcl loaded..."

