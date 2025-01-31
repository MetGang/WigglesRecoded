call scripts/misc/utility.tcl
call scripts/init/animinit.tcl

// ACHTUNG: Kristall ist in story/lorelei.tcl definiert, da es entspr. Klassen voraussetzt! - David

def_class Gold metal material 0 {} {
	class_defaultanim gold.standard
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl
	method change_owner {new_owner} {
//		add_owner_attrib [get_owner this] [get_objclass this] -1
		set_owner this $new_owner
//		add_owner_attrib [get_owner this] [get_objclass this] 1
	}
	obj_init {
		call scripts/classes/items/calls/resources.tcl
		set_anim this gold.standard 0 0
		set_viewinfog this 1
		set_storable this 1
		set_physic this 1
		set_hoverable this 1
	}
}

def_class Eisen metal material 0 {} {
	class_defaultanim eisen.standard
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl
	method change_owner {new_owner} {
//		add_owner_attrib [get_owner this] [get_objclass this] -1
		set_owner this $new_owner
//		add_owner_attrib [get_owner this] [get_objclass this] 1
	}
	obj_init {
		call scripts/classes/items/calls/resources.tcl
		set_anim this eisen.standard 0 0
		set_viewinfog this 1
		set_storable this 1
		set_physic this 1
		set_hoverable this 1
	}
}

def_class Steinbrocken stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/brocken.tcl
	obj_init {
		call scripts/classes/items/calls/brocken.tcl
		set expincr  "exp_Stein 0.002"
	}
}

def_class Stein stone material 0 {} {
	class_defaultanim stein_01.standard
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl
	method change_owner {new_owner} {
//		add_owner_attrib [get_owner this] [get_objclass this] -1
		set_owner this $new_owner
//		add_owner_attrib [get_owner this] [get_objclass this] 1
	}
	obj_init {
		call scripts/classes/items/calls/resources.tcl
		set_anim this stein_0[irandom 1 4].standard 0 0
		set_viewinfog this 1
		set_storable this 1
		set_physic this 1
		set_hoverable this 1
	}
}

def_class Kohlebrocken stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/brocken.tcl
	obj_init {
		set expincr  "exp_Energie 0.002"
		call scripts/classes/items/calls/brocken.tcl
	}
}

def_class Kohle stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim kohle_01.standard
	method change_owner {new_owner} {
//		add_owner_attrib [get_owner this] [get_objclass this] -1
		set_owner this $new_owner
//		add_owner_attrib [get_owner this] [get_objclass this] 1
	}
	obj_init {
		call scripts/classes/items/calls/resources.tcl
		set_anim this kohle_0[irandom 1 4].standard 0 0
		set_viewinfog this 1
		set_storable this 1
		set_physic this 1
		set_hoverable this 1
	}
}

def_class Kristallerzbrocken stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/brocken.tcl
	obj_init {
		set expincr  "exp_Stein 0.002"
		call scripts/classes/items/calls/brocken.tcl
	}
}

def_class Kristallerz stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim kristallerz_01.standard
	method change_owner {new_owner} {
//		add_owner_attrib [get_owner this] [get_objclass this] -1
		set_owner this $new_owner
//		add_owner_attrib [get_owner this] [get_objclass this] 1
	}
	obj_init {
		call scripts/classes/items/calls/resources.tcl
		set_anim this kristallerz_0[irandom 1 4].standard 0 0
		set_viewinfog this 1
		set_storable this 1
		set_physic this 1
		set_hoverable this 1
	}
}


def_class Golderzbrocken stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/brocken.tcl
	obj_init {
		set expincr  "exp_Metall 0.004"
		call scripts/classes/items/calls/brocken.tcl
	}
}

def_class Golderz stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim golderz_01.standard
	method change_owner {new_owner} {
//		add_owner_attrib [get_owner this] [get_objclass this] -1
		set_owner this $new_owner
//		add_owner_attrib [get_owner this] [get_objclass this] 1
	}
	obj_init {
		call scripts/classes/items/calls/resources.tcl
		set_anim this golderz_0[irandom 1 4].standard 0 0
		set_viewinfog this 1
		set_storable this 1
		set_physic this 1
		set_hoverable this 1
	}
}


def_class Eisenerzbrocken stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/brocken.tcl
	obj_init {
		set expincr  "exp_Metall 0.003"
		call scripts/classes/items/calls/brocken.tcl
	}
}

def_class Eisenerz stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim eisenerz_01.standard
	method change_owner {new_owner} {
//		add_owner_attrib [get_owner this] [get_objclass this] -1
		set_owner this $new_owner
//		add_owner_attrib [get_owner this] [get_objclass this] 1
	}
	obj_init {
		call scripts/classes/items/calls/resources.tcl
		set_anim this eisenerz_0[irandom 1 4].standard 0 0
		set_viewinfog this 1
		set_storable this 1
		set_physic this 1
		set_hoverable this 1
	}
}

def_class Grillpilz food material 0 {} {
	call scripts/misc/autodef.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim grillpilz.standard

	method get_toolclasses {} {
		return grillpilz
	}

	method use {user} {
		tasklist_add $user "sparetime_eat [get_ref this] ground"
	}

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/classes/items/calls/resources.tcl
		set_anim this grillpilz.standard 0 $ANIM_STILL
	}
}



