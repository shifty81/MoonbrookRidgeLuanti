-- ============================================================
-- MBR Upgrades — Tool Upgrade System
-- Provides tiered tool upgrades via an upgrade station
-- ============================================================

local modpath = core.get_modpath("mbr_upgrades")

-- ============================================================
-- Resolve material item names (prefer mbr_mining, fallback to mbr)
-- ============================================================

local function resolve_item(primary, fallback)
	if core.registered_items[primary] then
		return primary
	elseif fallback and core.registered_items[fallback] then
		return fallback
	end
	return primary
end

local mat = {
	copper_ingot  = resolve_item("mbr_mining:copper_ingot",  "mbr:copper_ingot"),
	iron_ingot    = resolve_item("mbr_mining:iron_ingot",    "mbr:iron_ingot"),
	gold_ingot    = resolve_item("mbr_mining:gold_ingot",    "mbr:gold_ingot"),
	crystal_shard = resolve_item("mbr_mining:crystal_ingot", "mbr:crystal_shard"),
}

-- ============================================================
-- Tier definitions
-- ============================================================

local TIERS = {"basic", "copper", "iron", "gold", "crystal"}

local TIER_COLORS = {
	basic   = "#8b7355",
	copper  = "#b87333",
	iron    = "#cccccc",
	gold    = "#ffd700",
	crystal = "#88ccff",
}

local TIER_LABELS = {
	basic   = "Basic",
	copper  = "Copper",
	iron    = "Iron",
	gold    = "Gold",
	crystal = "Crystal",
}

local function tier_index(tier)
	for i, t in ipairs(TIERS) do
		if t == tier then return i end
	end
	return nil
end

-- ============================================================
-- Upgrade cost definitions
-- ============================================================

local UPGRADE_COSTS = {
	-- basic -> copper
	{from = "basic",  to = "copper",  items = {{name = mat.copper_ingot, count = 5}}},
	-- copper -> iron
	{from = "copper", to = "iron",    items = {{name = mat.iron_ingot,   count = 5}}},
	-- iron -> gold
	{from = "iron",   to = "gold",    items = {{name = mat.gold_ingot,   count = 5}}},
	-- gold -> crystal
	{from = "gold",   to = "crystal", items = {
		{name = mat.crystal_shard, count = 3},
		{name = mat.gold_ingot,    count = 2},
	}},
}

local function get_upgrade_cost(from_tier)
	for _, cost in ipairs(UPGRADE_COSTS) do
		if cost.from == from_tier then
			return cost
		end
	end
	return nil
end

-- ============================================================
-- Tool type registry — maps tool names to {type, tier}
-- ============================================================

local tool_registry = {}
local type_tiers = {}

local function register_upgrade_tool(tool_type, tier, tool_name)
	tool_registry[tool_name] = {type = tool_type, tier = tier}
	if not type_tiers[tool_type] then
		type_tiers[tool_type] = {}
	end
	type_tiers[tool_type][tier] = tool_name
end

-- Register basic-tier tools from other mods
local function register_basic_tools()
	-- Pickaxe basics
	if core.registered_tools["mbr_tools:pick_wood"] then
		register_upgrade_tool("pickaxe", "basic", "mbr_tools:pick_wood")
	end
	if core.registered_tools["mbr_tools:pick_stone"] then
		register_upgrade_tool("pickaxe", "basic", "mbr_tools:pick_stone")
	end
	-- Axe basics
	if core.registered_tools["mbr_tools:axe_wood"] then
		register_upgrade_tool("axe", "basic", "mbr_tools:axe_wood")
	end
	if core.registered_tools["mbr_tools:axe_stone"] then
		register_upgrade_tool("axe", "basic", "mbr_tools:axe_stone")
	end
	-- Hoe basic
	if core.registered_tools["mbr_farming:hoe"] then
		register_upgrade_tool("hoe", "basic", "mbr_farming:hoe")
	end
	-- Watering can basic
	if core.registered_tools["mbr_farming:watering_can"] then
		register_upgrade_tool("watering_can", "basic", "mbr_farming:watering_can")
	end
	-- Fishing rod basic
	if core.registered_tools["mbr_fishing:fishing_rod"] then
		register_upgrade_tool("fishing_rod", "basic", "mbr_fishing:fishing_rod")
	end
