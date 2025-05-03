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
		ChopChop {1 Common}
		MoreTimber {3 Uncommon}
		Scavenger {2 Rare}
		YoungAgain {1 Epic}
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
