-- MoonBrook Ridge: Diablo-Style Loot System
-- Randomised rarity, affixes, and stat generation for dropped items.

mbr = mbr or {}
mbr.loot = {}

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

-- Rarity tiers (lowest → highest)
local RARITY_COMMON    = 1
local RARITY_MAGIC     = 2
local RARITY_RARE      = 3
local RARITY_EPIC      = 4
local RARITY_LEGENDARY = 5

mbr.loot.RARITY_COMMON    = RARITY_COMMON
mbr.loot.RARITY_MAGIC     = RARITY_MAGIC
mbr.loot.RARITY_RARE      = RARITY_RARE
mbr.loot.RARITY_EPIC      = RARITY_EPIC
mbr.loot.RARITY_LEGENDARY = RARITY_LEGENDARY

mbr.loot.rarity_names = {
	[RARITY_COMMON]    = "Common",
	[RARITY_MAGIC]     = "Magic",
	[RARITY_RARE]      = "Rare",
	[RARITY_EPIC]      = "Epic",
	[RARITY_LEGENDARY] = "Legendary",
}

mbr.loot.rarity_colors = {
	[RARITY_COMMON]    = "#FFFFFF",
	[RARITY_MAGIC]     = "#6888FF",
	[RARITY_RARE]      = "#FFFF00",
	[RARITY_EPIC]      = "#A335EE",
	[RARITY_LEGENDARY] = "#FF8000",
}

-- Default weights for rarity rolls (higher = more likely)
local DEFAULT_RARITY_WEIGHTS = {
	[RARITY_COMMON]    = 60,
	[RARITY_MAGIC]     = 25,
	[RARITY_RARE]      = 10,
	[RARITY_EPIC]      = 4,
	[RARITY_LEGENDARY] = 1,
}

-- Number of affixes per rarity tier
local AFFIX_COUNTS = {
	[RARITY_COMMON]    = 0,
	[RARITY_MAGIC]     = {1, 2},
	[RARITY_RARE]      = {2, 3},
	[RARITY_EPIC]      = {3, 4},
	[RARITY_LEGENDARY] = {4, 5},
}

---------------------------------------------------------------------------
-- Affix pool
---------------------------------------------------------------------------

-- Each affix: { name, stat, min_value, max_value, description_fmt }
local affix_pool = {
	-- Offensive
	{name = "Sharp",     stat = "damage",       min = 1,  max = 8,
		desc = "+%d Damage"},
	{name = "Fierce",    stat = "damage",       min = 3,  max = 12,
		desc = "+%d Damage"},
	{name = "Blazing",   stat = "fire_damage",  min = 2,  max = 10,
		desc = "+%d Fire Damage"},
	{name = "Frozen",    stat = "ice_damage",    min = 2,  max = 10,
		desc = "+%d Ice Damage"},
	{name = "Venomous",  stat = "poison_damage", min = 1, max = 6,
		desc = "+%d Poison Damage"},
	{name = "Swift",     stat = "attack_speed",  min = 5, max = 20,
		desc = "+%d%% Attack Speed"},
	{name = "Critical",  stat = "crit_chance",   min = 3, max = 15,
		desc = "+%d%% Critical Chance"},

	-- Defensive
	{name = "Sturdy",    stat = "armor",         min = 1, max = 8,
		desc = "+%d Armor"},
	{name = "Fortified", stat = "armor",         min = 3, max = 12,
		desc = "+%d Armor"},
	{name = "Resilient", stat = "hp_bonus",      min = 5, max = 25,
		desc = "+%d Max HP"},
	{name = "Warding",   stat = "resist_magic",  min = 3, max = 15,
		desc = "+%d%% Magic Resist"},

	-- Utility
	{name = "Lucky",     stat = "luck",          min = 1, max = 5,
		desc = "+%d Luck"},
	{name = "Bountiful", stat = "harvest_bonus", min = 5, max = 20,
		desc = "+%d%% Harvest Bonus"},
	{name = "Nimble",    stat = "speed_bonus",   min = 3, max = 12,
		desc = "+%d%% Movement Speed"},
	{name = "Enduring",  stat = "durability",    min = 10, max = 50,
		desc = "+%d Durability"},
	{name = "Gleaming",  stat = "xp_bonus",      min = 3, max = 15,
		desc = "+%d%% XP Bonus"},
}

