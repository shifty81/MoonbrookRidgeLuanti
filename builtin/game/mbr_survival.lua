-- MoonBrook Ridge: Hunger & Thirst Survival System

mbr = mbr or {}
mbr.survival = {}
mbr.survival.players = {}

local HUNGER_MAX = 100
local THIRST_MAX = 100

-- Timers
local decay_timer = 0
local activity_timer = 0
local damage_timer = 0

-- HUD element IDs per player
local hunger_huds = {}
local thirst_huds = {}
local warning_huds = {}

-- Registered food/drink definitions
local registered_foods = {}
local registered_drinks = {}

-- Initialize player data
local function init_player_data(name)
	mbr.survival.players[name] = {
		hunger = HUNGER_MAX,
		thirst = THIRST_MAX,
	}
end

-- Clamp value between 0 and max
local function clamp(val, min_v, max_v)
	if val < min_v then return min_v end
	if val > max_v then return max_v end
	return val
end

-- Helper functions
function mbr.survival.feed_player(player_name, amount)
	local data = mbr.survival.players[player_name]
	if not data then return end
	data.hunger = clamp(data.hunger + amount, 0, HUNGER_MAX)
	local player = core.get_player_by_name(player_name)
	if player and hunger_huds[player_name] then
		player:hud_change(hunger_huds[player_name], "number",
			math.ceil(data.hunger / HUNGER_MAX * 20))
	end
end

function mbr.survival.hydrate_player(player_name, amount)
	local data = mbr.survival.players[player_name]
	if not data then return end
	data.thirst = clamp(data.thirst + amount, 0, THIRST_MAX)
	local player = core.get_player_by_name(player_name)
	if player and thirst_huds[player_name] then
		player:hud_change(thirst_huds[player_name], "number",
			math.ceil(data.thirst / THIRST_MAX * 20))
	end
end

-- Register food item
function mbr.survival.register_food(itemname, def)
	registered_foods[itemname] = def
	core.register_craftitem(itemname, {
		description = def.description or itemname,
		inventory_image = def.texture or "heart.png",
		on_use = function(itemstack, user, pointed_thing)
			if not user then return itemstack end
			local name = user:get_player_name()
			mbr.survival.feed_player(name, def.hunger_restore or 10)
			if def.thirst_restore then
				mbr.survival.hydrate_player(name, def.thirst_restore)
			end
			itemstack:take_item()
			return itemstack
		end,
	})
end

-- Register drink item
function mbr.survival.register_drink(itemname, def)
	registered_drinks[itemname] = def
	core.register_craftitem(itemname, {
		description = def.description or itemname,
		inventory_image = def.texture or "bubble.png",
		on_use = function(itemstack, user, pointed_thing)
			if not user then return itemstack end
			local name = user:get_player_name()
			mbr.survival.hydrate_player(name, def.thirst_restore or 10)
			if def.hunger_restore then
				mbr.survival.feed_player(name, def.hunger_restore)
			end
			itemstack:take_item()
			return itemstack
		end,
	})
end

-- Update warning HUD text
local function update_warning(player, name, data)
	if not warning_huds[name] then return end
	local warnings = {}
	if data.hunger < 15 then
		table.insert(warnings, "HUNGER CRITICAL!")
	end
	if data.thirst < 15 then
		table.insert(warnings, "THIRST CRITICAL!")
	end
	local text = table.concat(warnings, "  ")
	player:hud_change(warning_huds[name], "text", text)
end

-- Apply speed debuffs based on hunger/thirst (lower of both wins)
local function apply_debuffs(player, data)
	local speed = 1.0
	if data.thirst < 20 then
		speed = math.min(speed, 0.9)
	end
	if data.hunger < 20 then
		speed = math.min(speed, 0.8)
	end
	player:set_physics_override({speed = speed})
end

-- Player join: create HUDs and init data
core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	init_player_data(name)

	-- Hunger statbar: positioned below health on the left side
	hunger_huds[name] = player:hud_add({
		type = "statbar",
		position = {x = 0.5, y = 1},
		text = "heart.png",
		text2 = "heart_gone.png",
		number = 20,
		item = 20,
		direction = 0,
		size = {x = 24, y = 24},
		offset = {x = (-10 * 24) - 25, y = -(48 + 24 + 16) + 28},
	})

	-- Thirst statbar: positioned below hunger on the right side
	thirst_huds[name] = player:hud_add({
		type = "statbar",
		position = {x = 0.5, y = 1},
		text = "bubble.png",
		text2 = "bubble_gone.png",
		number = 20,
		item = 20,
		direction = 0,
		size = {x = 24, y = 24},
		offset = {x = 25, y = -(48 + 24 + 16) + 28},
	})

	-- Warning text HUD
	warning_huds[name] = player:hud_add({
		type = "text",
		position = {x = 0.5, y = 0.85},
		offset = {x = 0, y = 0},
		text = "",
		alignment = {x = 0, y = 0},
		scale = {x = 100, y = 100},
		number = 0xFF0000,
	})
