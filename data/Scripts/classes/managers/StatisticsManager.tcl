def_class StatisticsManager none none 0 {} {

    # Singleton getter
    method_static get_instance {} {
        call scripts/debug.tcl

        set id [obj_query 0 -class StatisticsManager -limit 1]

        if { $id == 0 } {
            set id [new StatisticsManager]
            log INFO "Created new StatisticsManager $id"
        }

        return $id
    }

    #
    method get_stat_value {key} {
        return [subst \$stat_$key]
    }

    #
    method incr_stat_value {key value} {
        incr stat_$key $value
    }

    # Constructor
    obj_init {
        call scripts/db/statistics.tcl

        foreach key [db_statistics_keys] {
            set stat_$key 0
        }
    }
}