---------------------------------------------------------------------------
-- Registered loot tables
---------------------------------------------------------------------------

-- source_name → list of { itemname, weight, [min_rarity], [max_rarity] }
local loot_tables = {}

--- Register a loot table for a source (mob, node, chest, etc.).
-- @param source   string identifier (e.g. "mob:skeleton")
-- @param entries  list of { itemname, weight, [min_rarity], [max_rarity] }
function mbr.loot.register_loot_table(source, entries)
	loot_tables[source] = entries
end

--- Get the loot table for a source.
function mbr.loot.get_loot_table(source)
	return loot_tables[source]
end

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function clamp(v, lo, hi)
	if v < lo then return lo end
	if v > hi then return hi end
	return v
end

--- Weighted-random pick from a { key = weight } table.
local function weighted_pick(weights)
	local total = 0
	for _, w in pairs(weights) do
		total = total + w
	end
	local roll = math.random(1, total)
	local cumul = 0
	for key, w in pairs(weights) do
		cumul = cumul + w
		if roll <= cumul then
			return key
		end
	end
	-- Fallback (should not happen)
	return next(weights)
end

---------------------------------------------------------------------------
-- Core generation
---------------------------------------------------------------------------

--- Roll a rarity tier.
-- @param weights  optional custom weight table { [RARITY_*] = number }
-- @return rarity integer
function mbr.loot.roll_rarity(weights)
	return weighted_pick(weights or DEFAULT_RARITY_WEIGHTS)
end

--- Generate random affixes for a given rarity.
-- @return list of { name, stat, value, desc }
function mbr.loot.generate_affixes(rarity)
	local count_def = AFFIX_COUNTS[rarity] or 0
	local count
	if type(count_def) == "table" then
		count = math.random(count_def[1], count_def[2])
	else
		count = count_def
	end
	if count == 0 then
		return {}
	end

	-- Build shuffled copy of affix pool
	local pool = {}
	for i, a in ipairs(affix_pool) do
		pool[i] = a
	end
	-- Fisher-Yates shuffle
	for i = #pool, 2, -1 do
		local j = math.random(1, i)
		pool[i], pool[j] = pool[j], pool[i]
	end

	local affixes = {}
	local used_stats = {}
	for _, a in ipairs(pool) do
		if #affixes >= count then break end
		-- Avoid duplicate stat types
		if not used_stats[a.stat] then
			local value = math.random(a.min, a.max)
			affixes[#affixes + 1] = {
				name  = a.name,
				stat  = a.stat,
				value = value,
				desc  = string.format(a.desc, value),
			}
			used_stats[a.stat] = true
		end
	end
	return affixes
end

