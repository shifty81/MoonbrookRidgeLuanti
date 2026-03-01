-- MoonBrook Ridge Farming System
-- Crops, soil, watering, and seasonal growth

-- Crop definitions
local crops = {
	wheat = {
		desc = "Wheat",
		color = "#d4a017",
		hunger = 5,
		seasons = {"Spring", "Summer"},
	},
	corn = {
		desc = "Corn",
		color = "#f0c000",
		hunger = 8,
		seasons = {"Summer", "Fall"},
	},
	tomato = {
		desc = "Tomato",
		color = "#cc2200",
		hunger = 6,
		thirst = 3,
		seasons = {"Summer"},
	},
	potato = {
		desc = "Potato",
		color = "#8b6914",
		hunger = 10,
		seasons = {"Spring", "Fall"},
	},
	carrot = {
		desc = "Carrot",
		color = "#ff6600",
		hunger = 7,
		seasons = {"Spring", "Summer", "Fall"},
	},
	pumpkin = {
		desc = "Pumpkin",
		color = "#e8751a",
		hunger = 12,
		seasons = {"Fall"},
	},
	strawberry = {
		desc = "Strawberry",
		color = "#cc1144",
		hunger = 4,
		thirst = 5,
		seasons = {"Spring"},
	},
}

-- Growth stage colors
local stage_colors = {
	"#2d5a1e",
	"#3a7a2e",
	"#4a9a3e",
}

-- Quality tiers
local quality_tiers = {
	{name = "Normal", chance = 70, multiplier = 1.0},
	{name = "Silver", chance = 25, multiplier = 1.5},
	{name = "Gold", chance = 5, multiplier = 2.0},
}

local function get_random_quality()
	local roll = math.random(100)
	if roll <= 5 then
		return "Gold"
	elseif roll <= 30 then
		return "Silver"
	end
	return "Normal"
end

local function get_current_season()
	if mbr and mbr.time and mbr.time.get_season_name then
		return mbr.time.get_season_name()
	end
	return "Spring"
end

local function crop_can_grow(crop_name)
	local def = crops[crop_name]
	if not def then return false end
	local season = get_current_season()
	for _, s in ipairs(def.seasons) do
		if s == season then return true end
	end
	return false
end

-- ============================================================
-- Soil Nodes
-- ============================================================

core.register_node("mbr_farming:soil", {
	description = "Tilled Soil",
	tiles = {"[fill:16x16:#5a3a1e"},
	groups = {crumbly = 3, soil = 1, farming_soil = 1},
	drop = "mbr_core:dirt",
})

core.register_node("mbr_farming:soil_wet", {
	description = "Wet Soil",
	tiles = {"[fill:16x16:#3a2510"},
	groups = {crumbly = 3, soil = 1, farming_soil = 1, farming_soil_wet = 1},
	drop = "mbr_core:dirt",
})

-- Soil drying ABM: wet soil dries out over time
core.register_abm({
	label = "Soil drying",
	nodenames = {"mbr_farming:soil_wet"},
	interval = 120,
	chance = 1,
	action = function(pos)
		-- Rain keeps soil wet
		if mbr and mbr.weather and mbr.weather.current == "rainy" then
			return
		end
		if mbr and mbr.weather and mbr.weather.current == "stormy" then
			return
		end
		core.set_node(pos, {name = "mbr_farming:soil"})
	end,
})

-- Rain wetting ABM: rain turns dry soil wet
core.register_abm({
	label = "Rain wetting soil",
	nodenames = {"mbr_farming:soil"},
	interval = 30,
	chance = 3,
	action = function(pos)
		if mbr and mbr.weather then
			local w = mbr.weather.current
			if w == "rainy" or w == "stormy" then
				core.set_node(pos, {name = "mbr_farming:soil_wet"})
			end
		end
	end,
})

-- ============================================================
-- Watering Can Tool
-- ============================================================

core.register_tool("mbr_farming:watering_can", {
	description = "Watering Can",
	inventory_image = "[fill:16x16:#4488cc",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 0,
		groupcaps = {},
		damage_groups = {fleshy = 1},
	},
	on_use = function(itemstack, user, pointed_thing)
		if not pointed_thing or pointed_thing.type ~= "node" then
			return itemstack
		end
		local pos = pointed_thing.under
		local node = core.get_node(pos)
		if node.name == "mbr_farming:soil" then
			core.set_node(pos, {name = "mbr_farming:soil_wet"})
			itemstack:add_wear(65535 / 100)
		end
		return itemstack
	end,
})

core.register_craft({
	output = "mbr_farming:watering_can",
	recipe = {
		{"mbr_core:wood", "", ""},
		{"mbr_core:wood", "mbr_core:wood", ""},
		{"", "mbr_core:wood", ""},
	},
})

-- ============================================================
-- Fertilizer Item
-- ============================================================

