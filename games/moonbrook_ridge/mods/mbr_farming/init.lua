-- mbr_farming: Crop farming system with seasonal variations for MoonBrook Ridge

-- =============================================================================
-- Namespace
-- =============================================================================

mbr.farming = {crops = {}}

-- =============================================================================
-- Season Lookup
-- =============================================================================

local season_names_set = {
	Spring = true,
	Summer = true,
	Fall = true,
	Winter = true,
}

local function current_season_allowed(seasons)
	local season_name = mbr.time.get_season_name()
	for _, s in ipairs(seasons) do
		if s == season_name then
			return true
		end
	end
	return false
end

-- =============================================================================
-- Dead Crop Node
-- =============================================================================

core.register_node("mbr_farming:dead_crop", {
	description = "Dead Crop",
	drawtype = "plantlike",
	tiles = {"mbr_farming_dead_crop.png"},
	inventory_image = "mbr_farming_dead_crop.png",
	wield_image = "mbr_farming_dead_crop.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 0.2, 4 / 16},
	},
	groups = {snappy = 3, attached_node = 1},
	drop = "",
	sounds = {},
})

-- =============================================================================
-- Crop Registration Function
-- =============================================================================

function mbr.farming.register_crop(name, def)
	local growth_stages = def.growth_stages or 4
	local grow_time = def.grow_time or 120
	local seasons = def.seasons or {"Spring", "Summer", "Fall"}
	local harvest_item = def.harvest_item
	local seed_item = def.seed_item or ("mbr_farming:seed_" .. name)
	local base_texture = def.base_texture or ("mbr_farming_" .. name)

	-- Store crop data for ABM reference
	mbr.farming.crops[name] = {
		growth_stages = growth_stages,
		grow_time = grow_time,
		seasons = seasons,
		harvest_item = harvest_item,
		seed_item = seed_item,
	}

	-- Register seed craftitem
	core.register_craftitem(seed_item, {
		description = def.seed_description or (name:gsub("^%l", string.upper) .. " Seeds"),
		inventory_image = base_texture .. "_seed.png",
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then return end
			local pos = pointed_thing.above
			local under_pos = pointed_thing.under
			local under_node = core.get_node(under_pos)

			-- Must plant on farmland
			local under_def = core.registered_nodes[under_node.name]
			if not under_def or not under_def.groups or not under_def.groups.farmland then
				return
			end

			-- Check that the space above is free
			local above_node = core.get_node(pos)
			if above_node.name ~= "air" then return end

			-- Check season
			if not current_season_allowed(seasons) then
				if placer then
					mbr.notify_player(placer, "This crop cannot be planted in " .. mbr.time.get_season_name() .. "!")
				end
				return
			end

			core.set_node(pos, {name = "mbr_farming:" .. name .. "_1"})
			itemstack:take_item()
			return itemstack
		end,
	})

	-- Register growth stage nodes
	for stage = 1, growth_stages do
		local is_mature = (stage == growth_stages)
		local visual_scale = 0.5 + (stage - 1) * (0.5 / (growth_stages - 1))

		local node_groups = {
			snappy = 3,
			attached_node = 1,
			not_in_creative_inventory = 1,
			crop = 1,
			crop_stage = stage,
		}
		if is_mature then
			node_groups.crop_mature = 1
		end

		local node_def = {
			description = def.description or (name:gsub("^%l", string.upper) .. " (Stage " .. stage .. ")"),
			drawtype = "plantlike",
			tiles = {base_texture .. "_" .. stage .. ".png"},
			inventory_image = base_texture .. "_" .. stage .. ".png",
			wield_image = base_texture .. "_" .. stage .. ".png",
			paramtype = "light",
			sunlight_propagates = true,
			walkable = false,
			selection_box = {
				type = "fixed",
				fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, -0.5 + visual_scale, 4 / 16},
			},
			groups = node_groups,
			drop = "",
			sounds = {},
			_mbr_crop_name = name,
			_mbr_crop_stage = stage,
		}

		if is_mature then
			-- Mature crop: drops harvest + chance for seed on punch
			node_def.drop = {
				max_items = 2,
				items = {
					{items = {harvest_item}, rarity = 1},
					{items = {seed_item}, rarity = 2},
				},
			}
			node_def.on_punch = function(pos, node, puncher)
				local drops = core.get_node_drops(node.name, "")
				core.remove_node(pos)
				for _, drop in ipairs(drops) do
					core.add_item(pos, drop)
				end
				mbr.particles.spawn(pos, "sparkle")
			end
		end

		core.register_node("mbr_farming:" .. name .. "_" .. stage, node_def)
	end
end

-- =============================================================================
-- ABM: Crop Growth
-- =============================================================================

