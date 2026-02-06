-- mbr_player: Player character system with stats, inventory, and animations

local player_huds = {}
local player_timers = {}

-- =============================================================================
-- HUD Setup
-- =============================================================================

local function setup_hud(player)
	local name = player:get_player_name()
	player_huds[name] = {}

	-- Health bar background
	player_huds[name].health_bg = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.0, y = 0.0},
		offset = {x = 20, y = 20},
		text = "mbr_player_bar_bg.png",
		scale = {x = 2, y = 1},
		alignment = {x = 1, y = 1},
		z_index = 0,
	})

	-- Health bar
	player_huds[name].health_bar = player:hud_add({
		hud_elem_type = "statbar",
		position = {x = 0.0, y = 0.0},
		offset = {x = 22, y = 22},
		text = "mbr_player_heart.png",
		number = 20,
		direction = 0,
		size = {x = 24, y = 24},
		alignment = {x = 1, y = 1},
		z_index = 1,
	})

	-- Health label
	player_huds[name].health_text = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.0, y = 0.0},
		offset = {x = 22, y = 10},
		text = "HP",
		number = 0xFF4444,
		alignment = {x = 1, y = 1},
		scale = {x = 100, y = 20},
		z_index = 2,
	})

	-- Energy bar background
	player_huds[name].energy_bg = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.0, y = 0.0},
		offset = {x = 20, y = 54},
		text = "mbr_player_bar_bg.png",
		scale = {x = 2, y = 1},
		alignment = {x = 1, y = 1},
		z_index = 0,
	})

	-- Energy bar
	player_huds[name].energy_bar = player:hud_add({
		hud_elem_type = "statbar",
		position = {x = 0.0, y = 0.0},
		offset = {x = 22, y = 56},
		text = "mbr_player_energy.png",
		number = 20,
		direction = 0,
		size = {x = 24, y = 24},
		alignment = {x = 1, y = 1},
		z_index = 1,
	})

	-- Energy label
	player_huds[name].energy_text = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.0, y = 0.0},
		offset = {x = 22, y = 44},
		text = "Energy",
		number = 0xFFDD00,
		alignment = {x = 1, y = 1},
		scale = {x = 100, y = 20},
		z_index = 2,
	})

	-- Money display (top-right)
	player_huds[name].money_text = player:hud_add({
		hud_elem_type = "text",
		position = {x = 1.0, y = 0.0},
		offset = {x = -20, y = 20},
		text = "$500",
		number = 0x00FF00,
		alignment = {x = -1, y = 1},
		scale = {x = 100, y = 20},
		z_index = 2,
	})
end

-- =============================================================================
-- HUD Updates
-- =============================================================================

local function update_hud(player)
	local name = player:get_player_name()
	local data = mbr.get_player_data(name)
	local huds = player_huds[name]
	if not huds then return end

	-- Health: 20 max HP = 20 half-icons in statbar
	local health_icons = mbr.clamp(data.health, 0, 20)
	player:hud_change(huds.health_bar, "number", health_icons)

	-- Energy: scale 0-100 to 0-20 icons
	local energy_icons = math.floor(data.energy / 5)
	energy_icons = mbr.clamp(energy_icons, 0, 20)
	player:hud_change(huds.energy_bar, "number", energy_icons)

	-- Money
	player:hud_change(huds.money_text, "text", "$" .. tostring(data.money))
end

-- =============================================================================
-- Player Join / Leave
-- =============================================================================

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()

	-- Set 36-slot inventory
	player:get_inventory():set_size("main", 36)

	-- Visual properties
	player:set_properties({
		mesh = "character.b3d",
		textures = {"character.png"},
		visual = "mesh",
		visual_size = {x = 1, y = 1, z = 1},
		collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.77, 0.3},
		stepheight = 0.6,
		eye_height = 1.47,
	})

	-- Default physics
	player:set_physics_override({
		speed = 1.0,
		jump = 1.0,
		gravity = 1.0,
	})

	-- Initialize timers
	player_timers[name] = {
		energy_drain = 0,
		energy_regen = 0,
	}

	-- Setup HUD
	setup_hud(player)
	update_hud(player)

	-- Hide engine default health bar (we use our own)
	player:hud_set_flags({
		healthbar = false,
		breathbar = true,
		crosshair = true,
		hotbar = true,
		wielditem = true,
	})
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_huds[name] = nil
	player_timers[name] = nil
end)

-- =============================================================================
-- Globalstep: Movement, Energy, HUD
-- =============================================================================

core.register_globalstep(function(dtime)
	for _, player in ipairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local data = mbr.get_player_data(name)
		local timers = player_timers[name]
		if not timers then return end

		local controls = player:get_player_control()
		local is_moving = controls.up or controls.down or controls.left or controls.right
		local is_running = controls.aux1 and is_moving

		-- Sprint handling
		if is_running and data.energy > 0 then
			player:set_physics_override({speed = 1.5})

			-- Drain energy: 1 per 2 seconds
			timers.energy_drain = timers.energy_drain + dtime
			if timers.energy_drain >= 2.0 then
				timers.energy_drain = timers.energy_drain - 2.0
				data.energy = mbr.clamp(data.energy - 1, 0, 100)
			end
			timers.energy_regen = 0
		else
			-- Force walk speed if trying to run with no energy
			if is_running and data.energy <= 0 then
				player:set_physics_override({speed = 1.0})
			elseif not is_running then
				player:set_physics_override({speed = 1.0})
			end

			timers.energy_drain = 0

			-- Regenerate energy when standing still
			if not is_moving then
				timers.energy_regen = timers.energy_regen + dtime
				if timers.energy_regen >= 3.0 then
					timers.energy_regen = timers.energy_regen - 3.0
					data.energy = mbr.clamp(data.energy + 1, 0, 100)
				end
			else
				timers.energy_regen = 0
			end
		end

		update_hud(player)
	end
end)

core.log("action", "[mbr_player] Loaded.")