end

-- ============================================================
-- Hoe on_use — till dirt/grass into soil with area effect
-- ============================================================

local HOE_AREAS = {
	copper  = {{x = 0, y = 0, z = 0}},
	iron    = {{x = 0, y = 0, z = 0}, {x = 1, y = 0, z = 0}},
	gold    = {{x = 0, y = 0, z = 0}, {x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0}},
	crystal = {},
}

-- Build 3x3 area for crystal hoe
for dx = -1, 1 do
	for dz = -1, 1 do
		table.insert(HOE_AREAS.crystal, {x = dx, y = 0, z = dz})
	end
end

local TILLABLE_NODES = {
	["mbr_core:dirt"]            = "mbr_farming:soil",
	["mbr_core:dirt_with_grass"] = "mbr_farming:soil",
}

local function hoe_on_use(tier, uses)
	return function(itemstack, user, pointed_thing)
		if not pointed_thing or pointed_thing.type ~= "node" then
			return itemstack
		end
		local pos = pointed_thing.under
		local offsets = HOE_AREAS[tier] or {{x = 0, y = 0, z = 0}}
		local tilled = false

		for _, offset in ipairs(offsets) do
			local tgt = {x = pos.x + offset.x, y = pos.y + offset.y, z = pos.z + offset.z}
			local node = core.get_node(tgt)
			local replacement = TILLABLE_NODES[node.name]
			if replacement and core.registered_nodes[replacement] then
				core.set_node(tgt, {name = replacement})
				tilled = true
			end
		end

		if tilled then
			itemstack:add_wear(65535 / uses)
		end
		return itemstack
	end
end

-- ============================================================
-- Watering Can on_use — wet soil with area effect
-- ============================================================

local WATER_AREAS = {
	copper  = {{x = 0, y = 0, z = 0}},
	iron    = {{x = 0, y = 0, z = 0}, {x = 1, y = 0, z = 0}},
	gold    = {{x = 0, y = 0, z = 0}, {x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0}},
	crystal = {},
}

for dx = -1, 1 do
	for dz = -1, 1 do
		table.insert(WATER_AREAS.crystal, {x = dx, y = 0, z = dz})
	end
end

local function watering_can_on_use(tier, uses)
	return function(itemstack, user, pointed_thing)
		if not pointed_thing or pointed_thing.type ~= "node" then
			return itemstack
		end
		local pos = pointed_thing.under
		local offsets = WATER_AREAS[tier] or {{x = 0, y = 0, z = 0}}
		local watered = false

		for _, offset in ipairs(offsets) do
			local tgt = {x = pos.x + offset.x, y = pos.y + offset.y, z = pos.z + offset.z}
			local node = core.get_node(tgt)
			if node.name == "mbr_farming:soil" and
			   core.registered_nodes["mbr_farming:soil_wet"] then
				core.set_node(tgt, {name = "mbr_farming:soil_wet"})
				watered = true
			end
		end

		if watered then
			itemstack:add_wear(65535 / uses)
		end
		return itemstack
	end
end

-- ============================================================
-- Scythe on_use — harvest crops in an area
-- ============================================================

local SCYTHE_RANGES = {
	copper  = 0,
	iron    = 1,
	gold    = 1,
	crystal = 2,
}

local SCYTHE_WIDTHS = {
	copper  = 0,
	iron    = 0,
	gold    = 1,
	crystal = 2,
}