core.register_abm({
	label = "Crop growth",
	nodenames = {"group:crop"},
	interval = 30,
	chance = 3,
	action = function(pos, node)
		local node_def = core.registered_nodes[node.name]
		if not node_def then return end

		local crop_name = node_def._mbr_crop_name
		local crop_stage = node_def._mbr_crop_stage
		if not crop_name or not crop_stage then return end

		local crop_data = mbr.farming.crops[crop_name]
		if not crop_data then return end

		-- Check season
		if not current_season_allowed(crop_data.seasons) then
			-- Wrong season: crop wilts
			core.set_node(pos, {name = "mbr_farming:dead_crop"})
			return
		end

		-- Check if on wet farmland
		local below = {x = pos.x, y = pos.y - 1, z = pos.z}
		local below_node = core.get_node(below)
		if below_node.name ~= "mbr_tools:farmland_wet" then
			return
		end

		-- Already mature?
		if crop_stage >= crop_data.growth_stages then
			return
		end

		-- Advance to next stage
		local next_stage = crop_stage + 1
		core.set_node(pos, {name = "mbr_farming:" .. crop_name .. "_" .. next_stage})
	end,
})

-- =============================================================================
-- ABM: Farmland Drying
-- =============================================================================

core.register_abm({
	label = "Farmland drying",
	nodenames = {"mbr_tools:farmland_wet"},
	interval = 60,
	chance = 4,
	action = function(pos, node)
		-- If it is raining, keep farmland wet
		if mbr.weather and mbr.weather.current then
			local weather_name = mbr.weather.current
			if weather_name == "rainy" or weather_name == "stormy" then
				return
			end
		end

		core.set_node(pos, {name = "mbr_tools:farmland"})
	end,
})

-- =============================================================================
-- ABM: Rain Waters Farmland
-- =============================================================================

core.register_abm({
	label = "Rain waters farmland",
	nodenames = {"mbr_tools:farmland"},
	interval = 30,
	chance = 2,
	action = function(pos, node)
		if not mbr.weather or not mbr.weather.current then return end
		local weather_name = mbr.weather.current
		if weather_name ~= "rainy" and weather_name ~= "stormy" then
			return
		end

		-- Check that there is sky access above
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local above_node = core.get_node(above)
		if above_node.name ~= "air" then return end

		core.set_node(pos, {name = "mbr_tools:farmland_wet"})
		local meta = core.get_meta(pos)
		meta:set_string("watered", "true")
	end,
})

-- =============================================================================
-- Register Crops
-- =============================================================================

mbr.farming.register_crop("wheat", {
	description = "Wheat",
	growth_stages = 5,
	grow_time = 120,
	seasons = {"Spring", "Summer", "Fall"},
	harvest_item = "mbr_farming:wheat_bundle",
})

mbr.farming.register_crop("corn", {
	description = "Corn",
	growth_stages = 4,
	grow_time = 150,
	seasons = {"Summer"},
	harvest_item = "mbr_farming:corn",
})

mbr.farming.register_crop("tomato", {
	description = "Tomato",
	growth_stages = 4,
	grow_time = 130,
	seasons = {"Spring", "Summer"},
	harvest_item = "mbr_farming:tomato",
})

mbr.farming.register_crop("potato", {
	description = "Potato",
	growth_stages = 4,
	grow_time = 140,
	seasons = {"Spring", "Fall"},
	harvest_item = "mbr_farming:potato",
})

mbr.farming.register_crop("carrot", {
	description = "Carrot",
	growth_stages = 3,
	grow_time = 100,
	seasons = {"Spring", "Summer", "Fall"},
	harvest_item = "mbr_farming:carrot",
})

mbr.farming.register_crop("pumpkin", {
	description = "Pumpkin",
	growth_stages = 4,
	grow_time = 160,
	seasons = {"Fall"},
	harvest_item = "mbr_farming:pumpkin",
})

mbr.farming.register_crop("strawberry", {
	description = "Strawberry",
	growth_stages = 3,
	grow_time = 100,
	seasons = {"Spring", "Summer"},
	harvest_item = "mbr_farming:strawberry",
})

mbr.farming.register_crop("rice", {
	description = "Rice",
	growth_stages = 5,
	grow_time = 140,
	seasons = {"Summer", "Fall"},
	harvest_item = "mbr_farming:rice",
})

-- =============================================================================
-- Harvest Craftitems
-- =============================================================================

core.register_craftitem("mbr_farming:wheat_bundle", {
	description = "Wheat Bundle",
	inventory_image = "mbr_farming_wheat_bundle.png",
})

core.register_craftitem("mbr_farming:corn", {
	description = "Corn",
	inventory_image = "mbr_farming_corn.png",
})

core.register_craftitem("mbr_farming:tomato", {
	description = "Tomato",
	inventory_image = "mbr_farming_tomato.png",
})

core.register_craftitem("mbr_farming:potato", {
	description = "Potato",
	inventory_image = "mbr_farming_potato.png",
})

core.register_craftitem("mbr_farming:carrot", {
	description = "Carrot",
	inventory_image = "mbr_farming_carrot.png",
})

core.register_craftitem("mbr_farming:pumpkin", {
	description = "Pumpkin",
	inventory_image = "mbr_farming_pumpkin.png",
})

core.register_craftitem("mbr_farming:strawberry", {
	description = "Strawberry",
	inventory_image = "mbr_farming_strawberry.png",
})

core.register_craftitem("mbr_farming:rice", {
	description = "Rice",
	inventory_image = "mbr_farming_rice.png",
})

core.log("action", "[mbr_farming] Loaded.")
