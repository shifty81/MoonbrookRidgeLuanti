-- MoonBrook Ridge: Quality-Based Crafting System
-- Material quality carries over to crafted tools & weapons.

mbr = mbr or {}
mbr.crafting = {}

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

local QUALITY_POOR      = 1
local QUALITY_NORMAL    = 2
local QUALITY_FINE      = 3
local QUALITY_SUPERIOR  = 4
local QUALITY_MASTERWORK = 5

mbr.crafting.QUALITY_POOR      = QUALITY_POOR
mbr.crafting.QUALITY_NORMAL    = QUALITY_NORMAL
mbr.crafting.QUALITY_FINE      = QUALITY_FINE
mbr.crafting.QUALITY_SUPERIOR  = QUALITY_SUPERIOR
mbr.crafting.QUALITY_MASTERWORK = QUALITY_MASTERWORK

mbr.crafting.quality_names = {
	[QUALITY_POOR]       = "Poor",
	[QUALITY_NORMAL]     = "Normal",
	[QUALITY_FINE]       = "Fine",
	[QUALITY_SUPERIOR]   = "Superior",
	[QUALITY_MASTERWORK] = "Masterwork",
}

mbr.crafting.quality_colors = {
	[QUALITY_POOR]       = "#9D9D9D",
	[QUALITY_NORMAL]     = "#FFFFFF",
	[QUALITY_FINE]       = "#1EFF00",
	[QUALITY_SUPERIOR]   = "#0070DD",
	[QUALITY_MASTERWORK] = "#FF8000",
}

-- Stat multipliers per quality tier
local QUALITY_MULTIPLIERS = {
	[QUALITY_POOR]       = 0.75,
	[QUALITY_NORMAL]     = 1.00,
	[QUALITY_FINE]       = 1.20,
	[QUALITY_SUPERIOR]   = 1.50,
	[QUALITY_MASTERWORK] = 2.00,
}

mbr.crafting.quality_multipliers = QUALITY_MULTIPLIERS

---------------------------------------------------------------------------
-- Material registry
---------------------------------------------------------------------------

-- itemname → { quality = N, ... }
local registered_materials = {}

--- Register a crafting material with an inherent quality.
-- @param itemname  e.g. "mbr:iron_ingot"
-- @param def       { description, texture, quality }
function mbr.crafting.register_material(itemname, def)
	local quality = def.quality or QUALITY_NORMAL
	registered_materials[itemname] = {
		quality     = quality,
		description = def.description or itemname,
	}
	core.register_craftitem(itemname, {
		description = core.colorize(
			mbr.crafting.quality_colors[quality],
			mbr.crafting.quality_names[quality] .. " " ..
			(def.description or itemname)),
		inventory_image = def.texture or "heart.png",
		groups = {crafting_material = 1, quality = quality},
	})
end

--- Get the quality of a material item (from registry or ItemStack meta).
function mbr.crafting.get_material_quality(itemstack)
	if type(itemstack) == "string" then
		local reg = registered_materials[itemstack]
		return reg and reg.quality or QUALITY_NORMAL
	end
	-- Check meta first (loot items may have custom quality)
	local meta = itemstack:get_meta()
	local mq = meta:get_int("mbr_quality")
	if mq > 0 then
		return mq
	end
	local name = itemstack:get_name()
	local reg = registered_materials[name]
	return reg and reg.quality or QUALITY_NORMAL
end

---------------------------------------------------------------------------
-- Recipe registry
---------------------------------------------------------------------------

-- recipe_id → { output, ingredients, base_stats, category, description }
local registered_recipes = {}
local recipe_list = {} -- ordered list for formspec display

