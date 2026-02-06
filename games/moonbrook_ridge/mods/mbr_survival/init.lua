-- mbr_survival: Hunger and thirst survival mechanics

local player_huds = {}
local player_timers = {}
local critical_timers = {}
local warning_state = {}

-- =============================================================================
-- Survival Namespace
-- =============================================================================

mbr.survival = {}

-- =============================================================================
-- HUD Setup
-- =============================================================================

local function setup_hud(player)
	local name = player:get_player_name()
	player_huds[name] = {}

	-- Hunger bar background
	player_huds[name].hunger_bg = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.0, y = 0.0},
		offset = {x = 20, y = 88},
		text = "mbr_player_bar_bg.png",
		scale = {x = 2, y = 1},
		alignment = {x = 1, y = 1},
		z_index = 0,
	})

	-- Hunger bar
	player_huds[name].hunger_bar = player:hud_add({
		hud_elem_type = "statbar",
		position = {x = 0.0, y = 0.0},
		offset = {x = 22, y = 90},
		text = "mbr_survival_hunger.png",
		number = 20,
		direction = 0,
		size = {x = 24, y = 24},
		alignment = {x = 1, y = 1},
		z_index = 1,
	})

	-- Hunger label
	player_huds[name].hunger_text = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.0, y = 0.0},
		offset = {x = 22, y = 78},
		text = "Hunger",
		number = 0xCC8833,
		alignment = {x = 1, y = 1},
		scale = {x = 100, y = 20},
		z_index = 2,
	})

	-- Thirst bar background
	player_huds[name].thirst_bg = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.0, y = 0.0},
		offset = {x = 20, y = 122},
		text = "mbr_player_bar_bg.png",
		scale = {x = 2, y = 1},
		alignment = {x = 1, y = 1},
		z_index = 0,
	})

	-- Thirst bar
	player_huds[name].thirst_bar = player:hud_add({
		hud_elem_type = "statbar",
		position = {x = 0.0, y = 0.0},
		offset = {x = 22, y = 124},
		text = "mbr_survival_thirst.png",
		number = 20,
		direction = 0,
		size = {x = 24, y = 24},
		alignment = {x = 1, y = 1},
		z_index = 1,
	})

	-- Thirst label
	player_huds[name].thirst_text = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.0, y = 0.0},
		offset = {x = 22, y = 112},
		text = "Thirst",
		number = 0x3399FF,
		alignment = {x = 1, y = 1},
		scale = {x = 100, y = 20},
		z_index = 2,
	})

	-- Warning text (hidden by default)
	player_huds[name].warning = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.5, y = 0.3},
		offset = {x = 0, y = 0},
		text = "",
		number = 0xFF0000,
		alignment = {x = 0, y = 0},
		scale = {x = 200, y = 20},
		z_index = 100,
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

	-- Scale 0-100 to 0-20 icons
	local hunger_icons = math.floor(data.hunger / 5)
	hunger_icons = mbr.clamp(hunger_icons, 0, 20)
	player:hud_change(huds.hunger_bar, "number", hunger_icons)

	local thirst_icons = math.floor(data.thirst / 5)
	thirst_icons = mbr.clamp(thirst_icons, 0, 20)
	player:hud_change(huds.thirst_bar, "number", thirst_icons)

	-- Flashing warnings for critically low levels
	local ws = warning_state[name]
	if not ws then
		ws = {visible = true}
		warning_state[name] = ws
	end
	ws.visible = not ws.visible

	local warning_msg = ""
	if data.hunger < 15 and data.thirst < 15 then
		if ws.visible then
			warning_msg = "LOW HUNGER!  LOW THIRST!"
		end
	elseif data.hunger < 15 then
		if ws.visible then
			warning_msg = "LOW HUNGER!"
		end
	elseif data.thirst < 15 then
		if ws.visible then
			warning_msg = "LOW THIRST!"
		end
	end

	player:hud_change(huds.warning, "text", warning_msg)
end

-- =============================================================================
-- Player Join / Leave
-- =============================================================================

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local data = mbr.get_player_data(name)

	-- Initialize survival stats
	if data.hunger == nil then
		data.hunger = 100
	end
	if data.thirst == nil then
		data.thirst = 100
	end

	player_timers[name] = {
		hunger_decay = 0,
		thirst_decay = 0,
		activity_check = 0,
	}
	critical_timers[name] = 0
	warning_state[name] = {visible = true}

	setup_hud(player)
	update_hud(player)
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_huds[name] = nil
	player_timers[name] = nil
	critical_timers[name] = nil
	warning_state[name] = nil
end)

-- =============================================================================
-- Debuff Application
-- =============================================================================

local function apply_debuffs(player, data, dtime, name)
	-- Slow movement when hungry
	if data.hunger < 20 then
		player:set_physics_override({speed = 0.8})
	end

	-- Faster energy drain when thirsty
	if data.thirst < 20 then
		local energy_drain = 2 * dtime
		data.energy = mbr.clamp((data.energy or 100) - energy_drain, 0, 100)
	end

	-- Critical state: drain HP when starving or dehydrated
	if data.hunger <= 0 or data.thirst <= 0 then
		critical_timers[name] = (critical_timers[name] or 0) + dtime
		if critical_timers[name] >= 10.0 then
			critical_timers[name] = critical_timers[name] - 10.0
			local hp = player:get_hp()
			player:set_hp(hp - 1, {type = "set_hp", from = "mbr_survival"})
		end
	else
		critical_timers[name] = 0
	end
end

