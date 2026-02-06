-- mbr_tools: Upgradeable tool system for MoonBrook Ridge

-- =============================================================================
-- Namespace
-- =============================================================================

mbr.tools = {}

-- =============================================================================
-- Tier Definitions
-- =============================================================================

local tiers = {
	{name = "basic",   desc = "Basic",   uses_mult = 1.0, speed_mult = 1.0},
	{name = "copper",  desc = "Copper",  uses_mult = 1.3, speed_mult = 1.1},
	{name = "iron",    desc = "Iron",    uses_mult = 1.6, speed_mult = 1.3},
	{name = "gold",    desc = "Gold",    uses_mult = 2.0, speed_mult = 1.5},
	{name = "diamond", desc = "Diamond", uses_mult = 3.0, speed_mult = 2.0},
}

local tier_index = {}
for i, tier in ipairs(tiers) do
	tier_index[tier.name] = i
end

-- Base values for tool capabilities
local base_uses = 50
local base_axe_times   = {[1] = 2.5, [2] = 1.5, [3] = 1.0}
local base_pick_times  = {[1] = 2.8, [2] = 1.8, [3] = 1.2}
local base_scythe_times = {[1] = 1.5, [2] = 1.0, [3] = 0.5}

-- =============================================================================
-- Farmland Nodes
-- =============================================================================

core.register_node("mbr_tools:farmland", {
	description = "Farmland",
	tiles = {"mbr_core_dirt.png^mbr_tools_farmland_overlay.png", "mbr_core_dirt.png"},
	groups = {crumbly = 3, soil = 1, farmland = 1},
	drop = "mbr_core:dirt",
	sounds = {},
	soil = {
		base = "mbr_core:dirt",
		dry = "mbr_tools:farmland",
		wet = "mbr_tools:farmland_wet",
	},
})

core.register_node("mbr_tools:farmland_wet", {
	description = "Wet Farmland",
	tiles = {"mbr_core_dirt.png^mbr_tools_farmland_wet_overlay.png", "mbr_core_dirt.png"},
	groups = {crumbly = 3, soil = 1, farmland = 1, wet_farmland = 1},
	drop = "mbr_core:dirt",
	sounds = {},
	soil = {
		base = "mbr_core:dirt",
		dry = "mbr_tools:farmland",
		wet = "mbr_tools:farmland_wet",
	},
})

-- =============================================================================
-- Tool on_use Callbacks
-- =============================================================================

local function hoe_on_use(itemstack, user, pointed_thing)
	if pointed_thing.type ~= "node" then return end
	local pos = pointed_thing.under
	local node = core.get_node(pos)

	if node.name == "mbr_core:dirt" or node.name == "mbr_core:grass" then
		core.set_node(pos, {name = "mbr_tools:farmland"})
		mbr.particles.spawn(pos, "dirt")
		itemstack:add_wear(65535 / (itemstack:get_tool_capabilities().groupcaps.crumbly.uses or base_uses))
		return itemstack
	end
end

local function watering_can_on_use(itemstack, user, pointed_thing)
	if pointed_thing.type ~= "node" then return end
	local pos = pointed_thing.under
	local node = core.get_node(pos)

	if node.name == "mbr_tools:farmland" then
		core.set_node(pos, {name = "mbr_tools:farmland_wet"})
		local meta = core.get_meta(pos)
		meta:set_string("watered", "true")
		mbr.particles.spawn(pos, "water")
		itemstack:add_wear(65535 / (itemstack:get_tool_capabilities().groupcaps.crumbly.uses or base_uses))
		return itemstack
	elseif node.name == "mbr_tools:farmland_wet" then
		-- Already wet, just show particles
		mbr.particles.spawn(pos, "water")
	end
end

-- Fishing state per player
local fishing_active = {}