core.register_craftitem("mbr_farming:fertilizer", {
	description = "Fertilizer",
	inventory_image = "[fill:16x16:#6b4226",
	on_use = function(itemstack, user, pointed_thing)
		if not pointed_thing or pointed_thing.type ~= "node" then
			return itemstack
		end
		local pos = pointed_thing.under
		local node = core.get_node(pos)
		-- Check if it is a crop node at stage 1-3
		for crop_name, _ in pairs(crops) do
			for stage = 1, 3 do
				if node.name == "mbr_farming:" .. crop_name .. "_" .. stage then
					core.set_node(pos, {name = "mbr_farming:" .. crop_name .. "_" .. (stage + 1)})
					itemstack:take_item()
					return itemstack
				end
			end
		end
		return itemstack
	end,
})

core.register_craft({
	output = "mbr_farming:fertilizer 4",
	recipe = {
		{"mbr_core:dirt", "mbr_core:dirt"},
		{"mbr_core:dirt", "mbr_core:dirt"},
	},
})

-- ============================================================
-- Hoe Tool (for tilling soil)
-- ============================================================

core.register_tool("mbr_farming:hoe", {
	description = "Farming Hoe",
	inventory_image = "[fill:16x16:#8b7355",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {times = {[1] = 2.00, [2] = 1.00, [3] = 0.50}, uses = 30, maxlevel = 1},
		},
		damage_groups = {fleshy = 2},
	},
	on_use = function(itemstack, user, pointed_thing)
		if not pointed_thing or pointed_thing.type ~= "node" then
			return itemstack
		end
		local pos = pointed_thing.under
		local node = core.get_node(pos)
		if node.name == "mbr_core:dirt" or node.name == "mbr_core:dirt_with_grass" then
			core.set_node(pos, {name = "mbr_farming:soil"})
			itemstack:add_wear(65535 / 60)
			return itemstack
		end
		return itemstack
	end,
})

core.register_craft({
	output = "mbr_farming:hoe",
	recipe = {
		{"mbr_core:wood", "mbr_core:wood"},
		{"", "mbr_core:wood"},
		{"", "mbr_core:wood"},
	},
})

-- Override dirt nodes to support right-click with hoe
local function soil_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	if not clicker or not itemstack then return itemstack end
	local item_name = itemstack:get_name()
	if item_name == "mbr_farming:hoe" then
		core.set_node(pos, {name = "mbr_farming:soil"})
		itemstack:add_wear(65535 / 60)
	end
	return itemstack
end

core.override_item("mbr_core:dirt", {
	on_rightclick = soil_on_rightclick,
})

core.override_item("mbr_core:dirt_with_grass", {
	on_rightclick = soil_on_rightclick,
})

-- ============================================================
-- Crop Registration
-- ============================================================

-- Collect all crop node names for the growth ABM
local all_crop_nodes = {}

for crop_name, crop_def in pairs(crops) do
	-- Seed item
	core.register_craftitem("mbr_farming:" .. crop_name .. "_seed", {
		description = crop_def.desc .. " Seed",
		inventory_image = "[fill:16x16:#2d5a1e",
		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing or pointed_thing.type ~= "node" then
				return itemstack
			end
			local pos = pointed_thing.above
			local under_pos = pointed_thing.under
			local under_node = core.get_node(under_pos)
			if core.get_item_group(under_node.name, "farming_soil") == 0 then
				return itemstack
			end
			local above_node = core.get_node(pos)
			if above_node.name ~= "air" then
				return itemstack
			end
			core.set_node(pos, {name = "mbr_farming:" .. crop_name .. "_1"})
			itemstack:take_item()
			return itemstack
		end,
	})

	-- Harvest item
	core.register_craftitem("mbr_farming:" .. crop_name, {
		description = crop_def.desc,
		inventory_image = "[fill:16x16:" .. crop_def.color,
		on_use = function(itemstack, user, pointed_thing)
			if not user then return itemstack end
			if mbr and mbr.survival then
				local name = user:get_player_name()
				local meta = itemstack:get_meta()
				local quality = meta:get_string("quality")
				local mult = 1.0
				if quality == "Silver" then
					mult = 1.5
				elseif quality == "Gold" then
					mult = 2.0
				end
				mbr.survival.feed_player(name, math.floor(crop_def.hunger * mult))
				if crop_def.thirst then
					mbr.survival.hydrate_player(name, math.floor(crop_def.thirst * mult))
				end
				itemstack:take_item()
			end
			return itemstack
		end,
	})

	-- Growth stage nodes (1-4)
	for stage = 1, 4 do
		local color
		if stage < 4 then
			color = stage_colors[stage]
		else
			color = crop_def.color
		end

		local stage_desc
		if stage == 1 then
			stage_desc = crop_def.desc .. " (Seed)"
		elseif stage == 2 then
			stage_desc = crop_def.desc .. " (Sprout)"
		elseif stage == 3 then
			stage_desc = crop_def.desc .. " (Mature)"
		else
			stage_desc = crop_def.desc .. " (Harvestable)"
		end

		local drop_def
		if stage == 4 then
			drop_def = {
				max_items = 2,
				items = {
					{items = {"mbr_farming:" .. crop_name .. " 1"}, rarity = 1},
					{items = {"mbr_farming:" .. crop_name .. " 2"}, rarity = 3},
					{items = {"mbr_farming:" .. crop_name .. "_seed 1"}, rarity = 1},
					{items = {"mbr_farming:" .. crop_name .. "_seed 1"}, rarity = 2},
				},
			}
		else
			drop_def = "mbr_farming:" .. crop_name .. "_seed"
		end

		local node_name = "mbr_farming:" .. crop_name .. "_" .. stage

		core.register_node(node_name, {
			description = stage_desc,
			drawtype = "plantlike",
			tiles = {"[fill:16x16:" .. color},
			paramtype = "light",
			walkable = false,
			buildable_to = false,
			sunlight_propagates = true,
			selection_box = {
				type = "fixed",
				fixed = {-0.375, -0.5, -0.375, 0.375, -0.5 + stage * 0.25, 0.375},
			},
			groups = {
				snappy = 3,
				attached_node = 1,
				not_in_creative_inventory = (stage ~= 1) and 1 or 0,
				plant = 1,
				growing = (stage < 4) and 1 or 0,
			},
			drop = drop_def,
			on_construct = function(pos)
				if stage == 4 then
					local meta = core.get_meta(pos)
					local quality = get_random_quality()
					meta:set_string("quality", quality)
					if quality ~= "Normal" then
						meta:set_string("infotext", stage_desc .. " [" .. quality .. "]")
					end
				end
			end,
		})

		if stage < 4 then
			table.insert(all_crop_nodes, node_name)
		end
	end

	-- Register as food with survival system
	if mbr and mbr.survival and mbr.survival.register_food then
		mbr.survival.register_food("mbr_farming:" .. crop_name .. "_food", {
			description = crop_def.desc .. " (Cooked)",
			texture = "[fill:16x16:" .. crop_def.color,
			hunger_restore = crop_def.hunger,
			thirst_restore = crop_def.thirst,
		})

		core.register_craft({
			type = "cooking",
			output = "mbr_farming:" .. crop_name .. "_food",
			recipe = "mbr_farming:" .. crop_name,
			cooktime = 5,
		})
	end
