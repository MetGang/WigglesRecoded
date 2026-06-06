#
proc db_clans_race2key {idx} {
	return [lindex {Wiggles Voodoos Knockers Brains Vampire} $idx]
}

#
proc db_clans {} {
	array set db {
		Wiggles {
			{}
		}
		Voodoos {
			{{exp_Nahrung 1.3} {exp_Holz 1.1} {exp_Kampf 0.9}}
		}
		Knockers {
			{{exp_Stein 1.2} {exp_Metall 1.1}}
		}
		Brains {
			{{exp_Energie 1.2} {exp_Service 1.1}}
		}
		Vampire {
			{{exp_Kampf 1.2} {exp_Nahrung 0.8}}
		}
	}
	return [array get db]
}

#
proc db_clans_keys {} {
	array set db [db_clans]
	return [array names db]
}

#
proc db_clans_value {key index} {
	array set db [db_clans]
	return [lindex $db($key) $index]
}

#
proc db_clans_get_exp_factors {key} {
	return [db_clans_value $key 0]
}