def_class Grillhamster food material 1 {} {
	call scripts/misc/autodef.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim grillhamster.standard

	method get_toolclasses {} {
		return grillhamster
	}

	method use {user} {
		tasklist_add $user "sparetime_eat [get_ref this] ground"
	}

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/classes/items/calls/resources.tcl
		set_anim this grillhamster.standard 0 $ANIM_STILL
	}
}


def_class Bier food material 1 {} {
	call scripts/misc/autodef.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim bier.standard

	method set_animation {animname} {
		if {$animname == "standard"} {
			set_anim this bier.standard 0 $ANIM_STILL
		} elseif {$animname == "drink"} {
			set_anim this bier.krug 0 $ANIM_STILL
		} else {
			log "Bier : set_animation : illegal Animation"
		}
	}

	method use {user} {
		tasklist_add $user "drinkpotion [get_ref this]"
	}

	method reaction {user} {
		foreach entry $stt_Bier_reaction {
			eval "add_attrib $user $entry"
		}
	}

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/classes/items/calls/resources.tcl
		set_anim this bier.standard 0 $ANIM_STILL
		set sttsection_tocall "Bier"
		call scripts/misc/sparetimetunes.tcl
	}
}

def_class Pilzschnaps food material 1 {} {
	call scripts/misc/autodef.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim pilzschnaps.standard

	method set_animation {animname} {
		if {$animname == "standard"} {
			set_anim this pilzschnaps.standard 0 $ANIM_STILL
		} elseif {$animname == "drink"} {
			set_anim this pilzschnaps.trinken 0 $ANIM_STILL
		} else {
			log "Pilzschnaps : set_animation : illegal Animation"
		}
	}

	method use {user} {
		tasklist_add $user "drinkpotion [get_ref this]"
	}

	method reaction {user} {
		foreach entry $stt_Schnaps_reaction {
			eval "add_attrib $user $entry"
		}
	}

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/classes/items/calls/resources.tcl
		set_anim this pilzschnaps.standard 0 $ANIM_STILL
		set sttsection_tocall "Pilzschnaps"
		call scripts/misc/sparetimetunes.tcl
	}
}

def_class Raupensuppe food material 2 {} {
	call scripts/misc/autodef.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim raupensuppe.standard

	method get_toolclasses {} {
		return raupensuppe_teller
	}

	method use {user} {
		tasklist_add $user "sparetime_eat [get_ref this] ground"
	}

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/classes/items/calls/resources.tcl
		set_anim this raupensuppe.standard 0 $ANIM_STILL
	}
}

def_class Pilzbrot food material 2 {} {
	call scripts/misc/autodef.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim pilzbrot.standard


	method get_toolclasses {} {
		return pilzbrot
	}

	method use {user} {
		tasklist_add $user "sparetime_eat [get_ref this] ground"
	}

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/classes/items/calls/resources.tcl
		set_anim this pilzbrot.standard 0 $ANIM_STILL
	}
}


def_class Raupenschleimkuchen food material 2 {} {
	call scripts/misc/autodef.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim raupenschleimkuchen.standard

	method get_toolclasses {} {
		return raupenschleimkuchen
	}

	method use {user} {
		tasklist_add $user "sparetime_eat [get_ref this] ground"
	}

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/classes/items/calls/resources.tcl
		set_anim this raupenschleimkuchen.standard 0 $ANIM_STILL
	}
}


def_class Gourmetsuppe food material 2 {} {
	call scripts/misc/autodef.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim gourmetsuppe_fass.standard

	method get_toolclasses {} {
		return gourmetsuppe_teller
	}

	method use {user} {
		tasklist_add $user "sparetime_eat [get_ref this] ground"
	}

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/classes/items/calls/resources.tcl
		set_anim this gourmetsuppe_fass.standard 0 $ANIM_STILL
	}
}


def_class Hamstershake food material 2 {} {
	call scripts/misc/autodef.tcl
	call scripts/classes/items/calls/resources.tcl
	class_defaultanim hamstershake.standard

	method get_toolclasses {} {
		return hamstershake
	}

	method use {user} {
		tasklist_add $user "sparetime_eat [get_ref this] ground"
	}

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/classes/items/calls/resources.tcl
		set_anim this hamstershake.standard 0 $ANIM_STILL
	}
}



// Dummy_Objekte zum in die Hand nehmen

foreach classname {Grillpilz Grillhamster Pilzbrot Gourmetsuppe Hamstershake} {
	set tcn [call_method_static $classname get_toolclasses]
	def_class Ess$tcn none dummy 0 {} "
		call scripts/misc/autodef.tcl
		obj_init \{
			set_physic this 0
			call scripts/misc/autodef.tcl
			set_anim this $tcn.standard 0 \$ANIM_STILL
		\}
	"
}
def_class Essraupensuppe_teller none dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim raupensuppe.teller

	obj_init {
		set_physic this 0
		call scripts/misc/autodef.tcl
		set_anim this raupensuppe.teller 0 $ANIM_STILL
	}
}
def_class Essraupenschleimkuchen none dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim raupenschleimkuchen.essen

	obj_init {
		set_physic this 0
		call scripts/misc/autodef.tcl
		set_anim this raupenschleimkuchen.essen 0 $ANIM_STILL
	}
}
