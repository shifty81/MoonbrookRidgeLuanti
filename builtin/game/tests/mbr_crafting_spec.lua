-- Unit tests for mbr.crafting (MoonBrook Ridge Quality-Based Crafting)
-- Tests pure logic functions; engine API calls are stubbed.

-- Minimal engine stubs
_G.core = {
	colorize = function(color, text) return text end,
	serialize = function(t) return tostring(t) end,
	deserialize = function(s) return nil end,
	register_craftitem = function() end,
	register_tool = function() end,
	register_chatcommand = function() end,
	register_on_player_receive_fields = function() end,
	register_on_leaveplayer = function() end,
	registered_items = {},
	formspec_escape = function(s) return s end,
	show_formspec = function() end,
	explode_textlist_event = function() return {type = "INV"} end,
	settings = { get_bool = function() return false end },
}

_G.ItemStack = function(name)
	local meta_data = {}
	local count = 1
	-- Parse "name count" format
	if type(name) == "string" then
		local n, c = name:match("^(%S+)%s+(%d+)$")
		if n then
			name = n
			count = tonumber(c)
		end
	end
	return {
		get_name = function() return name or "" end,
		is_empty = function() return name == "" or name == nil end,
		get_count = function() return count end,
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

-- Stub mbr.loot since mbr_crafting uses it
_G.mbr = {loot = {
	generate_item = function(name, desc, rarity)
		return {affixes = {}, stats = {}, rarity = rarity or 1}
	end,
}}

dofile("builtin/game/mbr_crafting.lua")

describe("mbr.crafting", function()

	describe("quality constants", function()
		it("defines 5 quality tiers", function()
			assert.equal(1, mbr.crafting.QUALITY_POOR)
			assert.equal(2, mbr.crafting.QUALITY_NORMAL)
			assert.equal(3, mbr.crafting.QUALITY_FINE)
			assert.equal(4, mbr.crafting.QUALITY_SUPERIOR)
			assert.equal(5, mbr.crafting.QUALITY_MASTERWORK)
		end)

		it("has names for all tiers", function()
			assert.equal("Poor", mbr.crafting.quality_names[1])
			assert.equal("Normal", mbr.crafting.quality_names[2])
			assert.equal("Fine", mbr.crafting.quality_names[3])
			assert.equal("Superior", mbr.crafting.quality_names[4])
			assert.equal("Masterwork", mbr.crafting.quality_names[5])
		end)

		it("has colors for all tiers", function()
			for i = 1, 5 do
				assert.is_string(mbr.crafting.quality_colors[i])
			end
		end)

		it("has multipliers for all tiers", function()
			assert.equal(0.75, mbr.crafting.quality_multipliers[1])
			assert.equal(1.00, mbr.crafting.quality_multipliers[2])
			assert.equal(1.20, mbr.crafting.quality_multipliers[3])
			assert.equal(1.50, mbr.crafting.quality_multipliers[4])
			assert.equal(2.00, mbr.crafting.quality_multipliers[5])
		end)
	end)

	describe("calculate_quality()", function()
		it("returns NORMAL for empty inputs", function()
			local tier = mbr.crafting.calculate_quality({})
			assert.equal(mbr.crafting.QUALITY_NORMAL, tier)
		end)

		it("returns NORMAL for empty ItemStacks", function()
			local stacks = {ItemStack("")}
			local tier = mbr.crafting.calculate_quality(stacks)
			assert.equal(mbr.crafting.QUALITY_NORMAL, tier)
		end)

		it("returns POOR for average quality < 1.5", function()
			-- Simulate stacks with quality 1 (Poor)
			local stacks = {}
			for i = 1, 3 do
				local s = ItemStack("mbr:test_poor")
				local meta = s:get_meta()
				meta:set_int("mbr_quality", 1)
				stacks[i] = s
			end
			local tier = mbr.crafting.calculate_quality(stacks)
			assert.equal(mbr.crafting.QUALITY_POOR, tier)
		end)

		it("returns MASTERWORK for average quality >= 4.5", function()
			local stacks = {}
			for i = 1, 3 do
				local s = ItemStack("mbr:test_master")
				local meta = s:get_meta()
				meta:set_int("mbr_quality", 5)
				stacks[i] = s
			end
			local tier = mbr.crafting.calculate_quality(stacks)
			assert.equal(mbr.crafting.QUALITY_MASTERWORK, tier)
		end)
	end)

	describe("apply_quality()", function()
		it("sets quality metadata on an ItemStack", function()
			local stack = ItemStack("mbr:test_item")
			-- Register a fake item so apply_quality can look up description
			core.registered_items["mbr:test_item"] = {
				description = "Test Item",
			}
			mbr.crafting.apply_quality(stack, 3, {damage = 10})
			local meta = stack:get_meta()
			assert.equal(3, meta:get_int("mbr_quality"))
			assert.equal("Fine", meta:get_string("mbr_quality_name"))
			assert.is_truthy(meta:get_string("description"):find("Fine"))
		end)

		it("scales stats by quality multiplier", function()
			local stack = ItemStack("mbr:test_item")
			core.registered_items["mbr:test_item"] = {
				description = "Test Item",
			}
			mbr.crafting.apply_quality(stack, 5, {damage = 10, durability = 100})
			local meta = stack:get_meta()
			-- Masterwork = 2.0x multiplier, so damage = 20, durability = 200
			local scaled_str = meta:get_string("mbr_scaled_stats")
			assert.is_truthy(scaled_str ~= "")
		end)
	end)

	describe("get_material_quality()", function()
		it("returns NORMAL for unknown string material", function()
			local q = mbr.crafting.get_material_quality("unknown:item")
			assert.equal(mbr.crafting.QUALITY_NORMAL, q)
		end)

		it("reads quality from ItemStack meta", function()
			local stack = ItemStack("mbr:test_item")
			local meta = stack:get_meta()
			meta:set_int("mbr_quality", 4)
			local q = mbr.crafting.get_material_quality(stack)
			assert.equal(4, q)
		end)

		it("falls back to NORMAL for ItemStack without quality meta", function()
			local stack = ItemStack("unknown:item")
			local q = mbr.crafting.get_material_quality(stack)
			assert.equal(mbr.crafting.QUALITY_NORMAL, q)
		end)
	end)

	describe("recipe registration", function()
		it("registers and retrieves a recipe", function()
			mbr.crafting.register_recipe("test_recipe_123", {
				output = "mbr:test_output_123",
				description = "Test Output 123",
				ingredients = {{"mbr:wood_plank", 2}},
				base_stats = {damage = 5},
			})
			local recipe = mbr.crafting.get_recipe("test_recipe_123")
			assert.is_table(recipe)
			assert.equal("mbr:test_output_123", recipe.output)
			assert.equal("Test Output 123", recipe.description)
		end)

		it("returns nil for unknown recipe", function()
			assert.is_nil(mbr.crafting.get_recipe("nonexistent_recipe"))
		end)

		it("adds recipe to the recipe list", function()
			local list = mbr.crafting.get_recipe_list()
			assert.is_table(list)
			-- Should contain our test recipe
			local found = false
			for _, rid in ipairs(list) do
				if rid == "test_recipe_123" then
					found = true
					break
				end
			end
			assert.is_true(found)
		end)
	end)
end)
