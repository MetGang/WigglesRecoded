call scripts/debug.tcl

log INIT "classinit.tcl started"

def_attrib Pilz 0 10000 0
def_attrib Hamster 0 10000 0
def_attrib Raupe 0 10000 0
def_attrib LastBirth 0 10000 0
def_attrib PlayerAggressivity 0 1 0.5
def_attrib BpRaupensuppe 0 1 0
def_attrib BpPilzbrot 0 1 0
def_attrib BpRaupenschleimkuchen 0 1 0
def_attrib BpGourmetsuppe 0 1 0
def_attrib BpHamstershake 0 1 0

if { [startcache present] } {
	log INIT "classinit.tcl using startcache"
	startcache load
} else {
	set files [lsort [glob -nocomplain -directory "data/scripts/classes/characters" "*.tcl"]]
	foreach f $files {
		set tail [file tail $f]
		if { [string first "_" $tail] != -1 } { continue }
		log INIT "Loading class: $tail"
		catch "call $f"
	}

	set files [lsort [glob -nocomplain -directory "data/scripts/classes/items" "*.tcl"]]
	foreach f $files {
		set tail [file tail $f]
		log INIT "Loading class: $tail"
		catch "call $f"
	}

	set files [lsort [glob -nocomplain -directory "data/scripts/classes/deco" "*.tcl"]]
	foreach f $files {
		set tail [file tail $f]
		log INIT "Loading class: $tail"
		catch "call $f"
	}

	set files [lsort [glob -nocomplain -directory "data/scripts/classes/work" "*.tcl"]]
	foreach f $files {
		set tail [file tail $f]
		log INIT "Loading class: $tail"
		catch "call $f"
	}

	set files [lsort [glob -nocomplain -directory "data/scripts/classes/sparetime" "*.tcl"]]
	foreach f $files {
		set tail [file tail $f]
		log INIT "Loading class: $tail"
		catch "call $f"
	}

	set files [lsort [glob -nocomplain -directory "data/scripts/classes/story" "*.tcl"]]
	foreach f $files {
		set tail [file tail $f]
		if { $tail == "sequencer.tcl" } { continue }
		log INIT "Loading class: $tail"
		catch "call $f"
	}

	log INIT "Loading class: zwerg.tcl"
	call scripts/classes/zwerg/zwerg.tcl
	log INIT "Loading class: pzwerg.tcl"
	call scripts/classes/zwerg/pzwerg.tcl
	log INIT "Loading class: actors.tcl"
	call scripts/classes/zwerg/actors.tcl
	log INIT "Loading class: baby.tcl"
	call scripts/classes/zwerg/baby.tcl

	log INIT "Loading class: AchievementManager.tcl"
	call scripts/classes/managers/AchievementManager.tcl
	log INIT "Loading class: CheatManager.tcl"
	call scripts/classes/managers/CheatManager.tcl
	log INIT "Loading class: ConfigManager.tcl"
	call scripts/classes/managers/ConfigManager.tcl
	log INIT "Loading class: StatisticsManager.tcl"
	call scripts/classes/managers/StatisticsManager.tcl
	log INIT "Loading class: TextWinManager.tcl"
	call scripts/classes/managers/TextWinManager.tcl

	if { [startcache enabled] } {
		log INIT "classinit.tcl startcache enabled"
		startcache write
	}
}

def_attrib GnomeAge -40000 1000000 0
def_attrib GnomeStrike 0 1 0

call scripts/init/eventgen.tcl

reset_owner_attribs

log INIT "classinit.tcl finished"
