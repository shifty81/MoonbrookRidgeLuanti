-- MoonBrook Ridge: Marriage and Family System
-- Proposals, weddings, spouse benefits, and children

mbr = mbr or {}
mbr.marriage = {
	marriages = {},
	children = {},
}

-- Helpers
local function clamp(val, min_v, max_v)
	if val < min_v then return min_v end
	if val > max_v then return max_v end
	return val
end

-- Constants
local SEASON_DAYS = 28
local TODDLER_STAGE_AGE = 28
local CHILD_STAGE_AGE = 56
local MAX_CHILDREN = 2
local CHILD_SPAWN_CHANCE_PERCENT = 5
local SPOUSE_HELP_CHANCE_PERCENT = 30

-- Random child name lists
local child_names_male = {
	"Aiden", "Liam", "Noah", "Ethan", "Lucas",
	"Mason", "Logan", "James", "Owen", "Caleb",
}
local child_names_female = {
	"Sophia", "Olivia", "Ava", "Mia", "Luna",
	"Chloe", "Ella", "Grace", "Lily", "Zoey",
}

-- Spouse help action definitions
local spouse_actions = {
	{
		id = "water_crops",
		message = "watered the crops for you!",
		apply = function(player_name)
			-- Restore some hunger since player doesn't have to farm
			if mbr.survival and mbr.survival.feed_player then
				mbr.survival.feed_player(player_name, 5)
			end
		end,
	},
	{
		id = "feed_animals",
		message = "fed the animals this morning!",
		apply = function(player_name)
			if mbr.survival and mbr.survival.feed_player then
				mbr.survival.feed_player(player_name, 3)
			end
		end,
	},
	{
		id = "repair_fences",
		message = "repaired the fences around the property!",
		apply = function(player_name)
			-- Small morale boost via hunger
			if mbr.survival and mbr.survival.feed_player then
				mbr.survival.feed_player(player_name, 2)
			end
		end,
	},
	{
		id = "cook_food",
		message = "cooked a delicious meal for you!",
		apply = function(player_name)
			if mbr.survival then
				if mbr.survival.feed_player then
					mbr.survival.feed_player(player_name, 15)
				end
				if mbr.survival.hydrate_player then
					mbr.survival.hydrate_player(player_name, 10)
				end
			end
		end,
	},
}

---------------------------------------------------------------------------
-- 1. Marriage Functions
---------------------------------------------------------------------------

function mbr.marriage.can_propose(player_name, npc_name)
	-- Must have 10 hearts and not already married
	if mbr.marriage.marriages[player_name] then
		return false, "You are already married."
	end
	if not mbr.npcs or not mbr.npcs.get_hearts then
		return false, "NPC system not available."
	end
	local hearts = mbr.npcs.get_hearts(player_name, npc_name)
	if hearts < 10 then
		return false, "Your relationship isn't strong enough yet. (Need 10 hearts)"
	end
	return true
end

function mbr.marriage.propose(player, npc_name)
	local player_name = player:get_player_name()
	local can, reason = mbr.marriage.can_propose(player_name, npc_name)
	if not can then
		core.chat_send_player(player_name, reason)
		return false
	end

	local def = mbr.npcs and mbr.npcs.definitions and mbr.npcs.definitions[npc_name]
	local display_name = def and def.name or npc_name

	-- Show proposal formspec
	local fs = "formspec_version[6]"
		.. "size[8,6]"
		.. "bgcolor[#00000088;true]"
		.. "box[0.5,0.5;7,2.5;#88225588]"
		.. "label[1.5,1.2;♥ ♥ ♥  Proposal  ♥ ♥ ♥]"
		.. "label[1.0,2.2;You kneel before " .. core.formspec_escape(display_name) .. "...]"
		.. "label[1.0,2.7;Will you marry me?]"
		.. "button[0.5,3.8;3.2,0.8;btn_confirm_proposal;Propose!]"
		.. "button[4.3,3.8;3.2,0.8;btn_cancel_proposal;Not yet...]"

	-- Store proposal context
	if not mbr.marriage._proposal_context then
		mbr.marriage._proposal_context = {}
	end
	mbr.marriage._proposal_context[player_name] = npc_name

	core.show_formspec(player_name, "mbr:proposal", fs)
	return true
end

