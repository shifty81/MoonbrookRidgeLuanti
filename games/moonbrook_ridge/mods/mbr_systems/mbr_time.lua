-- MoonBrook Ridge: Time & Season System
-- Dynamic day/night cycle with 4 seasons (28 days each)

mbr = mbr or {}
mbr.time = {}

-- State
mbr.time.day = 1
mbr.time.season = 1
mbr.time.year = 1
mbr.time.hour = 6
mbr.time.minute = 0

mbr.time.season_names = {"Spring", "Summer", "Fall", "Winter"}
mbr.time.day_callbacks = {}
mbr.time.season_callbacks = {}

-- Last tracked timeofday for detecting day transitions
local last_timeofday = 0
local update_timer = 0

function mbr.time.get_season_name()
	return mbr.time.season_names[mbr.time.season] or "Unknown"
end

function mbr.time.get_total_day()
	return (mbr.time.year - 1) * 112 + (mbr.time.season - 1) * 28 + mbr.time.day
end

function mbr.time.is_daytime()
	return mbr.time.hour >= 6 and mbr.time.hour < 20
end

function mbr.time.register_on_new_day(func)
	table.insert(mbr.time.day_callbacks, func)
end

function mbr.time.register_on_season_change(func)
	table.insert(mbr.time.season_callbacks, func)
end

-- HUD storage per player
local time_huds = {}

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	time_huds[name] = player:hud_add({
		type = "text",
		position = {x = 0.5, y = 0},
		offset = {x = 0, y = 20},
		text = "",
		alignment = {x = 0, y = 0},
		scale = {x = 100, y = 100},
		number = 0xFFFFFF,
	})
end)

core.register_on_leaveplayer(function(player)
	time_huds[player:get_player_name()] = nil
end)

core.register_globalstep(function(dtime)
	update_timer = update_timer + dtime
	if update_timer < 1.0 then return end
	update_timer = 0

	local timeofday = core.get_timeofday()
	-- Convert to hour:minute
	local total_minutes = math.floor(timeofday * 1440)
	mbr.time.hour = math.floor(total_minutes / 60)
	mbr.time.minute = total_minutes % 60

	-- Detect day transition (timeofday wraps from ~1.0 to ~0.0)
	if timeofday < 0.1 and last_timeofday > 0.9 then
		-- New day
		mbr.time.day = mbr.time.day + 1
		if mbr.time.day > 28 then
			mbr.time.day = 1
			mbr.time.season = mbr.time.season + 1
			if mbr.time.season > 4 then
				mbr.time.season = 1
				mbr.time.year = mbr.time.year + 1
			end
			for _, func in ipairs(mbr.time.season_callbacks) do
				func(mbr.time.season, mbr.time.get_season_name())
			end
		end
		for _, func in ipairs(mbr.time.day_callbacks) do
			func(mbr.time.day, mbr.time.season)
		end
	end
	last_timeofday = timeofday

	-- Update HUD for all players
	local text = string.format("%s Day %d, Year %d - %02d:%02d",
		mbr.time.get_season_name(), mbr.time.day, mbr.time.year,
		mbr.time.hour, mbr.time.minute)
	for _, player in ipairs(core.get_connected_players()) do
		local name = player:get_player_name()
		if time_huds[name] then
			player:hud_change(time_huds[name], "text", text)
		end
	end
end)
