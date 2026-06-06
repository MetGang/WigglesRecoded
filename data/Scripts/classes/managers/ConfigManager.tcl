def_class ConfigManager none none 0 {} {

    # Singleton getter
    method_static get_instance {} {
        call scripts/debug.tcl

        set id [obj_query 0 -class ConfigManager -limit 1]

        if { $id == 0 } {
            set id [new ConfigManager]
            log INFO "Created new ConfigManager $id"
            call_method $id load_config
            log INFO "Config loaded by ConfigManager $id"
        }

        return $id
    }

    #
    method load_config {} {
        set preset_path "data/preset"
        set config_path "data/default.ini"

        if { ![file exists $preset_path] } {
            log WARN "No preset found, defaulting to use '$config_path'"
        } else {
            set preset_file [open $preset_path r]
            if { [gets $preset_file line] == -1 } {
                log WARN "Preset file seems to be empty, defaulting to use '$config_path'"
            } else {
                set config_path $line
            }
            close $preset_file
        }

        if { ![file exists $config_path] } {
            log ERROR "Config file '$config_path' does not exists, aborting"
            return
        }

        set config_file [open $config_path r]
        set current_section ""

        # Read line by line
        while { [gets $config_file line] >= 0 } {
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
                log INFO "Adding config: ${current_section}.$key = $value"
                set full_key "${current_section}_$key"
                set cfg_$full_key $value
            }
        }

        close $config_file
    }

    #
    method get_value {key} {
        set under_key [string map {. _} $key]
        if { [info exists cfg_$under_key] } {
            return [subst \$cfg_$under_key]
        }
        log ERROR "$key does not exist in the config, returning 0"
        return 0
    }

    #
    method get_value_or {key fallback} {
        set under_key [string map {. _} $key]
        if { [info exists cfg_$under_key] } {
            return [subst \$cfg_$under_key]
        }
        log WARN "$key does not exist in the config, returning fallback $fallback"
        return $fallback
    }

    # Constructor
    obj_init {
        call scripts/debug.tcl
        call scripts/utility.tcl
    }
}
