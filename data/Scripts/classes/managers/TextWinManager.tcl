call scripts/debug.tcl

def_class TextWinManager none none 0 {} {

    #
    method_static get_instance {} {
        set id [obj_query 0 -class TextWinManager -limit 1]

        if { $id == 0 } {
            set id [new TextWinManager]
            log INFO "Created new TextWinManager $id"
        }

        return $id
    }

    set saved_state {}
    member saved_state

    #
    method open_window {name state} {
        open_window $name $state
    }

    #
    method pop_saved_state {} {
        return [pop_saved_state]
    }

    # Ctor
    obj_init {

        #
        proc open_window {name state} {
            global saved_state
            set saved_state $state
            switch $name {
                "info_achievement" {
                    textwin run "data/scripts/text/doc/common/info_achievement.tcl"
                }
            }
        }

        #
        proc pop_saved_state {} {
            global saved_state
            set tmp $saved_state
            set saved_state {}
            return $tmp
        }
    }
}
