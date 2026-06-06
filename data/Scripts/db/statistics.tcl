#
proc db_statistics {} {
	array set db {
		BooksRead {}
		MushroomsHarvested {}
		ContainersLooted {}
	}
	return [array get db]
}

#
proc db_statistics_keys {} {
	array set db [db_statistics]
	return [array names db]
}

#
proc db_statistics_value {key index} {
	array set db [db_statistics]
	return [lindex $db($key) $index]
}
