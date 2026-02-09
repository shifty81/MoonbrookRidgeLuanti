-- MoonBrook Ridge Mapgen
-- World generation configuration

-- Set up basic world generation
core.register_on_mapgen_init(function(mgparams)
	minetest.log("action", "[MBR Mapgen] Initializing world generation")
	minetest.log("action", "[MBR Mapgen] Mapgen: " .. mgparams.mgname)
end)

-- Register biomes for v7 mapgen
core.register_biome({
	name = "grassland",
	node_top = "mbr_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mbr_core:dirt",
	depth_filler = 3,
	node_stone = "mbr_core:stone",
	node_water_top = "mbr_core:water_source",
	node_water = "mbr_core:water_source",
	node_river_water = "mbr_core:water_source",
	y_max = 31000,
	y_min = 4,
	heat_point = 50,
	humidity_point = 50,
})

-- Register a simple tree decoration
core.register_decoration({
	deco_type = "schematic",
	place_on = {"mbr_core:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.01,
	biomes = {"grassland"},
	y_max = 31000,
	y_min = 1,
	schematic = {
		size = {x = 3, y = 4, z = 3},
		data = {
			-- Layer 1 (y=0)
			{name = "air"}, {name = "air"}, {name = "air"},
			{name = "air"}, {name = "mbr_core:tree"}, {name = "air"},
			{name = "air"}, {name = "air"}, {name = "air"},
			-- Layer 2 (y=1)
			{name = "air"}, {name = "air"}, {name = "air"},
			{name = "air"}, {name = "mbr_core:tree"}, {name = "air"},
			{name = "air"}, {name = "air"}, {name = "air"},
			-- Layer 3 (y=2)
			{name = "mbr_core:leaves"}, {name = "mbr_core:leaves"}, {name = "mbr_core:leaves"},
			{name = "mbr_core:leaves"}, {name = "mbr_core:tree"}, {name = "mbr_core:leaves"},
			{name = "mbr_core:leaves"}, {name = "mbr_core:leaves"}, {name = "mbr_core:leaves"},
			-- Layer 4 (y=3)
			{name = "air"}, {name = "mbr_core:leaves"}, {name = "air"},
			{name = "mbr_core:leaves"}, {name = "mbr_core:leaves"}, {name = "mbr_core:leaves"},
			{name = "air"}, {name = "mbr_core:leaves"}, {name = "air"},
		},
	},
	flags = "place_center_x, place_center_z",
})

-- Set spawn point
core.register_on_newplayer(function(player)
	-- Spawn player at a reasonable height
	player:set_pos({x = 0, y = 10, z = 0})
end)

core.register_on_respawnplayer(function(player)
	player:set_pos({x = 0, y = 10, z = 0})
	return true
end)

minetest.log("action", "[MBR Mapgen] Loaded")