end)

-- Player leave: clean up
core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	mbr.survival.players[name] = nil
	hunger_huds[name] = nil
	thirst_huds[name] = nil
	warning_huds[name] = nil
end)

-- Respawn handler: reset hunger/thirst on starvation death
core.register_on_respawnplayer(function(player)
	local name = player:get_player_name()
	local data = mbr.survival.players[name]
	if data then
		if data.hunger <= 0 or data.thirst <= 0 then
			data.hunger = 20
			data.thirst = 20
		end
		if hunger_huds[name] then
			player:hud_change(hunger_huds[name], "number",
				math.ceil(data.hunger / HUNGER_MAX * 20))
		end
		if thirst_huds[name] then
			player:hud_change(thirst_huds[name], "number",
				math.ceil(data.thirst / THIRST_MAX * 20))
		end
		apply_debuffs(player, data)
		update_warning(player, name, data)
	end
end)

-- Main globalstep: decay, activity drain, debuffs, damage
core.register_globalstep(function(dtime)
	decay_timer = decay_timer + dtime
	activity_timer = activity_timer + dtime
	damage_timer = damage_timer + dtime

	local do_decay = decay_timer >= 1.0
	local do_activity = activity_timer >= 2.0
	local do_damage = damage_timer >= 10.0

	if not (do_decay or do_activity or do_damage) then return end

	for _, player in ipairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local data = mbr.survival.players[name]
		if data then
			local controls = player:get_player_control()

			-- Base decay per tick: lose 1 hunger every 60s, 1 thirst every 45s
			if do_decay then
				data.hunger = clamp(data.hunger - (1 / 60), 0, HUNGER_MAX)
				data.thirst = clamp(data.thirst - (1 / 45), 0, THIRST_MAX)
			end

			-- Activity drain every 2 seconds
			if do_activity then
				-- Running: movement + aux1
				local moving = controls.up or controls.down or
					controls.left or controls.right
				if moving and controls.aux1 then
					data.hunger = clamp(data.hunger - 0.5, 0, HUNGER_MAX)
					data.thirst = clamp(data.thirst - 0.7, 0, THIRST_MAX)
				end
				-- Digging
				if controls.dig then
					data.hunger = clamp(data.hunger - 0.3, 0, HUNGER_MAX)
					data.thirst = clamp(data.thirst - 0.2, 0, THIRST_MAX)
				end
			end

			-- Starvation/dehydration damage every 10 seconds
			if do_damage then
				if data.hunger <= 0 or data.thirst <= 0 then
					local hp = player:get_hp()
					if hp > 0 then
						player:set_hp(hp - 1, {type = "set_hp",
							cause = "starvation"})
					end
				end
			end

			-- Apply debuffs
			apply_debuffs(player, data)

			-- Update HUDs
			if hunger_huds[name] then
				player:hud_change(hunger_huds[name], "number",
					math.ceil(data.hunger / HUNGER_MAX * 20))
			end
			if thirst_huds[name] then
				player:hud_change(thirst_huds[name], "number",
					math.ceil(data.thirst / THIRST_MAX * 20))
			end

			-- Warning text
			update_warning(player, name, data)
		end
	end

	if do_decay then decay_timer = 0 end
	if do_activity then activity_timer = 0 end
	if do_damage then damage_timer = 0 end
end)

-- Register basic food items
mbr.survival.register_food("mbr:bread", {
	description = "Bread",
	hunger_restore = 25,
	texture = "heart.png",
})

mbr.survival.register_food("mbr:apple", {
	description = "Apple",
	hunger_restore = 15,
	texture = "heart.png",
})

mbr.survival.register_food("mbr:steak", {
	description = "Steak",
	hunger_restore = 40,
	texture = "heart.png",
})

-- Register basic drink items
mbr.survival.register_drink("mbr:water_bottle", {
	description = "Water Bottle",
	thirst_restore = 30,
	texture = "bubble.png",
})

mbr.survival.register_drink("mbr:juice", {
	description = "Juice",
	thirst_restore = 20,
	texture = "bubble.png",
})

-- Milk restores both thirst and some hunger
mbr.survival.register_drink("mbr:milk", {
	description = "Milk",
	thirst_restore = 25,
	hunger_restore = 5,
	texture = "bubble.png",
})
