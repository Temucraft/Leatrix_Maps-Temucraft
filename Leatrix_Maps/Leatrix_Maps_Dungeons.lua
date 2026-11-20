	----------------------------------------------------------------------
	-- Leatrix Maps dungeon maps (from Leatrix Maps 1.15.166, for the 3.3.5 map)
	----------------------------------------------------------------------

	-- The 3.3.5 client has no maps for these dungeons and raids; the pictures come with the addon
	-- (Leatrix_Maps_Dungeon_01 to 03 and Leatrix_Maps_Dungeon_Scholomance). Needs !TemucraftCompat (menus, C_Map).

	local void, Leatrix_Maps = ...

	function Leatrix_Maps.SetupDungeonMaps(LeaMapsLC, LeaMapsCB, L)

		local headerMenus = {} -- (1.15 keeps its map footer here; the 3.3.5 map has none)
		local areaAtOpen -- the map area shown when the map was opened (the player's zone)
		local mapEvents = CreateFrame("Frame")
		mapEvents:RegisterEvent("WORLD_MAP_UPDATE")

		-- 3.3.5 GetInstanceInfo has no instance map ID: find it from the instance name
		local instanceByName
		local function InstanceMapID()
			local name, kind = GetInstanceInfo()
			if kind ~= "party" and kind ~= "raid" then return nil end
			return instanceByName and (instanceByName[name] or instanceByName[GetRealZoneText()])
		end

		do

			-- Map art: [instance map ID] = {{map ID, level name, game map texture}, ...}
			-- Scholomance is not in the game in its classic layout so it uses {map ID, level name, nil, x, y} in Leatrix_Maps_Dungeon_Scholomance (2048x2048, maps are 1024x683)
			local dungeonArt = {
				[389] = {{213, nil, "Ragefire\\Ragefire1_"}}, -- Ragefire Chasm
				[36] = {{291, nil, "TheDeadmines\\TheDeadmines1_"}, {292, L["Ironclad Cove"], "TheDeadmines\\TheDeadmines2_"}}, -- The Deadmines
				[43] = {{279, nil, "WailingCaverns\\WailingCaverns1_"}}, -- Wailing Caverns
				[33] = {{310, L["The Courtyard"], "ShadowfangKeep\\ShadowfangKeep1_"}, {311, L["Dining Hall"], "ShadowfangKeep\\ShadowfangKeep2_"}, {312, L["The Vacant Den"], "ShadowfangKeep\\ShadowfangKeep3_"}, {313, L["Lower Observatory"], "ShadowfangKeep\\ShadowfangKeep4_"}, {314, L["Upper Observatory"], "ShadowfangKeep\\ShadowfangKeep5_"}, {316, L["The Wall Walk"], "ShadowfangKeep\\ShadowfangKeep7_"}, {315, L["Lord Godfrey's Chamber"], "ShadowfangKeep\\ShadowfangKeep6_"}}, -- Shadowfang Keep
				[34] = {{225, nil, "TheStockade\\TheStockade1_"}}, -- The Stockade
				[48] = {{221, L["The Pool of Ask'Ar"], "BlackFathomDeeps\\BlackFathomDeeps1_"}, {222, L["Moonshrine Sanctum"], "BlackFathomDeeps\\BlackFathomDeeps2_"}, {223, L["The Forgotten Pool"], "BlackFathomDeeps\\BlackFathomDeeps3_"}}, -- Blackfathom Deeps
				[90] = {{226, L["The Hall of Gears"], "Gnomeregan\\Gnomeregan1_"}, {227, L["The Dormitory"], "Gnomeregan\\Gnomeregan2_"}, {228, L["Launch Bay"], "Gnomeregan\\Gnomeregan3_"}, {229, L["Tinkers' Court"], "Gnomeregan\\Gnomeregan4_"}}, -- Gnomeregan
				[47] = {{301, nil, "RazorfenKraul\\RazorfenKraul1_"}}, -- Razorfen Kraul
				[189] = {{302, L["Graveyard"], "ScarletMonastery\\ScarletMonastery1_"}, {303, L["Library"], "ScarletMonastery\\ScarletMonastery2_"}, {304, L["Armory"], "ScarletMonastery\\ScarletMonastery3_"}, {305, L["Cathedral"], "ScarletMonastery\\ScarletMonastery4_"}}, -- Scarlet Monastery
				[129] = {{300, nil, "RazorfenDowns\\RazorfenDowns1_"}}, -- Razorfen Downs
				[70] = {{230, L["Hall of the Keepers"], "Uldaman\\Uldaman1_"}, {231, L["Khaz'Goroth's Seat"], "Uldaman\\Uldaman2_"}}, -- Uldaman
				[209] = {{219, nil, "ZulFarrak\\ZulFarrak"}}, -- Zul'Farrak
				[349] = {{280, L["Caverns of Maraudon"], "Maraudon\\Maraudon1_"}, {281, L["Zaetar's Grave"], "Maraudon\\Maraudon2_"}}, -- Maraudon
				[109] = {{220, nil, "TheTempleOfAtalHakkar\\TheTempleOfAtalHakkar1_"}}, -- Temple of Atal'Hakkar
				[230] = {{242, L["Detention Block"], "BlackrockDepths\\BlackrockDepths1_"}, {243, L["Shadowforge City"], "BlackrockDepths\\BlackrockDepths2_"}}, -- Blackrock Depths
				[229] = {{250, L["Tazz'Alor"], "BlackrockSpire\\BlackrockSpire1_"}, {251, L["Skitterweb Tunnels"], "BlackrockSpire\\BlackrockSpire2_"}, {252, L["Hordemar City"], "BlackrockSpire\\BlackrockSpire3_"}, {253, L["Hall of Blackhand"], "BlackrockSpire\\BlackrockSpire4_"}, {254, L["Halycon's Lair"], "BlackrockSpire\\BlackrockSpire5_"}, {255, L["Chamber of Battle"], "BlackrockSpire\\BlackrockSpire6_"}}, -- Blackrock Spire
				[409] = {{232, nil, "MoltenCore\\MoltenCore1_"}}, -- Molten Core
				[469] = {{287, L["Dragonmaw Garrison"], "BlackwingLair\\BlackwingLair1_"}, {288, L["Halls of Strife"], "BlackwingLair\\BlackwingLair2_"}, {289, L["Crimson Laboratories"], "BlackwingLair\\BlackwingLair3_"}, {290, L["Nefarian's Lair"], "BlackwingLair\\BlackwingLair4_"}}, -- Blackwing Lair
				[429] = {{235, L["Gordok Commons"], "DireMaul\\DireMaul1_"}, {236, L["Capital Gardens"], "DireMaul\\DireMaul2_"}, {237, L["Court of the Highborne"], "DireMaul\\DireMaul3_"}, {238, L["Prison of Immol'Thar"], "DireMaul\\DireMaul4_"}, {239, L["Warpwood Quarter"], "DireMaul\\DireMaul5_"}, {240, L["The Shrine of Eldretharr"], "DireMaul\\DireMaul6_"}}, -- Dire Maul
				[289] = {{306, L["The Reliquary"], nil, 0, 0}, {307, L["Chamber of Summoning"], nil, 1024, 0}, {308, L["The Upper Study"], nil, 0, 683}, {309, L["Headmaster's Study"], nil, 1024, 683}}, -- Scholomance
				[329] = {{317, L["Crusader's Square"], "Stratholme\\Stratholme1_"}, {318, L["The Gauntlet"], "Stratholme\\Stratholme2_"}}, -- Stratholme
				[309] = {{233, nil, "ZulGurub\\ZulGurub"}}, -- Zul'Gurub
				[249] = {{248, nil, "OnyxiasLair\\OnyxiasLair1_"}}, -- Onyxia's Lair
				[509] = {{247, nil, "RuinsofAhnQiraj\\RuinsofAhnQiraj"}}, -- Ruins of Ahn'Qiraj
				[531] = {{319, L["The Hive Undergrounds"], "AhnQiraj\\AhnQiraj1_"}, {320, L["The Temple Gates"], "AhnQiraj\\AhnQiraj2_"}, {321, L["Vault of C'Thun"], "AhnQiraj\\AhnQiraj3_"}}, -- Temple of Ahn'Qiraj
				[533] = {{162, L["The Construct Quarter"], "Naxxramas\\Naxxramas1_"}, {163, L["The Arachnid Quarter"], "Naxxramas\\Naxxramas2_"}, {164, L["The Military Quarter"], "Naxxramas\\Naxxramas3_"}, {165, L["The Plague Quarter"], "Naxxramas\\Naxxramas4_"}, {166, L["The Lower Necropolis"], "Naxxramas\\Naxxramas5_"}, {167, L["The Upper Necropolis"], "Naxxramas\\Naxxramas6_"}}, -- Naxxramas
			}

			-- Game maps in the addon folder for game locales that do not have them (such as esMX and ruRU)
			-- [game map texture] = map number (Leatrix_Maps_Dungeon_01 to 03 are 16x16 tiles of 256 pixels, 12 tiles per map in order)
			local bundledArt = {
				["Ragefire\\Ragefire1_"] = 0,
				["TheDeadmines\\TheDeadmines1_"] = 1,
				["TheDeadmines\\TheDeadmines2_"] = 2,
				["WailingCaverns\\WailingCaverns1_"] = 3,
				["ShadowfangKeep\\ShadowfangKeep1_"] = 4,
				["ShadowfangKeep\\ShadowfangKeep2_"] = 5,
				["ShadowfangKeep\\ShadowfangKeep3_"] = 6,
				["ShadowfangKeep\\ShadowfangKeep4_"] = 7,
				["ShadowfangKeep\\ShadowfangKeep5_"] = 8,
				["ShadowfangKeep\\ShadowfangKeep7_"] = 9,
				["ShadowfangKeep\\ShadowfangKeep6_"] = 10,
				["TheStockade\\TheStockade1_"] = 11,
				["BlackFathomDeeps\\BlackFathomDeeps1_"] = 12,
				["BlackFathomDeeps\\BlackFathomDeeps2_"] = 13,
				["BlackFathomDeeps\\BlackFathomDeeps3_"] = 14,
				["Gnomeregan\\Gnomeregan1_"] = 15,
				["Gnomeregan\\Gnomeregan2_"] = 16,
				["Gnomeregan\\Gnomeregan3_"] = 17,
				["Gnomeregan\\Gnomeregan4_"] = 18,
				["RazorfenKraul\\RazorfenKraul1_"] = 19,
				["ScarletMonastery\\ScarletMonastery1_"] = 20,
				["ScarletMonastery\\ScarletMonastery2_"] = 21,
				["ScarletMonastery\\ScarletMonastery3_"] = 22,
				["ScarletMonastery\\ScarletMonastery4_"] = 23,
				["RazorfenDowns\\RazorfenDowns1_"] = 24,
				["Uldaman\\Uldaman1_"] = 25,
				["Uldaman\\Uldaman2_"] = 26,
				["ZulFarrak\\ZulFarrak"] = 27,
				["Maraudon\\Maraudon1_"] = 28,
				["Maraudon\\Maraudon2_"] = 29,
				["TheTempleOfAtalHakkar\\TheTempleOfAtalHakkar1_"] = 30,
				["BlackrockDepths\\BlackrockDepths1_"] = 31,
				["BlackrockDepths\\BlackrockDepths2_"] = 32,
				["BlackrockSpire\\BlackrockSpire1_"] = 33,
				["BlackrockSpire\\BlackrockSpire2_"] = 34,
				["BlackrockSpire\\BlackrockSpire3_"] = 35,
				["BlackrockSpire\\BlackrockSpire4_"] = 36,
				["BlackrockSpire\\BlackrockSpire5_"] = 37,
				["BlackrockSpire\\BlackrockSpire6_"] = 38,
				["MoltenCore\\MoltenCore1_"] = 39,
				["BlackwingLair\\BlackwingLair1_"] = 40,
				["BlackwingLair\\BlackwingLair2_"] = 41,
				["BlackwingLair\\BlackwingLair3_"] = 42,
				["BlackwingLair\\BlackwingLair4_"] = 43,
				["DireMaul\\DireMaul1_"] = 44,
				["DireMaul\\DireMaul2_"] = 45,
				["DireMaul\\DireMaul3_"] = 46,
				["DireMaul\\DireMaul4_"] = 47,
				["DireMaul\\DireMaul5_"] = 48,
				["DireMaul\\DireMaul6_"] = 49,
				["Stratholme\\Stratholme1_"] = 50,
				["Stratholme\\Stratholme2_"] = 51,
				["ZulGurub\\ZulGurub"] = 52,
				["OnyxiasLair\\OnyxiasLair1_"] = 53,
				["RuinsofAhnQiraj\\RuinsofAhnQiraj"] = 54,
				["AhnQiraj\\AhnQiraj1_"] = 55,
				["AhnQiraj\\AhnQiraj2_"] = 56,
				["AhnQiraj\\AhnQiraj3_"] = 57,
				["Naxxramas\\Naxxramas1_"] = 58,
				["Naxxramas\\Naxxramas2_"] = 59,
				["Naxxramas\\Naxxramas3_"] = 60,
				["Naxxramas\\Naxxramas4_"] = 61,
				["Naxxramas\\Naxxramas5_"] = 62,
				["Naxxramas\\Naxxramas6_"] = 63,
			}

			-- Map pins: [map ID] = {{"entrance", x, y, type}, {"level", x, y, map ID, up}, {"boss", x, y, npc ID, name, level, display ID, style}, ...}
			local dungeonPins = {
				[213] = {
					{"entrance", 0.611, 0.072},
					{"boss", 0.564, 0.372, 11517, L["Oggleflint <Ragefire Chieftain>"], 16, 11611, 1},
					{"boss", 0.408, 0.574, 11520, L["Taragaman the Hungerer"], 16, 7970, 1},
					{"boss", 0.343, 0.814, 11518, L["Jergosh the Invoker"], 16, 11429, 1},
					{"boss", 0.422, 0.857, 11519, L["Bazzalan"], 16, 2007, 1},
				},
				[291] = {
					{"entrance", 0.297, 0.133},
					{"level", 0.655, 0.667, 292},
					{"boss", 0.364, 0.612, 644, L["Rhahk'Zor <The Foreman>"], 19, 14403, 1},
					{"boss", 0.523, 0.510, 3586, L["Miner Johnson"], 19, 556, 2},
					{"boss", 0.503, 0.863, 642, L["Sneed's Shredder / Sneed"], 20, 1269, 1},
					{"boss", 0.607, 0.572, 1763, L["Gilnid <The Smelter>"], 20, 7124, 1},
				},
				[292] = {
					{"level", 0.123, 0.883, 291, true},
					{"boss", 0.561, 0.265, 646, L["Mr. Smite <The Ship's First Mate>"], 20, 2026, 1},
					{"boss", 0.605, 0.372, 647, L["Captain Greenskin"], 20, 7113, 1},
					{"boss", 0.605, 0.447, 639, L["Edwin VanCleef <Defias Kingpin>"], 21, 2029, 1},
					{"boss", 0.668, 0.398, 645, L["Cookie <The Ship's Cook>"], 20, 1305, 1},
				},
				[279] = {
					{"entrance", 0.463, 0.590},
					{"boss", 0.307, 0.429, 3671, L["Lady Anacondra <Fanglord>"], 20, 4313, 1},
					{"boss", 0.159, 0.565, 3669, L["Lord Cobrahn <Fanglord>"], 20, 4213, 1},
					{"boss", 0.386, 0.350, 3653, L["Kresh"], 20, 5126, 1},
					{"boss", 0.190, 0.396, 3670, L["Lord Pythas <Fanglord>"], 21, 4214, 1},
					{"boss", 0.619, 0.737, 3674, L["Skum"], 21, 4203, 1},
					{"boss", 0.615, 0.534, 3673, L["Lord Serpentis <Fanglord>"], 21, 4215, 1},
					{"boss", 0.551, 0.463, 5775, L["Verdan the Everliving"], 21, 4256, 1},
					{"boss", 0.560, 0.400, 5912, L["Deviate Faerie Dragon"], 20, 1267, 2},
					{"boss", 0.344, 0.135, 3654, L["Mutanus the Devourer"], 22, 4088, 1},
				},
				[310] = {
					{"entrance", 0.705, 0.606},
					{"level", 0.367, 0.392, 311},
					{"level", 0.148, 0.866, 311},
					{"level", 0.355, 0.666, 316, true},
					{"boss", 0.667, 0.719, 3914, L["Rethilgore <The Cell Keeper>"], 20, 524, 1},
					{"boss", 0.279, 0.598, 4278, L["Commander Springvale"], 24, 3223, 1},
				},
				[311] = {
					{"level", 0.593, 0.121, 310, true},
					{"level", 0.273, 0.881, 310, true},
					{"boss", 0.303, 0.766, 3887, L["Baron Silverlaine"], 24, 3222, 1},
					{"boss", 0.472, 0.277, 3886, L["Razorclaw the Butcher"], 22, 524, 1},
				},
				[316] = {
					{"level", 0.239, 0.745, 310},
					{"level", 0.436, 0.331, 312, true},
					{"boss", 0.597, 0.824, 4279, L["Odo the Blindwatcher"], 24, 522, 1},
					{"boss", 0.690, 0.770, 3872, L["Deathsworn Captain"], 25, 3224, 2},
				},
				[312] = {
					{"level", 0.516, 0.904, 316, true},
					{"level", 0.533, 0.600, 313, true},
				},
				[313] = {
					{"level", 0.442, 0.749, 314, true},
					{"level", 0.526, 0.872, 312},
					{"boss", 0.543, 0.534, 4274, L["Fenrus the Devourer"], 25, 2352, 1},
				},
				[314] = {
					{"level", 0.437, 0.743, 315, true},
					{"level", 0.490, 0.780, 313},
				},
				[315] = {
					{"level", 0.420, 0.842, 314},
					{"boss", 0.560, 0.624, 3927, L["Wolf Master Nandos"], 25, 11179, 1},
					{"boss", 0.639, 0.200, 4275, L["Archmage Arugal"], 26, 2353, 1},
				},
				[225] = {
					{"entrance", 0.500, 0.815},
					{"boss", 0.440, 0.446, 1696, L["Targorr the Dread"], 24, 517, 1},
					{"boss", 0.691, 0.300, 1666, L["Kam Deepfury"], 27, 825, 1},
					{"boss", 0.783, 0.454, 1717, L["Hamhock"], 28, 3250, 1},
					{"boss", 0.745, 0.562, 1716, L["Bazil Thredd"], 29, 1621, 1},
					{"boss", 0.217, 0.261, 1663, L["Dextren Ward"], 26, 2149, 1},
					{"boss", 0.500, 0.210, 1720, L["Bruegal Ironknuckle"], 26, 2142, 2},
				},
				[221] = {
					{"entrance", 0.453, 0.108},
					{"level", 0.621, 0.741, 222},
					{"boss", 0.329, 0.602, 4887, L["Ghamoo-ra"], 25, 5027, 1},
					{"boss", 0.113, 0.394, 4831, L["Lady Sarevess"], 25, 4979, 1},
					{"boss", 0.543, 0.567, 6243, L["Gelihast"], 26, 1773, 1},
					{"boss", 0.614, 0.625, 12902, L["Lorgus Jett"], 26, 12822, 1},
				},
				[222] = {
					{"level", 0.477, 0.707, 223},
					{"level", 0.350, 0.290, 221},
					{"boss", 0.527, 0.817, 4832, L["Twilight Lord Kelris"], 27, 4939, 1},
					{"boss", 0.858, 0.862, 4829, L["Aku'mai"], 28, 2837, 1},
				},
				[223] = {
					{"level", 0.300, 0.612, 222, true},
					{"boss", 0.588, 0.302, 4830, L["Old Serra'kis"], 26, 1816, 1},
					{"boss", 0.234, 0.498, 12876, L["Baron Aquanis"], 28, 110, 1},
				},
				[226] = {
					{"entrance", 0.644, 0.275},
					{"level", 0.345, 0.640, 227},
					{"level", 0.470, 0.870, 227},
					{"level", 0.551, 0.440, 227},
					{"boss", 0.774, 0.664, 7361, L["Grubbis"], 32, 6533, 1},
				},
				[227] = {
					{"level", 0.245, 0.580, 228},
					{"level", 0.430, 0.830, 226, true},
					{"level", 0.640, 0.580, 226, true},
					{"boss", 0.758, 0.462, 7079, L["Viscous Fallout"], 30, 5497, 1},
				},
				[228] = {
					{"entrance", 0.870, 0.480},
					{"level", 0.488, 0.710, 229},
					{"level", 0.273, 0.308, 229},
					{"level", 0.445, 0.430, 227, true},
					{"boss", 0.432, 0.876, 6229, L["Crowd Pummeler 9-60"], 32, 6774, 1},
				},
				[229] = {
					{"level", 0.481, 0.540, 228, true},
					{"level", 0.710, 0.773, 228, true},
					{"boss", 0.655, 0.835, 6235, L["Electrocutioner 6000"], 32, 6915, 1},
					{"boss", 0.295, 0.540, 6228, L["Dark Iron Ambassador"], 41, 6669, 2},
					{"boss", 0.313, 0.293, 7800, L["Mekgineer Thermaplugg"], 34, 6980, 1},
				},
				[301] = {
					{"entrance", 0.715, 0.837},
					{"boss", 0.806, 0.514, 6168, L["Roogug"], 28, 6110, 1},
					{"boss", 0.874, 0.412, 4424, L["Aggem Thorncurse <Death's Head Prophet>"], 30, 6097, 1},
					{"boss", 0.573, 0.306, 4428, L["Death Speaker Jargba <Death's Head Captain>"], 30, 4644, 1},
					{"boss", 0.218, 0.306, 4420, L["Overlord Ramtusk"], 32, 4652, 1},
					{"boss", 0.112, 0.724, 4422, L["Agathelos the Raging"], 33, 2450, 1},
					{"boss", 0.110, 0.303, 4425, L["Blind Hunter"], 32, 4735, 2},
					{"boss", 0.079, 0.679, 4421, L["Charlga Razorflank <The Crone>"], 33, 4642, 1},
					{"boss", 0.494, 0.471, 4842, L["Earthcaller Halmgar"], 32, 6102, 2},
				},
				[302] = {
					{"entrance", 0.840, 0.830},
					{"boss", 0.721, 0.593, 3983, L["Interrogator Vishas"], 32, 2044, 1},
					{"boss", 0.243, 0.559, 4543, L["Bloodmage Thalnos"], 34, 11396, 1},
					{"boss", 0.325, 0.660, 6490, L["Azshir the Sleepless"], 33, 5534, 2},
					{"boss", 0.400, 0.460, 6488, L["Fallen Champion"], 33, 5230, 2},
					{"boss", 0.400, 0.660, 6489, L["Ironspine"], 33, 5231, 2},
				},
				[303] = {
					{"entrance", 0.130, 0.248},
					{"boss", 0.294, 0.841, 3974, L["Houndmaster Loksey"], 34, 2040, 1},
					{"boss", 0.834, 0.742, 6487, L["Arcanist Doan"], 37, 5266, 1},
				},
				[304] = {
					{"entrance", 0.610, 0.955},
					{"boss", 0.786, 0.106, 3975, L["Herod <The Scarlet Champion>"], 40, 2041, 1},
				},
				[305] = {
					{"entrance", 0.623, 0.920},
					{"boss", 0.490, 0.275, 3976, L["Scarlet Commander Mograine"], 42, 2042, 1},
					{"boss", 0.492, 0.164, 3977, L["High Inquisitor Whitemane"], 42, 2043, 1},
					{"boss", 0.554, 0.248, 4542, L["High Inquisitor Fairbanks"], 40, 2605, 1},
				},
				[300] = {
					{"entrance", 0.237, 0.190},
					{"boss", 0.470, 0.200, 7356, L["Plaguemaw the Rotting"], 40, 6124, 1},
					{"boss", 0.857, 0.465, 7357, L["Mordresh Fire Eye"], 39, 8055, 1},
					{"boss", 0.346, 0.664, 8567, L["Glutton"], 40, 7864, 1},
					{"boss", 0.529, 0.672, 7354, L["Ragglesnout"], 40, 11382, 1},
					{"boss", 0.444, 0.601, 7358, L["Amnennar the Coldbringer"], 41, 7971, 1},
					{"boss", 0.590, 0.339, 7355, L["Tuten'kash"], 40, 7845, 1},
				},
				[230] = {
					{"entrance", 0.285, 0.692},
					{"level", 0.485, 0.210, 231},
					{"entrance", 0.680, 0.725},
					{"boss", 0.532, 0.722, 6910, L["Revelosh"], 40, 5945, 1},
					{"boss", 0.585, 0.918, 6906, L["Baelog / Eric \"The Swift\" / Olaf"], 41, 5710, 1},
					{"boss", 0.475, 0.439, 7206, L["Ancient Stone Keeper"], 44, 10798, 1},
					{"boss", 0.266, 0.323, 7291, L["Galgann Firehammer"], 45, 6059, 1},
					{"boss", 0.220, 0.257, 4854, L["Grimlok <Stonevault Chieftain>"], 45, 11165, 1},
					{"boss", 0.370, 0.736, 7228, L["Ironaya"], 40, 6089, 1},
				},
				[231] = {
					{"level", 0.645, 0.410, 230, true},
					{"boss", 0.552, 0.504, 2748, L["Archaedas <Ancient Stone Watcher>"], 47, 5988, 1},
				},
				[219] = {
					{"entrance", 0.566, 0.901},
					{"boss", 0.690, 0.256, 8127, L["Antu'sul <Overseer of Sul>"], 48, 7353, 1},
					{"boss", 0.527, 0.261, 7272, L["Theka the Martyr"], 46, 6696, 1},
					{"boss", 0.442, 0.173, 7271, L["Witch Doctor Zum'rah"], 46, 6434, 1},
					{"boss", 0.255, 0.130, 7604, L["Sergeant Bly"], 45, 6433, 1},
					{"boss", 0.313, 0.408, 7795, L["Hydromancer Velratha"], 46, 6685, 1},
					{"boss", 0.423, 0.333, 7797, L["Ruuzlu"], 46, 6687, 1},
					{"boss", 0.423, 0.333, 7267, L["Chief Ukorz Sandscalp"], 48, 6439, 1},
					{"boss", 0.538, 0.373, 10082, L["Zerillis"], 45, 9293, 2},
					{"boss", 0.463, 0.578, 10080, L["Sandarr Dunereaver"], 45, 9291, 2},
					{"boss", 0.313, 0.408, 10081, L["Dustwraith"], 45, 9292, 2},
					{"boss", 0.235, 0.183, 7796, L["Nekrum Gutchewer"], 46, 6690, 1},
					{"boss", 0.334, 0.170, 7275, L["Shadowpriest Sezz'ziz"], 47, 6441, 1},
					{"boss", 0.313, 0.408, 7273, L["Gahz'rilla"], 46, 7271, 1},
				},
				[280] = {
					{"entrance", 0.768, 0.657},
					{"level", 0.145, 0.570, 281},
					{"entrance", 0.622, 0.281},
					{"boss", 0.359, 0.098, 13282, L["Noxxion"], 48, 11172, 1},
					{"boss", 0.163, 0.338, 12258, L["Razorlash"], 48, 12389, 1},
					{"boss", 0.378, 0.707, 12236, L["Lord Vyletongue"], 47, 12334, 1},
					{"boss", 0.246, 0.874, 12237, L["Meshlok the Harvester"], 48, 9014, 2},
				},
				[281] = {
					{"level", 0.295, 0.040, 280, true},
					{"boss", 0.245, 0.135, 12225, L["Celebras the Cursed"], 49, 12350, 1},
					{"boss", 0.412, 0.487, 12203, L["Landslide"], 50, 12293, 1},
					{"boss", 0.484, 0.686, 13601, L["Tinkerer Gizlock"], 50, 7125, 1},
					{"boss", 0.333, 0.771, 13596, L["Rotgrip"], 50, 13589, 1},
					{"boss", 0.259, 0.784, 12201, L["Princess Theradras"], 51, 12292, 1},
				},
				[220] = {
					{"entrance", 0.500, 0.110},
					{"boss", 0.525, 0.450, 5721, L["Dreamscythe"], 53, 7553, 1},
					{"boss", 0.470, 0.450, 5720, L["Weaver"], 51, 6375, 1},
					{"boss", 0.451, 0.585, 5713, L["Gasher"], 51, 6698, 1},
					{"boss", 0.451, 0.585, 5714, L["Loro"], 51, 6700, 1},
					{"boss", 0.451, 0.585, 5715, L["Hukku"], 52, 6702, 1},
					{"boss", 0.451, 0.585, 5712, L["Zolo"], 51, 6699, 1},
					{"boss", 0.451, 0.585, 5717, L["Mijan"], 52, 6707, 1},
					{"boss", 0.451, 0.585, 5716, L["Zul'Lor"], 52, 6701, 1},
					{"boss", 0.760, 0.370, 5710, L["Jammal'an the Prophet"], 54, 6708, 1},
					{"boss", 0.767, 0.361, 5711, L["Ogom the Wretched"], 53, 6709, 1},
					{"boss", 0.499, 0.866, 5719, L["Morphaz"], 52, 7975, 1},
					{"boss", 0.448, 0.851, 5722, L["Hazzas"], 53, 9584, 1},
					{"boss", 0.665, 0.874, 5709, L["Shade of Eranikus"], 55, 7806, 1},
					{"boss", 0.501, 0.358, 8580, L["Atal'alarion <Guardian of the Idol>"], 50, 7873, 1},
					{"boss", 0.241, 0.453, 8443, L["Avatar of Hakkar"], 49, 8053, 1},
				},
				[242] = {
					{"entrance", 0.333, 0.791},
					{"level", 0.655, 0.294, 243, true},
					{"boss", 0.494, 0.567, 9025, L["Lord Roccor"], 51, 5781, 1},
					{"boss", 0.476, 0.920, 9018, L["High Interrogator Gerstahn <Twilight's Hammer Interrogator>"], 52, 8761, 1},
					{"boss", 0.495, 0.617, 9319, L["Houndmaster Grebmar"], 52, 9212, 1},
					{"boss", 0.256, 0.526, 9016, L["Bael'Gar"], 54, 12162, 1},
					{"boss", 0.565, 0.308, 9017, L["Lord Incendius"], 55, 1204, 1},
					{"boss", 0.634, 0.206, 9056, L["Fineous Darkvire <Chief Architect>"], 54, 8704, 1},
					{"boss", 0.560, 0.667, 9024, L["Pyromancer Loregrain"], 52, 8762, 1},
					{"boss", 0.356, 0.570, 9033, L["General Angerforge"], 57, 8756, 1},
					{"boss", 0.500, 0.635, 9031, L["Anub'shiah / Eviscerator / Gorosh the Dervish / Grizzle / Hedrum the Creeper / Ok'thor the Breaker"], 56, 3004, 1},
				},
				[243] = {
					{"level", 0.595, 0.547, 242},
					{"boss", 0.595, 0.655, 9041, L["Warder Stilgiss / Verek"], 56, 9089, 1},
					{"boss", 0.364, 0.646, 8983, L["Golem Lord Argelmach"], 57, 8759, 1},
					{"boss", 0.498, 0.632, 9502, L["Phalanx"], 55, 8177, 1},
					{"boss", 0.498, 0.632, 9543, L["Ribbly Screwspigot"], 53, 8667, 1},
					{"boss", 0.498, 0.632, 9499, L["Plugger Spazzring"], 55, 8652, 1},
					{"boss", 0.539, 0.483, 9156, L["Ambassador Flamelash"], 57, 8329, 1},
					{"boss", 0.802, 0.113, 9938, L["Magmus"], 57, 12162, 1},
					{"boss", 0.535, 0.243, 9039, L["Doom'rel / Dope'rel / Hate'rel / Seeth'rel / Vile'rel / Gloom'rel / Anger'rel"], 57, 8687, 1},
					{"boss", 0.916, 0.115, 9019, L["Emperor Dagran Thaurissan"], 59, 8807, 1},
					{"boss", 0.916, 0.115, 8929, L["Princess Moira Bronzebeard <Princess of Ironforge>"], 58, 8705, 1},
					{"boss", 0.498, 0.632, 9537, L["Hurley Blackbreath"], 55, 8658, 1},
					{"boss", 0.505, 0.354, 8923, L["Panzor the Invincible"], 57, 8270, 2},
				},
				[232] = {
					{"entrance", 0.264, 0.226, "raid"},
					{"boss", 0.658, 0.376, 12118, L["Lucifron"], 9999, 13031, 3},
					{"boss", 0.689, 0.236, 11982, L["Magmadar"], 9999, 10193, 3},
					{"boss", 0.333, 0.486, 12259, L["Gehennas"], 9999, 13030, 3},
					{"boss", 0.309, 0.697, 12057, L["Garr"], 9999, 12110, 3},
					{"boss", 0.551, 0.845, 12264, L["Shazzrah"], 9999, 13032, 3},
					{"boss", 0.523, 0.775, 12056, L["Baron Geddon"], 9999, 12129, 3},
					{"boss", 0.827, 0.827, 12098, L["Sulfuron Harbinger"], 9999, 13030, 3},
					{"boss", 0.685, 0.583, 11988, L["Golemagg the Incinerator"], 9999, 11986, 3},
					{"boss", 0.839, 0.656, 12018, L["Majordomo Executus"], 9999, 12029, 3},
					{"boss", 0.558, 0.538, 11502, L["Ragnaros"], 9999, 11121, 3},
				},
				[287] = {
					{"entrance", 0.527, 0.836, "raid"},
					{"level", 0.435, 0.300, 288, true},
					{"level", 0.360, 0.130, 288, true},
					{"boss", 0.417, 0.601, 12435, L["Razorgore the Untamed"], 999, 10115, 3},
					{"boss", 0.331, 0.275, 13020, L["Vaelastrasz the Corrupt"], 999, 13992, 3},
				},
				[288] = {
					{"level", 0.525, 0.320, 287},
					{"level", 0.463, 0.198, 287},
					{"boss", 0.560, 0.780, 12017, L["Broodlord Lashlayer"], 999, 14308, 3},
				},
				[239] = {
					{"entrance", 0.070, 0.392},
					{"entrance", 0.164, 0.853},
					{"entrance", 0.954, 0.508},
					{"level", 0.505, 0.630, 240},
					{"boss", 0.122, 0.310, 14354, L["Pusillin"], 57, 7552, 1},
					{"boss", 0.439, 0.474, 11490, L["Zevrim Thornhoof"], 57, 11335, 1},
				},
				[240] = {
					{"entrance", 0.281, 0.555},
					{"level", 0.633, 0.844, 239, true},
					{"boss", 0.564, 0.284, 11492, L["Alzzin the Wildshaper"], 58, 14416, 1},
					{"boss", 0.536, 0.710, 13280, L["Hydrospawn"], 57, 5489, 1},
					{"boss", 0.576, 0.737, 14327, L["Lethtendris"], 57, 14378, 1},
				},
				[236] = {
					{"entrance", 0.935, 0.721},
					{"entrance", 0.936, 0.510},
					{"level", 0.270, 0.190, 237},
					{"level", 0.304, 0.430, 238},
					{"boss", 0.332, 0.530, 11489, L["Tendris Warpwood"], 60, 14383, 1},
					{"boss", 0.208, 0.779, 11488, L["Illyanna Ravenoak"], 60, 11270, 1},
				},
				[237] = {
					{"level", 0.415, 0.120, 236},
					{"boss", 0.338, 0.444, 11487, L["Magister Kalendris"], 60, 14384, 1},
					{"boss", 0.322, 0.143, 11467, L["Tsu'zee"], 59, 11250, 1},
				},
				[238] = {
					{"level", 0.745, 0.400, 236, true},
					{"boss", 0.349, 0.571, 11496, L["Immol'thar"], 61, 14173, 1},
					{"boss", 0.620, 0.230, 11486, L["Prince Tortheldrin"], 61, 11256, 1},
				},
				[235] = {
					{"entrance", 0.718, 0.926},
					{"boss", 0.694, 0.754, 14326, L["Guard Mol'dar"], 59, 11561, 1},
					{"boss", 0.609, 0.681, 14322, L["Stomper Kreeg <The Drunk>"], 59, 11545, 1},
					{"boss", 0.496, 0.778, 14321, L["Guard Fengus"], 59, 11561, 1},
					{"boss", 0.264, 0.570, 14323, L["Guard Slip'kik"], 59, 11561, 1},
					{"boss", 0.319, 0.496, 14325, L["Captain Kromcrush"], 61, 11564, 1},
					{"boss", 0.318, 0.263, 14324, L["Cho'Rush the Observer"], 60, 11537, 1},
					{"boss", 0.318, 0.263, 11501, L["King Gordok"], 62, 11583, 1},
				},
				[306] = {
					{"entrance", 0.390, 0.652},
				},
				[309] = {
					{"boss", 0.406, 0.884, 10508, L["Ras Frostwhisper"], 62, 7919, 1},
					{"boss", 0.674, 0.481, 10507, L["The Ravenian"], 60, 10433, 1},
					{"boss", 0.792, 0.296, 10504, L["Lord Alexei Barov"], 60, 11072, 1},
					{"boss", 0.672, 0.149, 10502, L["Lady Illucia Barov"], 60, 11835, 1},
				},
				[317] = {
					{"entrance", 0.640, 0.880},
					{"boss", 0.392, 0.287, 10808, L["Timmy the Cruel"], 58, 571, 2},
					{"entrance", 0.686, 0.880},
					{"level", 0.900, 0.330, 318, true},
					{"boss", 0.815, 0.438, 10393, L["Skul"], 58, 2606, 2},
					{"boss", 0.847, 0.454, 10558, L["Hearthsinger Forresten"], 57, 10482, 2},
					{"boss", 0.735, 0.200, 10516, L["The Unforgiven"], 57, 10771, 1},
					{"boss", 0.298, 0.405, 11032, L["Malor the Zealous"], 60, 10458, 1},
					{"boss", 0.041, 0.507, 10997, L["Cannon Master Willey"], 60, 10674, 1},
					{"boss", 0.272, 0.746, 10811, L["Archivist Galford"], 60, 10544, 1},
					{"boss", 0.204, 0.817, 10813, L["Balnazzar"], 62, 10691, 1},
				},
				[318] = {
					{"level", 0.355, 0.390, 317},
					{"level", 0.570, 0.770, 317},
					{"boss", 0.649, 0.489, 10809, L["Stonespine"], 60, 7856, 2},
					{"boss", 0.745, 0.460, 10436, L["Baroness Anastari"], 59, 10698, 1},
					{"boss", 0.571, 0.459, 10437, L["Nerub'enkan"], 60, 9793, 1},
					{"boss", 0.676, 0.213, 10438, L["Maleki the Pallid"], 61, 10546, 1},
					{"boss", 0.644, 0.752, 10435, L["Magistrate Barthilas"], 58, 10433, 1},
					{"boss", 0.391, 0.201, 10440, L["Baron Rivendare"], 62, 10729, 1},
					{"boss", 0.452, 0.197, 10439, L["Ramstein the Gorger"], 61, 12818, 1},
				},
				[233] = {
					{"entrance", 0.290, 0.490, "raid"},
					{"boss", 0.390, 0.730, 14517, L["High Priestess Jeklik"], 9999, 15219, 3},
					{"boss", 0.508, 0.541, 14507, L["High Priest Venoxis"], 9999, 15217, 3},
					{"boss", 0.470, 0.770, 14510, L["High Priestess Mar'li"], 9999, 15220, 3},
					{"boss", 0.602, 0.797, 11382, L["Bloodlord Mandokir"], 9999, 11288, 3},
					{"boss", 0.597, 0.460, 15082, L["Gri'lek / Hazza'rah / Renataki / Wushoolay"], 9999, 8390, 3},
					{"boss", 0.535, 0.320, 15114, L["Gahz'ranka"], 9999, 15288, 3},
					{"boss", 0.620, 0.340, 14509, L["High Priest Thekal"], 9999, 15216, 3},
					{"boss", 0.476, 0.204, 14515, L["High Priestess Arlokk"], 9999, 15218, 3},
					{"boss", 0.316, 0.245, 11380, L["Jin'do the Hexxer"], 9999, 11311, 3},
					{"boss", 0.499, 0.394, 14834, L["Hakkar"], 9999, 15295, 3},
				},
				[248] = {
					{"entrance", 0.341, 0.205, "raid"},
					{"boss", 0.673, 0.306, 10184, L["Onyxia"], 9999, 8570, 3},
				},
				[250] = {
					{"boss", 0.523, 0.546, 9237, L["War Master Voone"], 59, 9733, 1},
				},
				[251] = {
					{"boss", 0.554, 0.692, 9236, L["Shadow Hunter Vosh'gajin"], 58, 9732, 1},
					{"boss", 0.618, 0.739, 10596, L["Mother Smolderweb"], 59, 9929, 1},
					{"boss", 0.660, 0.700, 10376, L["Crystal Fang"], 60, 9755, 2},
				},
				[252] = {
					{"boss", 0.386, 0.586, 9196, L["Highlord Omokk"], 59, 11565, 1},
				},
				[253] = {
					{"boss", 0.454, 0.550, 10584, L["Urok Doomhowl"], 60, 11583, 1},
				},
				[254] = {
					{"boss", 0.380, 0.835, 10220, L["Halycon"], 59, 9567, 1},
					{"boss", 0.420, 0.880, 10268, L["Gizrul the Slavener"], 60, 9564, 1},
					{"boss", 0.540, 0.844, 9736, L["Quartermaster Zigris"], 59, 9738, 1},
				},
				[255] = {
					{"boss", 0.575, 0.604, 9568, L["Overlord Wyrmthalak"], 60, 8711, 1},
				},
				[289] = {
					{"boss", 0.501, 0.616, 11983, L["Firemaw"], 999, 6377, 3},
					{"boss", 0.462, 0.427, 14601, L["Ebonroc"], 999, 6377, 3},
					{"boss", 0.348, 0.209, 11981, L["Flamegor"], 999, 6377, 3},
				},
				[290] = {
					{"boss", 0.354, 0.372, 14020, L["Chromaggus"], 999, 14367, 3},
					{"boss", 0.702, 0.724, 11583, L["Nefarian"], 999, 11380, 3},
				},
				[247] = {
					{"boss", 0.559, 0.356, 15348, L["Kurinnaxx"], 999, 15742, 3},
					{"boss", 0.584, 0.492, 15341, L["General Rajaxx"], 999, 15376, 3},
					{"boss", 0.699, 0.619, 15340, L["Moam"], 999, 15392, 3},
					{"boss", 0.616, 0.899, 15370, L["Buru the Gorger"], 999, 15654, 3},
					{"boss", 0.329, 0.363, 15369, L["Ayamiss the Hunter"], 999, 15431, 3},
					{"boss", 0.432, 0.691, 15339, L["Ossirian the Unscarred"], 999, 15432, 3},
				},
				[319] = {
					{"boss", 0.621, 0.224, 15263, L["The Prophet Skeram"], 999, 15345, 3},
					{"boss", 0.721, 0.177, 15543, L["Bug Trio"], 999, 15657, 3},
					{"boss", 0.445, 0.333, 15516, L["Battleguard Sartura"], 999, 15583, 3},
					{"boss", 0.434, 0.498, 15510, L["Fankriss the Unyielding"], 999, 15743, 3},
					{"boss", 0.284, 0.493, 15299, L["Viscidus"], 999, 15686, 3},
					{"boss", 0.303, 0.812, 15509, L["Princess Huhuran"], 999, 15739, 3},
					{"boss", 0.605, 0.697, 15517, L["Ouro"], 999, 15509, 3},
				},
				[320] = {
					{"boss", 0.459, 0.513, 15275, L["Twin Emperors"], 999, 15761, 3},
				},
				[321] = {
					{"boss", 0.569, 0.625, 15727, L["C'Thun"], 999, 15787, 3},
				},
				[162] = {
					{"boss", 0.616, 0.523, 16028, L["Patchwerk"], 999, 16174, 3},
					{"boss", 0.459, 0.439, 15931, L["Grobbulus"], 999, 16035, 3},
					{"boss", 0.539, 0.417, 15932, L["Gluth"], 999, 16064, 3},
					{"boss", 0.265, 0.146, 15928, L["Thaddius"], 999, 16137, 3},
				},
				[163] = {
					{"boss", 0.306, 0.466, 15956, L["Anub'Rekhan"], 999, 15931, 3},
					{"boss", 0.440, 0.359, 15953, L["Grand Widow Faerlina"], 999, 15940, 3},
					{"boss", 0.685, 0.152, 15952, L["Maexxna"], 999, 15928, 3},
				},
				[164] = {
					{"boss", 0.674, 0.595, 16061, L["Instructor Razuvious"], 999, 16582, 3},
					{"boss", 0.427, 0.454, 16060, L["Gothik the Harvester"], 999, 16279, 3},
					{"boss", 0.302, 0.766, 16064, L["The Four Horsemen"], 999, 16155, 3},
				},
				[165] = {
					{"boss", 0.347, 0.562, 15954, L["Noth the Plaguebringer"], 999, 16590, 3},
					{"boss", 0.498, 0.454, 15936, L["Heigan the Unclean"], 999, 16309, 3},
					{"boss", 0.757, 0.282, 16011, L["Loatheb"], 999, 16110, 3},
				},
				[167] = {
					{"boss", 0.565, 0.671, 15989, L["Sapphiron"], 999, 16033, 3},
					{"boss", 0.366, 0.224, 15990, L["Kel'Thuzad"], 999, 15945, 3},
				},
				[307] = {
					{"boss", 0.496, 0.101, 10506, L["Kirtonos the Herald"], 60, 7534, 1},
					{"boss", 0.620, 0.700, 10503, L["Jandice Barov"], 61, 11073, 1},
				},
				[308] = {
					{"boss", 0.316, 0.643, 11622, L["Rattlegore"], 61, 12073, 1},
					{"boss", 0.511, 0.143, 10433, L["Marduk Blackpool"], 58, 10248, 1},
					{"boss", 0.571, 0.143, 10432, L["Vectus"], 60, 2606, 1},
					{"boss", 0.723, 0.219, 10901, L["Lorekeeper Polkelt"], 60, 11492, 1},
					{"boss", 0.726, 0.701, 10505, L["Instructor Malicia"], 60, 11069, 1},
					{"boss", 0.888, 0.456, 11261, L["Doctor Theolen Krastinov"], 60, 10901, 1},
					{"boss", 0.680, 0.420, 1853, L["Darkmaster Gandling"], 61, 11070, 1},
				},
			}

			-- Settings
			local artPath = "Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps_Dungeon_Scholomance"
			local pinPath = "Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps_Dungeon_Pins"
			local bundlePath = "Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps_Dungeon_"
			local maxZoom, wheelStep = 4, 1.25
			local bossSize, rareSize, pinSize = 34, 24, 26
			local ringScale = 1.55
			local skullLevels = 10 -- Show skull if boss is this many levels above the player

			-- Boss pin styles (ring color and dragon row in the pins texture)
			local pinStyles = {
				[0] = {0.55, 0.5, 0.4},
				[1] = {0.95, 0.75, 0.25, 0},
				[2] = {0.85, 0.87, 0.95, 1},
				[3] = {0.95, 0.75, 0.25, 0},
				[4] = {0.85, 0.87, 0.95, 2},
			}

			-- Use atlas if the client has it, otherwise use the fallback texture
			local function SetIcon(texture, atlas, fallback)
				if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then
					texture:SetAtlas(atlas)
				else
					texture:SetTexture(fallback)
					texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				end
			end

			-- State
			local container = WorldMapScrollFrame or WorldMapDetailFrame -- 3.3.5: the map art frame
			local levels, levelIndex, instanceID, shownMapID
			local chosenLevel = {} -- Level picked by the user while the map is open
			local hiddenFor -- Instance hidden with right-click until the map is opened again
			local view = {zoom = 1, x = 0, y = 0, baseW = 0, baseH = 0}
			local pins, pinRows = {}, nil
			local Refresh, SelectLevel, HideOverlay
			local previewID, previewIndex, previewMapID -- Instance shown with /ltm dun or a dungeon icon click (and the world map it was opened on)

			-- Create overlay (covers the map canvas)
			local overlay = CreateFrame("Frame", nil, container)
			overlay:SetAllPoints()
			overlay:EnableMouse(true)
			overlay:EnableMouseWheel(true)
			if overlay.SetClipsChildren then overlay:SetClipsChildren(true) end
			overlay:Hide()

			overlay.bg = overlay:CreateTexture(nil, "BACKGROUND")
			overlay.bg:SetAllPoints()
			overlay.bg:SetColorTexture(0, 0, 0, 1)

			-- Create canvas (holds the map art and pins, sized to the art)
			local canvas = CreateFrame("Frame", nil, overlay)
			canvas.art = canvas:CreateTexture(nil, "ARTWORK")
			canvas.art:SetAllPoints()

			-- Create game map tiles (game maps are 4x3 tiles of 256 pixels showing 1002x668 pixels)
			local tiles = {}
			for i = 1, 12 do
				local tile = canvas:CreateTexture(nil, "ARTWORK")
				local col, row = (i - 1) % 4, math.floor((i - 1) / 4)
				tile.col, tile.row = col, row
				tile:SetTexCoord(0, col == 3 and 234 / 256 or 1, 0, row == 2 and 156 / 256 or 1)
				tile:Hide()
				tiles[i] = tile
			end
			local usingTiles = false
			local nativeMissing = setmetatable({}, {__index = function() return true end}) -- 3.3.5: no dungeon map files in the client, the addon's own pictures are used

			-- Create level menu
			local levelMenu = CreateFrame("Button", nil, overlay, "WowStyle1DropdownTemplate")
			levelMenu:SetWidth(230)
			levelMenu:SetPoint("TOPLEFT", overlay, "TOPLEFT", 8, -8)

			-- Function to get level name
			local function GetLevelName(info)
				if info[2] then return info[2] end
				local instanceName = GetInstanceInfo()
				return instanceName or ""
			end

			levelMenu:SetupMenu(function(dropdown, rootDescription)
				if not levels then return end
				for i, info in ipairs(levels) do
					rootDescription:CreateRadio(GetLevelName(info), function() return i == levelIndex end, function() SelectLevel(i, true) end)
				end
			end)

			-- Function to position pins on the canvas
			local function PlacePins()
				for i = 1, #pins do
					local pin = pins[i]
					if pin:IsShown() then
						pin:ClearAllPoints()
						pin:SetPoint("CENTER", canvas, "TOPLEFT", view.baseW * view.zoom * pin.row[2], -view.baseH * view.zoom * pin.row[3])
					end
				end
			end

			-- Function to apply zoom and pan
			local function ApplyView()
				local w, h = view.baseW * view.zoom, view.baseH * view.zoom
				local maxX = math.max(0, (w - overlay:GetWidth()) / 2)
				local maxY = math.max(0, (h - overlay:GetHeight()) / 2)
				view.x = math.min(maxX, math.max(-maxX, view.x))
				view.y = math.min(maxY, math.max(-maxY, view.y))
				canvas:SetSize(w, h)
				canvas:ClearAllPoints()
				canvas:SetPoint("CENTER", overlay, "CENTER", view.x, view.y)
				if usingTiles then
					local tw, th = w * 256 / 1002, h * 256 / 668
					for i = 1, 12 do
						local tile = tiles[i]
						tile:SetSize(tile.col == 3 and w * 234 / 1002 or tw, tile.row == 2 and h * 156 / 668 or th)
						tile:ClearAllPoints()
						tile:SetPoint("TOPLEFT", canvas, "TOPLEFT", tile.col * tw, -tile.row * th)
					end
				end
				PlacePins()
			end

			-- Function to fit the art to the overlay
			local function Layout()
				if not levels or not levelIndex then return end
				local info = levels[levelIndex]
				local ow, oh = overlay:GetWidth(), overlay:GetHeight()
				if not ow or not oh or ow <= 0 or oh <= 0 then return end
				local ratio = info[3] and 668 / 1002 or 683 / 1024
				local w, h = ow, ow * ratio
				if h > oh then h = oh; w = oh / ratio end
				view.baseW, view.baseH = w, h
				ApplyView()
			end
			overlay:SetScript("OnSizeChanged", Layout)

			-- Function to get cursor position relative to overlay center
			local function GetCursorOffset()
				local scale = overlay:GetEffectiveScale()
				local cx, cy = overlay:GetCenter()
				if not cx or not scale or scale <= 0 then return end
				local x, y = GetCursorPosition()
				return x / scale - cx, y / scale - cy
			end

			-- Zoom with mouse wheel (zooms towards the cursor)
			overlay:SetScript("OnMouseWheel", function(self, delta)
				local zoom = math.min(maxZoom, math.max(1, view.zoom * wheelStep ^ delta))
				if zoom == view.zoom then return end
				local dx, dy = GetCursorOffset()
				if dx then
					local factor = zoom / view.zoom
					view.x = dx - (dx - view.x) * factor
					view.y = dy - (dy - view.y) * factor
				end
				view.zoom = zoom
				ApplyView()
			end)

			-- Pan by dragging (update script only runs while dragging)
			local drag = {}
			local function OnDragUpdate()
				if not IsMouseButtonDown("LeftButton") then
					overlay:SetScript("OnUpdate", nil)
					return
				end
				local dx, dy = GetCursorOffset()
				if not dx then return end
				view.x = drag.x + dx - drag.cx
				view.y = drag.y + dy - drag.cy
				ApplyView()
			end

			overlay:SetScript("OnMouseDown", function(self, button)
				if button ~= "LeftButton" or view.zoom <= 1 then return end
				local dx, dy = GetCursorOffset()
				if not dx then return end
				drag.cx, drag.cy, drag.x, drag.y = dx, dy, view.x, view.y
				overlay:SetScript("OnUpdate", OnDragUpdate)
			end)

			overlay:SetScript("OnMouseUp", function(self, button)
				if button == "LeftButton" then
					overlay:SetScript("OnUpdate", nil)
				elseif button == "RightButton" then
					HideOverlay()
				end
			end)

			-- Pin tooltip
			local function PinOnEnter(pin)
				local row = pin.row
				GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
				if row[1] == "boss" then
					GameTooltip:SetText(row[5], 1, 0.82, 0)
					if row[8] == 2 or row[8] == 4 then
						GameTooltip:AddLine(L["Rare"], 0.7, 0.8, 1)
					else
						GameTooltip:AddLine(L["Boss"], 1, 0.5, 0.25)
					end
					if row[6] then
						if row[6] >= UnitLevel("player") + skullLevels or row[8] == 3 then
							GameTooltip:AddLine(LEVEL .. " ??", 1, 0.1, 0.1)
						else
							local color = GetCreatureDifficultyColor(row[6])
							GameTooltip:AddLine(LEVEL .. " " .. row[6], color.r, color.g, color.b)
						end
					end
				elseif row[1] == "level" then
					GameTooltip:SetText(pin.levelIndex and GetLevelName(levels[pin.levelIndex]) or "", 1, 0.82, 0)
					GameTooltip:AddLine(L["Click to show this level."], 0.6, 0.6, 0.6)
				elseif row[4] == "raid" then
					GameTooltip:SetText(L["Raid entrance"], 1, 0.82, 0)
				else
					GameTooltip:SetText(L["Dungeon entrance"], 1, 0.82, 0)
				end
				GameTooltip:Show()
			end

			local function PinOnLeave(pin)
				if GameTooltip:IsOwned(pin) then GameTooltip:Hide() end
			end

			local function PinOnClick(pin, button)
				if button == "RightButton" then
					HideOverlay()
				elseif pin.row[1] == "level" and pin.levelIndex then
					PinOnLeave(pin)
					SelectLevel(pin.levelIndex, true)
				end
			end

			-- Function to add a circular mask to a texture
			local function AddMask(owner, texture)
				local mask = owner:CreateMaskTexture()
				mask:SetAllPoints(texture)
				mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
				texture:AddMaskTexture(mask)
			end

			-- Function to create a pin
			local function CreatePin()
				local pin = CreateFrame("Button", nil, canvas)
				pin:RegisterForClicks("LeftButtonUp", "RightButtonUp")
				pin.icon = pin:CreateTexture(nil, "ARTWORK")
				pin.icon:SetAllPoints()
				pin.highlight = pin:CreateTexture(nil, "HIGHLIGHT")
				pin.highlight:SetAllPoints()
				pin.highlight:SetBlendMode("ADD")
				pin.highlight:SetAlpha(0.5)

				-- Boss portrait and ring
				pin.portrait = pin:CreateTexture(nil, "ARTWORK")
				pin.portrait:SetPoint("TOPLEFT", 2, -2)
				pin.portrait:SetPoint("BOTTOMRIGHT", -2, 2)
				AddMask(pin, pin.portrait)
				pin.ring = pin:CreateTexture(nil, "OVERLAY", nil, 1)
				pin.ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
				pin.ring:SetTexCoord(0, 0.6, 0, 0.6)
				pin.ring:SetSize((bossSize - 4) * ringScale, (bossSize - 4) * ringScale)
				pin.ring:SetPoint("CENTER", pin.portrait, "CENTER")

				-- Elite and rare dragon
				local s = (bossSize - 4) / 64
				pin.dragon = pin:CreateTexture(nil, "OVERLAY", nil, 2)
				pin.dragon:SetTexture(pinPath)
				pin.dragon:SetSize(256 * s, 128 * s)
				pin.dragon:SetPoint("CENTER", pin, "CENTER", -54 * s, -20 * s)

				-- Level badge
				local badgeSize = 16 * s * 64 / 34
				pin.badge = CreateFrame("Frame", nil, pin)
				pin.badge:SetSize(badgeSize, badgeSize)
				pin.badge:SetPoint("CENTER", pin, "CENTER", 19.5 * s, -22 * s)
				pin.badge.ring = pin.badge:CreateTexture(nil, "BORDER")
				pin.badge.ring:SetAllPoints()
				pin.badge.fill = pin.badge:CreateTexture(nil, "ARTWORK")
				pin.badge.fill:SetPoint("TOPLEFT", 1.5, -1.5)
				pin.badge.fill:SetPoint("BOTTOMRIGHT", -1.5, 1.5)
				pin.badge.fill:SetColorTexture(0.05, 0.04, 0.03, 0.95)
				AddMask(pin.badge, pin.badge.ring)
				AddMask(pin.badge, pin.badge.fill)
				pin.badge.text = pin.badge:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				pin.badge.text:SetPoint("CENTER", 0.5, 0)
				local font, _, flags = pin.badge.text:GetFont()
				if font then pin.badge.text:SetFont(font, 8, flags) end
				pin.badge.skull = pin.badge:CreateTexture(nil, "OVERLAY")
				pin.badge.skull:SetSize(badgeSize - 5, badgeSize - 5)
				pin.badge.skull:SetPoint("CENTER")
				pin.badge.skull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")

				pin:SetScript("OnEnter", PinOnEnter)
				pin:SetScript("OnLeave", PinOnLeave)
				pin:SetScript("OnClick", PinOnClick)
				return pin
			end

			-- Function to style a pin for its row
			local function StylePin(pin, row)
				local isBoss = row[1] == "boss"
				local isRare = isBoss and (row[8] == 2 or row[8] == 4)
				local size = isRare and rareSize or isBoss and bossSize or pinSize
				pin:SetSize(size, size)
				if isBoss then
					-- Scale ring and level badge to the pin size
					local s = (size - 4) / 64
					local badgeSize = 16 * s * 64 / 34
					pin.ring:SetSize((size - 4) * ringScale, (size - 4) * ringScale)
					pin.badge:SetSize(badgeSize, badgeSize)
					pin.badge:ClearAllPoints()
					pin.badge:SetPoint("CENTER", pin, "CENTER", 19.5 * s, -22 * s)
					pin.badge.skull:SetSize(badgeSize - 5, badgeSize - 5)
				end
				pin.portrait:SetShown(isBoss)
				pin.ring:SetShown(isBoss)
				pin.icon:SetShown(not isBoss)
				pin.highlight:SetShown(not isBoss)
				pin.dragon:Hide()
				pin.badge:Hide()
				if isBoss then
					if row[7] and SetPortraitTextureFromCreatureDisplayID then
						SetPortraitTextureFromCreatureDisplayID(pin.portrait, row[7])
					else
						pin.portrait:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
					end
					local style = pinStyles[row[8]] or pinStyles[0]
					-- Rares are smaller, have a silver ring and no dragon
					if isRare then
						pin.ring:SetVertexColor(0.7, 0.8, 1)
					else
						pin.ring:SetVertexColor(1, 1, 1)
					end
					if style[4] and not isRare then
						pin.dragon:SetTexCoord(0, 1, style[4] * 0.25, (style[4] + 1) * 0.25)
						pin.dragon:Show()
					end
					local level = row[6]
					local isSkull = row[8] == 3 or (level and level >= UnitLevel("player") + skullLevels)
					if level or isSkull then
						pin.badge.ring:SetColorTexture(style[1], style[2], style[3], 1)
						pin.badge.text:SetShown(not isSkull)
						pin.badge.skull:SetShown(isSkull)
						if not isSkull then
							local color = GetCreatureDifficultyColor(level)
							pin.badge.text:SetText(level)
							pin.badge.text:SetTextColor(color.r, color.g, color.b)
						end
						pin.badge:Show()
					end
				elseif row[1] == "entrance" then
					SetIcon(pin.icon, row[4] == "raid" and "Raid" or "Dungeon", "Interface\\Icons\\INV_Misc_Bone_Skull_02")
					SetIcon(pin.highlight, row[4] == "raid" and "Raid" or "Dungeon", "Interface\\Icons\\INV_Misc_Bone_Skull_02")
					pin.icon:SetRotation(0)
					pin.highlight:SetRotation(0)
				else
					-- Level change arrow (points up for a level above, down for a level below)
					local rotation = row[5] and 0 or math.pi
					SetIcon(pin.icon, "Garr_LevelUpgradeArrow", "Interface\\Icons\\INV_Misc_Map_01")
					SetIcon(pin.highlight, "Garr_LevelUpgradeArrow", "Interface\\Icons\\INV_Misc_Map_01")
					pin.icon:SetRotation(rotation)
					pin.highlight:SetRotation(rotation)
				end
			end

			-- Function to show pins for a map
			local function UpdatePins(mapID)
				local rows = dungeonPins[mapID]
				local count = 0
				if rows then
					-- Draw rares above other pins and bosses above rares
					for pass = 1, 3 do
						for i = 1, #rows do
							local row = rows[i]
							local index
							if row[1] == "level" then
								for j = 1, #levels do
									if levels[j][1] == row[4] then index = j; break end
								end
							end
							local rowPass = row[1] ~= "boss" and 1 or (row[8] == 2 or row[8] == 4) and 2 or 3
							if pass == rowPass and (row[1] ~= "level" or index) then
								count = count + 1
								local pin = pins[count] or CreatePin()
								pins[count] = pin
								pin.row = row
								pin.levelIndex = index
								pin:SetFrameLevel(canvas:GetFrameLevel() + count * 4)
								pin.badge:SetFrameLevel(pin:GetFrameLevel() + 2)
								StylePin(pin, row)
								pin:Show()
							end
						end
					end
				end
				for i = count + 1, #pins do
					pins[i]:Hide()
				end
			end

			-- Function to show a level
			SelectLevel = function(index, byUser)
				if not levels or not levels[index] then return end
				if byUser then chosenLevel[instanceID] = index end
				local info = levels[index]
				if levelIndex ~= index or shownMapID ~= info[1] then
					levelIndex, shownMapID = index, info[1]
					-- Use the game map (Scholomance uses map art in the addon folder)
					usingTiles = false
					local native = info[3]
					if native and not nativeMissing[native] then
						local path = "Interface\\WorldMap\\" .. native
						local fileID
						if GetFileIDFromPath then
							fileID = GetFileIDFromPath(path .. "1")
						else
							tiles[1]:SetTexture(path .. "1")
							fileID = tiles[1]:GetTextureFileID()
						end
						if fileID and fileID > 0 then
							for i = 1, 12 do
								local tile = tiles[i]
								tile:SetTexture(path .. i)
								tile:SetTexCoord(0, tile.col == 3 and 234 / 256 or 1, 0, tile.row == 2 and 156 / 256 or 1)
							end
							usingTiles = true
						else
							nativeMissing[native] = true
						end
					end
					if not usingTiles and native and bundledArt[native] then
						-- Game map is not in this game locale so use the copy in the addon folder
						local first = bundledArt[native] * 12
						for i = 1, 12 do
							local tile = tiles[i]
							local slot = (first + i - 1) % 256
							local x, y = (slot % 16) * 256, math.floor(slot / 16) * 256
							local w, h = tile.col == 3 and 234 or 256, tile.row == 2 and 156 or 256
							tile:SetTexture(bundlePath .. string.format("%02d", math.floor((first + i - 1) / 256) + 1))
							tile:SetTexCoord((x + 0.5) / 4096, (x + w - 0.5) / 4096, (y + 0.5) / 4096, (y + h - 0.5) / 4096)
						end
						usingTiles = true
					end
					if not usingTiles and not info[4] then
						-- Game map is missing from the client so show the normal map instead
						levelIndex, shownMapID = nil, nil
						overlay:Hide()
						return
					end
					for i = 1, 12 do tiles[i]:SetShown(usingTiles) end
					canvas.art:SetShown(not usingTiles)
					if not usingTiles then
						local x, y = info[4], info[5]
						canvas.art:SetTexture(artPath)
						canvas.art:SetTexCoord((x + 0.5) / 2048, (x + 1024 - 0.5) / 2048, (y + 0.5) / 2048, (y + 683 - 0.5) / 2048)
					end
					view.zoom, view.x, view.y = 1, 0, 0
					UpdatePins(info[1])
					Layout()
				end
				levelMenu:SetShown(#levels > 1)
				levelMenu:GenerateMenu()
			end

			-- Function to hide the overlay until the map is opened again
			HideOverlay = function()
				if previewID then LeaMapsLC.StopPreview() else hiddenFor = instanceID end
				Refresh()
			end

			-- Function to show or hide the overlay
			Refresh = function()
				local art, id
				-- End the preview if the world map has been changed to another zone
				if previewID and GetCurrentMapAreaID() ~= previewMapID then LeaMapsLC.StopPreview() end
				if WorldMapFrame:IsShown() and previewID then
					art, id = dungeonArt[previewID], previewID
				elseif WorldMapFrame:IsShown() then
					local mapID = InstanceMapID()
					local playerMap = areaAtOpen
					if mapID and dungeonArt[mapID] and hiddenFor ~= mapID and playerMap and GetCurrentMapAreaID() == playerMap then
						art, id = dungeonArt[mapID], mapID
					end
				end
				if not art then
					overlay:Hide()
					return
				end
				if id ~= instanceID then
					instanceID, levels, levelIndex, shownMapID = id, art, nil, nil
				end
				-- Use the level picked by the user, otherwise the level the player is on
				local index = chosenLevel[id]
				if not index then
					local bestMap = C_Map.GetBestMapForUnit("player")
					for i = 1, #art do
						if art[i][1] == bestMap then index = i; break end
					end
				end
				overlay:Show()
				SelectLevel(index or levelIndex or 1)
			end

			-- Keep the map footer and scale handle above the overlay
			local raised = {}
			overlay:SetScript("OnShow", function()
				local top = 2000
				local manager = WorldMapFrame.GetPinFrameLevelsManager and WorldMapFrame:GetPinFrameLevelsManager()
				if manager and manager.GetValidFrameLevel then top = manager:GetValidFrameLevel("PIN_FRAME_LEVEL_TOPMOST", 1000) end
				overlay:SetFrameLevel(math.min(top + 100, 9000))
				canvas:SetFrameLevel(overlay:GetFrameLevel() + 1)
				for i = 1, #pins do
					pins[i]:SetFrameLevel(canvas:GetFrameLevel() + i * 4)
					pins[i].badge:SetFrameLevel(pins[i]:GetFrameLevel() + 2)
				end
				levelMenu:SetFrameLevel(overlay:GetFrameLevel() + 200)
				local offset = 300
				for void, key in ipairs({"footer", "scaleHandle", "scaleMouse"}) do
					local frame = headerMenus[key]
					if frame then
						raised[frame] = raised[frame] or frame:GetFrameLevel()
						frame:SetFrameLevel(overlay:GetFrameLevel() + offset)
						offset = offset + 5
					end
				end
				if shownMapID then UpdatePins(shownMapID) end -- Level colours depend on player level
				Layout()
			end)

			overlay:SetScript("OnHide", function()
				overlay:SetScript("OnUpdate", nil)
				for frame, level in pairs(raised) do
					frame:SetFrameLevel(level)
				end
				wipe(raised)
				if GameTooltip:GetOwner() and GameTooltip:GetOwner():GetParent() == canvas then GameTooltip:Hide() end
			end)

			-- Update when the map is opened, the map changes or the player changes zone
			WorldMapFrame:HookScript("OnShow", function()
				hiddenFor = nil
				areaAtOpen = GetCurrentMapAreaID() -- 3.3.5: the map opens on the player's zone
				if previewID then LeaMapsLC.StopPreview() end
				wipe(chosenLevel)
				view.zoom, view.x, view.y = 1, 0, 0
				Refresh()
			end)
			mapEvents:SetScript("OnEvent", function() if WorldMapFrame:IsShown() then Refresh() end end)

			local dungeonEvents = CreateFrame("Frame")
			dungeonEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
			dungeonEvents:RegisterEvent("ZONE_CHANGED_NEW_AREA")
			dungeonEvents:RegisterEvent("ZONE_CHANGED")
			dungeonEvents:RegisterEvent("ZONE_CHANGED_INDOORS")
			dungeonEvents:SetScript("OnEvent", function()
				if WorldMapFrame:IsShown() then Refresh() end
			end)

			-- Preview dungeon maps without being in the dungeon (/ltm dun)
			local previewList = {
				{389, "Ragefire Chasm"},
				{36, "The Deadmines"},
				{43, "Wailing Caverns"},
				{33, "Shadowfang Keep"},
				{34, "The Stockade"},
				{48, "Blackfathom Deeps"},
				{90, "Gnomeregan"},
				{47, "Razorfen Kraul"},
				{189, "Scarlet Monastery"},
				{129, "Razorfen Downs"},
				{70, "Uldaman"},
				{209, "Zul'Farrak"},
				{349, "Maraudon"},
				{109, "Temple of Atal'Hakkar"},
				{230, "Blackrock Depths"},
				{229, "Blackrock Spire"},
				{409, "Molten Core"},
				{469, "Blackwing Lair"},
				{429, "Dire Maul"},
				{289, "Scholomance"},
				{329, "Stratholme"},
				{309, "Zul'Gurub"},
				{249, "Onyxia's Lair"},
				{509, "Ruins of Ahn'Qiraj"},
				{531, "Temple of Ahn'Qiraj"},
				{533, "Naxxramas"},
			}

			-- Arrow keys change the previewed map (key frame only exists and listens while previewing, never in combat)
			local keyFrame
			local function StartPreviewKeys()
				if InCombatLockdown() then return end
				if not keyFrame then
					keyFrame = CreateFrame("Frame", nil, overlay)
					keyFrame:EnableKeyboard(true)
					keyFrame:SetPropagateKeyboardInput(true)
					keyFrame:SetScript("OnKeyDown", function(self, key)
						if InCombatLockdown() then return end
						if key == "LEFT" or key == "RIGHT" then
							self:SetPropagateKeyboardInput(false)
							LeaMapsLC.PreviewDungeon(key == "LEFT" and "prev" or "next")
						else
							self:SetPropagateKeyboardInput(true)
						end
					end)
					-- Stop listening when combat starts or the frame hides
					keyFrame:SetScript("OnEvent", function(self) self:Hide() end)
					keyFrame:SetScript("OnHide", function(self) self:UnregisterAllEvents() end)
				end
				keyFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
				keyFrame:Show()
			end

			-- Check which game map textures are in the client (/ltm duncheck)
			LeaMapsLC.CheckDungeonMaps = function()
				if not GetFileIDFromPath then
					LeaMapsLC:Print("GetFileIDFromPath is not available in this client.")
					return
				end
				local checked, bundled, missing = 0, 0, 0
				for void, levels in pairs(dungeonArt) do
					for void, info in ipairs(levels) do
						if info[3] then
							checked = checked + 1
							for i = 1, 12 do
								if not GetFileIDFromPath("Interface\\WorldMap\\" .. info[3] .. i) then
									if bundledArt[info[3]] then
										bundled = bundled + 1
									else
										missing = missing + 1
										LeaMapsLC:Print("Missing: " .. info[3] .. i .. " (map " .. info[1] .. ")")
									end
									break
								end
							end
						end
					end
				end
				LeaMapsLC:Print(checked .. " game maps checked, " .. (checked - bundled - missing) .. " in the game, " .. bundled .. " using the addon copy, " .. missing .. " missing.")
			end

			-- Dungeon icons on the world map show the dungeon map when clicked (icon name = instance map IDs)
			LeaMapsLC.DungeonMapsByName = {
				[L["Uldaman"]] = {70},
				[L["Scarlet Monastery"]] = {189},
				[L["Shadowfang Keep"]] = {33},
				[L["Scholomance"]] = {289},
				[L["Stratholme (Main Gate)"]] = {329},
				[L["Stratholme (Service Gate)"]] = {329},
				[L["Naxxramas"]] = {533},
				[L["Gnomeregan"]] = {90},
				[L["Blackrock Mountain"]] = {230, 229, 409, 469},
				[L["Zul'Gurub"]] = {309},
				[L["Temple of Atal'Hakkar"]] = {109},
				[L["The Deadmines"]] = {36},
				[L["The Stockade"]] = {34},
				[L["Wailing Caverns"]] = {43},
				[L["Razorfen Kraul"]] = {47},
				[L["Razorfen Downs"]] = {129},
				[L["Blackfathom Deeps"]] = {48},
				[L["Maraudon"]] = {349},
				[L["Dire Maul (North)"]] = {429},
				[L["Dire Maul (West)"]] = {429},
				[L["Dire Maul (East)"]] = {429},
				[L["Onyxia's Lair"]] = {249},
				[L["Zul'Farrak"]] = {209},
				[L["Ahn'Qiraj"]] = {509, 531},
				[L["Ragefire Chasm"]] = {389},
			}

			-- Function to show the dungeon map for an instance
			local function ShowDungeonMap(id)
				for i = 1, #previewList do
					if previewList[i][1] == id then LeaMapsLC.PreviewDungeon(tostring(i), true, true) return end
				end
			end

			-- Function to show the dungeon map for a clicked dungeon icon (a menu if the icon has several)
			LeaMapsLC.OpenDungeonMaps = function(owner, title, ids)
				if #ids == 1 or not MenuUtil or not MenuUtil.CreateContextMenu then
					ShowDungeonMap(ids[1])
					return
				end
				MenuUtil.CreateContextMenu(owner, function(owner, rootDescription)
					rootDescription:CreateTitle(title)
					for void, id in ipairs(ids) do
						local name = GetRealZoneText(id)
						if not name or name == "" then
							for i = 1, #previewList do
								if previewList[i][1] == id then name = previewList[i][2] end
							end
						end
						rootDescription:CreateButton(name, function() ShowDungeonMap(id) end)
					end
				end)
			end

			LeaMapsLC.StopPreview = function()
				previewID = nil
				if keyFrame then keyFrame:Hide() end
				if LeaMapsLC.UpdateZoneMenus then LeaMapsLC.UpdateZoneMenus() end
			end

			-- Functions used by the zone menus (Dungeons entry)
			LeaMapsLC.GetDungeonList = function()
				local list = {}
				for i = 1, #previewList do
					local id = previewList[i][1]
					local name = GetRealZoneText(id)
					if not name or name == "" then name = previewList[i][2] end
					list[i] = {id = id, name = name}
				end
				return list
			end
			LeaMapsLC.GetDungeonPreview = function() return previewID end
			LeaMapsLC.ShowDungeonPreview = function(id) ShowDungeonMap(id) end
			LeaMapsLC.EndDungeonPreview = function()
				LeaMapsLC.StopPreview()
				Refresh()
			end

			-- quiet: no chat messages, noKeys: no arrow keys (used when clicking dungeon icons)
			LeaMapsLC.PreviewDungeon = function(arg, quiet, noKeys)
				if not WorldMapFrame:IsShown() then
					LeaMapsLC:Print("Open the world map first.")
					return
				end
				if arg == "off" then
					LeaMapsLC.StopPreview()
					Refresh()
					return
				end
				local index = tonumber(arg)
				if arg == "prev" then
					index = ((previewIndex or 1) - 2) % #previewList + 1
				elseif arg == "next" then
					index = (previewIndex or 0) % #previewList + 1
				elseif not index and arg then
					-- Find instance by part of its name
					for i = 1, #previewList do
						if strfind(strlower(previewList[i][2]), arg, 1, true) then index = i; break end
					end
				end
				index = index or ((previewIndex or 0) % #previewList + 1)
				if not previewList[index] then
					LeaMapsLC:Print("Use a number from 1 to " .. #previewList .. ".")
					return
				end
				local keysOn = keyFrame and keyFrame:IsShown()
				previewIndex, previewID, previewMapID = index, previewList[index][1], GetCurrentMapAreaID()
				chosenLevel[previewID] = nil
				Refresh()
				if not noKeys then StartPreviewKeys() end
				if LeaMapsLC.UpdateZoneMenus then LeaMapsLC.UpdateZoneMenus() end
				if not quiet then
					if not keysOn and keyFrame and keyFrame:IsShown() then LeaMapsLC:Print("Use the left and right arrow keys to change map.") end
					LeaMapsLC:Print(index .. "/" .. #previewList .. ": " .. previewList[index][2])
				end
			end


			-- Instance names (English and translated) to instance map IDs
			instanceByName = {}
			for void, entry in ipairs(previewList) do
				instanceByName[entry[2]] = entry[1]
				instanceByName[L[entry[2]]] = entry[1]
			end
			for name, ids in pairs(LeaMapsLC.DungeonMapsByName or {}) do
				if #ids == 1 then instanceByName[name] = ids[1] end
			end

		end
	end
