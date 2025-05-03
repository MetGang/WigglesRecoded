call scripts/debug.tcl

def_class ConfigManager none none 0 {} {

	#
	method_static get_instance {} {
		set id [obj_query 0 -class ConfigManager -limit 1]

		if { $id == 0 } {
			set id [new ConfigManager]
			log INFO "Created new ConfigManager $id"
			call_method $id load_config
			log INFO "Config loaded by $id"
		}

		return $id
	}

	array set config {}

	#
	method load_config {} {
		return [load_config]
	}

	#
	method get_value {key} {
		return [get_value $key]
	}

	#
	method get_value_or {key fallback} {
		return [get_value_or $key $fallback]
	}

	# Constructor
	obj_init {
		call scripts/debug.tcl

		#
		proc load_config {} {
			global config

			set filename "data/config.ini"
			if { ![file exists $filename] } {
				log ERROR "Config file $filename does not exists"
				return
			}

			set file [open $filename r]
			set current_section ""

			# Read line by line
			while { [gets $file line] >= 0 } {
				# Trim whitespace
				set line [string trim $line]

				# Skip empty lines and comments
				if { $line == "" || [string match "#*" $line] || [string match ";*" $line] } {
					continue
				}

				# Handle section headers
				if { [regexp {\[(.+)\]} $line -> section] } {
					set current_section $section
					continue
				}

				# Handle key=value pairs
				if { [regexp {([^=]+)=(.+)} $line -> key value] } {
					set key [string trim $key]
					set value [string trim $value]
					set full_key "${current_section}.$key"
					log INFO "Adding config: $full_key = $value"
					set config($full_key) $value
				}
			}

			close $file
		}

		#
		proc get_value {key} {
			global config
			if { [info exists config($key)] } {
				return $config($key)
			}
			log ERROR "$key does not exist in the config"
			return 0
		}

		#
		proc get_value_or {key fallback} {
			global config
			if { [info exists config($key)] } {
				return $config($key)
			}
			return $fallback
		}
	}
}
