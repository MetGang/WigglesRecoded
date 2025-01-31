// traenke.tcl - alles, was in kleinen Fläschchen serviert wird :-)

def_class Kleiner_Heiltrank energy tool 2 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim heiltrank_klein.standard
	
	method set_animation {animname} {
		if {$animname == "standard"} {
			set_anim this heiltrank_klein.standard 0 $ANIM_STILL
		} elseif {$animname == "drink"} {
			set_anim this heiltrank_klein.trinken 0 $ANIM_STILL
		} else {
			log "Kleiner_Heiltrank: set_animation : illegal Animation"
		}
	} 

	method use {user} {
		tasklist_add $user "drinkpotion [get_ref this]"
	}
	
	method reaction {user} {
		add_attrib $user atr_Hitpoints 0.15
		create_particlesource 13 [get_pos $user] {0 -0.1 0.1} 16 1
	}

	obj_init { 
		call scripts/misc/autodef.tcl
		set_anim this heiltrank_klein.standard 0 $ANIM_STILL

		set_attrib this nutrivalue 0
		set_attrib this weight 0.05
	}
}


def_class Heiltrank energy tool 2 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim heiltrank.standard	
	
	method set_animation {animname} {
		if {$animname == "standard"} {
			set_anim this heiltrank.standard 0 $ANIM_STILL
		} elseif {$animname == "drink"} {
			set_anim this heiltrank.trinken 0 $ANIM_STILL
		} else {
			log "Heiltrank: set_animation : illegal Animation"
		}
	} 

	method use {user} {
		tasklist_add $user "drinkpotion [get_ref this]"
	}
	
	method reaction {user} {
		add_attrib $user atr_Hitpoints 0.4
		create_particlesource 13 [get_pos $user] {0 -0.1 0.1} 20 2
	}
	
	obj_init { 
		call scripts/misc/autodef.tcl
		set_anim this heiltrank.standard 0 $ANIM_STILL
	}
}



def_class Grosser_Heiltrank energy tool 2 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim heiltrank_gross.standard	
	
	method set_animation {animname} {
		if {$animname == "standard"} {
			set_anim this heiltrank_gross.standard 0 $ANIM_STILL
		} elseif {$animname == "drink"} {
			set_anim this heiltrank_gross.trinken 0 $ANIM_STILL
		} else {
			log "Grosser_Heiltrank: set_animation : illegal Animation"
		}
	} 
	
	method use {user} {
		tasklist_add $user "drinkpotion [get_ref this]"
	}
	
	method reaction {user} {
		add_attrib $user atr_Hitpoints 1.0
		create_particlesource 13 [get_pos $user] {0 -0.1 0.1} 32 2
	}	
	
	obj_init { 
		call scripts/misc/autodef.tcl
		set_anim this heiltrank_gross.standard 0 $ANIM_STILL
	}
}


def_class Liebestrank energy tool 4 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim liebestrank.standard	
		
	obj_init { 
		call scripts/misc/autodef.tcl
		set_anim this liebestrank.standard 0 $ANIM_STILL
	}
	
	method set_animation {animname} {
		if {$animname == "standard"} {
			set_anim this liebestrank.standard 0 $ANIM_STILL
		} elseif {$animname == "drink"} {
			set_anim this liebestrank.trinken 0 $ANIM_STILL
		} else {
			log "Liebestrank : set_animation : illegal Animation"
		}
	} 

	
	method use {user} {
		tasklist_add $user "drinkpotion [get_ref this]"
	}
	
	method reaction {user} {
		tasklist_add $user "become_lovecrazed"
		create_particlesource 13 [get_pos $user] {0 -0.1 0.1} 32 2
	}	
}