function mbr.marriage.hold_wedding(player, npc_name)
	local player_name = player:get_player_name()
	local def = mbr.npcs and mbr.npcs.definitions and mbr.npcs.definitions[npc_name]
	local display_name = def and def.name or npc_name

	-- Set marriage data
	mbr.marriage.marriages[player_name] = {
		spouse = npc_name,
		date = {
			day = mbr.time.day or 1,
			season = mbr.time.season or 1,
			year = mbr.time.year or 1,
		},
		anniversary = false,
		married_day_count = 0,
	}

	-- Initialize children list
	mbr.marriage.children[player_name] = {}

	-- Announce to all players
	local season_name = "Spring"
	if mbr.time and mbr.time.get_season_name then
		season_name = mbr.time.get_season_name()
	end
	local announcement = string.format(
		"*** %s and %s have been married! Congratulations! ***",
		player_name, display_name)
	for _, p in ipairs(core.get_connected_players()) do
		core.chat_send_player(p:get_player_name(), announcement)
	end

	-- Spawn heart particles around the player
	local pos = player:get_pos()
	if pos then
		core.add_particlespawner({
			amount = 40,
			time = 5,
			minpos = {x = pos.x - 3, y = pos.y, z = pos.z - 3},
			maxpos = {x = pos.x + 3, y = pos.y + 4, z = pos.z + 3},
			minvel = {x = -1, y = 1, z = -1},
			maxvel = {x = 1, y = 3, z = 1},
			minacc = {x = 0, y = -0.5, z = 0},
			maxacc = {x = 0, y = -0.5, z = 0},
			minexptime = 2,
			maxexptime = 4,
			minsize = 2,
			maxsize = 4,
			texture = "heart.png",
		})
	end

	core.chat_send_player(player_name,
		"You are now married to " .. display_name .. "! Check /family for details.")
end

---------------------------------------------------------------------------
-- 2. Proposal Formspec Handler
---------------------------------------------------------------------------

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "mbr:proposal" then return false end

	local player_name = player:get_player_name()
	local ctx = mbr.marriage._proposal_context
	if not ctx or not ctx[player_name] then return true end

	local npc_name = ctx[player_name]

	if fields.btn_confirm_proposal then
		-- At 10 hearts, always accepted
		local def = mbr.npcs and mbr.npcs.definitions and mbr.npcs.definitions[npc_name]
		local display_name = def and def.name or npc_name

		if mbr.npcs and mbr.npcs.show_bubble then
			mbr.npcs.show_bubble(player, npc_name, "Yes! Yes, a thousand times yes!")
		end

		-- Short delay then hold wedding
		core.after(2, function()
			local p = core.get_player_by_name(player_name)
			if p then
				mbr.marriage.hold_wedding(p, npc_name)
			end
		end)

		ctx[player_name] = nil
		return true
	end

	if fields.btn_cancel_proposal or fields.quit then
		if mbr.npcs and mbr.npcs.show_bubble then
			mbr.npcs.show_bubble(player, npc_name, "Take your time. I'll be here.")
		end
		ctx[player_name] = nil
		return true
	end

	return true
end)

---------------------------------------------------------------------------
-- 3. Spouse Benefits (daily callback)
---------------------------------------------------------------------------

