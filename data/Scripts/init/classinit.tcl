log "Class init"


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



if { ! [minimalrun] } {

	if { [startcache present] } {

		log "using startcache"
		startcache load
	
	} else {

		;# die restlichen classen aus /data/scripts/classes laden
	
		cd Data/scripts/classes/characters
		set filelist [lsort [glob -nocomplain "*.tcl"]]
		cd ../../../..
		foreach classfile $filelist {
			if {[string first "_" $classfile]!=-1} {continue}
	//		log "Classes: $classfile"
			catch "call scripts/classes/characters/$classfile"
			logdebug "class init done: $classfile"
		}
		cd Data/scripts/classes/items
		set filelist [lsort [glob -nocomplain "*.tcl"]]
		cd ../../../..
		foreach classfile $filelist {
	//		log "Classes: $classfile"
			catch "call scripts/classes/items/$classfile"
			logdebug "class init done: $classfile"
		}
		cd Data/scripts/classes/deco
		set filelist [lsort [glob -nocomplain "*.tcl"]]
		cd ../../../..
		foreach classfile $filelist {
	//		log "Classes: $classfile"
			catch "call scripts/classes/deco/$classfile"
			logdebug "class init done: $classfile"
		}
		cd Data/scripts/classes/work
		set filelist [lsort [glob -nocomplain "*.tcl"]]
		cd ../../../..
		foreach classfile $filelist {
	//		log "Classes: $classfile"
			catch "call scripts/classes/work/$classfile"
			logdebug "class init done: $classfile"
		}
		cd Data/scripts/classes/sparetime
		set filelist [lsort [glob -nocomplain "*.tcl"]]
		cd ../../../..
		foreach classfile $filelist {
	//		log "Classes: $classfile"
			catch "call scripts/classes/sparetime/$classfile"
			logdebug "class init done: $classfile"
		}
		cd Data/scripts/classes/story
		set filelist [lsort [glob -nocomplain "*.tcl"]]
		cd ../../../..
		foreach classfile $filelist {
			if { "sequencer.tcl" == $classfile } {
				continue
			}
	//		log "Classes: $classfile"
			catch "call scripts/classes/story/$classfile"
			logdebug "class init done: $classfile"
		}
		call scripts/classes/zwerg/zwerg.tcl
		call scripts/classes/zwerg/pzwerg.tcl
		call scripts/classes/zwerg/actors.tcl
		call scripts/classes/zwerg/baby.tcl

		if { [startcache enabled] } {
			startcache write
		}
	}
	
} else {
	if { [startcache present] } {

		log "using startcache"
		startcache load
	
	} else {
		call scripts/classes/items/werkzeuge.tcl
		call scripts/classes/items/rohstoffe.tcl
		call scripts/classes/zwerg/zwerg.tcl
		call scripts/classes/items/muetzen.tcl
		call scripts/classes/items/emitter.tcl
		call scripts/classes/work/feuerstelle.tcl
		call scripts/classes/work/hauklotz.tcl
		call scripts/classes/items/pilz.tcl
		startcache write
	}
}

def_attrib GnomeAge	-40000	1000000	0
def_attrib GnomeStrike	0	1	0
call scripts/init/eventgen.tcl

reset_owner_attribs