def_class Unverwundbarkeitstrank energy tool 4 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim unverwundbarkeitstrank.standard	

	method set_animation {animname} {
		if {$animname == "standard"} {
			set_anim this unverwundbarkeitstrank.standard 0 $ANIM_STILL
		} elseif {$animname == "drink"} {
			set_anim this unverwundbarkeitstrank.trinken 0 $ANIM_STILL
		} else {
			log "Unverwundbarkeitstrank : set_animation : illegal Animation"
		}
	} 

	method use {user} {
		tasklist_add $user "drinkpotion [get_ref this]"
	}
	
	method reaction {user} {
		if {[check_method [get_objclass $user] set_invulnerability]} {
			call_method $user set_invulnerability 1 30
		}
	}

	obj_init { 
		call scripts/misc/autodef.tcl
		set_anim this unverwundbarkeitstrank.standard 0 $ANIM_STILL
	}
}


def_class Jungbrunnentrank energy tool 4 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim jungbrunnentrank.standard
	
	method set_animation {animname} {
		if {$animname == "standard"} {
			set_anim this jungbrunnentrank.standard 0 $ANIM_STILL
		} elseif {$animname == "drink"} {
			set_anim this jungbrunnentrank.trinken 0 $ANIM_STILL
		} else {
			log "Jungbrunnen : set_animation : illegal Animation"
		}
	} 
	
	method use {user} {
		tasklist_add $user "drinkpotion [get_ref this]"
	}
	
	method reaction {user} {
		set baby [new Baby]
		set_owner $baby [get_owner $user]
		set_pos $baby [get_pos $user]
		set_rot $baby [get_rot $user]

		set otherattribs [list]
		foreach attribut [get_expattrib] {
			lappend otherattribs [get_attrib $user $attribut]
		}
		
		call_method $baby gnome_to_baby [get_objgender $user] [get_objname $user] [get_worktime $user] [get_attrib $user atr_Nutrition] [get_attrib $user atr_Alertness] [get_attrib $user atr_Mood] [get_attrib $user atr_Hitpoints] [get_attrib $user atr_ExpMax] $otherattribs 0
		set_visibility $user 0
		call_method $user destroy

		create_particlesource 13 [get_pos $user] {0 -0.1 0.1} 32 2
	}		
	
	obj_init { 
		call scripts/misc/autodef.tcl
		set_anim this jungbrunnentrank.standard 0 $ANIM_STILL
	}
}


def_class Unsichtbarkeitstrank energy tool 4 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim unsichtbarkeitstrank.standard
	
	method set_animation {animname} {
		if {$animname == "standard"} {
			set_anim this unsichtbarkeitstrank.standard 0 $ANIM_STILL
		} elseif {$animname == "drink"} {
			set_anim this unsichtbarkeitstrank.trinken 0 $ANIM_STILL
		} else {
			log "Unsichtbarkeitstrank : set_animation : illegal Animation"
		}
	} 

	method use {user} {
		tasklist_add $user "drinkpotion [get_ref this]"
	}
	
	method reaction {user} {
		if {[check_method [get_objclass $user] set_invisibility]} {
			call_method $user set_invisibility 1 180
		}
	}

	obj_init { 
		call scripts/misc/autodef.tcl
		set_anim this unsichtbarkeitstrank.standard 0 $ANIM_STILL
	}
}


def_class Fruchtbarkeitstrank energy tool 4 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim fruchtbarkeitstrank.standard
	
	obj_init { 
		call scripts/misc/autodef.tcl
		set_anim this fruchtbarkeitstrank.standard 0 $ANIM_STILL
	}
	
	method set_animation {animname} {
		if {$animname == "standard"} {
			set_anim this fruchtbarkeitstrank.standard 0 $ANIM_STILL
		} elseif {$animname == "drink"} {
			set_anim this fruchtbarkeitstrank.trinken 0 $ANIM_STILL
		} else {
			log "Fruchtbarkeitstrank : set_animation : illegal Animation"
		}
	} 
	

	method use {user} {
		tasklist_add $user "drinkpotion [get_ref this]"
	}
	
	method reaction {user} {
		tasklist_add $user "become_fertile"
		create_particlesource 13 [get_pos $user] {0 -0.1 0.1} 32 2
	}
}

def_class Wiederbelebung energy material 2 {} {}
