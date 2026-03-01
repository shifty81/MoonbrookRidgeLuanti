-- MoonBrook Ridge: Fishing System
-- Fishing rod, bait, fish species, and timing-based mini-game

local fishing_state = {}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function is_water(pos)
	local node = minetest.get_node(pos)
	if not node then return false end
	return minetest.get_item_group(node.name, "water") > 0
end

local function find_water_near(pos, radius)
	radius = radius or 3
	for x = -radius, radius do
		for y = -radius, radius do
			for z = -radius, radius do
				if is_water({x = pos.x + x, y = pos.y + y, z = pos.z + z}) then
					return true
				end
			end
		end
	end
	return false
end

local function get_season()
	if mbr and mbr.time and mbr.time.get_season_name then
		return mbr.time.get_season_name()
	end
	return "Spring"
end

local function get_hour()
	if mbr and mbr.time then
		return mbr.time.hour or 12
	end
	return 12
end

local function is_dawn_dusk()
	local hour = get_hour()
	return (hour >= 5 and hour <= 7) or (hour >= 18 and hour <= 20)
end

local function is_night()
	local hour = get_hour()
	return hour >= 21 or hour < 5
end

---------------------------------------------------------------------------
-- Fish definitions
---------------------------------------------------------------------------

local fish_data = {
	-- Common (all seasons)
	{name = "bass", desc = "Bass", color = "#6b8e5a",
		hunger = 8, seasons = {"Spring", "Summer", "Fall", "Winter"}, rarity = "common"},
	{name = "carp", desc = "Carp", color = "#8b7355",
		hunger = 7, seasons = {"Spring", "Summer", "Fall", "Winter"}, rarity = "common"},
	{name = "perch", desc = "Perch", color = "#7a9b6e",
		hunger = 6, seasons = {"Spring", "Summer", "Fall", "Winter"}, rarity = "common"},
	-- Spring
	{name = "trout", desc = "Trout", color = "#e8967d",
		hunger = 10, seasons = {"Spring"}, rarity = "seasonal"},
	{name = "salmon", desc = "Salmon", color = "#fa8072",
		hunger = 12, seasons = {"Spring"}, rarity = "seasonal"},
	-- Summer
	{name = "catfish", desc = "Catfish", color = "#696969",
		hunger = 9, seasons = {"Summer"}, rarity = "seasonal"},
	{name = "sunfish", desc = "Sunfish", color = "#ffd700",
		hunger = 5, thirst = 3, seasons = {"Summer"}, rarity = "seasonal"},
	-- Fall
	{name = "pike", desc = "Pike", color = "#556b2f",
		hunger = 11, seasons = {"Fall"}, rarity = "seasonal"},
	{name = "walleye", desc = "Walleye", color = "#8fbc8f",
		hunger = 10, seasons = {"Fall"}, rarity = "seasonal"},
	-- Winter
	{name = "ice_cod", desc = "Ice Cod", color = "#b0c4de",
		hunger = 8, seasons = {"Winter"}, rarity = "seasonal"},
}

local legendary_fish = {
	{name = "golden_koi", desc = "Golden Koi", color = "#ffd700",
		hunger = 30, chance = 0.01, rarity = "legendary"},
	{name = "ancient_sturgeon", desc = "Ancient Sturgeon", color = "#4a4a4a",
		hunger = 40, chance = 0.005, rarity = "legendary"},
	{name = "crystal_fish", desc = "Crystal Fish", color = "#7fffd4",
		hunger = 20, thirst = 20, chance = 0.005, rarity = "legendary"},
}

---------------------------------------------------------------------------
-- Register fish items
---------------------------------------------------------------------------

local function register_fish(itemname, fish)
	if mbr and mbr.survival and mbr.survival.register_food then
		local def = {
			description = fish.desc,
			texture = "[fill:16x16:0,0:" .. fish.color,
			hunger_restore = fish.hunger,
		}
		if fish.thirst then
			def.thirst_restore = fish.thirst
		end
		mbr.survival.register_food(itemname, def)
	else
		minetest.register_craftitem(itemname, {
			description = fish.desc,
			inventory_image = "[fill:16x16:0,0:" .. fish.color,
			on_use = function(itemstack, user)
				if not user then return itemstack end
				itemstack:take_item()
				return itemstack
			end,
		})
	end
end

for _, fish in ipairs(fish_data) do
	register_fish("mbr_fishing:" .. fish.name, fish)
end

for _, fish in ipairs(legendary_fish) do
	register_fish("mbr_fishing:" .. fish.name, fish)
end

---------------------------------------------------------------------------
-- Bait items
---------------------------------------------------------------------------

minetest.register_craftitem("mbr_fishing:worm", {
	description = "Worm\nBasic bait - +10% catch rate",
	inventory_image = "[fill:16x16:0,0:#8B4513",
})

minetest.register_craftitem("mbr_fishing:fancy_bait", {
	description = "Fancy Bait\nGood bait - +25% catch rate",
	inventory_image = "[fill:16x16:0,0:#DAA520",
})

minetest.register_craft({
	type = "shapeless",
	output = "mbr_fishing:fancy_bait",
	recipe = {"mbr_fishing:worm", "mbr_items:bread"},
})