local function fishing_rod_on_use(itemstack, user, pointed_thing)
	if not user then return end
	local player_name = user:get_player_name()

	-- If already fishing, ignore
	if fishing_active[player_name] then return end

	if pointed_thing.type ~= "node" then return end
	local pos = pointed_thing.under
	local node = core.get_node(pos)
	local node_def = core.registered_nodes[node.name]

	if not node_def or not node_def.groups or not node_def.groups.water then
		return
	end

	-- Start fishing
	fishing_active[player_name] = true
	mbr.particles.spawn(pos, "splash")
	mbr.notify_player(user, "Fishing...")

	local wait_time = math.random(3, 8)
	core.after(wait_time, function()
		fishing_active[player_name] = nil
		local player = core.get_player_by_name(player_name)
		if not player then return end

		local inv = player:get_inventory()
		local fish = ItemStack("mbr_tools:fish")
		if inv:room_for_item("main", fish) then
			inv:add_item("main", fish)
			mbr.notify_player(player, "You caught a fish!")
			mbr.particles.spawn(pos, "splash")
		else
			mbr.notify_player(player, "Inventory full!")
		end
	end)

	itemstack:add_wear(65535 / (itemstack:get_tool_capabilities().groupcaps.crumbly.uses or base_uses))
	return itemstack
end

local function scythe_on_use(itemstack, user, pointed_thing)
	if pointed_thing.type ~= "node" then return end
	local pos = pointed_thing.under
	local node = core.get_node(pos)
	local node_def = core.registered_nodes[node.name]

	if not node_def or not node_def.groups or not node_def.groups.crop_mature then
		return
	end

	-- Harvest the mature crop by simulating a punch
	local drops = core.get_node_drops(node.name, "")
	core.remove_node(pos)
	for _, drop in ipairs(drops) do
		core.add_item(pos, drop)
	end
	mbr.particles.spawn(pos, "sparkle")
	itemstack:add_wear(65535 / (itemstack:get_tool_capabilities().groupcaps.snappy.uses or base_uses))
	return itemstack
end

-- =============================================================================
-- Fish Craftitem
-- =============================================================================

core.register_craftitem("mbr_tools:fish", {
	description = "Fish",
	inventory_image = "mbr_tools_fish.png",
})

-- =============================================================================
-- Tool Registration
-- =============================================================================

