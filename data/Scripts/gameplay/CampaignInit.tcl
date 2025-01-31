# unique templates and story events definition:
call data/scripts/init/lgtools.tcl

set_diplomacy	0 1 neutral			;# Voodoos
set_diplomacy	1 0 neutral
set_diplomacy	0 2 neutral			;# Knockers
set_diplomacy	2 0 neutral
set_diplomacy	0 3 neutral			;# Brains
set_diplomacy	3 0 neutral
set_diplomacy	0 4 enemy			;# Vampyres
set_diplomacy	4 0 enemy
set_diplomacy	7 0 neutral         ;#Drache
set_diplomacy	0 7 neutral

set_ownerrace 	0 0
set_ownerrace	1 1
set_ownerrace	2 2
set_ownerrace	3 3
set_ownerrace	4 4

ai init 1 data/scripts/ai/std_ai.tcl
ai enable 1

ai init 2 data/scripts/ai/std_ai.tcl
ai enable 2

ai init 3 data/scripts/ai/std_ai.tcl
ai enable 3

ai init 4 data/scripts/ai/std_ai.tcl
ai enable 4

//sm_reset
sm_create_map 512 640

sm_set_digcount 32

// Musik
// marker - instant - both

// Musik Oberwelt
//adaptive_sound marker start { 241.5 30.5 10 }
//sm_music_theme start 		Trigger_Urw_006


// Musik Urwaldwelt
//adaptive_sound marker cave { 241.5 45.5 10 }
//sm_music_theme cave			Trigger_wusch marker
//sm_music_theme peacer 		Trigger_FirstContact
//sm_music_theme peacer 		Trigger_Voodoo_Lager marker
//sm_music_theme trolle 		Trigger_urw_unq_troll_005_Betreten
//sm_music_theme trolle 		Trigger_urw_unq_troll_005_Befreien marker
//sm_music_theme feen			Trigger_Urw_unq_feen_Start

// Musik Schwefelwelt
//sm_music_theme metall		Trigger_urw_unq_schwefel
//sm_music_theme titanic		Trigger_Swf_unq_titanic_pumpe
//sm_music_theme schwefelseen Trigger_swf_unq_drache_schlafen
//sm_music_theme knockers		Trigger_Swf_095
//sm_music_theme knockers		Trigger_Swf_118 marker

// Musik Kristallwelt
//sm_music_theme wigglesburg 	Trigger_Crystal_Burg_entdeckt
//sm_music_theme sirenen		Trigger_kri_140
//sm_music_theme kristallwelt Trigger_kri_144

// Musik Lavawelt
//sm_music_theme mauls		Trigger_lav_177




// Marker die nicht gel�scht werden k�nnen



// Templategruppen definitionen

sm_def_temp_group urw_kif_1 {
				{60	12	urw_gng_019_a}
				{72	0	urw_hol_018_c}
				{12	8	urw_unq_vodo_001_a}
				}

sm_def_temp_group urw_kif_2 {
				{56	12	urw_gng_019_a}
				{68	4	urw_hol_020_a}
				{12	4	urw_unq_vodo_001_a}
				}

sm_def_temp_group urw_kif_3 {
				{64	12	urw_gng_019_a}
				{48	12	urw_gng_013_a}
				{76	4	urw_hol_014_b}
				{28	12	urw_gng_021_a}
				{32	8	urw_hol_027_c}
				{12	20	urw_unq_vodo_001_a}
				{52	12	urw_gng_003_a}
				}

sm_def_temp_group urw_kif_4 {
				{64	8	urw_gng_019_a}
				{32	0	urw_hol_014_b}
				{28	12	urw_gng_021_a}
				{52	12	urw_gng_017_a}
				{76	4	urw_hol_027_a}
				{16	24	urw_unq_vodo_001_a}
				}

sm_def_temp_group urw_der_einsiedler {
				{64	24	urw_gng_019_b}
				{8	16	urw_unq_einsiedler}
				{92	16	urw_unq_raetsel_001}
				{76	32	urw_gng_018_a}
				{68	24	urw_gng_044_a}
				{80	32	urw_gng_003_a}
				}

sm_def_temp_group urw_trollburg_ring {
				{56	20	urw_gng_015_b}
				{60	4	urw_unq_troll_005_a}
				{4	8	urw_unq_troll_001_a}
				{56	24	urw_gng_020_a}
				{48	24	urw_gng_002_a}
				{36	16	urw_gng_025_b}
				{mat {0 60 24 4 8} }
				}