-- Drop worms when digging dirt
local function override_dirt_for_worms(nodename)
	local old_def = minetest.registered_nodes[nodename]
	if not old_def then return end
	local old_after_dig = old_def.after_dig_node
	minetest.override_item(nodename, {
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			if old_after_dig then
				old_after_dig(pos, oldnode, oldmetadata, digger)
			end
			if digger and math.random(1, 5) == 1 then
				local inv = digger:get_inventory()
				if inv then
					inv:add_item("main", "mbr_fishing:worm")
					minetest.chat_send_player(
						digger:get_player_name(), "You found a worm!")
				end
			end
		end,
	})
end

minetest.register_on_mods_loaded(function()
	override_dirt_for_worms("mbr_core:dirt")
	override_dirt_for_worms("mbr_core:dirt_with_grass")
end)

---------------------------------------------------------------------------
-- Bait detection
---------------------------------------------------------------------------

local function find_bait(player)
	local inv = player:get_inventory()
	if not inv then return false, nil end
	if inv:contains_item("main", "mbr_fishing:fancy_bait") then
		return true, "mbr_fishing:fancy_bait"
	end
	if inv:contains_item("main", "mbr_fishing:worm") then
		return true, "mbr_fishing:worm"
	end
	return false, nil
end

local function consume_bait(player, bait_type)
	if not bait_type then return end
	local inv = player:get_inventory()
	if inv then
		inv:remove_item("main", bait_type .. " 1")
	end
end

---------------------------------------------------------------------------
-- Catch logic
---------------------------------------------------------------------------

