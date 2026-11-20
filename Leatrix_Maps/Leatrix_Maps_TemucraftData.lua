-- Made by tools/gen_ltm_data.py from the Temucraft world database and WorldMapArea.dbc. Do not edit.
-- Keys are GetCurrentMapAreaID() (the WorldMapArea ID + 1). Leatrix_Maps_Temucraft.lua adds this to Leatrix Maps.

local void, Leatrix_Maps = ...

-- Zone levels: [map area ID] = {"English zone name", lowest level, highest level}
Leatrix_Maps["TemucraftZones"] = {
	[701] = {"Twilight Highlands", 58, 62},
	[721] = {"Uldum", 59, 61},
	[865] = {"Northshire", 2, 4},
	[867] = {"Coldridge Valley", 1, 4},
	[889] = {"Shadowglen Start", 2, 4},
	[890] = {"Valley of Trials Start", 1, 3},
	[893] = {"Deathknell Start", 1, 4},
}

-- Icons, in the Leatrix_Maps_Icons.lua format: {type, x, y, name, subtitle, texture, low level, high level}
Leatrix_Maps["TemucraftIcons"] = {
	--[[Tanaris]] [162] = {
		{"Dungeon", 54.7, 59.1, "Well of Eternity", "Dungeon", "Dungeon", 80, 83},
	},
	--[[Hyjal]] [607] = {
		{"Raid", 47.4, 78.0, "Firelands", "Raid", "Raid", 80, 83},
		{"Spirit", 79.0, 61.3, "Spirit Healer", nil, "Spirit"},
	},
	--[[Uldum]] [721] = {
		{"Raid", 38.3, 80.7, "Throne of the Four Winds", "Raid", "Raid", 80, 83},
		{"Dungeon", 60.5, 64.3, "Lost City of the Tol'vir", "Dungeon", "Dungeon", 79, 82},
		{"Dungeon", 69.1, 53.2, "Halls of Origination", "Dungeon", "Dungeon", 80, 82},
		{"Dungeon", 76.8, 84.6, "The Vortex Pinnacle", "Dungeon", "Dungeon", 77, 80},
	},
}