sm_def_temp_group swf_troll_wasser_raetzel {
				{136	52	swf_gng_034_c}
				{168	48	swf_unq_troll_002_a}
				{104	24	swf_gsg_001_a}
				{88	40	swf_unq_troll_013_a}
				{80	48	swf_gng_002_a}
				{76	48	swf_gng_018_a}
				{60	44	swf_gsg_001_a}
				{72	32	swf_gng_035_b}
				{84	32	swf_gng_042_a}
				{76	44	swf_gng_017_a}
				{56	44	swf_gng_019_a}
				{56	36	swf_gng_045_a}
				{68	36	swf_gng_020_b}
				{68	32	swf_gng_013_b}
				{64	32	swf_gng_021_b}
				{20	28	unq_wasser_001}
				{92	24	swf_gng_045_a}
				{112	48	swf_gng_022_d}
				{mat {0 4 28 4 36} {0 4 64 112 4} {0 116 28 4 40} }
				}

sm_def_temp_group urw_uebergang_swf {
									{28 	4 	urw_unq_metalltor}
									{32 	28 	swf_unq_start}
									{84 	32 	swf_unq_start2}
									{140 	44 	swf_gng_022_c}
									}

sm_def_temp_group swf_ei {
				{44	16	swf_gng_017_a}
				{8	8	swf_unq_ei_001}
				{60	16	swf_unq_troll_010_a}
				}

sm_def_temp_group swf_unq_titanic {
                    				{268	224	swf_gng_017_b}
                    				{152	240	swf_unq_drache}
                    				{184	228	swf_unq_tit_bug}
                    				{332	228	swf_unq_tit_heck}
                    				{308	236	swf_unq_tit_kabin}
                    				{236	228	swf_unq_tit_masch}
                    				{280	236	swf_unq_tit_treppe}
                    				{172	264	swf_unq_troll_003_a}
                    				{160	264	swf_gng_028_a}
                    				{160	276	swf_gng_043_a}
                    				{mat {0 148 240 12 16} {0 148 256 8 40} {0 156 256 4 4} {0 156 260 48 36} {0 204 256 16 40} }
                    				}


sm_def_temp_group urw_unq_voodoo_dorf {
                    				{108 40	urw_unq_vodo_003_a}
                    				{72	32	urw_unq_vodo_002_a}
                    				{68	32	urw_unq_vodo_008_a}
                    				{36	32	urw_unq_vodo_004_a}
                    				{44	52	urw_unq_vodo_007_a}
                    				{72	52	urw_unq_vodo_005_a}
                    				{92	52	urw_unq_vodo_006_a}
									{mat {0 28 24 80 8} {0 28 32 8 28} {0 36 52 8 4} {0 36 56 4 16} {0 48 64 20 8} {0 60 72 28 8} {0 92 72 16 8} {0 108 24 8 16} {0 108 48 8 32} }
                    				}

sm_def_temp_group swf_unq_lore {
				{44		24	swf_gng_018_a}
				{156	32	swf_unq_lore_001}
				{156	60	swf_unq_lore_003}
				{188	88	swf_unq_lore_002}
				{156	108	swf_unq_lore_004}
				{112	76	swf_unq_knk_001_a}
				{76		60	swf_unq_knk_002_a}
				{100	36	swf_unq_knk_003_a}
				{112	56	swf_unq_knk_004_a}
				{64		36	swf_unq_knk_004_b}
				{100	56	swf_gng_002_a}
				{56		48	swf_gng_002_b}
				{80		56	swf_gng_004_a}
				{96		52	swf_gng_007_a}
				{108	60	swf_gng_008_a}
				{108	76	swf_gng_009_a}
				{52		36	swf_gng_009_b}
				{96		48	swf_gng_013_a}
				{108	56	swf_gng_014_a}
				{144	68	swf_gng_014_b}
				{108	68	swf_gng_015_a}
				{108	72	swf_gng_017_a}
				{108	88	swf_gng_018_a}
				{52		48	swf_gng_018_b}
				{96		56	swf_gng_019_a}
				{76		56	swf_gng_021_a}
				{32		72	swf_gng_021_b}
				{124	120	swf_gng_021_c}
				{140	104	swf_gng_027_a}
				{144	72	swf_gng_027_b}
				{144	84	swf_gng_032_a}
				{144	116	swf_gng_034_a}
				{48		24	swf_gng_035_a}
				{140	96	swf_gng_045_a}
				{128	120	swf_unq_knk_tuer}
				{60		28	swf_gng_022_e}
				{156	96	swf_gsg_001_a}
				{184	96	swf_gng_022_a}
				{152	96	swf_gng_019_a}
				{172	96	swf_gng_003_b}
				{36		72	swf_unq_knk_tuer}
				{60		72	swf_gng_004_a}
				{52		72	swf_gng_002_b}
				{mat {0 40 24 4 4} {0 40 28 8 8} {0 40 36 12 16} {0 40 52 8 20} {0 40 76 8 44} {0 48 52 16 4} {0 48 112 92 8} {0 56 36 8 12} {0 60 24 196 4} {0 60 32 96 4} {0 64 28 184 4}
				{0 128 124 8 12} {0 136 124 4 4} {0 136 128 112 8} {0 248 28 8 108} }
				}

