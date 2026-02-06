-- MoonBrook Ridge: Enhanced NPC Interactions System
-- 7 unique NPCs with relationships, gifts, dialogues, and schedules

mbr = mbr or {}
mbr.npcs = {
	definitions = {},
	spawned = {},
	relationships = {},
	schedules = {},
}

-- Clamp helper
local function clamp(val, min_v, max_v)
	if val < min_v then return min_v end
	if val > max_v then return max_v end
	return val
end

-- HUD bubble tracking per player
local bubble_huds = {}

-- Schedule update timer
local schedule_timer = 0

---------------------------------------------------------------------------
-- 1. NPC Definitions
---------------------------------------------------------------------------

mbr.npcs.definitions = {
	emma = {
		name = "Emma",
		role = "Farmer",
		personality = "Warm and friendly, always eager to share gardening tips and freshly baked pies.",
		gift_preferences = {
			loved = {"crop", "flower", "seed"},
			liked = {"food", "tool"},
		},
		dialogues = {
			[0] = {
				"Hello there! I don't think we've met. I'm Emma.",
				"Welcome to MoonBrook Ridge! The soil here is wonderful.",
				"If you need any farming advice, just ask!",
			},
			[1] = {
				"Good to see you again! The crops are coming in nicely.",
				"Have you tried growing tomatoes? They love this climate.",
			},
			[2] = {
				"Oh, hello friend! I saved some seeds for you.",
				"The sunflowers are blooming beautifully this season!",
			},
			[3] = {
				"I'm so glad we're friends! Let me show you my secret garden.",
				"Between you and me, the best fertilizer is fish meal.",
			},
			[4] = {
				"You know, you're one of my favorite people in the village.",
				"I've been experimenting with hybrid flowers. Want to see?",
			},
			[5] = {
				"I made you some fresh bread from my wheat harvest!",
				"The farm feels livelier when you visit.",
			},
			[6] = {
				"I trust you completely. Here's the key to my greenhouse.",
				"You've taught me so much about new farming techniques!",
			},
			[7] = {
				"I saved the biggest pumpkin just for you!",
				"Sometimes I imagine what it would be like to farm together...",
			},
			[8] = {
				"My heart flutters when you walk by the fields.",
				"I wrote you a poem... about sunflowers. Don't laugh!",
			},
			[9] = {
				"I can't imagine MoonBrook Ridge without you in it.",
				"You mean everything to me. The farm, the flowers... it's all for you.",
			},
			[10] = {
				"Every sunrise reminds me of your smile.",
				"I want to spend every harvest season by your side, forever.",
			},
		},
		schedule = {
			[6]  = {x = 100, y = 10, z = 100},  -- Wake up at home
			[7]  = {x = 120, y = 10, z = 110},  -- Walk to farm
			[12] = {x = 105, y = 10, z = 95},   -- Lunch at home
			[13] = {x = 120, y = 10, z = 110},  -- Back to farm
			[18] = {x = 100, y = 10, z = 100},  -- Return home
			[20] = {x = 100, y = 10, z = 100},  -- Home for evening
		},
		home_pos = {x = 100, y = 10, z = 100},
	},

	marcus = {
		name = "Marcus",
		role = "Blacksmith",
		personality = "Gruff exterior but kind-hearted, speaks few words but means every one.",
		gift_preferences = {
			loved = {"mineral", "ore", "metal"},
			liked = {"tool", "weapon"},
		},
		dialogues = {
			[0] = {
				"Hmph. New face. Name's Marcus. I work the forge.",
				"Don't touch anything unless you want to lose a finger.",
			},
			[1] = {
				"Back again? At least you're persistent.",
				"The iron here is decent quality. Not the best I've seen.",
			},
			[2] = {
				"You're alright, I suppose. Need anything repaired?",
				"I respect someone who appreciates good craftsmanship.",
			},
			[3] = {
				"Heh. You're growing on me. Like rust on iron... in a good way.",
				"I'll sharpen your tools for free. Don't tell anyone.",
			},
			[4] = {
				"You know, I used to travel. Smithed for kings and queens.",
				"There's an art to working metal. I see you understand that.",
			},
			[5] = {
				"I forged something special. It's for you.",
				"My grandfather taught me everything. You remind me of him.",
			},
			[6] = {
				"I've never shown anyone my masterwork collection. Come, look.",
				"You've earned my respect. That's not easy to do.",
			},
			[7] = {
				"I made this pendant from starlight ore. Please, take it.",
				"The forge burns brighter when you're around. Strange, that.",
			},
			[8] = {
				"I... wrote your name on my best sword. Is that weird?",
				"You make this old blacksmith feel young again.",
			},
			[9] = {
				"I'd forge the stars themselves if you asked me to.",
				"My heart is like iron — unyielding, but you've shaped it.",
			},
			[10] = {
				"Every blade I make, I make for you now.",
				"You are my greatest creation. I mean... ah, you know what I mean.",
			},
		},
		schedule = {
			[6]  = {x = 80, y = 10, z = 90},
			[7]  = {x = 70, y = 10, z = 85},   -- Forge
			[12] = {x = 80, y = 10, z = 90},
			[13] = {x = 70, y = 10, z = 85},
			[19] = {x = 80, y = 10, z = 90},
			[21] = {x = 80, y = 10, z = 90},
		},
		home_pos = {x = 80, y = 10, z = 90},
	},

	lily = {
		name = "Lily",
		role = "Merchant",
		personality = "Charming businesswoman with a keen eye for value and a silver tongue.",
		gift_preferences = {
			loved = {"gem", "valuable", "rare"},
			liked = {"craft", "jewelry"},
		},
		dialogues = {
			[0] = {
				"Welcome, welcome! Lily's Emporium has everything you need!",
				"First time here? Let me show you my finest wares.",
			},
			[1] = {
				"Ah, a returning customer! I like that.",
				"I just got a shipment from the eastern provinces.",
			},
			[2] = {
				"For you, a special discount! Don't tell anyone.",
				"You have excellent taste. I can see it in your eyes.",
			},
			[3] = {
				"Between us traders, I have some... special inventory.",
				"I've been saving this rare piece. Interested?",
			},
			[4] = {
				"You're more than a customer now. You're a business partner!",
				"I'll let you in on my trade routes. Very profitable.",
			},
			[5] = {
				"I closed the shop early just to spend time with you.",
				"Gold is valuable, but your friendship? Priceless.",
			},
			[6] = {
				"I've never shown anyone my personal gem collection.",
				"You've changed how I see the world. It's not all about profit.",
			},
			[7] = {
				"I found the rarest diamond. It reminded me of you.",
				"My ledgers used to be my life. Now there's something more.",
			},
			[8] = {
				"I'd trade my entire fortune for another day with you.",
				"You're the most precious thing I've ever found.",
			},
			[9] = {
				"Every gem pales in comparison to you.",
				"I want to build an empire... with you by my side.",
			},
			[10] = {
				"You are my greatest treasure, now and always.",
				"Forget gold and diamonds. All I need is you.",
			},
		},
		schedule = {
			[6]  = {x = 110, y = 10, z = 80},
			[8]  = {x = 115, y = 10, z = 75},  -- Shop
			[12] = {x = 110, y = 10, z = 80},
			[13] = {x = 115, y = 10, z = 75},
			[18] = {x = 110, y = 10, z = 80},
			[20] = {x = 110, y = 10, z = 80},
		},
		home_pos = {x = 110, y = 10, z = 80},
	},

	oliver = {
		name = "Oliver",
		role = "Fisherman",
		personality = "Laid-back storyteller who finds wisdom in the rhythm of the tides.",
		gift_preferences = {
			loved = {"fish", "seafood", "bait"},
			liked = {"boat", "rope", "food"},
		},
		dialogues = {
			[0] = {
				"Hey there! Name's Oliver. Care to fish a while?",
				"The river's generous today. Pull up a seat!",
			},
			[1] = {
				"Ah, you came back! The fish are biting today.",
				"Did I ever tell you about the one that got away?",
			},
			[2] = {
				"You're good company. Most folk don't appreciate silence.",
				"Here, try my lucky lure. It's never failed me. Well, mostly.",
			},
			[3] = {
				"I know a secret fishing spot. Wanna see it?",
				"My old man taught me that patience is its own reward.",
			},
			[4] = {
				"You fish like you've done it your whole life!",
				"The river tells stories if you listen. I'll teach you how.",
			},
			[5] = {
				"I caught the biggest trout today. It's yours.",
				"The best days are the ones spent on the water with friends.",
			},
			[6] = {
				"I only share my grandpa's secret bait recipe with true friends.",
				"You've got the soul of a fisherman. That's the highest compliment.",
			},
			[7] = {
				"I carved a fishing rod just for you. From driftwood.",
				"The river brought you to me. I'm certain of it.",
			},
			[8] = {
				"When I look at the sunset on the water, I think of you.",
				"You're the calm in every storm I've weathered.",
			},
			[9] = {
				"I'd sail to the edge of the world for you.",
				"Every ripple in the water whispers your name.",
			},
			[10] = {
				"You are my anchor, my compass, my shore.",
				"The ocean is vast, but my love for you is deeper.",
			},
		},
		schedule = {
			[5]  = {x = 90, y = 10, z = 120},  -- Early riser
			[6]  = {x = 85, y = 8, z = 140},    -- River
			[11] = {x = 90, y = 10, z = 120},
			[14] = {x = 85, y = 8, z = 140},
			[19] = {x = 90, y = 10, z = 120},
			[21] = {x = 90, y = 10, z = 120},
		},
		home_pos = {x = 90, y = 10, z = 120},
	},

	sarah = {
		name = "Sarah",
		role = "Doctor",
		personality = "Caring and wise healer who puts others before herself.",
		gift_preferences = {
			loved = {"medicine", "herb", "potion"},
			liked = {"book", "flower", "food"},
		},
		dialogues = {
			[0] = {
				"Hello, I'm Sarah, the village doctor. Are you feeling well?",
				"Let me know if you ever need medical attention.",
			},
			[1] = {
				"Good to see you healthy! Prevention is the best medicine.",
				"I've been studying a new herbal remedy. Fascinating results!",
			},
			[2] = {
				"You're looking well. Have you been eating properly?",
				"I could teach you some basic first aid if you'd like.",
			},
			[3] = {
				"I trust you. Here's my recipe for healing salve.",
				"Between us, I've discovered a rare medicinal mushroom nearby.",
			},
			[4] = {
				"You have a natural gift for caring about others.",
				"I've been thinking of expanding the clinic. Your thoughts?",
			},
			[5] = {
				"I made you a special health tonic. My own recipe.",
				"You're the reason I became a doctor — to help people like you.",
			},
			[6] = {
				"My grandmother's medical journal. I want you to have it.",
				"You understand the weight of what I do. That means everything.",
			},
			[7] = {
				"I picked these rare healing herbs. They reminded me of you.",
				"My heart rate increases when you visit. Doctor's diagnosis.",
			},
			[8] = {
				"I've cured many ailments, but I can't cure how I feel about you.",
				"You're the best medicine I've ever known.",
			},
			[9] = {
				"I'd give up everything to keep you safe and happy.",
				"In all my years of healing, you're the greatest miracle.",
			},
			[10] = {
				"My prescription for happiness: a lifetime with you.",
				"You healed the part of me I didn't know was broken.",
			},
		},
		schedule = {
			[6]  = {x = 95, y = 10, z = 85},
			[7]  = {x = 90, y = 10, z = 80},    -- Clinic
			[12] = {x = 95, y = 10, z = 85},
			[13] = {x = 90, y = 10, z = 80},
			[17] = {x = 95, y = 10, z = 85},
			[20] = {x = 95, y = 10, z = 85},
		},
		home_pos = {x = 95, y = 10, z = 85},
	},

	jack = {
		name = "Jack",
		role = "Carpenter",
		personality = "Hardworking craftsman who takes pride in building things that last.",
		gift_preferences = {
			loved = {"wood", "lumber", "plank"},
			liked = {"tool", "nail", "craft"},
		},
		dialogues = {
			[0] = {
				"Hey! Name's Jack. I build things. Need a house? A fence? A barn?",
				"Careful where you step — I just finished sanding these planks.",
			},
			[1] = {
				"Back for more? I just finished a new bookshelf design.",
				"Good timber is hard to find. Know any good spots?",
			},
			[2] = {
				"You've got a good eye for woodwork. I appreciate that.",
				"Here, try this hand plane. It'll change your life.",
			},
			[3] = {
				"I'm working on a secret project. Want a sneak peek?",
				"My father was a carpenter too. Runs in the family.",
			},
			[4] = {
				"You know, I could teach you joinery techniques.",
				"I've been thinking of building a community hall. Help me plan?",
			},
			[5] = {
				"I carved this figure for you. Took me three nights.",
				"The workshop feels empty when you're not around.",
			},
			[6] = {
				"Here's my grandfather's chisel set. Treat them well.",
				"You're the only person I'd trust with my finest tools.",
			},
			[7] = {
				"I built you a music box. It plays our favorite tune.",
				"Every joint I cut, every board I plane... it's for you now.",
			},
			[8] = {
				"I built a bench by the lake. For us. Just us.",
				"You've nailed yourself into my heart. Carpenter humor, sorry.",
			},
			[9] = {
				"I want to build us a home. Together. What do you say?",
				"You're the foundation everything in my life is built upon.",
			},
			[10] = {
				"Every beam, every nail — I build it all for our future.",
				"You are my masterpiece. The one thing I could never craft alone.",
			},
		},
		schedule = {
			[6]  = {x = 75, y = 10, z = 105},
			[7]  = {x = 65, y = 10, z = 100},   -- Workshop
			[12] = {x = 75, y = 10, z = 105},
			[13] = {x = 65, y = 10, z = 100},
			[18] = {x = 75, y = 10, z = 105},
			[20] = {x = 75, y = 10, z = 105},
		},
		home_pos = {x = 75, y = 10, z = 105},
	},

	maya = {
		name = "Maya",
		role = "Artist",
		personality = "Creative dreamer who sees beauty in everything and paints the world in color.",
		gift_preferences = {
			loved = {"flower", "dye", "painting"},
			liked = {"gem", "beautiful", "rare"},
		},
		dialogues = {
			[0] = {
				"Oh! Hi there! I'm Maya. Sorry, I was lost in thought.",
				"The light here is just perfect for painting. Don't you think?",
			},
			[1] = {
				"You came back! I was just sketching the sunset.",
				"Do you see how the clouds make shapes? That one looks like a dragon!",
			},
			[2] = {
				"I painted something and... I think it looks like you.",
				"Colors speak louder than words. Let me show you.",
			},
			[3] = {
				"I have a secret studio in the hills. Want to see it?",
				"You inspire me more than any landscape ever could.",
			},
			[4] = {
				"I'm working on my masterpiece. You're my muse, you know.",
				"Art is about feeling. And I feel... happy when you're here.",
			},
			[5] = {
				"I painted the village at dawn. This copy is for you.",
				"You make the whole world more colorful just by being in it.",
			},
			[6] = {
				"Here's my private sketchbook. No one else has ever seen it.",
				"You see the world the way I do. That's incredibly rare.",
			},
			[7] = {
				"I sculpted something for you. It's not perfect, but it's from my heart.",
				"Every color I mix reminds me of a moment with you.",
			},
			[8] = {
				"I dreamed I painted us among the stars. It was beautiful.",
				"You're the most beautiful thing I've ever seen. And I've seen a lot.",
			},
			[9] = {
				"My art means nothing without you to share it with.",
				"I want to paint every sunrise with you for the rest of my life.",
			},
			[10] = {
				"You are my art, my inspiration, my everything.",
				"Together, we'll create a masterpiece called our life.",
			},
		},
		schedule = {
			[7]  = {x = 105, y = 10, z = 110},
			[8]  = {x = 130, y = 15, z = 130},  -- Hills (painting)
			[12] = {x = 105, y = 10, z = 110},
			[14] = {x = 115, y = 10, z = 75},   -- Visit merchant
			[17] = {x = 130, y = 15, z = 130},  -- Evening painting
			[20] = {x = 105, y = 10, z = 110},
		},
		home_pos = {x = 105, y = 10, z = 110},
	},
}

