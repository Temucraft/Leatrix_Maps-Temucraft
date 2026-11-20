
	----------------------------------------------------------------------
	-- Leatrix Maps (Temucraft): our extra zones
	----------------------------------------------------------------------

	-- Adds the zone levels and icons of the zones Leatrix Maps doesn't know (Leatrix_Maps_TemucraftData.lua, made
	-- by tools/gen_ltm_data.py from the Temucraft world database). Keys are GetCurrentMapAreaID().

	local void, Leatrix_Maps = ...
	local L = Leatrix_Maps.L

	-- Icons: added to the Leatrix Maps icon table (after Leatrix_Maps_Icons.lua, before Leatrix_Maps.lua reads it)
	do
		local icons, extra = Leatrix_Maps["Icons"], Leatrix_Maps["TemucraftIcons"]
		if icons and extra then
			for mapID, pins in pairs(extra) do
				icons[mapID] = icons[mapID] or {}
				for i = 1, #pins do
					local pin = pins[i]
					-- Localize the fixed words (the names come from the database in English)
					if pin[1] == "Spirit" then pin[4] = L["Spirit Healer"] end
					if pin[5] then pin[5] = L[pin[5]] end
					tinsert(icons[mapID], pin)
				end
			end
		end
	end

	-- Zone levels: called from the zone levels code in Leatrix_Maps.lua with its zone table (keyed by zone name)
	-- and its map ID to {continent, zone index, zone name} table. Zones Leatrix Maps has are not changed.
	function Leatrix_Maps.TemucraftZoneLevels(zoneData, mapIDToCZ)
		local zones = Leatrix_Maps["TemucraftZones"]
		if not zones or not next(zones) then return end

		-- Leatrix Maps reads the zone names of the first four continents: read the others too if we need them
		local names = {}
		for mapID, cz in pairs(mapIDToCZ) do names[mapID] = cz[3] end
		local missing = false
		for mapID in pairs(zones) do
			if not names[mapID] then missing = true break end
		end
		if missing then
			local continents = select("#", GetMapContinents())
			if continents > 4 then
				for cont = 5, continents do
					for zi, zoneName in ipairs({GetMapZones(cont)}) do
						SetMapZoom(cont, zi)
						names[GetCurrentMapAreaID()] = zoneName
					end
				end
				SetMapToCurrentZone()
			end
		end

		-- The map label shows the zone name in the client's language; the English name is kept as well
		for mapID, z in pairs(zones) do
			local entry = {z[2], z[3]}
			if z[1] and not zoneData[z[1]] then zoneData[z[1]] = entry end
			local localName = names[mapID]
			if localName and not zoneData[localName] then zoneData[localName] = entry end
		end
	end