sm_def_temp_group swf_uebergang_kris {
	                    			{0 		0 	swf_unq_bruecke}
	                    			{76 	32 	kris_unq_start}
	                    			}

sm_def_temp_group kris_sandburg_trollburg {
                    				{244	0	kris_unq_trollburg_mittel}
                    				{0		0	kris_unq_altesandburg}
                    				{312	0	kris_unq_trollburg}
                    				{76		68	kris_unq_gallery}
                    				}

sm_def_temp_group kris_lorelei 	{
                    				{176	0	kris_gng_009_a}
                    				{172	84	kris_unq_brains_001_a}
                    				{220	84	kris_unq_brains_002_a}
                    				{252	144	kris_unq_brains_003_a}
                    				{220	100	kris_unq_brains_004_a}
                    				{228	120	kris_unq_brains_005_a}
                    				{192	120	kris_unq_brains_006_a}
                    				{136	120	kris_unq_brains_007_a}
                    				{244	84	kris_unq_brains_008_a}
                    				{252	104	kris_unq_brains_009_a}
                    				{252	124	kris_unq_brains_010_a}
                    				{220	144	kris_unq_brains_011_a}
                    				{252	100	kris_unq_brains_012_a}
                    				{276	100	leer1x1}
                    				{272	84	leer2x2}
                    				{292	84	leer3x3}
                    				{148	108	leer3x3}
                    				{160	108	leer3x3}
                    				{280	96	leer3x3}
                    				{292	108	leer3x3}
                    				{280	108	leer3x3}
                    				{292	120	leer3x3}
                    				{280	120	leer3x3}
                    				{292	132	leer3x3}
                    				{280	132	leer3x3}
                    				{292	144	leer3x3}
                    				{280	144	leer3x3}
                    				{272	92	leer2x2}
                    				{272	104	leer2x2}
                    				{272	112	leer2x2}
                    				{272	120	leer2x2}
                    				{272	128	leer2x2}
                    				{252	136	leer1x1}
                    				{160	96	leer3x3}
                    				{160	84	leer3x3}
                    				{148	84	leer3x3}
                    				{148	96	leer3x3}
                    				{136	108	leer3x3}
                    				{136	96	leer3x3}
                    				{136	84	leer3x3}
                    				{280	84	leer3x3}
                    				{292	96	leer3x3}
                    				{0		180	kris_unq_lorelei_001_a}
                    				{8		180	kris_unq_lorelei_002_a}
                    				{56		152	kris_unq_lorelei_003_a}
                    				{68		132	kris_unq_lorelei_004_a}
                    				{96		124	kris_gng_001_a}
                    				{124	128	kris_gng_002_a}
                    				{84		128	kris_gng_002_b}
                    				{156	164	kris_gng_003_a}
                    				{192	180	kris_gng_003_b}
                    				{176	168	kris_gng_008_a}
                    				{132	132	kris_gng_009_a}
                    				{104	108	kris_gng_009_b}
                    				{172	156	kris_gng_012_a}
                    				{92		124	kris_gng_012_b}
                    				{176	164	kris_gng_014_a}
                    				{132	128	kris_gng_014_b}
                    				{96		128	kris_gng_014_c}
                    				{172	164	kris_gng_015_a}
                    				{168	160	kris_gng_016_a}
                    				{136	156	kris_gng_017_a}
                    				{172	160	kris_gng_017_b}
                    				{176	176	kris_gng_018_a}
                    				{92		128	kris_gng_019_a}
                    				{168	164	kris_gng_020_a}
                    				{132	156	kris_gng_021_a}
                    				{132	176	kris_gng_021_b}
                    				{152	164	kris_gng_021_c}
                    				{148	168	kris_gng_022_b}
                    				{100	92	kris_gng_024_a}
                    				{148	180	kris_gng_025_a}
                    				{160	180	kris_gng_030_a}
                    				{112	120	kris_gng_030_b}
                    				{136	172	kris_gng_034_a}
                    				{180	172	kris_gng_034_b}
                    				{100	120	kris_gng_034_c}
                    				{132	144	kris_gng_036_a}
                    				{136	160	kris_gng_036_b}
                    				{112	108	kris_gng_036_c}
                    				{164	168	kris_gng_039_a}
                    				{160	152	kris_gng_044_b}
                    				{144	152	kris_gsg_001_a}
                    				{124	116	kris_gng_022_b}
                    				{80		128	kris_gng_021_a}
                    				{100	96	kris_gng_036_c}
                    				{112	104	kris_gng_014_b}
                    				{68		120	leer3x3}
                    				{80		116	leer3x3}
                    				{92		108	leer3x3}
                    				{124	104	leer3x3}
                    				{172	188	kris_gng_022_b}
                    				{100	60	kris_gng_001_a}
                    				{128	68	kris_gng_001_b}
                    				{108	56	kris_gng_003_a}
                    				{92		64	kris_gng_004_a}
                    				{104	52	kris_gng_007_a}
                    				{24		92	kris_gng_008_a}
                    				{180	48	kris_gng_008_c}
                    				{200	36	kris_gng_009_b}
                    				{20		100	kris_gng_012_a}
                    				{184	52	kris_gng_012_b}
                    				{108	60	kris_gng_014_a}
                    				{104	56	kris_gng_015_a}
                    				{188	52	kris_gng_016_a}
                    				{208	28	kris_gng_016_b}
                    				{180	44	kris_gng_017_b}
                    				{184	56	kris_gng_017_c}
                    				{24		100	kris_gng_019_a}
                    				{104	60	kris_gng_019_b}
                    				{180	56	kris_gng_019_c}
                    				{108	64	kris_gng_020_a}
                    				{92		96	kris_gng_022_b}
                    				{28		92	kris_gng_026_a}
                    				{132	60	kris_gng_026_b}
                    				{156	52	kris_gng_026_c}
                    				{56		132	kris_gng_027_a}
                    				{44		148	kris_gng_029_a}
                    				{80		76	kris_gng_029_b}
                    				{144	52	kris_gng_030_a}
                    				{172	12	kris_gng_030_c}
                    				{48		120	kris_gng_032_a}
                    				{192	48	kris_gng_032_b}
                    				{116	64	kris_gng_033_a}
                    				{144	40	kris_gng_033_b}
                    				{44		160	kris_gng_034_a}
                    				{44		104	kris_gng_034_b}
                    				{80		88	kris_gng_034_c}
                    				{168	52	kris_gng_035_a}
                    				{196	24	kris_gng_035_b}
                    				{20		104	kris_gng_036_a}
                    				{32		108	kris_gng_037_a}
                    				{68		68	kris_gng_037_b}
                    				{80		60	kris_gng_038_c}
                    				{56		108	kris_gng_039_a}
                    				{120	52	kris_gng_039_b}
                    				{56		144	kris_gng_042_a}
                    				{156	32	kris_hol_012_a}
                    				{40		80	kris_hol_038_a}
                    				{184	16	kris_gng_034_c}
                    				{196	60	kris_gng_034_a}
                    				{172	72	leer3x3}
                    				{184	72	leer3x3}
                    				{196	72	leer3x3}
                    				{208	72	leer3x3}
                    				{160	72	leer3x3}
                    				{220	72	leer3x3}
                    				{232	72	leer3x3}
                    				{244	72	leer3x3}
                    				}


