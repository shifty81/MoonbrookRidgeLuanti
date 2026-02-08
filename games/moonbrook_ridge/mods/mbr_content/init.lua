-- MoonBrook Ridge Content Mod
-- NPCs, loot items, and other game content

-- Spawn NPCs for testing (if the NPC system is available)
if mbr and mbr.npcs then
	-- Spawn NPCs near the player spawn point after the world loads
	core.register_on_mods_loaded(function()
		core.after(2, function()
			-- Try to spawn NPCs at fixed positions for testing
			local spawn_positions = {
				{x = 10, y = 5, z = 10},
				{x = -10, y = 5, z = 10},
				{x = 10, y = 5, z = -10},
				{x = -10, y = 5, z = -10},
			}
			
			-- Note: The actual NPC spawning depends on the implementation
			-- in mbr_npcs.lua. For now, just log that we're ready
			minetest.log("action", "[MBR Content] NPC spawn positions defined")
		end)
	end)
	
	minetest.log("action", "[MBR Content] NPC system available")
else
	minetest.log("warning", "[MBR Content] NPC system not found")
end

-- Add some test loot items if the loot system is available
if mbr and mbr.loot then
	-- Create a test loot table
	mbr.loot.register_loot_table("mbr_content:test_chest", {
		{item = "mbr_items:bread", weight = 10},
		{item = "mbr_items:water_bottle", weight = 10},
		{item = "mbr_items:apple", weight = 8},
	})
	
	minetest.log("action", "[MBR Content] Registered test loot table")
else
	minetest.log("warning", "[MBR Content] Loot system not found")
end

-- Add a simple test chest to give players loot
core.register_node("mbr_content:test_chest", {
	description = "Test Loot Chest",
	tiles = {"default_wood.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not clicker then return end
		
		local player_name = clicker:get_player_name()
		
		-- Give some test items
		local inv = clicker:get_inventory()
		inv:add_item("main", "mbr_items:bread 3")
		inv:add_item("main", "mbr_items:water_bottle 2")
		
		minetest.chat_send_player(player_name, "You found some supplies!")
		
		return itemstack
	end,
})

-- Welcome message for new players
core.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	
	core.after(2, function()
		minetest.chat_send_player(player_name, "=== Welcome to MoonBrook Ridge! ===")
		minetest.chat_send_player(player_name, "A farming & life simulation game")
		minetest.chat_send_player(player_name, "")
		minetest.chat_send_player(player_name, "Try these commands:")
		minetest.chat_send_player(player_name, "  /time - Check current time and season")
		minetest.chat_send_player(player_name, "  /npc_status - View NPC relationships")
		minetest.chat_send_player(player_name, "  /craft - Open crafting menu")
		minetest.chat_send_player(player_name, "  /iteminfo - Inspect held item")
		minetest.chat_send_player(player_name, "")
		minetest.chat_send_player(player_name, "Watch your hunger and thirst bars!")
	end)
end)

-- Add some helpful chat commands
core.register_chatcommand("give_supplies", {
	description = "Get emergency supplies",
	func = function(name)
		local player = core.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		
		local inv = player:get_inventory()
		inv:add_item("main", "mbr_items:bread 10")
		inv:add_item("main", "mbr_items:water_bottle 10")
		inv:add_item("main", "mbr_items:apple 5")
		
		return true, "Supplies added to inventory"
	end,
})

core.register_chatcommand("test_weather", {
	description = "Cycle through weather types",
	func = function(name)
		if mbr and mbr.weather and mbr.weather.set_weather then
			-- Cycle through weather types
			local weather_types = {"clear", "sunny", "cloudy", "rainy", "stormy", "snowy", "windy", "foggy"}
			local current = math.random(1, #weather_types)
			mbr.weather.set_weather(weather_types[current])
			return true, "Weather changed to: " .. weather_types[current]
		else
			return false, "Weather system not available"
		end
	end,
})

minetest.log("action", "[MBR Content] Loaded")