--- Register a crafting recipe.
-- @param recipe_id  unique string (e.g. "iron_sword")
-- @param def {
--   output       = "mbr:iron_sword",  -- output itemname
--   description  = "Iron Sword",
--   texture      = "heart.png",
--   category     = "weapons",
--   ingredients  = { {"mbr:iron_ingot", 3}, {"mbr:wood_plank", 1} },
--   base_stats   = { damage = 8, durability = 100 },
--   tool_caps    = { ... },  -- optional Luanti tool_capabilities
-- }
function mbr.crafting.register_recipe(recipe_id, def)
	registered_recipes[recipe_id] = def
	recipe_list[#recipe_list + 1] = recipe_id

	-- Register the base output item if not already registered
	if not core.registered_items[def.output] then
		local item_def = {
			description = def.description or def.output,
			inventory_image = def.texture or "heart.png",
		}
		if def.tool_caps then
			item_def.tool_capabilities = def.tool_caps
			core.register_tool(def.output, item_def)
		else
			core.register_craftitem(def.output, item_def)
		end
	end
end

function mbr.crafting.get_recipe(recipe_id)
	return registered_recipes[recipe_id]
end

function mbr.crafting.get_recipe_list()
	return recipe_list
end

---------------------------------------------------------------------------
-- Quality calculation
---------------------------------------------------------------------------

--- Calculate output quality from a set of input ItemStacks.
-- Uses the weighted average of all input material qualities.
-- @param inputs  list of ItemStack objects
-- @return quality tier (integer), average quality (float)
function mbr.crafting.calculate_quality(inputs)
	local total_quality = 0
	local total_count = 0

	for _, stack in ipairs(inputs) do
		if not stack:is_empty() then
			local q = mbr.crafting.get_material_quality(stack)
			local c = stack:get_count()
			total_quality = total_quality + q * c
			total_count = total_count + c
		end
	end

	if total_count == 0 then
		return QUALITY_NORMAL, QUALITY_NORMAL
	end

	local avg = total_quality / total_count

	-- Map average to tier
	local tier
	if avg >= 4.5 then
		tier = QUALITY_MASTERWORK
	elseif avg >= 3.5 then
		tier = QUALITY_SUPERIOR
	elseif avg >= 2.5 then
		tier = QUALITY_FINE
	elseif avg >= 1.5 then
		tier = QUALITY_NORMAL
	else
		tier = QUALITY_POOR
	end

	return tier, avg
end

--- Apply quality to an output ItemStack.
-- Scales base_stats by the quality multiplier and writes metadata.
function mbr.crafting.apply_quality(itemstack, quality, base_stats)
	local meta = itemstack:get_meta()
	local qname = mbr.crafting.quality_names[quality] or "Normal"
	local qcolor = mbr.crafting.quality_colors[quality] or "#FFFFFF"
	local mult = QUALITY_MULTIPLIERS[quality] or 1.0

	-- Scale stats
	local scaled = {}
	for stat, value in pairs(base_stats or {}) do
		scaled[stat] = math.floor(value * mult + 0.5)
	end

	-- Build description
	local base_desc = core.registered_items[itemstack:get_name()]
	local display_name = base_desc and base_desc.description or itemstack:get_name()
	-- Strip any existing Luanti colour escape sequences to prevent nesting
	display_name = display_name:gsub("\27%([^%)]+%)", "")

	local lines = {
		core.colorize(qcolor, qname .. " " .. display_name),
	}
	for stat, value in pairs(scaled) do
		local label = stat:gsub("_", " ")
		label = label:sub(1, 1):upper() .. label:sub(2)
		lines[#lines + 1] = core.colorize("#AAAAFF", "  " .. label .. ": " .. value)
	end
	lines[#lines + 1] = core.colorize("#888888",
		"  Quality: " .. qname .. " (x" ..
		string.format("%.2f", mult) .. ")")

	meta:set_string("description", table.concat(lines, "\n"))
	meta:set_int("mbr_quality", quality)
	meta:set_string("mbr_quality_name", qname)
	meta:set_string("mbr_scaled_stats", core.serialize(scaled))

	return itemstack
end

---------------------------------------------------------------------------
-- Craft execution
---------------------------------------------------------------------------

--- Attempt to craft a recipe from a player's inventory.
-- Consumes ingredients and gives the quality-scaled output.
-- @param player       PlayerRef
-- @param recipe_id    registered recipe key
-- @return true/false, message
function mbr.crafting.craft(player, recipe_id)
	local recipe = registered_recipes[recipe_id]
	if not recipe then
		return false, "Unknown recipe."
	end

	local inv = player:get_inventory()
	if not inv then
		return false, "No inventory."
	end

	-- Check ingredients
	for _, ing in ipairs(recipe.ingredients) do
		local needed = ItemStack(ing[1] .. " " .. (ing[2] or 1))
		if not inv:contains_item("main", needed) then
			return false, "Missing: " .. (ing[2] or 1) .. "x " .. ing[1]
		end
	end

	-- Gather input stacks for quality calculation
	local input_stacks = {}
	for _, ing in ipairs(recipe.ingredients) do
		local stack = inv:remove_item("main",
			ItemStack(ing[1] .. " " .. (ing[2] or 1)))
		input_stacks[#input_stacks + 1] = stack
	end

	-- Calculate quality from consumed materials
	local quality = mbr.crafting.calculate_quality(input_stacks)

	-- Create output
	local output = ItemStack(recipe.output)
	mbr.crafting.apply_quality(output, quality, recipe.base_stats or {})

	-- Also merge loot affixes if the loot system is loaded
	if mbr.loot then
		local rarity = quality -- quality tier maps to rarity tier
		local loot_data = mbr.loot.generate_item(
			recipe.output,
			recipe.description or recipe.output,
			rarity)
		-- Combine: keep the crafting quality description but add affix stats
		if loot_data.affixes and #loot_data.affixes > 0 then
			local meta = output:get_meta()
			local existing_desc = meta:get_string("description")
			for _, a in ipairs(loot_data.affixes) do
				existing_desc = existing_desc .. "\n" ..
					core.colorize("#AADDFF", "  " .. a.desc)
			end
			meta:set_string("description", existing_desc)

			-- Merge affix stats into scaled stats
			local scaled_str = meta:get_string("mbr_scaled_stats")
			local scaled = core.deserialize(scaled_str) or {}
			for stat, val in pairs(loot_data.stats) do
				scaled[stat] = (scaled[stat] or 0) + val
			end
			meta:set_string("mbr_scaled_stats", core.serialize(scaled))
			meta:set_string("mbr_affixes", core.serialize(loot_data.affixes))
			meta:set_int("mbr_rarity", loot_data.rarity)
		end
	end

	-- Give to player
	if inv:room_for_item("main", output) then
		inv:add_item("main", output)
	else
		-- Drop at feet
		local pos = player:get_pos()
		core.add_item(pos, output)
	end

	-- Particle effect
	if mbr.particles then
		mbr.particles.spawn(player:get_pos(), "sparkle", player)
	end

	local meta = output:get_meta()
	local desc = meta:get_string("description"):split("\n")[1]
	return true, "Crafted: " .. desc
end

---------------------------------------------------------------------------
-- Crafting Station formspec
---------------------------------------------------------------------------

local function build_recipe_formspec(player_name, selected_idx)
	selected_idx = selected_idx or 1
	local recipes = recipe_list
	local fs = {
		"formspec_version[7]",
		"size[12,9]",
		"label[0.3,0.5;Crafting Station]",
	}

	-- Recipe list on the left
	local recipe_names = {}
	for _, rid in ipairs(recipes) do
		local r = registered_recipes[rid]
		recipe_names[#recipe_names + 1] = r and r.description or rid
	end
	fs[#fs + 1] = "textlist[0.3,1;4,6.5;recipe_list;" ..
		table.concat(recipe_names, ",") ..
		";" .. selected_idx .. ";false]"

	-- Details on the right
	if recipes[selected_idx] then
		local rid = recipes[selected_idx]
		local r = registered_recipes[rid]
		if r then
			local y = 1.2
			fs[#fs + 1] = string.format(
				"label[5,%.1f;%s]", y, r.description or rid)
			y = y + 0.6

			fs[#fs + 1] = string.format(
				"label[5,%.1f;Ingredients:]", y)
			y = y + 0.5
			for _, ing in ipairs(r.ingredients) do
				fs[#fs + 1] = string.format(
					"label[5.3,%.1f;%dx %s]", y, ing[2] or 1, ing[1])
				y = y + 0.4
			end

			y = y + 0.3
			if r.base_stats then
				fs[#fs + 1] = string.format(
					"label[5,%.1f;Base Stats:]", y)
				y = y + 0.5
				for stat, val in pairs(r.base_stats) do
					local label = stat:gsub("_", " ")
					label = label:sub(1, 1):upper() .. label:sub(2)
					fs[#fs + 1] = string.format(
						"label[5.3,%.1f;%s: %d]", y, label, val)
					y = y + 0.4
				end
			end

			y = y + 0.3
			fs[#fs + 1] = string.format(
				"label[5,%.1f;Quality scales with input materials!]", y)

			fs[#fs + 1] = "button[5,7;3,0.8;craft;Craft]"
		end
	end

	return table.concat(fs, "")
end

-- Per-player state for formspec
local player_craft_state = {}

--- Open the crafting station UI for a player.
function mbr.crafting.show_station(player)
	local name = player:get_player_name()
	player_craft_state[name] = player_craft_state[name] or {selected = 1}
	local fs = build_recipe_formspec(name, player_craft_state[name].selected)
	core.show_formspec(name, "mbr:crafting_station", fs)
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "mbr:crafting_station" then
		return false
	end
	local name = player:get_player_name()
	local state = player_craft_state[name] or {selected = 1}

	if fields.recipe_list then
		local evt = core.explode_textlist_event(fields.recipe_list)
		if evt.type == "CHG" or evt.type == "DCL" then
			state.selected = evt.index
			player_craft_state[name] = state
			local fs = build_recipe_formspec(name, state.selected)
			core.show_formspec(name, "mbr:crafting_station", fs)
		end
	end

	if fields.craft then
		local rid = recipe_list[state.selected]
		if rid then
			local ok, msg = mbr.crafting.craft(player, rid)
			core.chat_send_player(name,
				ok and core.colorize("#88FF88", msg)
				   or core.colorize("#FF8888", msg))
			-- Refresh formspec
			local fs = build_recipe_formspec(name, state.selected)
			core.show_formspec(name, "mbr:crafting_station", fs)
		end
	end

	return true
end)

core.register_on_leaveplayer(function(player)
	player_craft_state[player:get_player_name()] = nil
end)

---------------------------------------------------------------------------
-- Chat command to open crafting station
---------------------------------------------------------------------------

core.register_chatcommand("craft", {
	description = "Open the crafting station",
	func = function(name)
		local player = core.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		mbr.crafting.show_station(player)
		return true, "Crafting station opened."
	end,
})

---------------------------------------------------------------------------
-- Starter materials & recipes
---------------------------------------------------------------------------

-- Materials at different quality tiers
mbr.crafting.register_material("mbr:wood_plank", {
	description = "Wood Plank",
	texture = "heart.png",
	quality = QUALITY_NORMAL,
})

mbr.crafting.register_material("mbr:stone_chunk", {
	description = "Stone Chunk",
	texture = "heart.png",
	quality = QUALITY_NORMAL,
})

mbr.crafting.register_material("mbr:copper_ingot", {
	description = "Copper Ingot",
	texture = "heart.png",
	quality = QUALITY_FINE,
})

mbr.crafting.register_material("mbr:iron_ingot", {
	description = "Iron Ingot",
	texture = "heart.png",
	quality = QUALITY_SUPERIOR,
})

mbr.crafting.register_material("mbr:gold_ingot", {
	description = "Gold Ingot",
	texture = "heart.png",
	quality = QUALITY_SUPERIOR,
})

mbr.crafting.register_material("mbr:crystal_shard", {
	description = "Crystal Shard",
	texture = "heart.png",
	quality = QUALITY_MASTERWORK,
})

-- Recipes — quality of inputs determines quality of output
mbr.crafting.register_recipe("wooden_sword", {
	output = "mbr:wooden_sword",
	description = "Wooden Sword",
	texture = "heart.png",
	category = "weapons",
	ingredients = {
		{"mbr:wood_plank", 3},
	},
	base_stats = {damage = 4, durability = 60},
	tool_caps = {
		full_punch_interval = 1.0,
		damage_groups = {fleshy = 4},
	},
})

mbr.crafting.register_recipe("stone_sword", {
	output = "mbr:stone_sword",
	description = "Stone Sword",
	texture = "heart.png",
	category = "weapons",
	ingredients = {
		{"mbr:stone_chunk", 2},
		{"mbr:wood_plank", 1},
	},
	base_stats = {damage = 6, durability = 80},
	tool_caps = {
		full_punch_interval = 1.0,
		damage_groups = {fleshy = 6},
	},
})

mbr.crafting.register_recipe("iron_sword", {
	output = "mbr:iron_sword",
	description = "Iron Sword",
	texture = "heart.png",
	category = "weapons",
	ingredients = {
		{"mbr:iron_ingot", 3},
		{"mbr:wood_plank", 1},
	},
	base_stats = {damage = 10, durability = 150},
	tool_caps = {
		full_punch_interval = 0.8,
		damage_groups = {fleshy = 10},
	},
})

mbr.crafting.register_recipe("crystal_sword", {
	output = "mbr:crystal_sword",
	description = "Crystal Sword",
	texture = "heart.png",
	category = "weapons",
	ingredients = {
		{"mbr:crystal_shard", 3},
		{"mbr:iron_ingot", 1},
	},
	base_stats = {damage = 16, durability = 250},
	tool_caps = {
		full_punch_interval = 0.6,
		damage_groups = {fleshy = 16},
	},
})

mbr.crafting.register_recipe("wooden_pickaxe", {
	output = "mbr:wooden_pickaxe",
	description = "Wooden Pickaxe",
	texture = "heart.png",
	category = "tools",
	ingredients = {
		{"mbr:wood_plank", 5},
	},
	base_stats = {dig_speed = 3, durability = 60},
	tool_caps = {
		full_punch_interval = 1.2,
		max_drop_level = 0,
		groupcaps = {
			cracky = {times = {[3] = 1.6}, uses = 10, maxlevel = 1},
		},
		damage_groups = {fleshy = 2},
	},
})

mbr.crafting.register_recipe("iron_pickaxe", {
	output = "mbr:iron_pickaxe",
	description = "Iron Pickaxe",
	texture = "heart.png",
	category = "tools",
	ingredients = {
		{"mbr:iron_ingot", 3},
		{"mbr:wood_plank", 2},
	},
	base_stats = {dig_speed = 6, durability = 150},
	tool_caps = {
		full_punch_interval = 1.0,
		max_drop_level = 1,
		groupcaps = {
			cracky = {times = {[2] = 1.0, [3] = 0.6}, uses = 20, maxlevel = 2},
		},
		damage_groups = {fleshy = 4},
	},
})

mbr.crafting.register_recipe("iron_hoe", {
	output = "mbr:iron_hoe",
	description = "Iron Hoe",
	texture = "heart.png",
	category = "tools",
	ingredients = {
		{"mbr:iron_ingot", 2},
		{"mbr:wood_plank", 2},
	},
	base_stats = {efficiency = 5, durability = 120},
})

mbr.crafting.register_recipe("copper_axe", {
	output = "mbr:copper_axe",
	description = "Copper Axe",
	texture = "heart.png",
	category = "tools",
	ingredients = {
		{"mbr:copper_ingot", 3},
		{"mbr:wood_plank", 2},
	},
	base_stats = {dig_speed = 5, durability = 100},
	tool_caps = {
		full_punch_interval = 1.0,
		max_drop_level = 1,
		groupcaps = {
			choppy = {times = {[2] = 1.4, [3] = 0.8}, uses = 15, maxlevel = 2},
		},
		damage_groups = {fleshy = 4},
	},
})