sm_def_temp_group lava_vampy_siedlung {
				{12	8	lava_unq_vampy_001}
				{92	8	lava_unq_vampy_002}
				{52	116	lava_unq_vampy_003}
				{48	88	lava_unq_vampy_004}
				{32	140	lava_unq_vampy_005}
				{92	120	lava_unq_vampy_006}
				{76	76	lava_gng_010_a}
				{76	104	lava_gng_010_b}
				{76	136	lava_gng_010_c}
				{76	92	lava_gng_008_a}
				{76	124	lava_gng_008_b}
				{76	100	lava_gng_017_a}
				{76	120	lava_gng_017_b}
				{76	152	lava_gng_020_c}
				{76	132	lava_gng_015_b}
				{80	132	lava_gng_003_a}
				{60	152	lava_gng_004_a}
				{4	100	lava_gng_021_a}
				{12	152	lava_gng_021_b}
				{144	168	lava_gng_022_a}
				{16	152	lava_unq_vampy_tuer}
				{144	152	lava_unq_vampy_tuer}
				{8	100	lava_unq_vampy_tuer}
				{24	100	lava_gng_003_a}
				{36	100	lava_gng_003_a}
				{148	132	lava_gng_025_a}
				{160	148	lava_gng_042_a}
				{160	140	lava_gng_044_a}
				{140	152	lava_gng_012_a}
				{140	156	lava_gng_009_b}
				{140	168	lava_gng_018_a}
				{mat {0 12 76 64 8} {0 12 84 8 16} {0 12 104 8 44} {0 20 84 56 4} {0 20 140 12 12} {0 20 156 12 8} {0 20 164 116 8} {0 128 144 28 8} {0 128 152 8 12} {0 148 156 8 12} {0 156 160 24 8}
				{0 160 84 8 44} {0 168 120 12 8} {0 172 128 8 32} }
				}


