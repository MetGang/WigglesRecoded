#
proc db_achievements_rarities {} {
	return {
		Common
		Uncommon
		Rare
		Epic
		Legendary
	}
}

#
proc db_achievements {} {
	array set db {
		ChopChop {1 Common count 0 {}}
		MoreTimber {3 Uncommon count 0 {}}
		FastChopping {1 Uncommon time 60 {0 0 0}}
		Scavenger {2 Rare count 0 {}}
		YoungAgain {1 Epic count 0 {}}
	}
	return [array get db]
}

#
proc db_achievements_keys {} {
	array set db [db_achievements]
	return [array names db]
}

#
proc db_achievements_value {key index} {
	array set db [db_achievements]
	return [lindex $db($key) $index]
}

#
proc db_achievements_get_steps {key} {
	return [db_achievements_value $key 0]
}

#
proc db_achievements_get_rarity {key} {
	return [db_achievements_value $key 1]
}

#
proc db_achievements_get_type {key} {
	return [db_achievements_value $key 2]
}

#
proc db_achievements_get_time_window {key} {
	return [db_achievements_value $key 3]
}

#
proc db_achievements_get_def_entries {key} {
	return [db_achievements_value $key 4]
}
