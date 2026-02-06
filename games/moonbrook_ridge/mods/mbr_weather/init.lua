-- mbr_weather: Dynamic weather system with 8 types and seasonal effects

-- =============================================================================
-- Weather State
-- =============================================================================

mbr.weather = {
	current = "clear",
	duration = 0,
	timer = 0,
}

-- Per-player tracking
local player_huds = {}
local player_spawners = {}

-- =============================================================================
-- Weather Type Definitions
-- =============================================================================

local weather_types = {
	clear = {
		description = "Clear",
		sky_color = nil,
		particles = nil,
		speed_mult = 1.0,
		fog_distance = nil,
	},
	sunny = {
		description = "Sunny",
		sky_color = {day_sky = "#87CEEB", day_horizon = "#C6E2FF"},
		particles = nil,
		speed_mult = 1.0,
		fog_distance = nil,
	},
	cloudy = {
		description = "Cloudy",
		sky_color = {day_sky = "#8E8E8E", day_horizon = "#A0A0A0"},
		particles = nil,
		speed_mult = 1.0,
		fog_distance = nil,
	},
	rainy = {
		description = "Rainy",
		sky_color = {day_sky = "#6B7B8D", day_horizon = "#8899AA"},
		particles = {
			texture = "[fill:2x4:#4488CC",
			amount = 50,
			time = 2,
			minvel = {x = -0.5, y = -8, z = -0.5},
			maxvel = {x = 0.5, y = -6, z = 0.5},
			minacc = {x = 0, y = -2, z = 0},
			maxacc = {x = 0, y = -1, z = 0},
			minexptime = 0.8,
			maxexptime = 1.5,
			minsize = 0.5,
			maxsize = 1.0,
		},
		speed_mult = 1.0,
		fog_distance = nil,
		waters_crops = true,
	},
	stormy = {
		description = "Stormy",
		sky_color = {day_sky = "#3D4550", day_horizon = "#555F6B"},
		particles = {
			texture = "[fill:2x4:#3366AA",
			amount = 80,
			time = 2,
			minvel = {x = -2, y = -12, z = -2},
			maxvel = {x = 2, y = -8, z = 2},
			minacc = {x = 0, y = -3, z = 0},
			maxacc = {x = 0, y = -2, z = 0},
			minexptime = 0.5,
			maxexptime = 1.0,
			minsize = 0.5,
			maxsize = 1.2,
		},
		speed_mult = 0.9,
		fog_distance = nil,
		lightning = true,
	},
	snowy = {
		description = "Snowy",
		sky_color = {day_sky = "#C8D0DA", day_horizon = "#E0E8F0"},
		particles = {
			texture = "[fill:3x3:#EEEEFF",
			amount = 30,
			time = 3,
			minvel = {x = -1, y = -2, z = -1},
			maxvel = {x = 1, y = -1, z = 1},
			minacc = {x = 0, y = -0.5, z = 0},
			maxacc = {x = 0, y = -0.2, z = 0},
			minexptime = 2.0,
			maxexptime = 4.0,
			minsize = 1.0,
			maxsize = 2.0,
		},
		speed_mult = 1.0,
		fog_distance = nil,
	},
	windy = {
		description = "Windy",
		sky_color = {day_sky = "#90B8D8", day_horizon = "#B0CCE0"},
		particles = {
			texture = "[fill:3x2:#66AA44",
			amount = 15,
			time = 2,
			minvel = {x = 4, y = -1, z = -1},
			maxvel = {x = 8, y = 1, z = 1},
			minacc = {x = 1, y = -0.5, z = 0},
			maxacc = {x = 2, y = 0, z = 0},
			minexptime = 1.0,
			maxexptime = 2.5,
			minsize = 0.5,
			maxsize = 1.5,
		},
		speed_mult = 0.95,
		fog_distance = nil,
	},
	foggy = {
		description = "Foggy",
		sky_color = {day_sky = "#B0B0B0", day_horizon = "#C0C0C0"},
		particles = nil,
		speed_mult = 1.0,
		fog_distance = 30,
	},
}