sm_def_temp_group kris_sirene {
				{148	4	kris_gng_009_a}
				{108	4	kris_unq_sirene_001}
				{148	16	kris_gng_020_a}
				{104	32	kris_gng_022_b}
				{80	32	kris_gng_026_b}
				{92	24	kris_gng_030_a}
				{64	40	kris_unq_sirene_002}
				{96	16	kris_gng_045_b}
				{60	40	kris_gng_021_a}
				{mat {0 60 36 16 4} {0 64 44 44 4} {0 76 28 16 4} {0 76 32 4 8} {0 88 12 8 12} {0 88 24 4 4} {0 92 36 16 8} {0 96 12 12 4} {0 104 4 4 8} {0 104 24 52 8} {0 108 32 8 8}
				{0 148 20 20 4} {0 152 4 16 16} }
				}

sm_def_temp_group kris_brains {
				{268	16	kris_unq_brains_003_a}
				{244	28	kris_unq_brains_002_a}
				{244	48	kris_unq_brains_004_a}
				{288	28	kris_unq_brains_005_a}
				{292	76	kris_unq_brains_006_a}
				{224	76	kris_unq_brains_007_a}
				{320	44	kris_unq_brains_008_a}
				{336	76	kris_unq_brains_009_a}
				{284	56	kris_unq_brains_010_a}
				{332	68	kris_unq_brains_012_a}
				{288	92	kris_gng_001_a}
				{268	72	kris_gng_001_c}
				{268	32	kris_gng_001_b}
				{276	64	kris_gng_002_a}
				{312	48	kris_gng_002_b}
				{328	88	kris_gng_002_a}
				{280	32	kris_gng_002_b}
				{324	60	kris_gng_007_a}
				{272	68	kris_gng_007_b}
				{272	36	kris_gng_007_a}
				{248	44	kris_gng_007_b}
				{272	40	kris_gng_008_a}
				{284	76	kris_gng_010_a}
				{272	32	kris_gng_013_a}
				{264	72	kris_gng_013_b}
				{284	72	kris_gng_014_a}
				{284	92	kris_gng_019_a}
				{276	32	kris_gng_019_b}
				{320	100	kris_gng_021_a}
				{328	100	kris_gng_022_a}
				{328	80	kris_gng_022_a}
				{312	32	kris_gng_026_a}
				{320	64	kris_gng_033_a}
				{248	68	kris_gng_043_b}
				{276	40	kris_gng_026_a}
				{316	68	kris_gng_021_a}
				{280	92	kris_gng_001_a}
				{240	60	kris_gng_021_a}
				{260	72	kris_gng_001_b}
				{272	72	kris_gng_019_a}
				{276	72	kris_gng_002_b}
				{324	100	kris_gng_019_a}
				{mat {0 224 100 112 4} {0 240 44 8 16} {0 240 64 8 12} {0 260 68 16 8} {0 260 88 4 4} {0 268 28 20 16} {0 268 44 8 4} {0 276 44 12 8} {0 276 52 44 8} {0 276 60 8 16} {0 280 76 12 24}
				{0 312 44 8 8} {0 316 104 20 4} {0 328 60 16 16} {0 328 76 8 24} {0 336 96 20 4} }
				}

sm_def_temp_group kris_brainsA {
				{272	16	kris_unq_brains_003_a}
				{244	28	kris_unq_brains_002_a}
				{244	48	kris_unq_brains_004_a}
				{288	28	kris_unq_brains_005_a}
				{292	76	kris_unq_brains_006_a}
				{224	76	kris_unq_brains_007_a}
				{320	44	kris_unq_brains_008_a}
				{336	76	kris_unq_brains_009_a}
				{284	56	kris_unq_brains_010_a}
				{332	68	kris_unq_brains_012_a}
				{288	92	kris_gng_001_a}
				{268	72	kris_gng_001_c}
				{268	32	kris_gng_001_b}
				{276	64	kris_gng_002_a}
				{312	48	kris_gng_002_b}
				{328	88	kris_gng_002_a}
				{324	60	kris_gng_007_a}
				{272	68	kris_gng_007_b}
				{272	36	kris_gng_007_a}
				{248	44	kris_gng_007_b}
				{272	40	kris_gng_008_a}
				{284	76	kris_gng_010_a}
				{272	32	kris_gng_013_a}
				{264	72	kris_gng_013_b}
				{284	72	kris_gng_014_a}
				{284	92	kris_gng_019_a}
				{280	32	kris_gng_019_b}
				{320	100	kris_gng_021_a}
				{328	100	kris_gng_022_a}
				{328	80	kris_gng_022_a}
				{312	32	kris_gng_026_a}
				{320	64	kris_gng_033_a}
				{248	68	kris_gng_043_b}
				{276	40	kris_gng_026_a}
				{316	68	kris_gng_021_a}
				{280	92	kris_gng_001_a}
				{240	60	kris_gng_021_a}
				{260	72	kris_gng_001_b}
				{272	72	kris_gng_019_a}
				{276	72	kris_gng_002_b}
				{324	100	kris_gng_019_a}
				{284	32	kris_gng_001_c}
				{276	32	kris_gng_001_a}
				{mat {0 224 100 112 8} {0 240 44 8 16} {0 240 64 8 12} {0 260 68 16 8} {0 260 88 4 4} {0 268 28 20 16} {0 268 44 8 4} {0 276 44 12 8} {0 276 52 44 8} {0 276 60 8 16} {0 280 76 12 24}
				{0 312 44 8 8} {0 328 60 16 16} {0 328 76 8 24} {0 336 96 20 12} }
				}

