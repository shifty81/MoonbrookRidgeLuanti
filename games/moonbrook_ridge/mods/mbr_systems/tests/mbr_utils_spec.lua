-- Unit tests for mbr.utils (MoonBrook Ridge Shared Utilities)

-- Minimal engine stubs
_G.core = {
	settings = { get_bool = function() return false end },
}

dofile("games/moonbrook_ridge/mods/mbr_systems/mbr_utils.lua")

local FILLED_HEART = "\xe2\x99\xa5"  -- ♥
local EMPTY_HEART  = "\xe2\x99\xa1"  -- ♡

describe("mbr.utils", function()

	describe("clamp()", function()
		it("returns value when within range", function()
			assert.equal(5, mbr.utils.clamp(5, 0, 10))
		end)

		it("returns min when value is below range", function()
			assert.equal(0, mbr.utils.clamp(-5, 0, 10))
		end)

		it("returns max when value is above range", function()
			assert.equal(10, mbr.utils.clamp(15, 0, 10))
		end)

		it("returns min when value equals min", function()
			assert.equal(0, mbr.utils.clamp(0, 0, 10))
		end)

		it("returns max when value equals max", function()
			assert.equal(10, mbr.utils.clamp(10, 0, 10))
		end)

		it("works with negative ranges", function()
			assert.equal(-3, mbr.utils.clamp(-3, -5, -1))
		end)

		it("works with fractional values", function()
			assert.equal(0.5, mbr.utils.clamp(0.5, 0, 1))
		end)
	end)

	describe("format_hearts()", function()
		it("returns all empty hearts for 0", function()
			local result = mbr.utils.format_hearts(0)
			assert.equal(10, select(2, result:gsub(EMPTY_HEART, "")))
		end)

		it("returns all filled hearts for 10", function()
			local result = mbr.utils.format_hearts(10)
			assert.equal(10, select(2, result:gsub(FILLED_HEART, "")))
		end)

		it("returns correct mix for 5 hearts", function()
			local result = mbr.utils.format_hearts(5)
			local _, filled = result:gsub(FILLED_HEART, "")
			local _, empty = result:gsub(EMPTY_HEART, "")
			assert.equal(5, filled)
			assert.equal(5, empty)
		end)

		it("floors fractional hearts", function()
			local result = mbr.utils.format_hearts(3.7)
			local _, filled = result:gsub(FILLED_HEART, "")
			assert.equal(3, filled)
		end)

		it("respects custom max parameter", function()
			local result = mbr.utils.format_hearts(3, 5)
			local _, filled = result:gsub(FILLED_HEART, "")
			local _, empty = result:gsub(EMPTY_HEART, "")
			assert.equal(3, filled)
			assert.equal(2, empty)
		end)
	end)
end)
