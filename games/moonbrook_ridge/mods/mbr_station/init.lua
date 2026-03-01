-- MoonBrook Ridge Crafting Station
-- Placeable crafting station node with recipe categories and discovery

mbr_station = {}

local mod_storage = core.get_mod_storage()

-- ============================================================
-- Per-player runtime state
-- ============================================================

local player_state = {}

local function get_state(player_name)
	if not player_state[player_name] then
		player_state[player_name] = {
			selected = 1,
			category = "all",
		}
	end
	return player_state[player_name]
end

core.register_on_leaveplayer(function(player)
	player_state[player:get_player_name()] = nil
end)

-- ============================================================
-- Recipe Discovery System
-- ============================================================

local DEFAULT_RECIPES = {
	wooden_sword = true,
	wooden_pickaxe = true,
	stone_sword = true,
}

local MILESTONES = {
	{count =   5, recipes = {"iron_sword", "copper_axe"}},
	{count =  15, recipes = {"iron_pickaxe"}},
	{count =  30, recipes = {"iron_hoe"}},
	{count =  50, recipes = {"crystal_sword"}},
	{count = 100, recipes = {}},
}

local function load_discovered(player_name)
	local raw = mod_storage:get_string("discovered_" .. player_name)
	if raw and raw ~= "" then
		return core.deserialize(raw) or {}
	end
	return {}
end

local function save_discovered(player_name, discovered)
	mod_storage:set_string("discovered_" .. player_name,
		core.serialize(discovered))
end

local function load_craft_count(player_name)
	return mod_storage:get_int("craft_count_" .. player_name)
end

local function save_craft_count(player_name, count)
	mod_storage:set_int("craft_count_" .. player_name, count)
end

--- Discover a recipe for a player.
-- @param player_name  player name string
-- @param recipe_id    recipe identifier
-- @return true if newly discovered, false if already known
function mbr_station.discover_recipe(player_name, recipe_id)
	local discovered = load_discovered(player_name)
	if discovered[recipe_id] then
		return false
	end
	discovered[recipe_id] = true
	save_discovered(player_name, discovered)
	minetest.log("action", "[MBR Station] " .. player_name ..
		" discovered recipe: " .. recipe_id)
	return true
end

--- Check if a player has discovered a recipe.
function mbr_station.has_discovered(player_name, recipe_id)
	if DEFAULT_RECIPES[recipe_id] then
		return true
	end
	local discovered = load_discovered(player_name)
	return discovered[recipe_id] == true
end

--- Get the set of all discovered recipes for a player.
-- @return table of recipe_id → true
function mbr_station.get_discovered(player_name)
	local discovered = load_discovered(player_name)
	for rid in pairs(DEFAULT_RECIPES) do
		discovered[rid] = true
	end
	return discovered
end

-- Ensure default recipes are persisted on first join
core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local discovered = load_discovered(name)
	local changed = false
	for rid in pairs(DEFAULT_RECIPES) do
		if not discovered[rid] then
			discovered[rid] = true
			changed = true
		end
	end
	if changed then
		save_discovered(name, discovered)
	end
end)

-- ============================================================
-- Craft Counter & Milestones
-- ============================================================

local function check_milestones(player_name, count)
	for _, ms in ipairs(MILESTONES) do
		if count >= ms.count then
			for _, rid in ipairs(ms.recipes) do
				if mbr_station.discover_recipe(player_name, rid) then
					core.chat_send_player(player_name,
						core.colorize("#FFD700",
							"[Milestone] " .. count ..
							" crafts reached! Unlocked recipe: " .. rid))
				end
			end
		end
	end
end

local function increment_craft_count(player_name)
	local count = load_craft_count(player_name) + 1
	save_craft_count(player_name, count)
	check_milestones(player_name, count)
	return count
end

-- ============================================================
-- NPC friendship integration (optional)
-- ============================================================

