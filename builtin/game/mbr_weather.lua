mbr = mbr or {}

mbr.weather = {
	current = "clear",
	timer = 0,
	duration = 0,
	effect_timer = 0,
	hud_ids = {},
	particle_ids = {},
	speed_overrides = {},
}

mbr.weather.types = {
	clear = {},
	sunny = {
		sky_color = {r = 255, g = 248, b = 220},
	},
	cloudy = {
		sky_color = {r = 180, g = 180, b = 190},
	},
	rainy = {
		sky_color = {r = 150, g = 160, b = 180},
		has_particles = true,
		speed_mult = 0.95,
		waters_crops = true,
	},
	stormy = {
		sky_color = {r = 100, g = 100, b = 120},
		has_particles = true,
		speed_mult = 0.85,
		has_lightning = true,
		waters_crops = true,
	},
	snowy = {
		sky_color = {r = 230, g = 235, b = 245},
		has_particles = true,
		speed_mult = 0.9,
	},
	windy = {
		sky_color = {r = 200, g = 210, b = 220},
		speed_mult = 0.95,
	},
	foggy = {
		sky_color = {r = 190, g = 190, b = 190},
		fog_distance = 30,
	},
}

mbr.weather.seasonal_weights = {
	-- Spring
	[1] = {clear = 15, sunny = 15, cloudy = 25, rainy = 30, stormy = 5, windy = 10},
	-- Summer
	[2] = {clear = 25, sunny = 35, cloudy = 10, rainy = 10, stormy = 10, windy = 10},
	-- Fall
	[3] = {clear = 15, sunny = 10, cloudy = 20, rainy = 20, stormy = 5, windy = 15, foggy = 15},
	-- Winter
	[4] = {clear = 10, sunny = 5, cloudy = 15, snowy = 40, windy = 10, foggy = 20},
}

local function get_current_season()
	if mbr.time and mbr.time.season then
		return mbr.time.season
	end
	return 1
end

local function weighted_random_weather()
	local season = get_current_season()
	local weights = mbr.weather.seasonal_weights[season]
	if not weights then
		weights = mbr.weather.seasonal_weights[1]
	end

	local total = 0
	for _, w in pairs(weights) do
		total = total + w
	end

	local roll = math.random(1, total)
	local cumulative = 0
	for weather_type, w in pairs(weights) do
		cumulative = cumulative + w
		if roll <= cumulative then
			return weather_type
		end
	end
	return "clear"
end

local function random_duration()
	return math.random(1800, 7200)
end

function mbr.weather.set_weather(weather_type)
	if not mbr.weather.types[weather_type] then
		return false
	end
	mbr.weather.current = weather_type
	mbr.weather.timer = 0
	mbr.weather.duration = random_duration()
	-- Apply immediately to all connected players
	for _, player in ipairs(core.get_connected_players()) do
		mbr.weather._apply_effects(player)
	end
	return true
end

function mbr.weather.get_weather()
	return mbr.weather.current
end

function mbr.weather.get_speed_mult(player_name)
	return mbr.weather.speed_overrides[player_name] or 1.0
end

local function color_to_hex(c)
	return string.format("#%02X%02X%02X", c.r, c.g, c.b)
end

local function spawn_rain_particles(player)
	local ppos = player:get_pos()
	local pname = player:get_player_name()
	if mbr.weather.particle_ids[pname] then
		core.delete_particlespawner(mbr.weather.particle_ids[pname])
	end
	mbr.weather.particle_ids[pname] = core.add_particlespawner({
		amount = 80,
		time = 3,
		minpos = {x = ppos.x - 15, y = ppos.y + 8, z = ppos.z - 15},
		maxpos = {x = ppos.x + 15, y = ppos.y + 15, z = ppos.z + 15},
		minvel = {x = -0.5, y = -8, z = -0.5},
		maxvel = {x = 0.5, y = -12, z = 0.5},
		minacc = {x = 0, y = -2, z = 0},
		maxacc = {x = 0, y = -2, z = 0},
		minexptime = 0.8,
		maxexptime = 1.5,
		minsize = 0.5,
		maxsize = 1.0,
		texture = "[fill:2x4:#4169E1",
		playername = pname,
	})
end

local function spawn_snow_particles(player)
	local ppos = player:get_pos()
	local pname = player:get_player_name()
	if mbr.weather.particle_ids[pname] then
		core.delete_particlespawner(mbr.weather.particle_ids[pname])
	end
	mbr.weather.particle_ids[pname] = core.add_particlespawner({
		amount = 60,
		time = 3,
		minpos = {x = ppos.x - 15, y = ppos.y + 8, z = ppos.z - 15},
		maxpos = {x = ppos.x + 15, y = ppos.y + 15, z = ppos.z + 15},
		minvel = {x = -1, y = -2, z = -1},
		maxvel = {x = 1, y = -4, z = 1},
		minacc = {x = 0, y = -0.5, z = 0},
		maxacc = {x = 0, y = -0.5, z = 0},
		minexptime = 2,
		maxexptime = 4,
		minsize = 1.0,
		maxsize = 2.0,
		texture = "[fill:4x4:#FFFFFF",
		playername = pname,
	})
end

