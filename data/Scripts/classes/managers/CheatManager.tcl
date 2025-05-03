call scripts/debug.tcl

def_class CheatManager none none 0 {} {

    #
    method_static get_instance {} {
        set id [obj_query 0 -class CheatManager -limit 1]

        if { $id == 0 } {
            set id [new CheatManager]
            log INFO "Created new CheatManager $id"
        }

        return $id
    }

    set enabled 0
    member enabled

    #
    method is_enabled {} {
        return $enabled
    }

    #
    method toggle_enabled {} {
        set enabled [expr {!$enabled}]
    }

    #
    method is_cheat_enabled {name} {
        if { ![info exists $name] } {
            set $name 0
        }
        return [subst \$$name]
    }

    #
    method toggle_cheat_enabled {name} {
        set $name [expr {![call_method this is_cheat_enabled $name]}]
    }

    #
    method get_available_cheats {} {
        return [get_available_cheats]
    }

    # Ctor
    obj_init {

        #
        proc get_available_cheats {} {
            return {InventButtons Foo Bar}
        }
    }
}
