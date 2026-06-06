#
proc db_gnome_skills {} {
	array set db {
		QuickHarvest {1 Axt}
		MasterChef {2 GrillPilz}
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

#
proc db_gnome_skills_get_cost {key} {
	return [db_gnome_skills_value $key 0]
}

#
proc db_gnome_skills_get_icon {key} {
	return [db_gnome_skills_value $key 1]
}