if mbr.time and mbr.time.register_on_new_day then
	mbr.time.register_on_new_day(function(day, season)
		for player_name, mdata in pairs(mbr.marriage.marriages) do
			-- Track marriage duration
			mdata.married_day_count = (mdata.married_day_count or 0) + 1

			-- Check anniversary
			if mdata.date then
				if day == mdata.date.day and season == mdata.date.season then
					mdata.anniversary = true
					core.chat_send_player(player_name,
						"♥ Happy Anniversary! It's your wedding anniversary today! ♥")
				else
					mdata.anniversary = false
				end
			end

			-- 30% chance spouse helps each day
			if math.random(100) <= SPOUSE_HELP_CHANCE_PERCENT then
				local action = spouse_actions[math.random(#spouse_actions)]
				local def = mbr.npcs and mbr.npcs.definitions and mbr.npcs.definitions[mdata.spouse]
				local spouse_display = def and def.name or mdata.spouse

				core.chat_send_player(player_name,
					"♥ " .. spouse_display .. " " .. action.message)
				action.apply(player_name)
			end

			-- Children: after 28 days (1 season) of marriage, 5% chance per day (max 2)
			if mdata.married_day_count >= SEASON_DAYS then
				local kids = mbr.marriage.children[player_name]
				if kids and #kids < MAX_CHILDREN then
					if math.random(100) <= CHILD_SPAWN_CHANCE_PERCENT then
						-- New child!
						local name_list
						if math.random(2) == 1 then
							name_list = child_names_male
						else
							name_list = child_names_female
						end
						local child_name = name_list[math.random(#name_list)]
						local child = {
							name = child_name,
							stage = "baby",
							age = 0,
							happiness = 50,
							education = 0,
						}
						table.insert(kids, child)

						local def2 = mbr.npcs and mbr.npcs.definitions and mbr.npcs.definitions[mdata.spouse]
						local spouse_display = def2 and def2.name or mdata.spouse
						core.chat_send_player(player_name,
							"♥♥♥ Wonderful news! You and " .. spouse_display ..
							" have a new baby: " .. child_name .. "! ♥♥♥")
					end
				end
			end

			-- Age existing children and update stages
			local kids = mbr.marriage.children[player_name]
			if kids then
				for _, child in ipairs(kids) do
					child.age = child.age + 1
					if child.age >= CHILD_STAGE_AGE then
						child.stage = "child"
					elseif child.age >= TODDLER_STAGE_AGE then
						child.stage = "toddler"
					else
						child.stage = "baby"
					end
				end
			end
		end
	end)
end

---------------------------------------------------------------------------
-- 4. Child Interaction
---------------------------------------------------------------------------

function mbr.marriage.interact_child(player, child_index, action)
	local player_name = player:get_player_name()
	local kids = mbr.marriage.children[player_name]
	if not kids or not kids[child_index] then
		return false, "Child not found."
	end

	local child = kids[child_index]
	local msg = ""

	if action == "play" then
		child.happiness = clamp(child.happiness + 5, 0, 100)
		msg = "You played with " .. child.name .. "! (+5 happiness)"
	elseif action == "gift" then
		child.happiness = clamp(child.happiness + 3, 0, 100)
		msg = "You gave " .. child.name .. " a gift! (+3 happiness)"
	elseif action == "teach" then
		child.education = clamp(child.education + 5, 0, 100)
		msg = "You taught " .. child.name .. " something new! (+5 education)"
	elseif action == "hug" then
		child.happiness = clamp(child.happiness + 2, 0, 100)
		msg = "You hugged " .. child.name .. "! (+2 happiness)"
	else
		return false, "Unknown action."
	end

	core.chat_send_player(player_name, msg)
	return true
end

---------------------------------------------------------------------------
-- 5. Family Menu Formspec
---------------------------------------------------------------------------

local function show_family_formspec(player)
	local player_name = player:get_player_name()
	local mdata = mbr.marriage.marriages[player_name]

	local fs = "formspec_version[6]"
		.. "size[12,10]"
		.. "bgcolor[#00000088;true]"
		.. "label[4.5,0.5;♥ Family ♥]"

	if not mdata then
		fs = fs .. "label[2,3;You are not married yet.]"
			.. "label[2,3.8;Reach 10 hearts with an NPC and propose!]"
			.. "button[4,8.5;4,0.8;btn_family_close;Close]"
		core.show_formspec(player_name, "mbr:family", fs)
		return
	end

	-- Spouse info
	local def = mbr.npcs and mbr.npcs.definitions and mbr.npcs.definitions[mdata.spouse]
	local spouse_display = def and def.name or mdata.spouse
	local spouse_role = def and def.role or "Villager"
	local season_name = "Spring"
	if mbr.time and mbr.time.season_names and mdata.date then
		season_name = mbr.time.season_names[mdata.date.season] or "Spring"
	end
	local date_str = ""
	if mdata.date then
		date_str = string.format("Day %d of %s, Year %d",
			mdata.date.day, season_name, mdata.date.year)
	end

	fs = fs .. "box[0.5,1;5,2.5;#88225544]"
		.. "label[1,1.5;Spouse: " .. core.formspec_escape(spouse_display) .. "]"
		.. "label[1,2.0;Role: " .. core.formspec_escape(spouse_role) .. "]"
		.. "label[1,2.5;Married: " .. core.formspec_escape(date_str) .. "]"
		.. "label[1,3.0;Days Together: " .. (mdata.married_day_count or 0) .. "]"

	if mdata.anniversary then
		fs = fs .. "label[6.5,1.5;♥ Happy Anniversary! ♥]"
	end

	-- Children section
	local kids = mbr.marriage.children[player_name] or {}
	fs = fs .. "label[0.5,4.0;Children (" .. #kids .. "/" .. MAX_CHILDREN .. "):]"

	if #kids == 0 then
		fs = fs .. "label[1,4.8;No children yet.]"
	else
		for i, child in ipairs(kids) do
			local y_base = 4.0 + (i * 1.8)
			local stage_display = child.stage:sub(1, 1):upper() .. child.stage:sub(2)

			fs = fs .. "box[0.5," .. y_base .. ";11,1.6;#44446644]"
				.. "label[1," .. (y_base + 0.3) .. ";" .. core.formspec_escape(child.name)
				.. " (" .. stage_display .. ", Age: " .. child.age .. " days)]"
				.. "label[1," .. (y_base + 0.8) .. ";Happiness: " .. child.happiness
				.. "/100  |  Education: " .. child.education .. "/100]"

			-- Interaction buttons
			local btn_y = y_base + 1.1
			fs = fs .. "button[6," .. btn_y .. ";1.3,0.4;btn_play_" .. i .. ";Play]"
				.. "button[7.4," .. btn_y .. ";1.3,0.4;btn_gift_" .. i .. ";Gift]"
				.. "button[8.8," .. btn_y .. ";1.3,0.4;btn_teach_" .. i .. ";Teach]"
				.. "button[10.2," .. btn_y .. ";1.3,0.4;btn_hug_" .. i .. ";Hug]"
		end
	end

	fs = fs .. "button[4,9;4,0.8;btn_family_close;Close]"
	core.show_formspec(player_name, "mbr:family", fs)
end

---------------------------------------------------------------------------
-- 6. Family Formspec Handler
---------------------------------------------------------------------------

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "mbr:family" then return false end

	local player_name = player:get_player_name()

	if fields.btn_family_close or fields.quit then
		return true
	end

	-- Handle child interaction buttons
	for i = 1, MAX_CHILDREN do
		if fields["btn_play_" .. i] then
			mbr.marriage.interact_child(player, i, "play")
			show_family_formspec(player)
			return true
		end
		if fields["btn_gift_" .. i] then
			mbr.marriage.interact_child(player, i, "gift")
			show_family_formspec(player)
			return true
		end
		if fields["btn_teach_" .. i] then
			mbr.marriage.interact_child(player, i, "teach")
			show_family_formspec(player)
			return true
		end
		if fields["btn_hug_" .. i] then
			mbr.marriage.interact_child(player, i, "hug")
			show_family_formspec(player)
			return true
		end
	end

	return true
end)

---------------------------------------------------------------------------
-- 7. Chat Commands
---------------------------------------------------------------------------

core.register_chatcommand("family", {
	description = "Open the family menu showing spouse and children info",
	func = function(player_name, param)
		local player = core.get_player_by_name(player_name)
		if not player then
			return false, "Player not found."
		end
		show_family_formspec(player)
		return true
	end,
})

core.register_chatcommand("propose", {
	description = "Propose to an NPC you are talking to or near",
	func = function(player_name, param)
		local player = core.get_player_by_name(player_name)
		if not player then
			return false, "Player not found."
		end

		-- Check if player is currently talking to an NPC
		local npc_name = nil
		if mbr.npcs and mbr.npcs.spawned and mbr.npcs.spawned[player_name] then
			npc_name = mbr.npcs.spawned[player_name].talking_to
		end

		-- If param is provided, use it as NPC name
		if param and param ~= "" then
			-- Normalize: try lowercase match
			local lower_param = param:lower()
			for npc_id, def in pairs(mbr.npcs.definitions) do
				if npc_id == lower_param or def.name:lower() == lower_param then
					npc_name = npc_id
					break
				end
			end
		end

		if not npc_name then
			return false, "Specify an NPC name: /propose <name>"
		end

		mbr.marriage.propose(player, npc_name)
		return true
	end,
})

---------------------------------------------------------------------------
-- 8. Keybind Support via Player Fields
---------------------------------------------------------------------------

-- The Y key and V key bindings work through formspec_version inventory
-- key detection. Players can also use the chat commands.
core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then return false end

	-- Detect inventory key presses for family/propose shortcuts
	-- These are triggered by custom key settings in the client
	if fields.key_family then
		show_family_formspec(player)
		return true
	end

	if fields.key_propose then
		local player_name = player:get_player_name()
		if mbr.npcs and mbr.npcs.spawned and mbr.npcs.spawned[player_name] then
			local npc_name = mbr.npcs.spawned[player_name].talking_to
			if npc_name then
				mbr.marriage.propose(player, npc_name)
				return true
			end
		end
		core.chat_send_player(player_name,
			"You need to be talking to an NPC to propose. Use /propose <name> instead.")
		return true
	end

	return false
end)

---------------------------------------------------------------------------
-- 9. Player Cleanup
---------------------------------------------------------------------------

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if mbr.marriage._proposal_context then
		mbr.marriage._proposal_context[name] = nil
	end
end)