local function scythe_on_use(tier, uses)
	local range = SCYTHE_RANGES[tier] or 0
	local width = SCYTHE_WIDTHS[tier] or 0
	return function(itemstack, user, pointed_thing)
		if not pointed_thing or pointed_thing.type ~= "node" then
			return itemstack
		end
		local pos = pointed_thing.under
		local harvested = false

		for dx = -width, width do
			for dz = -range, range do
				local tgt = {x = pos.x + dx, y = pos.y, z = pos.z + dz}
				local node = core.get_node(tgt)
				local def = core.registered_nodes[node.name]
				if def and def.groups and def.groups.plant then
					local drops = core.get_node_drops(node.name, "")
					core.remove_node(tgt)
					for _, drop in ipairs(drops) do
						core.add_item(tgt, drop)
					end
					harvested = true
				end
			end
		end

		if harvested then
			itemstack:add_wear(65535 / uses)
		end
		return itemstack
	end
end

-- ============================================================
-- Fishing Rod on_use — placeholder that stores catch bonus
-- ============================================================

local function fishing_rod_on_use(tier, uses, catch_bonus)
	return function(itemstack, user, pointed_thing)
		-- Set catch bonus in tool metadata for the fishing system to read
		local meta = itemstack:get_meta()
		if meta:get_float("catch_bonus") == 0 then
			meta:set_float("catch_bonus", catch_bonus)
			meta:set_string("description",
				itemstack:get_definition().description ..
				"\nCatch Bonus: +" .. math.floor(catch_bonus * 100) .. "%")
		end
		return itemstack
	end
end

-- ============================================================
-- Register upgraded tools
-- ============================================================

-- Pickaxe tiers
local pick_defs = {
	{tier = "copper",  color = "#b87333", dmg = 4,
		caps = {cracky = {times = {[2] = 1.8, [3] = 0.9}, uses = 25, maxlevel = 2}}},
	{tier = "iron",    color = "#cccccc", dmg = 5,
		caps = {cracky = {times = {[1] = 2.5, [2] = 1.2, [3] = 0.6}, uses = 35, maxlevel = 3}}},
	{tier = "gold",    color = "#ffd700", dmg = 6,
		caps = {cracky = {times = {[1] = 2.0, [2] = 0.9, [3] = 0.4}, uses = 50, maxlevel = 3}}},
	{tier = "crystal", color = "#88ccff", dmg = 8,
		caps = {cracky = {times = {[1] = 1.5, [2] = 0.7, [3] = 0.3}, uses = 75, maxlevel = 3}}},
}

for _, def in ipairs(pick_defs) do
	local name = "mbr_upgrades:pick_" .. def.tier
	core.register_tool(name, {
		description = TIER_LABELS[def.tier] .. " Pickaxe",
		inventory_image = "[fill:16x16:" .. def.color,
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level = 1,
			groupcaps = def.caps,
			damage_groups = {fleshy = def.dmg},
		},
	})
	register_upgrade_tool("pickaxe", def.tier, name)
end

-- Axe tiers
local axe_defs = {
	{tier = "copper",  color = "#b87333", dmg = 4,
		caps = {choppy = {times = {[1] = 2.5, [2] = 1.5, [3] = 0.9}, uses = 25, maxlevel = 2}}},
	{tier = "iron",    color = "#cccccc", dmg = 5,
		caps = {choppy = {times = {[1] = 2.0, [2] = 1.2, [3] = 0.7}, uses = 35, maxlevel = 3}}},
	{tier = "gold",    color = "#ffd700", dmg = 6,
		caps = {choppy = {times = {[1] = 1.6, [2] = 0.9, [3] = 0.5}, uses = 50, maxlevel = 3}}},
	{tier = "crystal", color = "#88ccff", dmg = 8,
		caps = {choppy = {times = {[1] = 1.2, [2] = 0.7, [3] = 0.3}, uses = 75, maxlevel = 3}}},
}

for _, def in ipairs(axe_defs) do
	local name = "mbr_upgrades:axe_" .. def.tier
	core.register_tool(name, {
		description = TIER_LABELS[def.tier] .. " Axe",
		inventory_image = "[fill:16x16:" .. def.color,
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level = 1,
			groupcaps = def.caps,
			damage_groups = {fleshy = def.dmg},
		},
	})
	register_upgrade_tool("axe", def.tier, name)
end

