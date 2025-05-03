call scripts/debug.tcl
call scripts/utility.tcl

def_class AchievementManager none none 0 {} {

    #
    method_static get_instance {} {
        set id [obj_query 0 -class AchievementManager -limit 1]

        if { $id == 0 } {
            set id [new AchievementManager]
            log INFO "Created new AchievementManager $id"
        }

        return $id
    }

    set achv_ChopChop {0 1 Common}
    member achv_ChopChop

    set achv_MoreTimber {0 3 Uncommon}
    member achv_MoreTimber

    set achv_Scavenger {0 2 Rare}
    member achv_Scavenger

    set achv_YoungAgain {0 1 Epic}
    member achv_YoungAgain

    set last_unlocked_achv 0
    member last_unlocked_achv

    #
    method get_achv_list {rarity} {
        set all {ChopChop MoreTimber Scavenger YoungAgain}
        if { $rarity == "all" } {
            return $all
        } else {
            set rlst {}
            foreach entry $all {
                if { [call_method this get_achv_rarity $entry] == $rarity } {
                    lappend rlst $entry
                }
            }
            return $rlst
        }
    }

    #
    method get_achv_rarities {} {
        return [get_achv_rarities]
    }

    #
    method trigger_achv_step {key} {
        if { ![call_method this is_achv_unlocked $key] } {
            set callback "callback_achv_$key"
            if { [incr_achv_progress $key] } {
                set last_unlocked_achv $key
                create_achv_sticker $key
            }
        }
    }

    #
    method is_achv_unlocked {key} {
        set dividend [lindex [subst \$achv_$key] 0]
        set divisor [lindex [subst \$achv_$key] 1]
        return [expr {$dividend >= $divisor}]
    }

    #
    method get_achv_progress {key} {
        set dividend [lindex [subst \$achv_$key] 0]
        set divisor [lindex [subst \$achv_$key] 1]
        return [list $dividend $divisor]
    }

    #
    method get_achv_rarity {key} {
        return [lindex [subst \$achv_$key] 2]
    }

    #
    method get_unlocked_achv_count {rarity} {
        set cnt 0
        foreach key [call_method this get_achv_list $rarity] {
            if { [call_method this is_achv_unlocked $key] } {
                incr cnt
            }
        }
        return $cnt
    }

    #
    method get_locked_achv_count {rarity} {
        set cnt 0
        foreach key [call_method this get_achv_list $rarity] {
            if { ![call_method this is_achv_unlocked $key] } {
                incr cnt
            }
        }
        return $cnt
    }

    #
    method get_total_achv_count {rarity} {
        return [llength [call_method this get_achv_list $rarity]]
    }

    # Ctor
    obj_init {

        #
        proc get_achv_rarities {} {
            return {Common Uncommon Rare Epic Legendary}
        }

        #
        proc create_achv_sticker {key} {
            set msg "Achievement \"[lmsg AchvTitle_$key]\" unlocked!"
            set id [newsticker new 0 -text $msg -time 60]
            newsticker change $id -click "newsticker delete $id; twm_open_window info_achievement $key"
        }

        #
        proc incr_achv_progress {key} {
            upvar achv_$key achv

            set dividend [lindex $achv 0]
            set divisor [lindex $achv 1]
            incr dividend
            set achv [lreplace $achv 0 0 $dividend]

            if { $dividend >= $divisor } {
                return 1
            }

            return 0
        }
    }
}