sm_def_temp_group kris_uebergang {
				{92	80	kris_unq_lorelei_004_a}
				{24	128	kris_unq_lorelei_001_a}
				{32	128	kris_unq_lorelei_002_a}
				{80	100	kris_unq_lorelei_003_a}
				{80	80	kris_gng_027_a}
				{68	96	kris_gng_029_a}
				{68	108	kris_gng_034_a}
				{80	92	kris_gng_042_a}
				{4	184	lava_unq_start}
				{56	96	kris_gng_045_c}
				{56	104	kris_gng_018_c}
				{60	104	kris_gng_014_c}
				{60	108	kris_gng_007_b}
				{60	112	lava_gng_018_a}
				{64	112	kris_gng_001_b}
				{28	180	kris_gng_024_a}
				}

sm_def_temp_group kris_wasser_raetzel {
				{28	20	kris_gng_013_a}
				{32	16	kris_unq_060}
				{28	32	kris_unq_061}
				{28	24	kris_gng_008_c}
				}

sm_def_temp_group lava_troll_lost {
				{36	24	lava_gng_037_b}
				{12	20	lava_unq_troll_013_a}
				{76	20	lava_unq_lostvegos}
				}

sm_def_temp_group lava_drachenmama {
				{20	16	lava_unq_drachenmama}
				{60	32	lava_gng_008_a}
				{16	32	lava_gng_021_a}
				{mat {0 12 28 8 4} {0 12 32 4 4} {0 12 36 8 4} {0 16 24 4 4} {0 16 40 4 4} }
				}
// Story Events

sm_add_event Voodoo_Hoehle_entdeckt		Trigger_FirstContact
sm_add_event Einsiedler_entdeckt		Trigger_Einsiedler_1
sm_add_event Einsiedler_Karte_erhalten	Trigger_Einsiedler_2 "shut"
sm_add_event Trollburg_entdeckt			Trigger_urw_unq_troll_005_Betreten
sm_add_event Torwaechterin_befreit		Trigger_urw_unq_troll_005_Befreien
sm_add_event Ring_Der_Natur_erhalten    Trigger_RingCheck "RdL"
sm_add_event Torwaechterin_zurueck		Trigger_Urw_040
sm_add_event Drache_Auftrag_erhalten	Trigger_swf_unq_drache_auftrag
sm_add_event Drache_angeriffen
sm_add_event Drachenbaby_tot
sm_add_event Voodoos_angegriffen
sm_add_event Lorenbahn_geloest
sm_add_event Drache_tot
sm_add_event Drache_Auftrag_efuellt		Trigger_swf_unq_drache_graben "shut"
sm_add_event Titanic_Pumpe_aktiviert    Trigger_Swf_unq_titanic_pumpe

sm_add_event MetallTor_geoeffnet		Trigger_urw_unq_metalltor_oeffnen "shut"
sm_add_event Uebergang_Urw_Met
sm_add_event Uebergang_Met_Kris
sm_add_event Uebergang_Kris_Lava
sm_add_event Uebergang_Lava_Ende

sm_add_event Brains_Disko_aufgebaut
sm_add_event Brains_Ring_gestohlen
sm_add_event Brains_Maschine_abgeschaltet
sm_add_event Lorelei_zerstoert

sm_add_event Fenris_besiegt
sm_add_event Fenris_vergiftet

catch { sm_add_event GameOverCheck }


// Story Events f�r Questlog

sm_add_event QL_Find_Six_Rings
sm_add_event QL_Find_Six_Rings_done

sm_add_event QL_Free_Gatekeeper
sm_add_event QL_Free_Gatekeeper_done

sm_add_event QL_Bring_Hamsters
sm_add_event QL_Bring_Hamsters_done

sm_add_event QL_Save_the_Fairys
sm_add_event QL_Save_the_Fairys_done

sm_add_event QL_Find_Ring_of_Life
sm_add_event QL_Find_Ring_of_Life_done

sm_add_event QL_Open_Gate
sm_add_event QL_Open_Gate_done

sm_add_event QL_Gate_Closing
sm_add_event QL_Gate_Closing_done

sm_add_event QL_Dragon_Cave
sm_add_event QL_Dragon_Cave_done

sm_add_event QL_Dragon_Egg
sm_add_event QL_Dragon_Egg_done

sm_add_event QL_Brigde_1
sm_add_event QL_Brigde_1_done

