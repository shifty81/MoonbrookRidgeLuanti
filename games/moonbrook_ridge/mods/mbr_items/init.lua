-- MoonBrook Ridge Items Mod
-- Food, drinks, and consumable items

-- Register some starter food items using the survival system
if mbr and mbr.survival then
	-- Foods
	mbr.survival.register_food("mbr_items:bread", {
		description = "Bread",
		texture = "heart.png",  -- Using builtin texture as placeholder
		hunger_restore = 20,
	})

	mbr.survival.register_food("mbr_items:apple", {
		description = "Apple",
		texture = "heart.png",  -- Using builtin texture as placeholder
		hunger_restore = 10,
		thirst_restore = 5,
	})

	mbr.survival.register_food("mbr_items:cooked_meat", {
		description = "Cooked Meat",
		texture = "heart.png",  -- Using builtin texture as placeholder
		hunger_restore = 30,
	})

	-- Drinks
	mbr.survival.register_drink("mbr_items:water_bottle", {
		description = "Water Bottle",
		texture = "bubble.png",  -- Using builtin texture as placeholder
		thirst_restore = 30,
	})

	mbr.survival.register_drink("mbr_items:milk", {
		description = "Milk",
		texture = "bubble.png",  -- Using builtin texture as placeholder
		thirst_restore = 20,
		hunger_restore = 10,
	})

	minetest.log("action", "[MBR Items] Registered food and drink items")
else
	minetest.log("warning", "[MBR Items] MBR survival system not found!")
end

-- Register basic tools using the crafting system
if mbr and mbr.crafting then
	-- Register basic tool materials
	mbr.crafting.register_material("mbr_items:wood_material", {
		description = "Wood Material",
		quality = "normal",
		texture = "default_wood.png",
	})

	mbr.crafting.register_material("mbr_items:stone_material", {
		description = "Stone Material",
		quality = "fine",
		texture = "default_stone.png",
	})

	minetest.log("action", "[MBR Items] Registered crafting materials")
else
	minetest.log("warning", "[MBR Items] MBR crafting system not found!")
end

-- Give new players some starting items
core.register_on_newplayer(function(player)
	local inv = player:get_inventory()
	
	-- Give starter food and water
	inv:add_item("main", "mbr_items:bread 5")
	inv:add_item("main", "mbr_items:apple 3")
	inv:add_item("main", "mbr_items:water_bottle 3")
	
	-- Give some basic blocks
	inv:add_item("main", "mbr_core:wood 50")
	inv:add_item("main", "mbr_core:dirt 50")
	inv:add_item("main", "mbr_core:stone 20")
	
	minetest.log("action", "[MBR Items] Gave starting items to " .. player:get_player_name())
end)

minetest.log("action", "[MBR Items] Loaded")