-- Hoe tiers
local hoe_defs = {
	{tier = "copper",  color = "#b87333", uses = 50},
	{tier = "iron",    color = "#cccccc", uses = 80},
	{tier = "gold",    color = "#ffd700", uses = 120},
	{tier = "crystal", color = "#88ccff", uses = 200},
}

for _, def in ipairs(hoe_defs) do
	local name = "mbr_upgrades:hoe_" .. def.tier
	core.register_tool(name, {
		description = TIER_LABELS[def.tier] .. " Hoe",
		inventory_image = "[fill:16x16:" .. def.color,
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level = 0,
			groupcaps = {
				crumbly = {times = {[1] = 1.5, [2] = 0.8, [3] = 0.4}, uses = def.uses, maxlevel = 1},
			},
			damage_groups = {fleshy = 2},
		},
		on_use = hoe_on_use(def.tier, def.uses),
	})
	register_upgrade_tool("hoe", def.tier, name)
end

-- Watering Can tiers
local wcan_defs = {
	{tier = "copper",  color = "#b8934a", uses = 150},
	{tier = "iron",    color = "#aabbcc", uses = 250},
	{tier = "gold",    color = "#ddc855", uses = 400},
	{tier = "crystal", color = "#77bbee", uses = 800},
}

for _, def in ipairs(wcan_defs) do
	local name = "mbr_upgrades:watering_can_" .. def.tier
	core.register_tool(name, {
		description = TIER_LABELS[def.tier] .. " Watering Can",
		inventory_image = "[fill:16x16:" .. def.color,
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level = 0,
			groupcaps = {},
			damage_groups = {fleshy = 1},
		},
		on_use = watering_can_on_use(def.tier, def.uses),
	})
	register_upgrade_tool("watering_can", def.tier, name)
end

-- Fishing Rod tiers
local frod_defs = {
	{tier = "copper",  color = "#b87333", uses = 40,  catch_bonus = 0.10},
	{tier = "iron",    color = "#cccccc", uses = 60,  catch_bonus = 0.20},
	{tier = "gold",    color = "#ffd700", uses = 100, catch_bonus = 0.35},
	{tier = "crystal", color = "#88ccff", uses = 200, catch_bonus = 0.50},
}

for _, def in ipairs(frod_defs) do
	local name = "mbr_upgrades:fishing_rod_" .. def.tier
	core.register_tool(name, {
		description = TIER_LABELS[def.tier] .. " Fishing Rod\nCatch Bonus: +" ..
			math.floor(def.catch_bonus * 100) .. "%",
		inventory_image = "[fill:16x16:" .. def.color,
		tool_capabilities = {
			full_punch_interval = 1.2,
			max_drop_level = 0,
			groupcaps = {},
			damage_groups = {fleshy = 1},
		},
		on_use = fishing_rod_on_use(def.tier, def.uses, def.catch_bonus),
	})
	register_upgrade_tool("fishing_rod", def.tier, name)
end

-- Scythe tiers
local scythe_defs = {
	{tier = "copper",  color = "#b87333", uses = 30,  dmg = 3},
	{tier = "iron",    color = "#cccccc", uses = 50,  dmg = 4},
	{tier = "gold",    color = "#ffd700", uses = 80,  dmg = 5},
	{tier = "crystal", color = "#88ccff", uses = 120, dmg = 7},
}

for _, def in ipairs(scythe_defs) do
	local name = "mbr_upgrades:scythe_" .. def.tier
	core.register_tool(name, {
		description = TIER_LABELS[def.tier] .. " Scythe",
		inventory_image = "[fill:16x16:" .. def.color,
		tool_capabilities = {
			full_punch_interval = 0.8,
			max_drop_level = 0,
			groupcaps = {
				snappy = {times = {[1] = 1.5, [2] = 1.0, [3] = 0.5}, uses = def.uses, maxlevel = 1},
			},
			damage_groups = {fleshy = def.dmg},
		},
		on_use = scythe_on_use(def.tier, def.uses),
	})
	register_upgrade_tool("scythe", def.tier, name)
end

-- ============================================================
-- Tool lookup helpers
-- ============================================================