--- Build a complete loot item definition.
-- @param base_name   item name (e.g. "mbr:iron_sword")
-- @param base_desc   base description (e.g. "Iron Sword")
-- @param rarity      optional forced rarity
-- @param weights     optional rarity weight overrides
-- @return table { name, description, rarity, rarity_name, color, affixes, stats }
function mbr.loot.generate_item(base_name, base_desc, rarity, weights)
	rarity = rarity or mbr.loot.roll_rarity(weights)
	rarity = clamp(rarity, RARITY_COMMON, RARITY_LEGENDARY)

	local rarity_name = mbr.loot.rarity_names[rarity]
	local color = mbr.loot.rarity_colors[rarity]

	local affixes = mbr.loot.generate_affixes(rarity)

	-- Aggregate stats
	local stats = {}
	for _, a in ipairs(affixes) do
		stats[a.stat] = (stats[a.stat] or 0) + a.value
	end

	-- Build description lines
	local desc_lines = {
		core.colorize(color, rarity_name .. " " .. base_desc),
	}
	for _, a in ipairs(affixes) do
		desc_lines[#desc_lines + 1] = core.colorize("#AAAAFF", "  " .. a.desc)
	end

	return {
		name        = base_name,
		description = table.concat(desc_lines, "\n"),
		rarity      = rarity,
		rarity_name = rarity_name,
		color       = color,
		affixes     = affixes,
		stats       = stats,
	}
end

---------------------------------------------------------------------------
-- Serialisation — store loot data in ItemStack meta
---------------------------------------------------------------------------

--- Write loot data into an ItemStack's metadata.
function mbr.loot.apply_to_itemstack(itemstack, loot_data)
	local meta = itemstack:get_meta()
	meta:set_string("description", loot_data.description)
	meta:set_int("mbr_rarity", loot_data.rarity)
	meta:set_string("mbr_rarity_name", loot_data.rarity_name)
	meta:set_string("mbr_color", loot_data.color)
	meta:set_string("mbr_affixes", core.serialize(loot_data.affixes))
	meta:set_string("mbr_stats", core.serialize(loot_data.stats))
	return itemstack
end

--- Read loot data from an ItemStack's metadata.
function mbr.loot.read_from_itemstack(itemstack)
	local meta = itemstack:get_meta()
	local rarity = meta:get_int("mbr_rarity")
	if rarity == 0 then
		return nil -- not a loot item
	end
	return {
		rarity      = rarity,
		rarity_name = meta:get_string("mbr_rarity_name"),
		color       = meta:get_string("mbr_color"),
		affixes     = core.deserialize(meta:get_string("mbr_affixes")) or {},
		stats       = core.deserialize(meta:get_string("mbr_stats")) or {},
		description = meta:get_string("description"),
	}
end

---------------------------------------------------------------------------
-- Identification mechanic
---------------------------------------------------------------------------

-- Unidentified items carry rarity but affixes are hidden until identified.

--- Create an unidentified loot drop (affixes hidden).
function mbr.loot.create_unidentified(base_name, base_desc, rarity, weights)
	local loot_data = mbr.loot.generate_item(base_name, base_desc, rarity, weights)
	-- Store full data but show "Unidentified" description
	local color = loot_data.color
	loot_data.identified = false
	loot_data.original_description = loot_data.description
	loot_data.description = core.colorize(color, "Unidentified " .. base_desc) ..
		"\n" .. core.colorize("#888888", "Use an Identify Scroll to reveal stats")
	return loot_data
end

--- Identify a previously unidentified item on an ItemStack.
function mbr.loot.identify(itemstack)
	local meta = itemstack:get_meta()
	local original = meta:get_string("mbr_original_description")
	if original ~= "" then
		meta:set_string("description", original)
		meta:set_string("mbr_original_description", "")
		meta:set_int("mbr_identified", 1)
		return true
	end
	return false
end

--- Apply unidentified loot data to an ItemStack.
function mbr.loot.apply_unidentified_to_itemstack(itemstack, loot_data)
	local meta = itemstack:get_meta()
	meta:set_string("description", loot_data.description)
	meta:set_int("mbr_rarity", loot_data.rarity)
	meta:set_string("mbr_rarity_name", loot_data.rarity_name)
	meta:set_string("mbr_color", loot_data.color)
	meta:set_string("mbr_affixes", core.serialize(loot_data.affixes))
	meta:set_string("mbr_stats", core.serialize(loot_data.stats))
	meta:set_string("mbr_original_description", loot_data.original_description)
	meta:set_int("mbr_identified", 0)
	return itemstack
end

---------------------------------------------------------------------------
-- Loot-drop helper
---------------------------------------------------------------------------

--- Roll loot from a registered table and drop items at a position.
-- @param source   loot table key
-- @param pos      world position to drop at
-- @param count    number of drops (default 1)
function mbr.loot.drop_loot(source, pos, count)
	local entries = loot_tables[source]
	if not entries or #entries == 0 then
		return
	end
	count = count or 1

	-- Build weight map for picking entries
	local total_weight = 0
	for _, e in ipairs(entries) do
		total_weight = total_weight + (e.weight or 1)
	end

	for _ = 1, count do
		-- Pick an entry
		local roll = math.random(1, total_weight)
		local cumul = 0
		local chosen
		for _, e in ipairs(entries) do
			cumul = cumul + (e.weight or 1)
			if roll <= cumul then
				chosen = e
				break
			end
		end
		if not chosen then
			chosen = entries[1]
		end

		-- Roll rarity within entry constraints
		local rarity_weights = {}
		for r, w in pairs(DEFAULT_RARITY_WEIGHTS) do
			local min_r = chosen.min_rarity or RARITY_COMMON
			local max_r = chosen.max_rarity or RARITY_LEGENDARY
			if r >= min_r and r <= max_r then
				rarity_weights[r] = w
			end
		end
		local rarity = mbr.loot.roll_rarity(rarity_weights)

		local base_desc = chosen.description or chosen.itemname
		local loot_data = mbr.loot.generate_item(
			chosen.itemname, base_desc, rarity)

		-- Create and drop the ItemStack
		local stack = ItemStack(chosen.itemname)
		mbr.loot.apply_to_itemstack(stack, loot_data)

		local drop_pos = {
			x = pos.x + math.random() * 0.6 - 0.3,
			y = pos.y + 0.5,
			z = pos.z + math.random() * 0.6 - 0.3,
		}
		core.add_item(drop_pos, stack)
	end
end

---------------------------------------------------------------------------
-- Identify Scroll item
---------------------------------------------------------------------------

core.register_craftitem("mbr:identify_scroll", {
	description = core.colorize("#88DDFF", "Identify Scroll") ..
		"\n" .. core.colorize("#888888", "Right-click an unidentified item to reveal its stats"),
	inventory_image = "heart.png",
	stack_max = 99,
	on_use = function(itemstack, user)
		if not user then return itemstack end
		local name = user:get_player_name()
		-- Try to identify the next unidentified item in inventory
		local inv = user:get_inventory()
		if not inv then return itemstack end
		local list = inv:get_list("main")
		if not list then return itemstack end

		for i, stack in ipairs(list) do
			if not stack:is_empty() then
				local meta = stack:get_meta()
				if meta:get_int("mbr_identified") == 0 and
						meta:get_string("mbr_original_description") ~= "" then
					mbr.loot.identify(stack)
					inv:set_stack("main", i, stack)
					core.chat_send_player(name,
						core.colorize("#88DDFF",
							"Item identified: " ..
							meta:get_string("description"):split("\n")[1]))
					itemstack:take_item()
					return itemstack
				end
			end
		end
		core.chat_send_player(name,
			core.colorize("#FF8888",
				"No unidentified items found in your inventory."))
		return itemstack
	end,
})

---------------------------------------------------------------------------
-- Chat command for inspecting held item
---------------------------------------------------------------------------

core.register_chatcommand("iteminfo", {
	description = "Show loot stats for the currently held item",
	func = function(name)
		local player = core.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		local stack = player:get_wielded_item()
		if stack:is_empty() then
			return false, "You are not holding anything."
		end
		local loot = mbr.loot.read_from_itemstack(stack)
		if not loot then
			return true, "This item has no special loot properties."
		end
		local lines = {
			core.colorize(loot.color, loot.rarity_name .. " item"),
		}
		for _, a in ipairs(loot.affixes) do
			lines[#lines + 1] = "  " .. a.desc
		end
		return true, table.concat(lines, "\n")
	end,
})