---------------------------------------------------------------------------
-- 2. Relationship System
---------------------------------------------------------------------------

local function ensure_relationship(player_name, npc_name)
	if not mbr.npcs.relationships[player_name] then
		mbr.npcs.relationships[player_name] = {}
	end
	if not mbr.npcs.relationships[player_name][npc_name] then
		mbr.npcs.relationships[player_name][npc_name] = {
			hearts = 0,
			total_gifts = 0,
		}
	end
	return mbr.npcs.relationships[player_name][npc_name]
end

function mbr.npcs.get_hearts(player_name, npc_name)
	local rel = ensure_relationship(player_name, npc_name)
	return rel.hearts
end

function mbr.npcs.add_hearts(player_name, npc_name, amount)
	local rel = ensure_relationship(player_name, npc_name)
	rel.hearts = clamp(rel.hearts + amount, 0, 10)
	return rel.hearts
end

---------------------------------------------------------------------------
-- 3. Chat Bubble System
---------------------------------------------------------------------------

function mbr.npcs.show_bubble(player, npc_name, text)
	local player_name = player:get_player_name()
	if not bubble_huds[player_name] then
		bubble_huds[player_name] = {}
	end

	-- Remove existing bubble for this NPC if present
	if bubble_huds[player_name][npc_name] then
		player:hud_remove(bubble_huds[player_name][npc_name])
		bubble_huds[player_name][npc_name] = nil
	end

	local def = mbr.npcs.definitions[npc_name]
	local display_name = def and def.name or npc_name
	local bubble_text = display_name .. ": " .. text

	local hud_id = player:hud_add({
		type = "text",
		position = {x = 0.5, y = 0.2},
		offset = {x = 0, y = 0},
		text = bubble_text,
		alignment = {x = 0, y = 0},
		scale = {x = 100, y = 100},
		number = 0xFFFFAA,
	})

	bubble_huds[player_name][npc_name] = hud_id

	-- Auto-remove after 4 seconds
	core.after(4, function()
		local p = core.get_player_by_name(player_name)
		if p and bubble_huds[player_name] and bubble_huds[player_name][npc_name] == hud_id then
			p:hud_remove(hud_id)
			bubble_huds[player_name][npc_name] = nil
		end
	end)
