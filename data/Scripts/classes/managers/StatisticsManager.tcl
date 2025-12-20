call scripts/debug.tcl
call scripts/utility.tcl

def_class StatisticsManager none none 0 {} {

	#
	method_static get_instance {} {
		set id [obj_query 0 -class StatisticsManager -limit 1]

		if { $id == 0 } {
			set id [new StatisticsManager]
			log INFO "Created new StatisticsManager $id"
			call_method $id apply_config
			log INFO "Config applied to StatisticsManager $id"
		}

		return $id
	}

	#
	method apply_config {} {

	}

	#
	method get_stat_list {} {
		return [get_available_stats]
	}

	#
	method get_stat_value {key} {
		return [subst \$stat_$key]
	}

	#
	method incr_stat_value {key value} {
		# FIXME: Somehow it does not work correctly
		# [incr_stat_value $key $value]
		# Workaround
		incr stat_$key $value
	}

	# Constructor
	obj_init {
		call scripts/db/statistics.tcl

		foreach key [db_statistics_keys] {
			set stat_$key 0
		}

		#
		proc get_available_stats {} {
			return [db_statistics_keys]
		}

		#
		proc incr_stat_value {key value} {
			upvar stat_$key stat

			incr stat $value
		}
	}
}