local NPC_UNLOCK_RECIPES = {
	blacksmith  = {"iron_sword", "iron_pickaxe"},
	farmer      = {"iron_hoe"},
	jeweler     = {"crystal_sword"},
}

local function check_npc_unlocks(player_name)
	if not (mbr and mbr.npcs) then
		return
	end
	for npc_id, recipes in pairs(NPC_UNLOCK_RECIPES) do
		local hearts = mbr.npcs.get_hearts and
			mbr.npcs.get_hearts(player_name, npc_id) or 0
		if hearts >= 3 then
			for _, rid in ipairs(recipes) do
				if mbr_station.discover_recipe(player_name, rid) then
					core.chat_send_player(player_name,
						core.colorize("#FF69B4",
							"[Friendship] " .. npc_id ..
							" shared a recipe with you: " .. rid))
				end
			end
		end
	end
end

-- ============================================================
-- Category Tabs Enhancement
-- ============================================================

local CATEGORIES = {"all", "weapons", "tools", "food", "materials"}
local CATEGORY_LABELS = {
	all       = "All",
	weapons   = "Weapons",
	tools     = "Tools",
	food      = "Food",
	materials = "Materials",
}

local function get_filtered_recipes(player_name, category)
	if not (mbr and mbr.crafting) then
		return {}, {}
	end
	local all_ids = mbr.crafting.get_recipe_list()
	local discovered = mbr_station.get_discovered(player_name)
	local filtered_ids = {}
	local filtered_names = {}
	for _, rid in ipairs(all_ids) do
		if discovered[rid] then
			local r = mbr.crafting.get_recipe(rid)
			if r then
				local match = (category == "all") or
					(r.category and r.category == category)
				if match then
					filtered_ids[#filtered_ids + 1] = rid
					filtered_names[#filtered_names + 1] = r.description or rid
				end
			end
		end
	end
	return filtered_ids, filtered_names
end

-- ============================================================
-- Formspec Builder (wraps / enhances the crafting station UI)
-- ============================================================

local function build_station_formspec(player_name)
	local state = get_state(player_name)
	local selected_idx = state.selected or 1
	local category = state.category or "all"

	local filtered_ids, filtered_names = get_filtered_recipes(player_name, category)

	-- Clamp selection
	if selected_idx > #filtered_ids then
		selected_idx = math.max(1, #filtered_ids)
		state.selected = selected_idx
	end

	local craft_count = load_craft_count(player_name)
	local discovered = mbr_station.get_discovered(player_name)
	local total_recipes = 0
	if mbr and mbr.crafting then
		total_recipes = #mbr.crafting.get_recipe_list()
	end
	local discovered_count = 0
	for _ in pairs(discovered) do
		discovered_count = discovered_count + 1
	end

	-- Next milestone
	local next_milestone = nil
	for _, ms in ipairs(MILESTONES) do
		if craft_count < ms.count then
			next_milestone = ms.count
			break
		end
	end

	local fs = {
		"formspec_version[7]",
		"size[14,10]",
		"label[0.3,0.5;Crafting Station]",
	}

	-- Category tabs
	local tab_x = 0.3
	for _, cat in ipairs(CATEGORIES) do
		local label = CATEGORY_LABELS[cat]
		if cat == category then
			label = "> " .. label .. " <"
		end
		fs[#fs + 1] = string.format(
			"button[%.1f,0.8;2,0.6;cat_%s;%s]", tab_x, cat, label)
		tab_x = tab_x + 2.1
	end

	-- Recipe list
	if #filtered_names > 0 then
		fs[#fs + 1] = "textlist[0.3,1.7;4.5,6.5;recipe_list;" ..
			table.concat(filtered_names, ",") ..
			";" .. selected_idx .. ";false]"
	else
		fs[#fs + 1] = "label[0.3,3;No discovered recipes in this category.]"
	end

	-- Recipe details on the right
	if filtered_ids[selected_idx] and mbr and mbr.crafting then
		local rid = filtered_ids[selected_idx]
		local r = mbr.crafting.get_recipe(rid)
		if r then
			local y = 1.9
			fs[#fs + 1] = string.format(
				"label[5.5,%.1f;%s]", y, r.description or rid)
			y = y + 0.6

			if r.category then
				fs[#fs + 1] = string.format(
					"label[5.5,%.1f;Category: %s]", y,
					CATEGORY_LABELS[r.category] or r.category)
				y = y + 0.5
			end

			fs[#fs + 1] = string.format(
				"label[5.5,%.1f;Ingredients:]", y)
			y = y + 0.5
			for _, ing in ipairs(r.ingredients) do
				fs[#fs + 1] = string.format(
					"label[5.8,%.1f;%dx %s]", y, ing[2] or 1, ing[1])
				y = y + 0.4
			end

			y = y + 0.3
			if r.base_stats then
				fs[#fs + 1] = string.format(
					"label[5.5,%.1f;Base Stats:]", y)
				y = y + 0.5
				for stat, val in pairs(r.base_stats) do
					local label = stat:gsub("_", " ")
					label = label:sub(1, 1):upper() .. label:sub(2)
					fs[#fs + 1] = string.format(
						"label[5.8,%.1f;%s: %d]", y, label, val)
					y = y + 0.4
				end
			end

			y = y + 0.3
			fs[#fs + 1] = string.format(
				"label[5.5,%.1f;Quality scales with input materials!]", y)

			fs[#fs + 1] = "button[5.5,8;3,0.8;craft;Craft]"
		end
	end

	-- Progress bar area
	fs[#fs + 1] = string.format(
		"label[0.3,8.7;Crafts: %d | Recipes: %d/%d]",
		craft_count, discovered_count, total_recipes)
	if next_milestone then
		fs[#fs + 1] = string.format(
			"label[0.3,9.2;Next milestone: %d crafts]", next_milestone)
	else
		fs[#fs + 1] = "label[0.3,9.2;All milestones reached!]"
	end

	return table.concat(fs, ""), filtered_ids
end

-- Store filtered IDs per player for formspec field handling
local player_filtered_ids = {}

-- ============================================================
-- Show Station (override / wrap)
-- ============================================================

local function show_station(player)
	local name = player:get_player_name()
	check_npc_unlocks(name)
	local fs, fids = build_station_formspec(name)
	player_filtered_ids[name] = fids
	core.show_formspec(name, "mbr_station:crafting_station", fs)
end

-- Override mbr.crafting.show_station if available
if mbr and mbr.crafting then
	local orig_show_station = mbr.crafting.show_station
	mbr.crafting.show_station = function(player)
		show_station(player)
	end
end

-- ============================================================
-- Formspec field handler
-- ============================================================

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "mbr_station:crafting_station" then
		return false
	end
	local name = player:get_player_name()
	local state = get_state(name)

	-- Category buttons
	for _, cat in ipairs(CATEGORIES) do
		if fields["cat_" .. cat] then
			state.category = cat
			state.selected = 1
			show_station(player)
			return true
		end
	end

	-- Recipe list selection
	if fields.recipe_list then
		local evt = core.explode_textlist_event(fields.recipe_list)
		if evt.type == "CHG" or evt.type == "DCL" then
			state.selected = evt.index
			show_station(player)
		end
		return true
	end

	-- Craft button
	if fields.craft then
		local fids = player_filtered_ids[name] or {}
		local rid = fids[state.selected]
		if rid and mbr and mbr.crafting then
			local ok, msg = mbr.crafting.craft(player, rid)
			if ok then
				increment_craft_count(name)
			end
			core.chat_send_player(name,
				ok and core.colorize("#88FF88", msg)
				   or core.colorize("#FF8888", msg))
			show_station(player)
		end
		return true
	end

	return true
end)

-- ============================================================
-- Crafting Station Node
-- ============================================================

core.register_node("mbr_station:crafting_station", {
	description = "Crafting Station",
	tiles = {"[fill:16x16:#aa8855"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	is_ground_content = false,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not clicker or not clicker:is_player() then
			return itemstack
		end
		if mbr and mbr.crafting then
			show_station(clicker)
		else
			core.chat_send_player(clicker:get_player_name(),
				core.colorize("#FF8888",
					"Crafting system is not available."))
		end
		return itemstack
	end,
})

core.register_craft({
	output = "mbr_station:crafting_station",
	recipe = {
		{"mbr_core:wood", "mbr_core:stone", "mbr_core:wood"},
		{"mbr_core:wood", "",               "mbr_core:wood"},
		{"mbr_core:stone","",               "mbr_core:stone"},
	},
})

-- ============================================================
-- Recipe Scroll Item
-- ============================================================

core.register_craftitem("mbr_station:recipe_scroll", {
	description = "Recipe Scroll (use to learn a recipe)",
	inventory_image = "[fill:16x16:#eecc88",
	on_use = function(itemstack, user, pointed_thing)
		if not user or not user:is_player() then
			return itemstack
		end
		local name = user:get_player_name()
		if not (mbr and mbr.crafting) then
			core.chat_send_player(name,
				core.colorize("#FF8888",
					"Crafting system is not available."))
			return itemstack
		end

		local all_ids = mbr.crafting.get_recipe_list()
		local discovered = mbr_station.get_discovered(name)
		local undiscovered = {}
		for _, rid in ipairs(all_ids) do
			if not discovered[rid] then
				undiscovered[#undiscovered + 1] = rid
			end
		end

		if #undiscovered == 0 then
			core.chat_send_player(name,
				core.colorize("#FFFF00",
					"You have already discovered all recipes!"))
			return itemstack
		end

		local chosen = undiscovered[math.random(#undiscovered)]
		mbr_station.discover_recipe(name, chosen)

		local r = mbr.crafting.get_recipe(chosen)
		local desc = r and r.description or chosen
		core.chat_send_player(name,
			core.colorize("#88FF88",
				"You learned a new recipe: " .. desc .. "!"))

		itemstack:take_item()
		return itemstack
	end,
})

-- ============================================================
-- Chat Commands
-- ============================================================

core.register_chatcommand("recipes", {
	description = "Show discovered vs total recipes",
	func = function(name)
		local player = core.get_player_by_name(name)
		if not player then
			return false, "Player not found."
		end
		if not (mbr and mbr.crafting) then
			return false, "Crafting system is not available."
		end

		local discovered = mbr_station.get_discovered(name)
		local total = #mbr.crafting.get_recipe_list()
		local count = 0
		local names = {}
		for rid in pairs(discovered) do
			count = count + 1
			local r = mbr.crafting.get_recipe(rid)
			names[#names + 1] = r and r.description or rid
		end
		table.sort(names)

		local craft_count = load_craft_count(name)
		local msg = string.format(
			"Recipes discovered: %d/%d | Total crafts: %d\n%s",
			count, total, craft_count, table.concat(names, ", "))
		return true, msg
	end,
})

core.register_chatcommand("station", {
	description = "Show info about the crafting station",
	func = function(name)
		local lines = {
			"Crafting Station — place it in the world and right-click to open.",
			"Craft recipe: 4x Wood + 2x Stone (shaped).",
			"Use Recipe Scrolls to unlock new recipes.",
			"Reach crafting milestones (5, 15, 30, 50, 100) for bonus unlocks.",
		}
		if mbr and mbr.npcs then
			lines[#lines + 1] = "Befriend NPCs (heart level 3+) for special recipes."
		end
		return true, table.concat(lines, "\n")
	end,
})

-- ============================================================
-- Cleanup filtered IDs on leave
-- ============================================================

core.register_on_leaveplayer(function(player)
	player_filtered_ids[player:get_player_name()] = nil
end)

minetest.log("action", "[MBR Station] Loaded")