for _, tier in ipairs(tiers) do
	local tier_uses = math.floor(base_uses * tier.uses_mult)

	-- Helper to scale time tables
	local function scale_times(base_times, speed_mult)
		local t = {}
		for level, time in pairs(base_times) do
			t[level] = time / speed_mult
		end
		return t
	end

	-- Hoe
	core.register_tool("mbr_tools:hoe_" .. tier.name, {
		description = tier.desc .. " Hoe",
		inventory_image = "mbr_tools_hoe_" .. tier.name .. ".png",
		on_use = hoe_on_use,
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level = tier_index[tier.name],
			groupcaps = {
				crumbly = {
					maxlevel = tier_index[tier.name],
					uses = tier_uses,
					times = scale_times({[1] = 2.0, [2] = 1.2, [3] = 0.8}, tier.speed_mult),
				},
			},
		},
	})

	-- Watering Can
	core.register_tool("mbr_tools:watering_can_" .. tier.name, {
		description = tier.desc .. " Watering Can",
		inventory_image = "mbr_tools_watering_can_" .. tier.name .. ".png",
		on_use = watering_can_on_use,
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level = tier_index[tier.name],
			groupcaps = {
				crumbly = {
					maxlevel = tier_index[tier.name],
					uses = tier_uses,
					times = {[1] = 1.0, [2] = 1.0, [3] = 1.0},
				},
			},
		},
	})

	-- Axe
	core.register_tool("mbr_tools:axe_" .. tier.name, {
		description = tier.desc .. " Axe",
		inventory_image = "mbr_tools_axe_" .. tier.name .. ".png",
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level = tier_index[tier.name],
			groupcaps = {
				choppy = {
					maxlevel = tier_index[tier.name],
					uses = tier_uses,
					times = scale_times(base_axe_times, tier.speed_mult),
				},
			},
			damage_groups = {fleshy = 2 + tier_index[tier.name]},
		},
		after_use = function(itemstack, user, node, digparams)
			mbr.particles.spawn(node, "wood")
			itemstack:add_wear(digparams.wear)
			return itemstack
		end,
	})

	-- Pickaxe
	core.register_tool("mbr_tools:pickaxe_" .. tier.name, {
		description = tier.desc .. " Pickaxe",
		inventory_image = "mbr_tools_pickaxe_" .. tier.name .. ".png",
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level = tier_index[tier.name],
			groupcaps = {
				cracky = {
					maxlevel = tier_index[tier.name],
					uses = tier_uses,
					times = scale_times(base_pick_times, tier.speed_mult),
				},
			},
			damage_groups = {fleshy = 2 + tier_index[tier.name]},
		},
		after_use = function(itemstack, user, node, digparams)
			mbr.particles.spawn(node, "rock")
			itemstack:add_wear(digparams.wear)
			return itemstack
		end,
	})

	-- Fishing Rod
	core.register_tool("mbr_tools:fishing_rod_" .. tier.name, {
		description = tier.desc .. " Fishing Rod",
		inventory_image = "mbr_tools_fishing_rod_" .. tier.name .. ".png",
		on_use = fishing_rod_on_use,
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level = tier_index[tier.name],
			groupcaps = {
				crumbly = {
					maxlevel = tier_index[tier.name],
					uses = tier_uses,
					times = {[1] = 1.0, [2] = 1.0, [3] = 1.0},
				},
			},
		},
	})

	-- Scythe
	core.register_tool("mbr_tools:scythe_" .. tier.name, {
		description = tier.desc .. " Scythe",
		inventory_image = "mbr_tools_scythe_" .. tier.name .. ".png",
		on_use = scythe_on_use,
		tool_capabilities = {
			full_punch_interval = 0.8,
			max_drop_level = tier_index[tier.name],
			groupcaps = {
				snappy = {
					maxlevel = tier_index[tier.name],
					uses = tier_uses,
					times = scale_times(base_scythe_times, tier.speed_mult),
				},
			},
		},
	})
end

-- =============================================================================
-- Tool Upgrade Function
-- =============================================================================

function mbr.tools.upgrade(player, tool_name, tier)
	if not tier_index[tier] then
		core.log("warning", "[mbr_tools] Unknown tier: " .. tostring(tier))
		return false
	end

	local inv = player:get_inventory()
	local new_tool = ItemStack("mbr_tools:" .. tool_name .. "_" .. tier)

	if not core.registered_tools[new_tool:get_name()] then
		core.log("warning", "[mbr_tools] Unknown tool: " .. new_tool:get_name())
		return false
	end

	-- Find and replace the old tool in inventory
	local list = inv:get_list("main")
	for i, stack in ipairs(list) do
		local sname = stack:get_name()
		-- Match any tier of this tool type
		if sname:find("^mbr_tools:" .. tool_name .. "_") then
			inv:set_stack("main", i, new_tool)
			mbr.notify_player(player, "Tool upgraded to " .. tier .. "!")
			return true
		end
	end

	-- Tool not found in inventory, try to add it
	if inv:room_for_item("main", new_tool) then
		inv:add_item("main", new_tool)
		return true
	end

	return false
end

-- =============================================================================
-- Give Starter Tools on First Join
-- =============================================================================

core.register_on_newplayer(function(player)
	local inv = player:get_inventory()
	local starter_tools = {
		"mbr_tools:hoe_basic",
		"mbr_tools:watering_can_basic",
		"mbr_tools:axe_basic",
		"mbr_tools:pickaxe_basic",
		"mbr_tools:fishing_rod_basic",
		"mbr_tools:scythe_basic",
	}
	for _, tool in ipairs(starter_tools) do
		inv:add_item("main", ItemStack(tool))
	end
end)

-- =============================================================================
-- Cleanup
-- =============================================================================

core.register_on_leaveplayer(function(player)
	fishing_active[player:get_player_name()] = nil
end)

core.log("action", "[mbr_tools] Loaded.")
