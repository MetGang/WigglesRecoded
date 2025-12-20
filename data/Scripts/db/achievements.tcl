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
	# key : steps rarity type time_window window_count
	array set db {
		FirstCut {1 Common count 0 {}}
		FastChopping {1 Uncommon time 60 3}
		Scavenger {5 Uncommon count 0 {}}
		Enlightenment {3 Uncommon count 0 {}}
		SoMuchDigging {1 Rare count 0 {}}
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
proc db_achievements_get_window_count {key} {
	return [db_achievements_value $key 4]
}
