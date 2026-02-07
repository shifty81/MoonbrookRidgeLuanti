-- Unit tests for mbr.time (MoonBrook Ridge Time & Season System)
-- Tests pure logic functions; engine API calls are stubbed.

-- Minimal engine stubs
_G.core = {
	get_timeofday = function() return 0.5 end,
	get_connected_players = function() return {} end,
	register_on_joinplayer = function() end,
	register_on_leaveplayer = function() end,
	register_globalstep = function() end,
	settings = { get_bool = function() return false end },
}

dofile("builtin/game/mbr_time.lua")

describe("mbr.time", function()

	before_each(function()
		mbr.time.day = 1
		mbr.time.season = 1
		mbr.time.year = 1
		mbr.time.hour = 6
		mbr.time.minute = 0
	end)

	describe("get_season_name()", function()
		it("returns Spring for season 1", function()
			mbr.time.season = 1
			assert.equal("Spring", mbr.time.get_season_name())
		end)

		it("returns Summer for season 2", function()
			mbr.time.season = 2
			assert.equal("Summer", mbr.time.get_season_name())
		end)

		it("returns Fall for season 3", function()
			mbr.time.season = 3
			assert.equal("Fall", mbr.time.get_season_name())
		end)

		it("returns Winter for season 4", function()
			mbr.time.season = 4
			assert.equal("Winter", mbr.time.get_season_name())
		end)

		it("returns Unknown for out-of-range season", function()
			mbr.time.season = 99
			assert.equal("Unknown", mbr.time.get_season_name())
		end)
	end)

	describe("get_total_day()", function()
		it("returns 1 for year 1, season 1, day 1", function()
			mbr.time.year = 1
			mbr.time.season = 1
			mbr.time.day = 1
			assert.equal(1, mbr.time.get_total_day())
		end)

		it("returns 28 for last day of Spring year 1", function()
			mbr.time.year = 1
			mbr.time.season = 1
			mbr.time.day = 28
			assert.equal(28, mbr.time.get_total_day())
		end)

		it("returns 29 for first day of Summer year 1", function()
			mbr.time.year = 1
			mbr.time.season = 2
			mbr.time.day = 1
			assert.equal(29, mbr.time.get_total_day())
		end)

		it("returns 112 for last day of Winter year 1", function()
			mbr.time.year = 1
			mbr.time.season = 4
			mbr.time.day = 28
			assert.equal(112, mbr.time.get_total_day())
		end)

		it("returns 113 for first day of year 2", function()
			mbr.time.year = 2
			mbr.time.season = 1
			mbr.time.day = 1
			assert.equal(113, mbr.time.get_total_day())
		end)
	end)

	describe("is_daytime()", function()
		it("returns true at hour 6 (dawn)", function()
			mbr.time.hour = 6
			assert.is_true(mbr.time.is_daytime())
		end)

		it("returns true at hour 12 (noon)", function()
			mbr.time.hour = 12
			assert.is_true(mbr.time.is_daytime())
		end)

		it("returns true at hour 19 (last daytime hour)", function()
			mbr.time.hour = 19
			assert.is_true(mbr.time.is_daytime())
		end)

		it("returns false at hour 20 (dusk)", function()
			mbr.time.hour = 20
			assert.is_false(mbr.time.is_daytime())
		end)

		it("returns false at hour 5 (before dawn)", function()
			mbr.time.hour = 5
			assert.is_false(mbr.time.is_daytime())
		end)

		it("returns false at midnight", function()
			mbr.time.hour = 0
			assert.is_false(mbr.time.is_daytime())
		end)
	end)

	describe("register_on_new_day()", function()
		it("registers a callback", function()
			local count = #mbr.time.day_callbacks
			mbr.time.register_on_new_day(function() end)
			assert.equal(count + 1, #mbr.time.day_callbacks)
		end)
	end)

	describe("register_on_season_change()", function()
		it("registers a callback", function()
			local count = #mbr.time.season_callbacks
			mbr.time.register_on_season_change(function() end)
			assert.equal(count + 1, #mbr.time.season_callbacks)
		end)
	end)

	describe("season_names table", function()
		it("has exactly 4 seasons", function()
			assert.equal(4, #mbr.time.season_names)
		end)

		it("contains Spring, Summer, Fall, Winter", function()
			assert.equal("Spring", mbr.time.season_names[1])
			assert.equal("Summer", mbr.time.season_names[2])
			assert.equal("Fall", mbr.time.season_names[3])
			assert.equal("Winter", mbr.time.season_names[4])
		end)
	end)
end)
