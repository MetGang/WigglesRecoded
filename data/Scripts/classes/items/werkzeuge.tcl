# Axe used for harvesting mushrooms
def_class Axt stone dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim axt.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this axt.standard 0 $ANIM_STILL
	}
}

# Pickaxe used for digging
def_class Spitzhacke stone dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim spitzhacke.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this spitzhacke.standard 0 $ANIM_STILL
	}
}

# Hammer used at workplaces
def_class Hammer stone dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim hammer.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this hammer.standard 0 $ANIM_STILL
	}
}

# Plane (tool for shaping wood using muscle power) used at workplaces
def_class Hobel stone dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim hobel.standard
	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this hobel.standard 0 $ANIM_STILL
	}
}

# File (tool used for smoothing or shaping materials like metal or wood)
# Unused!
def_class Feile stone dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim feile.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this feile.standard 0 $ANIM_STILL
	}
}

# Handsaw used at workplaces
def_class Fuchsschwanz stone dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim fuchsschwanz.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this fuchsschwanz.standard 0 $ANIM_STILL

	}
}

# Hand welder used at workplaces
def_class Handschweissgeraet stone dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim handschweissgeraet.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this handschweissgeraet.standard 0 $ANIM_STILL
	}
}

# Screwdriver used at workplaces
def_class Akkuschrauber stone dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim akuschrauber.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this akuschrauber.standard 0 $ANIM_STILL

	}
}

# Chisel used at workplaces
def_class Meissel stone dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim meissel.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this meissel.standard 0 $ANIM_STILL

	}
}

# Smelting crucible but looks like ladle
# Unused!
def_class Schmelztiegel stone dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim schmelztiegel.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this schmelztiegel.standard 0 $ANIM_STILL
	}
}

# Syringe used at workplaces
def_class Spritze stone dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim spritze.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this spritze.standard 0 $ANIM_STILL
	}
}

# Training sword used in Dojo
def_class Trainierschwert wood dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim schwert.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this schwert.standard 0 $ANIM_STILL
	}
}

# Two-handed sword used in Dojo
def_class Trainier_2h_Schwert wood dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim schwert.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this schwert.standard 0 $ANIM_STILL
	}
}

# Training bow used in Dojo
def_class Trainierbogen wood dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim bogen.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this bogen.standard 0 $ANIM_STILL
	}
}

# Training shield used in Dojo
def_class Trainierschild wood dummy 1 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim schild.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this schild.standard 0 $ANIM_STILL
	}
}

# Jackhammer, real (craftable) tool
def_class Presslufthammer metal tool 3 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim presslufthammer.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this presslufthammer.standard 0 $ANIM_STILL
	}
}

# Chainsaw, real (craftable) tool
def_class Kettensaege metal tool 3 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim kettensaege.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this kettensaege.standard 0 $ANIM_STILL
	}
}

# Crystal Beam, real (craftable) tool
def_class Kristallstrahl energy tool 4 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim kristallstrahl.standard

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this kristallstrahl.standard 0 $ANIM_STILL
	}
}

# Testing tube
def_class Reagenzglas metal tool 3 {} {
	call scripts/misc/autodef.tcl

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this reagenzglas.standard 0 $ANIM_STILL
	}
}

# Smoking pipe
def_class Pfeife wood tool 3 {} {
	call scripts/misc/autodef.tcl

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this pfeife_a.standard 0 $ANIM_STILL
	}
}

# Semi-finished wood
def_class Halbzeug_holz wood dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim pilzstamm.standard

	method change_look {look} {
		set look [string map {roh pilzstamm half halber_pilzstamm kant kantholz brett brett rad holzzahnrad} $look]
		set_anim this $look.standard 0 $ANIM_STILL
	}

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this pilzstamm.standard 0 $ANIM_STILL
	}
}

# Semi-finished stone
def_class Halbzeug_stein stone dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim stein_01.standard

	method change_look {look} {
		set look [string map {roh stein mauer bearbeiteter_stein} $look]
		if { $look == "stein" } {
			set_anim this "stein_0[expr {[irandom 3] + 1}].standard" 0 $ANIM_STILL
		} else {
			set_anim this $look.standard 0 $ANIM_STILL
		}
	}

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this "stein_0[expr {[irandom 3] + 1}].standard" 0 $ANIM_STILL
	}
}

# Semi-finished metal
def_class Halbzeug_eisen metal dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim eisen.standard

	method change_look {look} {
		set look [string map {roh eisen half halber_metallbarren stab metallstab rad metallzahnrad blech metallblech gold gold golderz golderz} $look]
		if { $look == "golderz" } {
			set_anim this "golderz_0[expr {[irandom 3] + 1}].standard" 0 $ANIM_STILL
		} else {
			set_anim this $look.standard 0 $ANIM_STILL
		}
	}

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this eisen.standard 0 $ANIM_STILL
	}
}

# Tray of beers
def_class Halbzeug_tablett food dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim tablett_dreikruege.standard

	method change_look {look} {
		set look [string map {drei tablett_dreikruege zwei tablett_zweikruege eins tablett_einkrug} $look]
		set_anim this $look.standard 0 $ANIM_STILL
	}

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this tablett_dreikruege.standard 0 $ANIM_STILL
	}
}

# Pot for cooking
def_class Halbzeug_topf food dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim topf.standard

	method change_look {look} {
		set look [string map {} $look]
		set_anim this $look.standard 0 $ANIM_STILL
	}

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this topf.standard 0 $ANIM_STILL
	}
}

# Pan for cooking
def_class Halbzeug_pfanne food dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim pfanne.standard

	method change_look {look} {
		set look [string map {} $look]
		set_anim this $look.standard 0 $ANIM_STILL
	}

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this pfanne.standard 0 $ANIM_STILL
	}
}

# Box
def_class Halbzeug_kiste none dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim kiste_offen.standard

	method change_look {look} {
		set look [string map {offen kiste_offen tragen kiste_tragen geschlossen kiste} $look]
		set_anim this $look.standard 0 $ANIM_STILL
	}

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this kiste_offen.standard 0 $ANIM_STILL
	}
}

# Pocker calculator
def_class Halbzeug_Taschenrechner none dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim taschenrechner.standard

	method change_look {look} {
		set look [string map {taschenrechner taschenrechner} $look]
		set_anim this $look.standard 0 $ANIM_STILL
	}

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this taschenrechner.standard 0 $ANIM_STILL
	}
}

# Potion
def_class Halbzeug_trank none dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim unverwundbarkeitstrank.standard

	method change_look {look} {
		set look [string map {unverwundbarkeitstrank unverwundbarkeitstrank liebestrank liebestrank heiltrank heiltrank} $look]
		set_anim this $look.standard 0 $ANIM_STILL
	}

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this unverwundbarkeitstrank.standard 0 $ANIM_STILL
	}
}

# Beer
def_class Halbzeug_bier none dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim bier.krug

	method change_look {look} {
		set look [string map {} $look]
		set_anim this $look.standard 0 $ANIM_STILL
	}

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this bier.krug 0 $ANIM_STILL
	}
}

# Billboard with points
def_class Wigglepoints none dummy 0 {} {
	call scripts/misc/autodef.tcl
	class_defaultanim punkte_60.standard

	method set_points {points} {
		set_anim this punkte_$points.standard 0 $ANIM_STILL
	}

	obj_init {
		call scripts/misc/autodef.tcl
		set_physic this 0
		set_anim this punkte_60.standard 0 $ANIM_STILL
	}
}