-- =============================================================================
-- Seasonal Probability Weights
-- =============================================================================

local season_weights = {
	Spring = {clear = 15, sunny = 15, cloudy = 25, rainy = 30, stormy = 5, windy = 10},
	Summer = {clear = 25, sunny = 35, cloudy = 10, rainy = 10, stormy = 10, windy = 10},
	Fall   = {clear = 15, sunny = 10, cloudy = 20, rainy = 20, stormy = 5, windy = 15, foggy = 15},
	Winter = {clear = 10, sunny = 5, cloudy = 15, snowy = 40, windy = 10, foggy = 20},
}

-- =============================================================================
-- Weighted Random Selection
-- =============================================================================

local function pick_weighted_weather(season_name)
	local weights = season_weights[season_name]
	if not weights then
		weights = season_weights["Spring"]
	end

	local total = 0
	for _, w in pairs(weights) do
		total = total + w
	end

	local roll = math.random(1, total)
	local cumulative = 0
	for weather_name, w in pairs(weights) do
		cumulative = cumulative + w
		if roll <= cumulative then
			return weather_name
		end
	end

	return "clear"
end

local function random_duration()
	return math.random(1800, 7200)
end

-- =============================================================================
-- Sky Override
-- =============================================================================

local function apply_sky(player, weather_def)
	if weather_def.sky_color then
		player:set_sky({
			type = "regular",
			sky_color = weather_def.sky_color,
		})
	else
		player:set_sky({type = "regular"})
	end

	if weather_def.fog_distance then
		player:set_sky({fog = {fog_start = 0.0, fog_distance = weather_def.fog_distance}})
	end
end

-- =============================================================================
-- Movement Speed Override
-- =============================================================================

local function apply_speed(player, weather_def)
	player:set_physics_override({speed = weather_def.speed_mult})
end

-- =============================================================================
-- Particle Spawners
-- =============================================================================

local function remove_spawner(player_name)
	local sid = player_spawners[player_name]
	if sid then
		core.delete_particlespawner(sid)
		player_spawners[player_name] = nil
	end
end

local function add_spawner(player, weather_def)
	local name = player:get_player_name()
	remove_spawner(name)

	local pdef = weather_def.particles
	if not pdef then
		return
	end

	local pos = player:get_pos()
	local sid = core.add_particlespawner({
		amount = pdef.amount,
		time = pdef.time,
		minpos = {x = pos.x - 15, y = pos.y + 5, z = pos.z - 15},
		maxpos = {x = pos.x + 15, y = pos.y + 15, z = pos.z + 15},
		minvel = pdef.minvel,
		maxvel = pdef.maxvel,
		minacc = pdef.minacc,
		maxacc = pdef.maxacc,
		minexptime = pdef.minexptime,
		maxexptime = pdef.maxexptime,
		minsize = pdef.minsize,
		maxsize = pdef.maxsize,
		texture = pdef.texture,
		playername = name,
		collisiondetection = true,
		collision_removal = true,
	})
	player_spawners[name] = sid
end

-- =============================================================================
-- Lightning Flash (HUD-based screen flash for storms)
-- =============================================================================

local lightning_timer = 0
local lightning_interval = 0

local function reset_lightning_interval()
	lightning_interval = math.random(8, 25)
	lightning_timer = 0
end

local function do_lightning_flash()
	for _, player in ipairs(core.get_connected_players()) do
		local flash_id = player:hud_add({
			hud_elem_type = "image",
			position = {x = 0.5, y = 0.5},
			scale = {x = -100, y = -100},
			text = "[fill:1x1:#FFFFFFCC",
			z_index = 1000,
			alignment = {x = 0, y = 0},
		})
		if flash_id then
			local pname = player:get_player_name()
			core.after(0.15, function()
				local p = core.get_player_by_name(pname)
				if p then
					p:hud_remove(flash_id)
				end
			end)
		end
	end