end

---------------------------------------------------------------------------
-- 4. Gift System
---------------------------------------------------------------------------

local function item_matches_category(itemname, categories)
	local lower = itemname:lower()
	for _, cat in ipairs(categories) do
		if lower:find(cat) then
			return true
		end
	end
	return false
end

function mbr.npcs.give_gift(player, npc_name, itemstack)
	local player_name = player:get_player_name()
	local def = mbr.npcs.definitions[npc_name]
	if not def then
		return false, "Unknown NPC."
	end

	if itemstack:is_empty() then
		return false, "You must hold an item to give as a gift."
	end

	local itemname = itemstack:get_name()
	local rel = ensure_relationship(player_name, npc_name)
	local heart_gain = 0.5  -- neutral default
	local reaction = ""

	if def.gift_preferences then
		if def.gift_preferences.loved and item_matches_category(itemname, def.gift_preferences.loved) then
			heart_gain = 2
			reaction = "I love this! Thank you so much!"
		elseif def.gift_preferences.liked and item_matches_category(itemname, def.gift_preferences.liked) then
			heart_gain = 1
			reaction = "Oh, that's nice! Thank you."
		else
			reaction = "Thanks, I suppose."
		end
	else
		reaction = "That's thoughtful of you."
	end

	mbr.npcs.add_hearts(player_name, npc_name, heart_gain)
	rel.total_gifts = rel.total_gifts + 1

	-- Remove 1 item from player
	itemstack:take_item(1)
	player:set_wielded_item(itemstack)

	mbr.npcs.show_bubble(player, npc_name, reaction)
	return true