local function spawn_storm_particles(player)
	local ppos = player:get_pos()
	local pname = player:get_player_name()
	if mbr.weather.particle_ids[pname] then
		core.delete_particlespawner(mbr.weather.particle_ids[pname])
	end
	mbr.weather.particle_ids[pname] = core.add_particlespawner({
		amount = 150,
		time = 3,
		minpos = {x = ppos.x - 20, y = ppos.y + 8, z = ppos.z - 20},
		maxpos = {x = ppos.x + 20, y = ppos.y + 18, z = ppos.z + 20},
		minvel = {x = -2, y = -12, z = -2},
		maxvel = {x = 2, y = -18, z = 2},
		minacc = {x = 0, y = -3, z = 0},
		maxacc = {x = 0, y = -3, z = 0},
		minexptime = 0.5,
		maxexptime = 1.0,
		minsize = 0.5,
		maxsize = 1.5,
		texture = "[fill:2x4:#4169E1",
		playername = pname,
	})
end

local function clear_particles(player)
	local pname = player:get_player_name()
	if mbr.weather.particle_ids[pname] then
		core.delete_particlespawner(mbr.weather.particle_ids[pname])
		mbr.weather.particle_ids[pname] = nil
	end
end

local lightning_active = {}

local function trigger_lightning(player)
	local pname = player:get_player_name()
	if lightning_active[pname] then
		return
	end
	lightning_active[pname] = true

	local hud_id = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0, y = 0},
		scale = {x = -100, y = -100},
		text = "[fill:1x1:#FFFFFFCC",
		z_index = 1000,
		alignment = {x = 1, y = 1},
		offset = {x = 0, y = 0},
	})

	core.after(0.15, function()
		local p = core.get_player_by_name(pname)
		if p and hud_id then
			p:hud_remove(hud_id)
		end
		lightning_active[pname] = nil
	end)
end

function mbr.weather._apply_effects(player)
	local pname = player:get_player_name()
	local wtype = mbr.weather.current
	local wdef = mbr.weather.types[wtype]

	-- Sky override
	if wdef.sky_color then
		local sky_params = {
			type = "plain",
			base_color = wdef.sky_color,
		}
		if wdef.fog_distance then
			sky_params.fog = {
				fog_distance = wdef.fog_distance,
			}
		end
		player:set_sky(sky_params)
	else
		player:set_sky({type = "regular"})
	end

	-- Fog-only weather
	if wdef.fog_distance and not wdef.sky_color then
		player:set_sky({
			fog = {fog_distance = wdef.fog_distance},
		})
	end

	-- Particles
	if wdef.has_particles then
		if wtype == "rainy" then
			spawn_rain_particles(player)
		elseif wtype == "snowy" then
			spawn_snow_particles(player)
		elseif wtype == "stormy" then
			spawn_storm_particles(player)
		end
	else
		clear_particles(player)
	end

	-- Store weather speed multiplier for other systems to read
	if not mbr.weather.speed_overrides then
		mbr.weather.speed_overrides = {}
	end
	mbr.weather.speed_overrides[pname] = wdef.speed_mult or 1.0

	-- HUD weather text
	if mbr.weather.hud_ids[pname] then
		player:hud_change(mbr.weather.hud_ids[pname], "text",
			"Weather: " .. wtype:sub(1, 1):upper() .. wtype:sub(2))
	else
		mbr.weather.hud_ids[pname] = player:hud_add({
			hud_elem_type = "text",
			position = {x = 1, y = 0},
			offset = {x = -10, y = 30},
			text = "Weather: " .. wtype:sub(1, 1):upper() .. wtype:sub(2),
			alignment = {x = -1, y = 1},
			scale = {x = 100, y = 100},
			number = 0xFFFFFF,
			z_index = 100,
		})
	end
end

-- Globalstep: advance weather timer and apply effects (throttled)
core.register_globalstep(function(dtime)
	mbr.weather.timer = mbr.weather.timer + dtime
	mbr.weather.effect_timer = (mbr.weather.effect_timer or 0) + dtime

	-- Initialize duration on first run
	if mbr.weather.duration == 0 then
		mbr.weather.duration = random_duration()
		mbr.weather.current = weighted_random_weather()
	end

	-- Check if weather should change
	if mbr.weather.timer >= mbr.weather.duration then
		local new_weather = weighted_random_weather()
		mbr.weather.set_weather(new_weather)
	end

	-- Throttle per-player effects to every 2 seconds
	if mbr.weather.effect_timer < 2 then
		return
	end
	mbr.weather.effect_timer = 0

	local wdef = mbr.weather.types[mbr.weather.current]
	for _, player in ipairs(core.get_connected_players()) do
		mbr.weather._apply_effects(player)

		-- Lightning flash during storms
		if wdef.has_lightning and math.random(1, 10) == 1 then
			trigger_lightning(player)
		end
	end
end)

-- Clean up HUD and particles on player leave
core.register_on_leaveplayer(function(player)
	local pname = player:get_player_name()
	mbr.weather.hud_ids[pname] = nil
	mbr.weather.speed_overrides[pname] = nil
	if mbr.weather.particle_ids[pname] then
		core.delete_particlespawner(mbr.weather.particle_ids[pname])
		mbr.weather.particle_ids[pname] = nil
	end
	lightning_active[pname] = nil
end)

-- On join, apply current weather
core.register_on_joinplayer(function(player)
	core.after(1, function()
		local p = core.get_player_by_name(player:get_player_name())
		if p then
			mbr.weather._apply_effects(p)
		end
	end)
end)

-- Season change hook: trigger weather change when season changes
if mbr.time and mbr.time.register_on_season_change then
	mbr.time.register_on_season_change(function(new_season)
		local new_weather = weighted_random_weather()
		mbr.weather.set_weather(new_weather)
	end)
end