local function get_tool_info(tool_name)
	return tool_registry[tool_name]
end

local function get_next_tier(current_tier)
	local idx = tier_index(current_tier)
	if idx and idx < #TIERS then
		return TIERS[idx + 1]
	end
	return nil
end

local function get_upgraded_tool_name(tool_type, next_tier)
	if type_tiers[tool_type] and type_tiers[tool_type][next_tier] then
		return type_tiers[tool_type][next_tier]
	end
	return nil
end

local TOOL_TYPE_LABELS = {
	pickaxe      = "Pickaxe",
	axe          = "Axe",
	hoe          = "Hoe",
	watering_can = "Watering Can",
	fishing_rod  = "Fishing Rod",
	scythe       = "Scythe",
}

-- ============================================================
-- Upgrade Station — Node Definition
-- ============================================================

local function get_station_formspec(pos, player_name)
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	local tool_stack = inv:get_stack("tool", 1)

	local fs = "formspec_version[7]"
	fs = fs .. "size[12,9]"
	fs = fs .. "label[0.3,0.5;Upgrade Station]"
	fs = fs .. "box[0.2,0.8;11.6,0.05;#8866aa]"

	-- Tool slot
	fs = fs .. "label[0.5,1.4;Place tool here:]"
	fs = fs .. "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";tool;3,1.1;1,1;]"

	-- Material slots
	fs = fs .. "label[5.5,1.4;Materials:]"
	fs = fs .. "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";materials;7,1.1;4,1;]"

	-- Player inventory
	fs = fs .. "list[current_player;main;0.5,5;8,4;]"

	-- Ring for shift-click
	fs = fs .. "listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";tool]"
	fs = fs .. "listring[current_player;main]"
	fs = fs .. "listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";materials]"
	fs = fs .. "listring[current_player;main]"

	-- Info panel
	if not tool_stack:is_empty() then
		local info = get_tool_info(tool_stack:get_name())
		if info then
			local next_tier = get_next_tier(info.tier)
			if next_tier then
				local upgraded_name = get_upgraded_tool_name(info.type, next_tier)
				local type_label = TOOL_TYPE_LABELS[info.type] or info.type
				local cost = get_upgrade_cost(info.tier)

				fs = fs .. "label[0.5,3.0;Current: " ..
					core.formspec_escape(TIER_LABELS[info.tier] .. " " .. type_label) .. "]"
				fs = fs .. "label[0.5,3.5;Upgrade to: " ..
					core.formspec_escape(TIER_LABELS[next_tier] .. " " .. type_label) .. "]"

				-- Show required materials
				if cost then
					local mat_str = ""
					for i, req in ipairs(cost.items) do
						local item_def = core.registered_items[req.name]
						local item_desc = item_def and item_def.description or req.name
						if i > 1 then mat_str = mat_str .. ", " end
						mat_str = mat_str .. req.count .. "x " .. item_desc
					end
					fs = fs .. "label[0.5,4.0;Cost: " ..
						core.formspec_escape(mat_str) .. "]"
				end

				-- Stat comparison
				if upgraded_name then
					local cur_def = core.registered_tools[tool_stack:get_name()]
					local new_def = core.registered_tools[upgraded_name]
					if cur_def and new_def then
						local cur_caps = cur_def.tool_capabilities or {}
						local new_caps = new_def.tool_capabilities or {}
						local cur_uses = 0
						local new_uses = 0
						for _, gc in pairs(cur_caps.groupcaps or {}) do
							cur_uses = math.max(cur_uses, gc.uses or 0)
						end
						for _, gc in pairs(new_caps.groupcaps or {}) do
							new_uses = math.max(new_uses, gc.uses or 0)
						end
						local cur_dmg = (cur_caps.damage_groups or {}).fleshy or 0
						local new_dmg = (new_caps.damage_groups or {}).fleshy or 0
						fs = fs .. "label[5.5,3.0;Durability: " .. cur_uses .. " → " .. new_uses .. "]"
						fs = fs .. "label[5.5,3.5;Damage: " .. cur_dmg .. " → " .. new_dmg .. "]"
					end
				end

				-- Upgrade button
				fs = fs .. "button[9,3.8;2.5,0.8;do_upgrade;Upgrade]"
			else
				fs = fs .. "label[0.5,3.0;This tool is already at maximum tier (Crystal).]"
			end
		else
			fs = fs .. "label[0.5,3.0;This tool cannot be upgraded.]"
		end
	else
		fs = fs .. "label[0.5,3.0;Place a tool in the slot above to see upgrade options.]"
	end

	return fs