sm_add_event QL_Brigde_2
sm_add_event QL_Brigde_2_done

sm_add_event QL_Bridge_closing
sm_add_event QL_Bridge_closing_done

sm_add_event QL_Free_males
sm_add_event QL_Free_males_done

sm_add_event QL_Cave_Closing
sm_add_event QL_Cave_Closing_done

sm_add_event QL_Forge_Gleipnir
sm_add_event QL_Forge_Gleipnir_done

sm_add_event QL_Catch_Fenris
sm_add_event QL_Catch_Fenris_done


// Kampagnen Definition

sm_add_zone "Urwald"

sm_add_temp urw_unq_start
//sm_add_temp urw_kif_1				16	82		-connect {{0 2 1 0} {0 1 2 0}}
//sm_add_temp urw_kif_2				16	82		-connect {{0 2 1 0} {0 1 2 0}}
//sm_add_temp urw_kif_3				16	82		-connect {{1 0 5 0} {0 2 2 0}}
//sm_add_temp urw_kif_4				16	82		-connect {{0 2 4 0} {0 1 3 0} {3 1 5 0}}

//sm_add_temp urw_der_einsiedler		0 0
sm_add_temp urw_der_einsiedler		56	60
sm_add_temp urw_unq_voodoo_dorf		60	110     -digconnect 0 1
sm_add_temp urw_unq_feen			60  160     -nonrelevant 0.4740217 -middist 10
sm_add_temp urw_unq_troll_012_a		60	88	    -nonrelevant 0.3 -digconnect 0 1
sm_add_temp urw_unq_troll_014_a     60	88      -nonrelevant 0.3 -digconnect 0 1

sm_add_temp urw_trollburg_ring		88  128 	-mindist urw_der_einsiedler 0.1
//sm_add_temp urw_unq_troll_001_a		128 132		-mindist urw_unq_troll_005_a 0.1
sm_add_temp urw_uebergang_swf		132	164 	-mindist urw_trollburg_ring 0.1 -exclusive 1 -zoneborder "Urwald" -stoneidx 0



sm_add_zone "Metall"
sm_add_temp swf_unq_lore			0	32
sm_add_temp swf_troll_wasser_raetzel 32	64		-connect {{0 2 1 0}};# {0 1 2 0}}
sm_add_temp swf_unq_titanic			64	128     -connect {{0 2 1 0}} -mindist swf_unq_lore 0.1 -checkalign 0 -exclusive 1 -stoneidx 1
sm_add_temp swf_ei					100 164     -mindist swf_unq_titanic 0.1 -connect {{0 1 2 0}}
sm_add_temp swf_uebergang_kris		160 196		-mindist swf_ei 0.1 -exclusive 1 -zoneborder "Metall" -stoneidx 0



sm_add_zone "Kristall"
sm_add_temp kris_sandburg_trollburg 0	16		-checkalign 0
sm_add_temp kris_wasser_raetzel		64	208		-digconnect 0 1 -nonrelevant 0.3730216 -middist 50
sm_add_temp kris_unq_raetsel_002	64	208		-digconnect 0 1 -nonrelevant 0.3730216 -middist 50
sm_add_temp kris_sirene 			32	64		-exclusive 1 -stoneidx 0 -mindist kris_sandburg_trollburg 0.1
sm_add_temp kris_brainsA			64	128		-mindist kris_sirene 0.1 -checkalign 0
sm_add_temp kris_uebergang			124 142		-mindist kris_brainsA 0.1 -exclusive 1 -zoneborder "Kristall" -stoneidx 1

sm_add_zone "Lava"
sm_add_temp unq_wasser_003     		16	48	 	-nonrelevant 0.25 -middist 10
sm_add_temp lava_unq_troll_006_a	16	48 		-nonrelevant 0.25 -middist 10
sm_add_temp lava_unq_troll_004		32	64		-nonrelevant 0.25 -middist 10
sm_add_temp lava_troll_lost			32	64		-nonrelevant 0.25 -connect {{0 2 2 0}} -digconnect 0 1
sm_add_temp lava_drachenmama    	0	32      -digconnect 0 1

sm_add_temp lava_unq_4thring		16	48		-mindist lava_drachenmama 0.1
sm_add_temp lava_vampy_siedlung     32	64	    -mindist lava_unq_4thring 0.1 -digconnect 0 1
sm_add_temp lava_unq_fenris			64 128		-mindist lava_vampy_siedlung 0.1 -checkalign 0

// Newsticker Meldungen

//{{KFX_MSG_MAP(CStoryMgr)

// Syntax:
// {{ <Triggername> [triggermessage]}  {<newtickercommand> <newticker text nr> [story event] [liste von events, die nicht gesetz sein d�rfen]}

lappend newslist {{dig}	{dig dig}}		;# Dig Messages

