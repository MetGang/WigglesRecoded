call scripts/misc/utility.tcl
call scripts/init/animinit.tcl

# Stone boulder
def_class Steinbrocken stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/brocken.tcl

	obj_init {
		call scripts/classes/items/calls/brocken.tcl
		set expincr "exp_Stein 0.002"
	}
}

# Stone
def_class Stein stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl

	class_defaultanim stein_01.standard

	method change_owner {new_owner} {
		set_owner this $new_owner
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

# Chunk of coal
def_class Kohlebrocken stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/brocken.tcl

	obj_init {
		set expincr "exp_Energie 0.002"
		call scripts/classes/items/calls/brocken.tcl
	}
}

# Coal
def_class Kohle stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl

	class_defaultanim kohle_01.standard

	method change_owner {new_owner} {
		set_owner this $new_owner
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

# Iron ore boulder
def_class Eisenerzbrocken stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/brocken.tcl

	obj_init {
		set expincr "exp_Metall 0.003"
		call scripts/classes/items/calls/brocken.tcl
	}
}

# Iron ore
def_class Eisenerz stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl

	class_defaultanim eisenerz_01.standard

	method change_owner {new_owner} {
		set_owner this $new_owner
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

# Iron ingot
def_class Eisen metal material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl

	class_defaultanim eisen.standard

	method change_owner {new_owner} {
		set_owner this $new_owner
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

# Gold ore boulder
def_class Golderzbrocken stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/brocken.tcl

	obj_init {
		set expincr "exp_Metall 0.004"
		call scripts/classes/items/calls/brocken.tcl
	}
}

# Gold
def_class Golderz stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl

	class_defaultanim golderz_01.standard

	method change_owner {new_owner} {
		set_owner this $new_owner
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

# Golden ingot
def_class Gold metal material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl

	class_defaultanim gold.standard

	method change_owner {new_owner} {
		set_owner this $new_owner
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

# Crystal ore boulder
def_class Kristallerzbrocken stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/brocken.tcl

	obj_init {
		set expincr "exp_Stein 0.002"
		call scripts/classes/items/calls/brocken.tcl
	}
}

# Crystal ore
def_class Kristallerz stone material 0 {} {
	call scripts/misc/animclassinit.tcl
	call scripts/classes/items/calls/resources.tcl

	class_defaultanim kristallerz_01.standard

	method change_owner {new_owner} {
		set_owner this $new_owner
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

# Grilled fungus
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

# Grilled hamster
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

# Grub soup
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

# Mushroom bread
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

# Slimy grubcakes
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

# Gourmet soup
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

# Hamster shake
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

# Bulk definition for edibles
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

# Grub soup plate
def_class Essraupensuppe_teller none dummy 0 {} {
	call scripts/misc/autodef.tcl

	class_defaultanim raupensuppe.teller

	obj_init {
		set_physic this 0
		call scripts/misc/autodef.tcl
		set_anim this raupensuppe.teller 0 $ANIM_STILL
	}
}

# Slimy grubcakes roll
def_class Essraupenschleimkuchen none dummy 0 {} {
	call scripts/misc/autodef.tcl

	class_defaultanim raupenschleimkuchen.essen

	obj_init {
		set_physic this 0
		call scripts/misc/autodef.tcl
		set_anim this raupenschleimkuchen.essen 0 $ANIM_STILL
	}
}

# Beer
def_class Bier food material 1 {} {
	call scripts/misc/autodef.tcl
	call scripts/classes/items/calls/resources.tcl

	class_defaultanim bier.standard

	method set_animation {animname} {
		if { $animname == "standard" } {
			set_anim this bier.standard 0 $ANIM_STILL
		} elseif { $animname == "drink" } {
			set_anim this bier.krug 0 $ANIM_STILL
		}
	}

	method use {user} {
		tasklist_add $user "drinkpotion [get_ref this]"
	}

	method reaction {user} {
		add_attrib $user atr_Hitpoints -0.01
		add_attrib $user atr_Mood 0.1
		add_attrib $user atr_Nutrition 0.02
		add_attrib $user atr_Alertness -0.1
	}

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/classes/items/calls/resources.tcl

		set_anim this bier.standard 0 $ANIM_STILL
	}
}

# Mushroom liquor
def_class Pilzschnaps food material 1 {} {
	call scripts/misc/autodef.tcl
	call scripts/classes/items/calls/resources.tcl

	class_defaultanim pilzschnaps.standard

	method set_animation {animname} {
		if { $animname == "standard" } {
			set_anim this pilzschnaps.standard 0 $ANIM_STILL
		} elseif { $animname == "drink" } {
			set_anim this pilzschnaps.trinken 0 $ANIM_STILL
		}
	}

	method use {user} {
		tasklist_add $user "drinkpotion [get_ref this]"
	}

	method reaction {user} {
		add_attrib $user atr_Hitpoints -0.05
		add_attrib $user atr_Mood 0.4
		add_attrib $user atr_Nutrition 0.02
		add_attrib $user atr_Alertness -0.3
	}

	obj_init {
		call scripts/misc/autodef.tcl
		call scripts/classes/items/calls/resources.tcl

		set_anim this pilzschnaps.standard 0 $ANIM_STILL
	}
}