end

core.register_node("mbr_upgrades:upgrade_station", {
	description = "Upgrade Station",
	tiles = {"[fill:16x16:#8866aa"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	paramtype2 = "facedir",

	on_construct = function(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("tool", 1)
		inv:set_size("materials", 4)
		meta:set_string("infotext", "Upgrade Station")
	end,

	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not clicker or not clicker:is_player() then
			return itemstack
		end
		local player_name = clicker:get_player_name()
		local fs = get_station_formspec(pos, player_name)
		core.show_formspec(player_name, "mbr_upgrades:station_" ..
			pos.x .. "_" .. pos.y .. "_" .. pos.z, fs)
		return itemstack
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "tool" then
			if core.registered_tools[stack:get_name()] then
				return 1
			end
			return 0
		end
		return stack:get_count()
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return count
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local player_name = player:get_player_name()
		local fs = get_station_formspec(pos, player_name)
		core.show_formspec(player_name, "mbr_upgrades:station_" ..
			pos.x .. "_" .. pos.y .. "_" .. pos.z, fs)
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local player_name = player:get_player_name()
		local fs = get_station_formspec(pos, player_name)
		core.show_formspec(player_name, "mbr_upgrades:station_" ..
			pos.x .. "_" .. pos.y .. "_" .. pos.z, fs)
	end,

	-- Drop contents when broken
	on_destruct = function(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		for _, listname in ipairs({"tool", "materials"}) do
			for i = 1, inv:get_size(listname) do
				local stack = inv:get_stack(listname, i)
				if not stack:is_empty() then
					core.add_item(pos, stack)
				end
			end
		end
	end,
})

-- ============================================================
-- Upgrade Station — Craft Recipe
-- ============================================================

local station_ingot = resolve_item("mbr_mining:iron_ingot", "mbr:iron_ingot")
local station_stone = "mbr_core:stone"

core.register_craft({
	output = "mbr_upgrades:upgrade_station",
	recipe = {
		{"",               station_stone, ""},
		{station_stone,    station_ingot, station_stone},
		{station_ingot,    station_stone, station_ingot},
	},
})

-- ============================================================
-- Upgrade Logic — formspec field handler
-- ============================================================

local function parse_station_pos(formname)
	local x, y, z = formname:match("^mbr_upgrades:station_([%-]?%d+)_([%-]?%d+)_([%-]?%d+)$")
	if x and y and z then
		return {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
	end
	return nil
end

local function check_materials(inv, cost)
	for _, req in ipairs(cost.items) do
		local total = 0
		for i = 1, inv:get_size("materials") do
			local stack = inv:get_stack("materials", i)
			if stack:get_name() == req.name then
				total = total + stack:get_count()
			end
		end
		if total < req.count then
			return false
		end
	end
	return true
end

local function consume_materials(inv, cost)
	for _, req in ipairs(cost.items) do
		local remaining = req.count
		for i = 1, inv:get_size("materials") do
			if remaining <= 0 then break end
			local stack = inv:get_stack("materials", i)
			if stack:get_name() == req.name then
				local take = math.min(remaining, stack:get_count())
				stack:set_count(stack:get_count() - take)
				if stack:get_count() == 0 then
					stack = ItemStack("")
				end
				inv:set_stack("materials", i, stack)
				remaining = remaining - take
			end
		end
	end
end

core.register_on_player_receive_fields(function(player, formname, fields)
	local pos = parse_station_pos(formname)
	if not pos then return end

	if not fields.do_upgrade then
		-- Refresh formspec when tool slot changes
		if fields.quit then return end
		return
	end

	local player_name = player:get_player_name()
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	local tool_stack = inv:get_stack("tool", 1)

	if tool_stack:is_empty() then
		core.chat_send_player(player_name, "Place a tool in the upgrade slot first.")
		return true
	end

	local info = get_tool_info(tool_stack:get_name())
	if not info then
		core.chat_send_player(player_name, "This tool cannot be upgraded.")
		return true
	end

	local next_tier = get_next_tier(info.tier)
	if not next_tier then
		core.chat_send_player(player_name, "This tool is already at maximum tier.")
		return true
	end

	local upgraded_name = get_upgraded_tool_name(info.type, next_tier)
	if not upgraded_name then
		core.chat_send_player(player_name,
			"No upgrade available for this tool type at the next tier.")
		return true
	end

	local cost = get_upgrade_cost(info.tier)
	if not cost then
		core.chat_send_player(player_name, "No upgrade path defined for this tier.")
		return true
	end

	-- Check materials in station inventory
	if not check_materials(inv, cost) then
		core.chat_send_player(player_name,
			"Not enough materials. Place the required items in the material slots.")
		return true
	end

	-- Perform upgrade
	consume_materials(inv, cost)
	local new_stack = ItemStack(upgraded_name)
	inv:set_stack("tool", 1, new_stack)

	-- Particle effect if available
	if mbr and mbr.particles and mbr.particles.spawn then
		mbr.particles.spawn(pos, "sparkle")
	end

	local type_label = TOOL_TYPE_LABELS[info.type] or info.type
	core.chat_send_player(player_name,
		"Upgraded to " .. TIER_LABELS[next_tier] .. " " .. type_label .. "!")
	minetest.log("action", "[MBR Upgrades] " .. player_name ..
		" upgraded " .. info.type .. " to " .. next_tier)

	-- Refresh formspec
	local fs = get_station_formspec(pos, player_name)
	core.show_formspec(player_name, formname, fs)
	return true
end)

-- ============================================================
-- Chat Commands
-- ============================================================

core.register_chatcommand("upgrades", {
	description = "Show list of all upgradeable tools and their tiers",
	func = function(name, param)
		local lines = {"=== Tool Upgrade Tiers ==="}
		for _, tool_type in ipairs({"pickaxe", "axe", "hoe", "watering_can", "fishing_rod", "scythe"}) do
			local label = TOOL_TYPE_LABELS[tool_type] or tool_type
			local tier_names = {}
			for _, tier in ipairs(TIERS) do
				if type_tiers[tool_type] and type_tiers[tool_type][tier] then
					table.insert(tier_names, TIER_LABELS[tier])
				end
			end
			table.insert(lines, label .. ": " .. table.concat(tier_names, " → "))
		end
		table.insert(lines, "")
		table.insert(lines, "Upgrade path: Basic → Copper → Iron → Gold → Crystal")
		return true, table.concat(lines, "\n")
	end,
})

core.register_chatcommand("upgrade_info", {
	description = "Show info about the upgrade station and how to use it",
	func = function(name, param)
		local lines = {
			"=== Upgrade Station ===",
			"Craft an Upgrade Station to improve your tools.",
			"",
			"How to use:",
			"1. Place the Upgrade Station in the world",
			"2. Right-click to open the interface",
			"3. Place your tool in the tool slot (left)",
			"4. Place required materials in the material slots (right)",
			"5. Click 'Upgrade' to improve your tool",
			"",
			"Upgrade costs:",
			"  Basic → Copper: 5x Copper Ingot",
			"  Copper → Iron:  5x Iron Ingot",
			"  Iron → Gold:    5x Gold Ingot",
			"  Gold → Crystal: 3x Crystal Ingot + 2x Gold Ingot",
		}
		return true, table.concat(lines, "\n")
	end,
})

-- ============================================================
-- Register basic tools after all mods are loaded
-- ============================================================

core.register_on_mods_loaded(function()
	register_basic_tools()
	minetest.log("action", "[MBR Upgrades] Tool upgrade system loaded")
end)