-- =============================================================================
-- Blackout / Respawn on Starvation Death
-- =============================================================================

core.register_on_player_hpchange(function(player, hp_change, reason)
	if reason and reason.from == "mbr_survival" then
		local hp = player:get_hp()
		if hp + hp_change <= 0 then
			local name = player:get_player_name()
			local data = mbr.get_player_data(name)

			-- Respawn at spawn with minimal stats
			data.hunger = 20
			data.thirst = 20
			local spawn = core.setting_get_pos("static_spawnpoint") or {x = 0, y = 10, z = 0}
			player:set_pos(spawn)
			player:set_hp(20, {type = "set_hp", from = "mbr_survival_respawn"})
			mbr.notify_player(player, "You blacked out from starvation...")

			-- Cancel the lethal damage
			return 0
		end
	end
	return hp_change
end, true)

-- =============================================================================
-- Globalstep: Hunger, Thirst, Debuffs
-- =============================================================================

core.register_globalstep(function(dtime)
	for _, player in ipairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local data = mbr.get_player_data(name)
		local timers = player_timers[name]
		if not timers then return end

		-- Base hunger decay: 1 per 60 seconds
		timers.hunger_decay = timers.hunger_decay + dtime
		if timers.hunger_decay >= 60.0 then
			timers.hunger_decay = timers.hunger_decay - 60.0
			data.hunger = mbr.clamp(data.hunger - 1, 0, 100)
		end

		-- Base thirst decay: 1 per 45 seconds
		timers.thirst_decay = timers.thirst_decay + dtime
		if timers.thirst_decay >= 45.0 then
			timers.thirst_decay = timers.thirst_decay - 45.0
			data.thirst = mbr.clamp(data.thirst - 1, 0, 100)
		end

		-- Activity-based drain (checked every 2 seconds)
		timers.activity_check = timers.activity_check + dtime
		if timers.activity_check >= 2.0 then
			timers.activity_check = timers.activity_check - 2.0

			local controls = player:get_player_control()
			local is_moving = controls.up or controls.down or controls.left or controls.right
			local is_running = controls.aux1 and is_moving

			if is_running then
				data.hunger = mbr.clamp(data.hunger - 0.5, 0, 100)
				data.thirst = mbr.clamp(data.thirst - 0.7, 0, 100)
			end

			if controls.dig then
				data.hunger = mbr.clamp(data.hunger - 0.3, 0, 100)
				data.thirst = mbr.clamp(data.thirst - 0.2, 0, 100)
			end
		end

		-- Apply debuffs
		apply_debuffs(player, data, dtime, name)

		-- Update HUD
		update_hud(player)
	end
end)

-- =============================================================================
-- Food & Drink Registration Helpers
-- =============================================================================

function mbr.survival.register_food(item_name, def)
	local hunger_restore = def.hunger_restore or 10
	core.register_craftitem(item_name, {
		description = def.description or "Food",
		inventory_image = def.inventory_image or "mbr_survival_food.png",
		on_use = function(itemstack, user, pointed_thing)
			local name = user:get_player_name()
			local data = mbr.get_player_data(name)
			data.hunger = mbr.clamp(data.hunger + hunger_restore, 0, 100)
			if def.thirst_restore then
				data.thirst = mbr.clamp(data.thirst + def.thirst_restore, 0, 100)
			end
			core.sound_play("mbr_survival_eat", {to_player = name, gain = 0.7}, true)
			mbr.notify_player(user, "+" .. hunger_restore .. " Hunger")
			itemstack:take_item()
			return itemstack
		end,
	})
end

function mbr.survival.register_drink(item_name, def)
	local thirst_restore = def.thirst_restore or 10
	core.register_craftitem(item_name, {
		description = def.description or "Drink",
		inventory_image = def.inventory_image or "mbr_survival_drink.png",
		on_use = function(itemstack, user, pointed_thing)
			local name = user:get_player_name()
			local data = mbr.get_player_data(name)
			data.thirst = mbr.clamp(data.thirst + thirst_restore, 0, 100)
			if def.hunger_restore then
				data.hunger = mbr.clamp(data.hunger + def.hunger_restore, 0, 100)
			end
			core.sound_play("mbr_survival_drink", {to_player = name, gain = 0.7}, true)
			mbr.notify_player(user, "+" .. thirst_restore .. " Thirst")
			itemstack:take_item()
			return itemstack
		end,
	})
end

-- =============================================================================
-- Basic Food and Drink Items
-- =============================================================================

mbr.survival.register_food("mbr_survival:bread", {
	description = "Bread",
	inventory_image = "mbr_survival_bread.png",
	hunger_restore = 25,
})

mbr.survival.register_food("mbr_survival:apple", {
	description = "Apple",
	inventory_image = "mbr_survival_apple.png",
	hunger_restore = 15,
})

mbr.survival.register_food("mbr_survival:steak", {
	description = "Steak",
	inventory_image = "mbr_survival_steak.png",
	hunger_restore = 40,
})

mbr.survival.register_drink("mbr_survival:water_bottle", {
	description = "Water Bottle",
	inventory_image = "mbr_survival_water_bottle.png",
	thirst_restore = 30,
})

mbr.survival.register_drink("mbr_survival:juice", {
	description = "Juice",
	inventory_image = "mbr_survival_juice.png",
	thirst_restore = 20,
})

mbr.survival.register_drink("mbr_survival:milk", {
	description = "Milk",
	inventory_image = "mbr_survival_milk.png",
	thirst_restore = 25,
	hunger_restore = 5,
})

core.log("action", "[mbr_survival] Loaded.")
