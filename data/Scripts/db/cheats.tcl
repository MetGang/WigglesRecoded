#
proc db_cheats {} {
	array set db {
		InventButtons {}
		InstantHarvest {}
	}
	return [array get db]
}

#
proc db_cheats_keys {} {
	array set db [db_cheats]
	return [array names db]
}

#
proc db_cheats_value {key index} {
	array set db [db_cheats]
	return [lindex $db($key) $index]
}
