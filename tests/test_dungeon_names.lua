-- Plain Lua 5.1 test for Leatrix Maps dungeon detection on every game language (stubs for the game API).
-- Run from the repo: lua5.1 tests/test_dungeon_names.lua Leatrix_Maps
local dir = arg[1]
local any
local anyMT = {}
anyMT.__index = function(t, k) return function() return any end end
anyMT.__call = function() return any end
any = setmetatable({}, anyMT)
local function obj()
	local o = setmetatable({}, {__index = function(t, k)
		if k == "GetWidth" or k == "GetHeight" or k == "GetFrameLevel" or k == "GetEffectiveScale" then return function() return 100 end end
		if k == "IsShown" then return function() return false end end
		return function() return any end
	end})
	return o
end
CreateFrame = function() return obj() end
WorldMapFrame = obj(); WorldMapDetailFrame = obj()
GameTooltip = obj()
strfind, strlower, wipe = string.find, string.lower, function(t) for k in pairs(t) do t[k] = nil end return t end
InCombatLockdown = function() return false end
GetCurrentMapAreaID = function() return 1 end
C_Map = {GetBestMapForUnit = function() return nil end}
local locale, instName, instKind, zoneText = "enUS", nil, "none", ""
GetLocale = function() return locale end
GetInstanceInfo = function() return instName, instKind end
GetRealZoneText = function() return zoneText end

local function load()
	local ns = {}
	assert(loadfile(dir .. "/Leatrix_Maps_DungeonNames.lua"))("Leatrix_Maps", ns)
	assert(loadfile(dir .. "/Leatrix_Maps_Dungeons.lua"))("Leatrix_Maps", ns)
	local LC = {Print = function() end}
	local L = setmetatable({}, {__index = function(t, k) return k end})
	ns.SetupDungeonMaps(LC, {}, L)
	return ns, LC
end

local fails, checks = 0, 0
local function check(cond, msg) checks = checks + 1; if not cond then fails = fails + 1; print("FAIL: " .. msg) end end

-- Every instance is found from its game name and from each zone name, on every language
local ns = {}
assert(loadfile(dir .. "/Leatrix_Maps_DungeonNames.lua"))("Leatrix_Maps", ns)
local langs = {"enUS", "deDE", "esES", "esMX", "frFR", "koKR", "ruRU", "zhCN", "zhTW"}
for _, lang in ipairs(langs) do
	locale = lang
	local _, LC = load()
	for id, entry in pairs(ns.DungeonNames) do
		local kind = (id == 409 or id == 469 or id == 309 or id == 249 or id == 509 or id == 531 or id == 533) and "raid" or "party"
		instName, instKind, zoneText = entry.map[lang], kind, "?"
		check(LC.GetInstanceMapID() == id, lang .. " instance name " .. tostring(entry.map[lang]) .. " -> " .. id .. " (got " .. tostring(LC.GetInstanceMapID()) .. ")")
		for _, z in ipairs(entry.zone and entry.zone[lang] or {}) do
			instName, zoneText = "Unknown name", z
			check(LC.GetInstanceMapID() == id, lang .. " zone name " .. z .. " -> " .. id)
		end
	end
	-- Not in an instance: nothing
	instName, instKind, zoneText = "Deadmines", "none", ""
	check(LC.GetInstanceMapID() == nil, lang .. " outside an instance")
	-- Dungeon list is in the game language
	local list = LC.GetDungeonList()
	check(#list == 26, lang .. " list has 26 dungeons")
	for _, e in ipairs(list) do
		check(e.name == ns.DungeonNames[e.id].map[lang], lang .. " list name for " .. e.id .. " is " .. tostring(e.name))
	end
end

-- The two that failed even in English before: Ahn'Qiraj Temple and Sunken Temple
locale = "enUS"; local _, LC = load()
instName, instKind, zoneText = "Ahn'Qiraj Temple", "raid", "Ahn'Qiraj"; check(LC.GetInstanceMapID() == 531, "enUS Ahn'Qiraj Temple")
instName, instKind, zoneText = "Sunken Temple", "party", "The Temple of Atal'Hakkar"; check(LC.GetInstanceMapID() == 109, "enUS Sunken Temple")
-- enGB clients use the English names
locale = "enGB"; local _, LC = load()
instName, instKind = "Todesminen", "party"; check(LC.GetInstanceMapID() == 36, "enGB client still knows other language names")
check(LC.GetDungeonList()[2].name == "Deadmines", "enGB list uses English")
-- A locale with no table (itIT, made up) falls back to English names
locale = "itIT"; local _, LC = load()
check(LC.GetDungeonList()[1].name == "Ragefire Chasm", "unknown locale falls back to English")

-- No name is shared by two instances
local seen = {}
for id, entry in pairs(ns.DungeonNames) do
	local function add(n) if seen[n] and seen[n] ~= id then check(false, "shared name " .. n) end seen[n] = id end
	for _, n in pairs(entry.map) do add(n) end
	for _, zs in pairs(entry.zone or {}) do for _, n in ipairs(zs) do add(n) end end
end

print(checks .. " checks, " .. fails .. " failed")
os.exit(fails == 0 and 0 or 1)