end

-- =============================================================================
-- HUD: Weather Display
-- =============================================================================

local weather_icons = {
	clear  = "☀",
	sunny  = "☀",
	cloudy = "☁",
	rainy  = "🌧",
	stormy = "⛈",
	snowy  = "❄",
	windy  = "🌬",
	foggy  = "🌫",
}

local function setup_hud(player)
	local name = player:get_player_name()
	player_huds[name] = {}

	player_huds[name].weather_text = player:hud_add({
		hud_elem_type = "text",
		position = {x = 1.0, y = 0.0},
		offset = {x = -10, y = 20},
		text = "",
		number = 0xFFFFFF,
		alignment = {x = -1, y = 1},
		scale = {x = 200, y = 20},
		z_index = 10,
	})
end

local function update_hud_text()
	local def = weather_types[mbr.weather.current]
	local icon = weather_icons[mbr.weather.current] or ""
	local text = icon .. " " .. (def and def.description or mbr.weather.current)

	for _, player in ipairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local huds = player_huds[name]
		if huds and huds.weather_text then
			player:hud_change(huds.weather_text, "text", text)
		end
	end
end

-- =============================================================================
-- Weather Change Logic
-- =============================================================================

local function apply_weather_to_player(player)
	local def = weather_types[mbr.weather.current]
	if not def then return end

	apply_sky(player, def)
	apply_speed(player, def)
	add_spawner(player, def)
end

local function apply_weather_all_players()
	for _, player in ipairs(core.get_connected_players()) do
		apply_weather_to_player(player)
	end
	update_hud_text()
end

function mbr.weather.set_weather(weather_type)
	if not weather_types[weather_type] then
		core.log("warning", "[mbr_weather] Unknown weather type: " .. tostring(weather_type))
		return
	end

	mbr.weather.current = weather_type
	mbr.weather.duration = random_duration()
	mbr.weather.timer = 0

	if weather_types[weather_type].lightning then
		reset_lightning_interval()
	end

	apply_weather_all_players()
	core.log("action", "[mbr_weather] Weather changed to: " .. weather_type)
end

function mbr.weather.get_weather()
	return mbr.weather.current
end

-- =============================================================================
-- Player Join / Leave
-- =============================================================================

core.register_on_joinplayer(function(player)
	setup_hud(player)
	apply_weather_to_player(player)
	update_hud_text()
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	remove_spawner(name)
	player_huds[name] = nil
end)

-- =============================================================================
-- Globalstep: Weather Timer and Particle Refresh
-- =============================================================================

local particle_refresh_timer = 0

core.register_globalstep(function(dtime)
	-- Weather duration countdown
	mbr.weather.timer = mbr.weather.timer + dtime
	if mbr.weather.timer >= mbr.weather.duration then
		local season_name = mbr.time.get_season_name()
		local new_weather = pick_weighted_weather(season_name)
		mbr.weather.set_weather(new_weather)
	end

	-- Lightning during storms
	local def = weather_types[mbr.weather.current]
	if def and def.lightning then
		lightning_timer = lightning_timer + dtime
		if lightning_timer >= lightning_interval then
			do_lightning_flash()
			reset_lightning_interval()
		end
	end

	-- Refresh particle spawners periodically (they expire)
	particle_refresh_timer = particle_refresh_timer + dtime
	if particle_refresh_timer >= 2.0 then
		particle_refresh_timer = 0
		if def and def.particles then
			for _, player in ipairs(core.get_connected_players()) do
				add_spawner(player, def)
			end
		end
	end
end)

-- =============================================================================
-- Initialize
-- =============================================================================

mbr.weather.duration = random_duration()
reset_lightning_interval()

core.log("action", "[mbr_weather] Loaded.")
