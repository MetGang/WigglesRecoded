def_class TextWinManager none none 0 {} {

    # Singleton getter
    method_static get_instance {} {
        call scripts/debug.tcl

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
        handle_window "textwin run" $name $state
    }

    #
    method embed_window {name state} {
        handle_window "call" $name $state
    }

    #
    method has_saved_state {} {
        if { $saved_state != {} } { return 1 } { return 0 }
    }

    #
    method pop_saved_state {} {
        set tmp_state $saved_state
        set saved_state {}
        return $tmp_state
    }

    # Constructor
    obj_init {

        #
        proc handle_window {cmd name state} {
            global saved_state
            set saved_state $state
            switch $name {
                "info_achievement" {
                    eval $cmd "data/scripts/text/doc/common/info_achievement.tcl"
                }
                "info_invention" {
                    eval $cmd "data/scripts/text/doc/common/info_invention.tcl"
                }
            }
        }
    }
}