end

-- ============================================================
-- Crop Growth ABM
-- ============================================================

core.register_abm({
	label = "Crop growth",
	nodenames = all_crop_nodes,
	interval = 30,
	chance = 1,
	action = function(pos)
		local node = core.get_node(pos)
		-- Parse crop name and stage
		local full_name = node.name
		local crop_name, stage_str = full_name:match("^mbr_farming:(.+)_(%d+)$")
		if not crop_name or not stage_str then return end

		local stage = tonumber(stage_str)
		if not stage or stage >= 4 then return end

		-- Check seasonal availability
		if not crop_can_grow(crop_name) then return end

		-- Check soil type below
		local below = core.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
		local is_wet = core.get_item_group(below.name, "farming_soil_wet") > 0
		local is_soil = core.get_item_group(below.name, "farming_soil") > 0

		if not is_soil then return end

		-- Growth chance: wet soil = 1 in 3, dry soil = 1 in 6
		local chance = is_wet and 3 or 6
		if math.random(chance) ~= 1 then return end

		-- Advance growth stage
		core.set_node(pos, {name = "mbr_farming:" .. crop_name .. "_" .. (stage + 1)})
	end,
})

-- ============================================================
-- Quality-aware harvest drop override
-- ============================================================

-- Override stage 4 crop drops to include quality metadata
local old_handle_drop = core.handle_node_drops
if old_handle_drop then
	core.handle_node_drops = function(pos, drops, digger)
		local node = core.get_node(pos)
		if node.name:match("^mbr_farming:.+_4$") then
			local meta = core.get_meta(pos)
			local quality = meta:get_string("quality")
			if quality ~= "" and quality ~= "Normal" then
				for i, drop in ipairs(drops) do
					if type(drop) == "string" then
						local stack = ItemStack(drop)
						local smeta = stack:get_meta()
						smeta:set_string("quality", quality)
						smeta:set_string("description",
							stack:get_definition().description .. " [" .. quality .. "]")
						drops[i] = stack:to_string()
					end
				end
			end
		end
		return old_handle_drop(pos, drops, digger)
	end
end

-- ============================================================
-- Chat Command
-- ============================================================

core.register_chatcommand("crops", {
	description = "Show crop info, seasons, and current conditions",
	func = function(name, param)
		local season = get_current_season()
		local weather = "unknown"
		if mbr and mbr.weather then
			weather = mbr.weather.current or "unknown"
		end
		local lines = {
			"=== MoonBrook Ridge Farming ===",
			"Current Season: " .. season .. " | Weather: " .. weather,
			"",
		}
		for crop_name, def in pairs(crops) do
			local can_grow = crop_can_grow(crop_name)
			local status = can_grow and "GROWING" or "dormant"
			local season_list = table.concat(def.seasons, ", ")
			table.insert(lines, string.format("  %s - Seasons: %s [%s]",
				def.desc, season_list, status))
		end
		table.insert(lines, "")
		table.insert(lines, "Tip: Use a hoe on dirt to create soil, then plant seeds!")
		return true, table.concat(lines, "\n")
	end,
})

minetest.log("action", "[MBR Farming] Loaded with " .. #all_crop_nodes .. " crop growth stages")