end

---------------------------------------------------------------------------
-- 5. Dialogue System
---------------------------------------------------------------------------

local DIALOGUE_LEVEL_MAX = 10
local DIALOGUE_LEVEL_HIGH = 7
local DIALOGUE_LEVEL_MID = 4
local DIALOGUE_LEVEL_MIN = 0

local function get_dialogue_level(hearts)
	if hearts >= DIALOGUE_LEVEL_MAX then return DIALOGUE_LEVEL_MAX end
	if hearts >= DIALOGUE_LEVEL_HIGH then return DIALOGUE_LEVEL_HIGH end
	if hearts >= DIALOGUE_LEVEL_MID then return DIALOGUE_LEVEL_MID end
	return DIALOGUE_LEVEL_MIN
end

local function get_dialogue_text(npc_name, hearts)
	local def = mbr.npcs.definitions[npc_name]
	if not def or not def.dialogues then
		return "..."
	end

	local level = get_dialogue_level(hearts)

	-- Search for closest available dialogue level at or below computed level
	local best_level = 0
	for dlevel, _ in pairs(def.dialogues) do
		if dlevel <= level and dlevel > best_level then
			best_level = dlevel
		end
	end

	local lines = def.dialogues[best_level]
	if lines and #lines > 0 then
		return lines[math.random(#lines)]
	end
	return "..."
end

function mbr.npcs.start_dialogue(player, npc_name)
	local player_name = player:get_player_name()
	local def = mbr.npcs.definitions[npc_name]
	if not def then return end

	local hearts = mbr.npcs.get_hearts(player_name, npc_name)
	local text = get_dialogue_text(npc_name, hearts)
	local heart_display = ""
	for i = 1, 10 do
		if i <= math.floor(hearts) then
			heart_display = heart_display .. "♥"
		else
			heart_display = heart_display .. "♡"
		end
	end

	local fs = "formspec_version[6]"
		.. "size[10,8]"
		.. "bgcolor[#00000088;true]"

		-- NPC portrait area
		.. "box[0.5,0.5;2.5,3;#44444488]"
		.. "label[1.2,1.5;" .. core.formspec_escape(def.name) .. "]"
		.. "label[1.0,2.0;" .. core.formspec_escape(def.role) .. "]"
		.. "label[0.7,2.8;" .. core.formspec_escape(heart_display) .. "]"

		-- Dialogue text
		.. "box[3.5,0.5;6,3;#33333388]"
		.. "textarea[3.7,0.7;5.6,2.6;;;" .. core.formspec_escape(text) .. "]"

		-- Response buttons
		.. "button[0.5,4.2;4,0.8;btn_chat;Chat More]"
		.. "button[5.5,4.2;4,0.8;btn_gift;Give Gift]"

	if hearts >= 10 then
		fs = fs .. "button[0.5,5.3;4,0.8;btn_propose;Propose ♥]"
	end

	if hearts >= 4 then
		fs = fs .. "button[5.5,5.3;4,0.8;btn_hint;Ask for Hint]"
	end

	fs = fs .. "button[0.5,6.8;9,0.8;btn_close;Goodbye]"

	-- Store current NPC context for the player
	if not mbr.npcs.spawned[player_name] then
		mbr.npcs.spawned[player_name] = {}
	end
	mbr.npcs.spawned[player_name].talking_to = npc_name

	core.show_formspec(player_name, "mbr:npc_dialogue", fs)
end

---------------------------------------------------------------------------
-- 6. Formspec Handler
---------------------------------------------------------------------------

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "mbr:npc_dialogue" then return false end

	local player_name = player:get_player_name()
	local context = mbr.npcs.spawned[player_name]
	if not context or not context.talking_to then return true end

	local npc_name = context.talking_to

	if fields.btn_close or fields.quit then
		context.talking_to = nil
		return true
	end

	if fields.btn_chat then
		mbr.npcs.start_dialogue(player, npc_name)
		return true
	end

	if fields.btn_gift then
		local wielded = player:get_wielded_item()
		if wielded:is_empty() then
			mbr.npcs.show_bubble(player, npc_name, "You don't seem to be holding anything.")
			core.close_formspec(player_name, "mbr:npc_dialogue")
		else
			mbr.npcs.give_gift(player, npc_name, wielded)
			-- Refresh dialogue to show updated hearts
			mbr.npcs.start_dialogue(player, npc_name)
		end
		return true
	end

	if fields.btn_hint then
		local def = mbr.npcs.definitions[npc_name]
		if def and def.gift_preferences and def.gift_preferences.loved then
			local hint = "I really love things related to: " .. table.concat(def.gift_preferences.loved, ", ")
			mbr.npcs.show_bubble(player, npc_name, hint)
		end
		core.close_formspec(player_name, "mbr:npc_dialogue")
		return true
	end

	if fields.btn_propose then
		-- Delegate to marriage system if available
		if mbr.marriage and mbr.marriage.propose then
			mbr.marriage.propose(player, npc_name)
		else
			mbr.npcs.show_bubble(player, npc_name, "I'm flattered, but the time isn't right yet.")
		end
		core.close_formspec(player_name, "mbr:npc_dialogue")
		return true
	end

	return true
end)

---------------------------------------------------------------------------
-- 7. NPC Schedule System (globalstep every 30 seconds)
---------------------------------------------------------------------------

core.register_globalstep(function(dtime)
	schedule_timer = schedule_timer + dtime
	if schedule_timer < 30 then return end
	schedule_timer = 0

	local current_hour = mbr.time.hour or 12

	for npc_id, def in pairs(mbr.npcs.definitions) do
		-- Find the best matching schedule entry for the current hour
		local best_hour = nil
		for sched_hour, _ in pairs(def.schedule) do
			if sched_hour <= current_hour then
				if not best_hour or sched_hour > best_hour then
					best_hour = sched_hour
				end
			end
		end

		if best_hour then
			mbr.npcs.schedules[npc_id] = {
				target_pos = def.schedule[best_hour],
				current_hour = current_hour,
			}
		end
	end
end)

---------------------------------------------------------------------------
-- 8. Chat Command: /npc_status
---------------------------------------------------------------------------

core.register_chatcommand("npc_status", {
	description = "Show your relationship levels with all NPCs",
	func = function(player_name, param)
		local lines = {"=== NPC Relationships ==="}
		for npc_id, def in pairs(mbr.npcs.definitions) do
			local hearts = mbr.npcs.get_hearts(player_name, npc_id)
			local heart_bar = ""
			for i = 1, 10 do
				if i <= math.floor(hearts) then
					heart_bar = heart_bar .. "♥"
				else
					heart_bar = heart_bar .. "♡"
				end
			end
			local rel = ensure_relationship(player_name, npc_id)
			table.insert(lines, string.format("%s (%s): %s (%.1f/10) | Gifts: %d",
				def.name, def.role, heart_bar, hearts, rel.total_gifts))
		end
		return true, table.concat(lines, "\n")
	end,
})

---------------------------------------------------------------------------
-- 9. Player cleanup
---------------------------------------------------------------------------

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	bubble_huds[name] = nil
	if mbr.npcs.spawned[name] then
		mbr.npcs.spawned[name] = nil
	end
end)