local function determine_catch(has_bait, bait_type)
	local bait_bonus = 0
	if has_bait then
		if bait_type == "mbr_fishing:fancy_bait" then
			bait_bonus = 0.25
		else
			bait_bonus = 0.10
		end
	end

	-- Check legendary first
	for _, fish in ipairs(legendary_fish) do
		local chance = fish.chance + (fish.chance * bait_bonus)
		if math.random() < chance then
			return "mbr_fishing:" .. fish.name, fish.desc, "legendary"
		end
	end

	-- Build seasonal and common pools
	local season = get_season()
	local seasonal_pool = {}
	local common_pool = {}

	for _, fish in ipairs(fish_data) do
		if #fish.seasons == 4 then
			table.insert(common_pool, fish)
		else
			for _, s in ipairs(fish.seasons) do
				if s == season then
					table.insert(seasonal_pool, fish)
					break
				end
			end
		end
	end

	-- Base catch rate with time bonuses
	local base_rate = 0.60
	if is_dawn_dusk() then
		base_rate = base_rate + 0.15
	elseif is_night() then
		base_rate = base_rate + 0.05
	end
	base_rate = base_rate + bait_bonus

	if math.random() > base_rate then
		return nil, nil, nil
	end

	-- 80% seasonal pool, 20% common pool
	local pool
	if #seasonal_pool > 0 and math.random() < 0.8 then
		pool = seasonal_pool
	else
		pool = common_pool
	end

	if #pool == 0 then
		pool = common_pool
	end

	local fish = pool[math.random(1, #pool)]
	return "mbr_fishing:" .. fish.name, fish.desc, fish.rarity
end

---------------------------------------------------------------------------
-- Timing window
---------------------------------------------------------------------------

local function get_timing_window(has_bait, rarity)
	local window = 3.0
	if rarity == "legendary" then
		window = 1.5
	end
	if has_bait then
		window = window + math.random(5, 10) / 10.0
	end
	return window
end

---------------------------------------------------------------------------
-- Fishing action
---------------------------------------------------------------------------

local function start_fishing(player, itemstack)
	local name = player:get_player_name()
	local state = fishing_state[name]

	-- Phase: biting -> reel in attempt
	if state and state.phase == "biting" then
		local elapsed = minetest.get_us_time() / 1000000 - state.bite_time
		if elapsed <= state.window then
			local fish_item = state.catch_item
			local fish_desc = state.catch_desc
			local rarity = state.catch_rarity
			if fish_item then
				local inv = player:get_inventory()
				if inv then
					inv:add_item("main", fish_item)
				end
				local msg = "You caught a " .. fish_desc .. "!"
				if rarity == "legendary" then
					msg = "LEGENDARY CATCH! You caught a " .. fish_desc .. "!!"
				end
				minetest.chat_send_player(name, msg)
			else
				minetest.chat_send_player(name, "The line came up empty.")
			end
		else
			minetest.chat_send_player(name, "The fish got away!")
		end
		fishing_state[name] = nil
		return itemstack
	end

	-- Phase: already casting
	if state and state.phase == "casting" then
		minetest.chat_send_player(name,
			"You already have a line in the water. Be patient!")
		return itemstack
	end

	-- Check for water nearby
	local pos = player:get_pos()
	if not find_water_near(pos) then
		minetest.chat_send_player(name,
			"You need to be near water to fish!")
		return itemstack
	end

	-- Check for bait and consume it
	local has_bait, bait_type = find_bait(player)
	if has_bait then
		consume_bait(player, bait_type)
		local bait_label = "Worm"
		if bait_type == "mbr_fishing:fancy_bait" then
			bait_label = "Fancy Bait"
		end
		minetest.chat_send_player(name,
			"You cast your line... (using " .. bait_label .. ")")
	else
		minetest.chat_send_player(name, "You cast your line...")
	end

	-- Pre-determine the catch and timing window
	local fish_item, fish_desc, rarity = determine_catch(has_bait, bait_type)
	local window = get_timing_window(has_bait, rarity)

	fishing_state[name] = {
		phase = "casting",
		has_bait = has_bait,
		bait_type = bait_type,
		catch_item = fish_item,
		catch_desc = fish_desc,
		catch_rarity = rarity,
		window = window,
	}

	-- Random delay before bite (5-15 seconds)
	local delay = math.random(5, 15)
	minetest.after(delay, function()
		local current = fishing_state[name]
		if not current or current.phase ~= "casting" then
			return
		end

		local p = minetest.get_player_by_name(name)
		if not p then
			fishing_state[name] = nil
			return
		end

		current.phase = "biting"
		current.bite_time = minetest.get_us_time() / 1000000

		minetest.chat_send_player(name,
			"Something's biting! Right-click again to reel in!")

		-- Expire the window
		minetest.after(current.window, function()
			local s = fishing_state[name]
			if s and s.phase == "biting" then
				fishing_state[name] = nil
				local pp = minetest.get_player_by_name(name)
				if pp then
					minetest.chat_send_player(name, "The fish got away!")
				end
			end
		end)
	end)

	return itemstack
end

---------------------------------------------------------------------------
-- Fishing rod tools
---------------------------------------------------------------------------

minetest.register_tool("mbr_fishing:fishing_rod", {
	description = "Fishing Rod",
	inventory_image = "[fill:16x16:0,0:#8B6914",
	tool_capabilities = {
		full_punch_interval = 1.5,
		max_drop_level = 0,
		damage_groups = {fleshy = 1},
	},
	on_place = function(itemstack, placer, pointed_thing)
		if not placer then return itemstack end
		return start_fishing(placer, itemstack)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		if not user then return itemstack end
		return start_fishing(user, itemstack)
	end,
})

minetest.register_tool("mbr_fishing:fishing_rod_baited", {
	description = "Fishing Rod (Baited)",
	inventory_image = "[fill:16x16:0,0:#A0822B",
	tool_capabilities = {
		full_punch_interval = 1.5,
		max_drop_level = 0,
		damage_groups = {fleshy = 1},
	},
	on_place = function(itemstack, placer, pointed_thing)
		if not placer then return itemstack end
		return start_fishing(placer, itemstack)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		if not user then return itemstack end
		return start_fishing(user, itemstack)
	end,
})

---------------------------------------------------------------------------
-- Craft recipes
---------------------------------------------------------------------------

minetest.register_craft({
	output = "mbr_fishing:fishing_rod",
	recipe = {
		{"", "", "mbr_core:wood"},
		{"", "mbr_core:wood", ""},
		{"mbr_core:wood", "", ""},
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mbr_fishing:fishing_rod_baited",
	recipe = {"mbr_fishing:fishing_rod", "mbr_fishing:worm"},
})

---------------------------------------------------------------------------
-- Cleanup on player leave
---------------------------------------------------------------------------

minetest.register_on_leaveplayer(function(player)
	fishing_state[player:get_player_name()] = nil
end)

---------------------------------------------------------------------------
-- /fish_guide chat command
---------------------------------------------------------------------------

minetest.register_chatcommand("fish_guide", {
	description = "Shows available fish for the current season",
	func = function(name)
		local season = get_season()
		local lines = {"=== Fish Guide - " .. season .. " ==="}

		table.insert(lines, "-- Common (all seasons) --")
		for _, fish in ipairs(fish_data) do
			if #fish.seasons == 4 then
				table.insert(lines,
					"  " .. fish.desc .. " (Hunger: " .. fish.hunger .. ")")
			end
		end

		table.insert(lines, "-- " .. season .. " Specials --")
		local found_seasonal = false
		for _, fish in ipairs(fish_data) do
			for _, s in ipairs(fish.seasons) do
				if s == season and #fish.seasons < 4 then
					local info = "  " .. fish.desc .. " (Hunger: " .. fish.hunger
					if fish.thirst then
						info = info .. ", Thirst: " .. fish.thirst
					end
					info = info .. ")"
					table.insert(lines, info)
					found_seasonal = true
					break
				end
			end
		end
		if not found_seasonal then
			table.insert(lines, "  No seasonal specials this season.")
		end

		table.insert(lines, "-- Legendary (very rare) --")
		for _, fish in ipairs(legendary_fish) do
			table.insert(lines, "  " .. fish.desc .. " (???)")
		end

		table.insert(lines, "")
		table.insert(lines, "Tips: Fish at dawn/dusk for better catches!")
		table.insert(lines, "Use bait to increase your catch rate.")

		return true, table.concat(lines, "\n")
	end,
})

minetest.log("action", "[MBR Fishing] Loaded")
