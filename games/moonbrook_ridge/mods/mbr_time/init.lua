-- mbr_time: Dynamic day/night cycle with seasonal system

-- =============================================================================
-- Time State
-- =============================================================================

mbr.time = {
	day = 1,
	season = 1,
	year = 1,
	hour = 6,
	minute = 0,
}

mbr.time.season_names = {"Spring", "Summer", "Fall", "Winter"}

-- Callback registries
local on_new_day_callbacks = {}
local on_season_change_callbacks = {}

-- Per-player HUD tracking
local player_huds = {}

-- Internal state
local update_timer = 0
local prev_timeofday = 0.25

-- =============================================================================
-- Helper Functions
-- =============================================================================

function mbr.time.get_season_name()
	return mbr.time.season_names[mbr.time.season] or "Unknown"
end

function mbr.time.get_total_day()
	return (mbr.time.year - 1) * 112 + (mbr.time.season - 1) * 28 + mbr.time.day
end

function mbr.time.is_daytime()
	return mbr.time.hour >= 6 and mbr.time.hour < 20
end

-- =============================================================================
-- Callback Registration
-- =============================================================================

function mbr.time.register_on_new_day(func)
	table.insert(on_new_day_callbacks, func)
end

function mbr.time.register_on_season_change(func)
	table.insert(on_season_change_callbacks, func)
end

local function fire_new_day()
	for _, func in ipairs(on_new_day_callbacks) do
		func(mbr.time.day, mbr.time.season, mbr.time.year)
	end
end

local function fire_season_change()
	for _, func in ipairs(on_season_change_callbacks) do
		func(mbr.time.season, mbr.time.get_season_name(), mbr.time.year)
	end
end

-- =============================================================================
-- Day/Season Advancement
-- =============================================================================

local function advance_day()
	mbr.time.day = mbr.time.day + 1

	if mbr.time.day > 28 then
		mbr.time.day = 1
		mbr.time.season = mbr.time.season + 1

		if mbr.time.season > 4 then
			mbr.time.season = 1
			mbr.time.year = mbr.time.year + 1
		end

		fire_season_change()
	end

	fire_new_day()
end

-- =============================================================================
-- HUD
-- =============================================================================

local function get_time_string()
	local h = string.format("%02d", mbr.time.hour)
	local m = string.format("%02d", mbr.time.minute)
	return mbr.time.get_season_name() .. " Day" .. mbr.time.day ..
		" Year" .. mbr.time.year .. " - " .. h .. ":" .. m
end

local function setup_hud(player)
	local name = player:get_player_name()
	player_huds[name] = {}

	player_huds[name].time_text = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.5, y = 0.0},
		offset = {x = 0, y = 20},
		text = get_time_string(),
		number = 0xFFFFFF,
		alignment = {x = 0, y = 1},
		scale = {x = 200, y = 20},
		z_index = 10,
	})
end

local function update_all_huds()
	local text = get_time_string()
	for _, player in ipairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local huds = player_huds[name]
		if huds and huds.time_text then
			player:hud_change(huds.time_text, "text", text)
		end
	end
end

-- =============================================================================
-- Player Join / Leave
-- =============================================================================

core.register_on_joinplayer(function(player)
	setup_hud(player)
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_huds[name] = nil
end)

-- =============================================================================
-- Globalstep: Time Tracking
-- =============================================================================

core.register_globalstep(function(dtime)
	update_timer = update_timer + dtime
	if update_timer < 1.0 then
		return
	end
	update_timer = update_timer - 1.0

	-- Read engine time and convert to 24h clock
	local timeofday = core.get_timeofday()
	mbr.time.hour = math.floor(timeofday * 24) % 24
	mbr.time.minute = math.floor((timeofday * 24 * 60) % 60)

	-- Detect dawn crossing (timeofday 0.25 = 6:00 AM) for day transition
	-- Dawn occurs when timeofday crosses from below 0.25 to at/above 0.25
	if prev_timeofday < 0.25 and timeofday >= 0.25 then
		advance_day()
	end
	prev_timeofday = timeofday

	update_all_huds()
end)

core.log("action", "[mbr_time] Loaded.")