lappend newslist {{Trigger_Urw_006}							{new 006 QL_Find_Six_Rings}}

lappend newslist {{Trigger_FirstContact} 					{new 007 QL_Free_Gatekeeper}}
lappend newslist {{Trigger_urw_unq_troll_005_Befreien} 		{ful 007 QL_Free_Gatekeeper_done}}

lappend newslist {{Trigger_Einsiedler_1} 					{new 020 QL_Bring_Hamsters}}
lappend newslist {{Trigger_Einsiedler_2  "activate"}		{upd 020}}
lappend newslist {{Trigger_Einsiedler_2} 					{ful 020 QL_Bring_Hamsters_done}}
lappend newslist {{Trigger_urw_unq_troll_005_Befreien}		{del 020}}

lappend newslist {{Trigger_Urw_unq_feen_Start} 				{new 008 QL_Save_the_Fairys}}
lappend newslist {{Trigger_Urw_unq_feen_End} 				{ful 008 QL_Save_the_Fairys_done}}

lappend newslist {{Trigger_urw_unq_troll_005_Befreien}		{new 025 QL_Find_Ring_of_Life {QL_Find_Ring_of_Life_done}}}
lappend newslist {{Trigger_RingCheck "RdL"}					{ful 025 QL_Find_Ring_of_Life_done}}

lappend newslist {{Trigger_urw_unq_troll_005_Befreien}		{new 026 QL_Open_Gate}}
lappend newslist {{Trigger_urw_unq_metalltor_oeffnen}		{ful 026 QL_Open_Gate_done}}

lappend newslist {{Trigger_urw_unq_metalltor_oeffnen}		{spec Ueber_0}}
lappend newslist {{Trigger_urw_unq_metalltor_oeffnen}		{new 040 QL_Gate_Closing}}
lappend newslist {{Trigger_urw_040_c}						{ful 040 QL_Gate_Closing_done}}

lappend newslist {{Trigger_swf_unq_drache_auftrag}			{new 085 QL_Dragon_Cave {Drache_angegriffen}}}
lappend newslist {{Trigger_swf_unq_drache_graben "kill"} 	{del 085 QL_Dragon_Cave_done}}
lappend newslist {{Trigger_swf_unq_drache_graben}			{ful 085 QL_Dragon_Cave_done}}

lappend newslist {{Trigger_Swf_116}							{new 116 QL_Dragon_Egg {Drache_angegriffen}}}

lappend newslist {{Trigger_Swf_unq_bruecke "Pilzstaemme"} 	{new 701 QL_Brigde_1}}
lappend newslist {{Trigger_Swf_unq_bruecke "Eisen"} 		{new 702 QL_Brigde_2}}
lappend newslist {{Trigger_Swf_unq_bruecke "Eisen"} 		{ful 701 QL_Brigde_1_done}}
lappend newslist {{Trigger_Swf_unq_bruecke "Umzug"} 		{new 703 QL_Bridge_closing}}
lappend newslist {{Trigger_Swf_unq_bruecke}					{spec Ueber_1}}
lappend newslist {{Trigger_Swf_unq_bruecke "Umzug"} 		{ful 702 QL_Brigde_2_done}}
lappend newslist {{Trigger_swf_704_Bruecke_Einsturz} 		{ful 703 QL_Bridge_closing_done}}

lappend newslist {{Trigger_Lava_175_220_Drachenbaby}		{ful 116 QL_Dragon_Egg_done}}

lappend newslist {{Trigger_Crystal_Lorelei_Entfuehrung} 	{new 140 QL_Free_males}}
lappend newslist {{Trigger_Crystal_Lorelei_Vernichtung} 	{del 140 QL_Free_males_done}}
lappend newslist {{Trigger_Crystal_Lorelei_Vernichtung} 	{new 144 QL_Cave_Closing}}
lappend newslist {{Trigger_Crystal_Lorelei_Vernichtung}		{spec Ueber_2}}
lappend newslist {{Trigger_Crystal_160_Hol_Einsturz}		{ful 144 QL_Cave_Closing_done}}

lappend newslist {{Trigger_Lava_300_Feuerring}				{ful 006 QL_Find_Six_Rings_done}}
lappend newslist {{Trigger_Lava_300_Feuerring}				{new 300 QL_Forge_Gleipnir}}

lappend newslist {{Trigger_Lava_Amboss_200} 				{ful 300 QL_Forge_Gleipnir_done}}
lappend newslist {{Trigger_Lava_Amboss_200} 				{new 200 QL_Catch_Fenris}}

lappend newslist {{Trigger_Lava_400a}						{ful 200 QL_Catch_Fenris_done}}
lappend newslist {{Trigger_Lava_400b}						{ful 200 QL_Catch_Fenris_done}}
lappend newslist {{Dimensionstor "alleweg"}					{spec Ueber_3}}


//}}KFX_MSG_MAP
