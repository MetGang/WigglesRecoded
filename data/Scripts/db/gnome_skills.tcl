#
proc db_gnome_skills {} {
	array set db {
		QuickHarvest {1}
		MasterChef {2}
	}
	return [array get db]
}

#
proc db_gnome_skills_keys {} {
	array set db [db_gnome_skills]
	return [array names db]
}

#
proc db_gnome_skills_value {key index} {
	array set db [db_gnome_skills]
	return [lindex $db($key) $index]
}
