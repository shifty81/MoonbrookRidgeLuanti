-- Unit tests for mbr.loot (MoonBrook Ridge Diablo-Style Loot System)
-- Tests pure logic functions; engine API calls are stubbed.

-- Minimal engine stubs
_G.core = {
	colorize = function(color, text) return text end,
	serialize = function(t) return tostring(t) end,
	deserialize = function(s) return nil end,
	register_craftitem = function() end,
	register_chatcommand = function() end,
	register_on_player_receive_fields = function() end,
	register_on_leaveplayer = function() end,
	registered_items = {},
	settings = { get_bool = function() return false end },
}

_G.ItemStack = function(name)
	local meta_data = {}
	return {
		get_name = function() return name end,
		is_empty = function() return name == "" or name == nil end,
		get_meta = function()
			return {
				set_string = function(_, k, v) meta_data[k] = v end,
				get_string = function(_, k) return meta_data[k] or "" end,
				set_int = function(_, k, v) meta_data[k] = v end,
				get_int = function(_, k) return meta_data[k] or 0 end,
			}
		end,
	}
end

dofile("builtin/game/mbr_loot.lua")

describe("mbr.loot", function()

	describe("rarity constants", function()
		it("defines 5 rarity tiers", function()
			assert.equal(1, mbr.loot.RARITY_COMMON)
			assert.equal(2, mbr.loot.RARITY_MAGIC)
			assert.equal(3, mbr.loot.RARITY_RARE)
			assert.equal(4, mbr.loot.RARITY_EPIC)
			assert.equal(5, mbr.loot.RARITY_LEGENDARY)
		end)

		it("has names for all tiers", function()
			assert.equal("Common", mbr.loot.rarity_names[1])
			assert.equal("Magic", mbr.loot.rarity_names[2])
			assert.equal("Rare", mbr.loot.rarity_names[3])
			assert.equal("Epic", mbr.loot.rarity_names[4])
			assert.equal("Legendary", mbr.loot.rarity_names[5])
		end)

		it("has colors for all tiers", function()
			for i = 1, 5 do
				assert.is_string(mbr.loot.rarity_colors[i])
			end
		end)
	end)

	describe("roll_rarity()", function()
		it("returns a value between 1 and 5", function()
			for _ = 1, 50 do
				local r = mbr.loot.roll_rarity()
				assert.is_true(r >= 1 and r <= 5,
					"rarity out of range: " .. tostring(r))
			end
		end)

		it("respects custom weights", function()
			-- Force legendary only
			local weights = {[5] = 100}
			for _ = 1, 10 do
				assert.equal(5, mbr.loot.roll_rarity(weights))
			end
		end)

		it("respects single-tier custom weights", function()
			local weights = {[1] = 100}
			for _ = 1, 10 do
				assert.equal(1, mbr.loot.roll_rarity(weights))
			end
		end)
	end)

	describe("generate_affixes()", function()
		it("returns empty table for Common rarity", function()
			local affixes = mbr.loot.generate_affixes(1)
			assert.equal(0, #affixes)
		end)

		it("returns 1-2 affixes for Magic rarity", function()
			for _ = 1, 20 do
				local affixes = mbr.loot.generate_affixes(2)
				assert.is_true(#affixes >= 1 and #affixes <= 2,
					"magic affix count: " .. #affixes)
			end
		end)

		it("returns 2-3 affixes for Rare rarity", function()
			for _ = 1, 20 do
				local affixes = mbr.loot.generate_affixes(3)
				assert.is_true(#affixes >= 2 and #affixes <= 3,
					"rare affix count: " .. #affixes)
			end
		end)

		it("returns 3-4 affixes for Epic rarity", function()
			for _ = 1, 20 do
				local affixes = mbr.loot.generate_affixes(4)
				assert.is_true(#affixes >= 3 and #affixes <= 4,
					"epic affix count: " .. #affixes)
			end
		end)

		it("returns 4-5 affixes for Legendary rarity", function()
			for _ = 1, 20 do
				local affixes = mbr.loot.generate_affixes(5)
				assert.is_true(#affixes >= 4 and #affixes <= 5,
					"legendary affix count: " .. #affixes)
			end
		end)

		it("affixes have name, stat, value, desc fields", function()
			local affixes = mbr.loot.generate_affixes(3)
			for _, a in ipairs(affixes) do
				assert.is_string(a.name)
				assert.is_string(a.stat)
				assert.is_number(a.value)
				assert.is_string(a.desc)
			end
		end)

		it("does not duplicate stat types", function()
			for _ = 1, 20 do
				local affixes = mbr.loot.generate_affixes(5)
				local seen = {}
				for _, a in ipairs(affixes) do
					assert.is_nil(seen[a.stat],
						"duplicate stat: " .. a.stat)
					seen[a.stat] = true
				end
			end
		end)
	end)

	describe("generate_item()", function()
		it("returns a complete item table", function()
			local item = mbr.loot.generate_item("test:sword", "Test Sword")
			assert.is_string(item.name)
			assert.is_string(item.description)
			assert.is_number(item.rarity)
			assert.is_string(item.rarity_name)
			assert.is_string(item.color)
			assert.is_table(item.affixes)
			assert.is_table(item.stats)
		end)

		it("respects forced rarity", function()
			local item = mbr.loot.generate_item("test:axe", "Test Axe", 5)
			assert.equal(5, item.rarity)
			assert.equal("Legendary", item.rarity_name)
		end)

		it("clamps rarity to valid range", function()
			local item = mbr.loot.generate_item("test:bow", "Test Bow", 99)
			assert.equal(5, item.rarity)
		end)

		it("clamps rarity below valid range", function()
			local item = mbr.loot.generate_item("test:bow", "Test Bow", -1)
			assert.equal(1, item.rarity)
		end)
	end)

	describe("loot table registration", function()
		it("registers and retrieves a loot table", function()
			mbr.loot.register_loot_table("test_source", {
				{itemname = "test:item_a", weight = 10},
				{itemname = "test:item_b", weight = 5},
			})
			local tbl = mbr.loot.get_loot_table("test_source")
			assert.is_table(tbl)
			assert.equal(2, #tbl)
			assert.equal("test:item_a", tbl[1].itemname)
		end)

		it("returns nil for unknown source", function()
			assert.is_nil(mbr.loot.get_loot_table("nonexistent"))
		end)
	end)
end)
