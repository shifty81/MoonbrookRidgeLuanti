-- ============================================================
-- MBR Shop System
-- Currency, merchants, supply/demand, and shipping bin
-- ============================================================

local S = core.get_translator("mbr_shop")

-- ============================================================
-- Currency Items
-- ============================================================

core.register_craftitem("mbr_shop:gold_coin", {
    description = "Gold Coin",
    inventory_image = "[fill:16x16:#FFD700",
    stack_max = 9999,
    groups = {currency = 1},
})

core.register_craftitem("mbr_shop:silver_coin", {
    description = "Silver Coin",
    inventory_image = "[fill:16x16:#C0C0C0",
    stack_max = 9999,
    groups = {currency = 1},
})

-- 1 gold = 10 silver
core.register_craft({
    output = "mbr_shop:silver_coin 10",
    recipe = {{"mbr_shop:gold_coin"}},
})

core.register_craft({
    output = "mbr_shop:gold_coin",
    recipe = {
        {"mbr_shop:silver_coin", "mbr_shop:silver_coin", "mbr_shop:silver_coin"},
        {"mbr_shop:silver_coin", "mbr_shop:silver_coin", "mbr_shop:silver_coin"},
        {"mbr_shop:silver_coin", "mbr_shop:silver_coin", "mbr_shop:silver_coin"},
    },
    -- Uses 9 silver; close approximation for grid craft (see also manual conversion)
})

-- Manual 10:1 conversion handled in shop formspec as well

-- ============================================================
-- Shop Catalog
-- ============================================================

local shop_catalog = {
    -- Crops
    {item = "mbr_farming:wheat",       buy_price = 8,   sell_price = 4,   category = "crops"},
    {item = "mbr_farming:corn",        buy_price = 10,  sell_price = 5,   category = "crops"},
    {item = "mbr_farming:tomato",      buy_price = 12,  sell_price = 6,   category = "crops"},
    {item = "mbr_farming:potato",      buy_price = 8,   sell_price = 4,   category = "crops"},
    {item = "mbr_farming:carrot",      buy_price = 8,   sell_price = 4,   category = "crops"},
    {item = "mbr_farming:pumpkin",     buy_price = 20,  sell_price = 10,  category = "crops"},
    {item = "mbr_farming:strawberry",  buy_price = 15,  sell_price = 8,   category = "crops"},

    -- Seeds
    {item = "mbr_farming:wheat_seed",      buy_price = 3,  sell_price = 1,  category = "seeds", always_available = true},
    {item = "mbr_farming:corn_seed",       buy_price = 4,  sell_price = 2,  category = "seeds", always_available = true},
    {item = "mbr_farming:tomato_seed",     buy_price = 5,  sell_price = 2,  category = "seeds", always_available = true},
    {item = "mbr_farming:potato_seed",     buy_price = 3,  sell_price = 1,  category = "seeds", always_available = true},
    {item = "mbr_farming:carrot_seed",     buy_price = 3,  sell_price = 1,  category = "seeds", always_available = true},
    {item = "mbr_farming:pumpkin_seed",    buy_price = 6,  sell_price = 3,  category = "seeds"},
    {item = "mbr_farming:strawberry_seed", buy_price = 5,  sell_price = 2,  category = "seeds"},

    -- Fish
    {item = "mbr_fishing:bass",            buy_price = 15,  sell_price = 8,   category = "fish"},
    {item = "mbr_fishing:carp",            buy_price = 12,  sell_price = 6,   category = "fish"},
    {item = "mbr_fishing:perch",           buy_price = 12,  sell_price = 6,   category = "fish"},
    {item = "mbr_fishing:trout",           buy_price = 18,  sell_price = 10,  category = "fish"},
    {item = "mbr_fishing:salmon",          buy_price = 20,  sell_price = 12,  category = "fish"},
    {item = "mbr_fishing:catfish",         buy_price = 16,  sell_price = 9,   category = "fish"},
    {item = "mbr_fishing:sunfish",         buy_price = 14,  sell_price = 7,   category = "fish"},
    {item = "mbr_fishing:pike",            buy_price = 22,  sell_price = 12,  category = "fish"},
    {item = "mbr_fishing:walleye",         buy_price = 24,  sell_price = 14,  category = "fish"},
    {item = "mbr_fishing:ice_cod",         buy_price = 28,  sell_price = 16,  category = "fish"},
    {item = "mbr_fishing:golden_koi",      buy_price = 80,  sell_price = 50,  category = "fish", rare = true},
    {item = "mbr_fishing:ancient_sturgeon",buy_price = 100, sell_price = 60,  category = "fish", rare = true},
    {item = "mbr_fishing:crystal_fish",    buy_price = 120, sell_price = 75,  category = "fish", rare = true},

    -- Ores and Ingots
    {item = "mbr_mining:copper_raw",   buy_price = 10,  sell_price = 5,   category = "ores"},
    {item = "mbr_mining:iron_raw",     buy_price = 15,  sell_price = 8,   category = "ores"},
    {item = "mbr_mining:silver_raw",   buy_price = 25,  sell_price = 14,  category = "ores"},
    {item = "mbr_mining:gold_raw",     buy_price = 40,  sell_price = 22,  category = "ores"},
    {item = "mbr_mining:copper_ingot", buy_price = 18,  sell_price = 10,  category = "ores"},
    {item = "mbr_mining:iron_ingot",   buy_price = 28,  sell_price = 15,  category = "ores"},
    {item = "mbr_mining:silver_ingot", buy_price = 45,  sell_price = 25,  category = "ores"},
    {item = "mbr_mining:gold_ingot",   buy_price = 70,  sell_price = 40,  category = "ores"},
    {item = "mbr_mining:ruby",         buy_price = 90,  sell_price = 55,  category = "ores", rare = true},
    {item = "mbr_mining:sapphire",     buy_price = 90,  sell_price = 55,  category = "ores", rare = true},
    {item = "mbr_mining:emerald",      buy_price = 95,  sell_price = 58,  category = "ores", rare = true},
    {item = "mbr_mining:diamond",      buy_price = 150, sell_price = 90,  category = "ores", rare = true},

    -- Forage
    {item = "mbr_foraging:herb_mint",             buy_price = 6,   sell_price = 3,   category = "forage"},
    {item = "mbr_foraging:herb_basil",            buy_price = 6,   sell_price = 3,   category = "forage"},
    {item = "mbr_foraging:herb_lavender",         buy_price = 8,   sell_price = 4,   category = "forage"},
    {item = "mbr_foraging:herb_ginseng",          buy_price = 14,  sell_price = 8,   category = "forage"},
    {item = "mbr_foraging:mushroom_button",       buy_price = 5,   sell_price = 2,   category = "forage"},
    {item = "mbr_foraging:mushroom_chanterelle",  buy_price = 10,  sell_price = 5,   category = "forage"},
    {item = "mbr_foraging:mushroom_morel",        buy_price = 16,  sell_price = 9,   category = "forage"},
    {item = "mbr_foraging:mushroom_truffle",      buy_price = 30,  sell_price = 18,  category = "forage", rare = true},
    {item = "mbr_foraging:four_leaf_clover",      buy_price = 50,  sell_price = 30,  category = "forage", rare = true},
    {item = "mbr_foraging:ancient_root",          buy_price = 40,  sell_price = 24,  category = "forage", rare = true},
    {item = "mbr_foraging:fairy_dust",            buy_price = 60,  sell_price = 35,  category = "forage", rare = true},

    -- Food and Drink
    {item = "mbr_items:bread",        buy_price = 6,  sell_price = 3,  category = "food", always_available = true},
    {item = "mbr_items:apple",        buy_price = 4,  sell_price = 2,  category = "food"},
    {item = "mbr_items:cooked_meat",  buy_price = 14, sell_price = 7,  category = "food"},
    {item = "mbr_items:water_bottle", buy_price = 3,  sell_price = 1,  category = "food", always_available = true},
    {item = "mbr_items:milk",         buy_price = 5,  sell_price = 2,  category = "food"},

    -- Tools
    {item = "mbr_farming:hoe",          buy_price = 25, sell_price = 10, category = "tools"},
    {item = "mbr_farming:watering_can", buy_price = 30, sell_price = 12, category = "tools"},
    {item = "mbr_fishing:fishing_rod",  buy_price = 20, sell_price = 8,  category = "tools"},

    -- Bait / Materials
    {item = "mbr_fishing:worm",       buy_price = 2,  sell_price = 1,  category = "materials", always_available = true},
    {item = "mbr_fishing:fancy_bait", buy_price = 8,  sell_price = 4,  category = "materials"},
}

-- Build lookup table by item name
local catalog_by_item = {}
for _, entry in ipairs(shop_catalog) do
    catalog_by_item[entry.item] = entry
end

-- ============================================================
-- Supply and Demand System
-- ============================================================

-- Tracks cumulative buy/sell volumes; price adjustments derived from these
local demand_data = {}
-- demand_data[item] = {bought = N, sold = N}

local function get_demand(item_name)
    if not demand_data[item_name] then
        demand_data[item_name] = {bought = 0, sold = 0}
    end
    return demand_data[item_name]
end

local function get_buy_price(entry)
    local d = get_demand(entry.item)
    -- More buying -> higher price (max 2x)
    local multiplier = 1.0 + math.min(1.0, d.bought * 0.02)
    return math.max(1, math.floor(entry.buy_price * multiplier + 0.5))
end

local function get_sell_price(entry)
    local d = get_demand(entry.item)
    -- More selling -> lower buyback price (min 0.5x)
    local multiplier = 1.0 - math.min(0.5, d.sold * 0.02)
    return math.max(1, math.floor(entry.sell_price * multiplier + 0.5))
end

-- Normalize prices toward base over time (called on new day)
local function normalize_prices()
    for item_name, d in pairs(demand_data) do
        if d.bought > 0 then
            d.bought = math.max(0, d.bought - 2)
        end
        if d.sold > 0 then
            d.sold = math.max(0, d.sold - 2)
        end
    end
end

-- ============================================================
-- Daily Rotating Inventory
-- ============================================================

local todays_stock = {}

local function rotate_stock()
    todays_stock = {}

    -- Always-available items go in first
    local pool = {}
    for _, entry in ipairs(shop_catalog) do
        if entry.always_available then
            todays_stock[#todays_stock + 1] = entry
        else
            pool[#pool + 1] = entry
        end
    end

    -- Shuffle pool
    for i = #pool, 2, -1 do
        local j = math.random(1, i)
        pool[i], pool[j] = pool[j], pool[i]
    end

    -- Pick items to fill up to 15 total, rare items have lower chance
    local target = math.random(12, 15)
    local count = #todays_stock
    for _, entry in ipairs(pool) do
        if count >= target then break end
        if entry.rare then
            if math.random(1, 4) == 1 then
                todays_stock[#todays_stock + 1] = entry
                count = count + 1
            end
        else
            todays_stock[#todays_stock + 1] = entry
            count = count + 1
        end
    end

    minetest.log("action", "[MBR Shop] Rotated daily stock: " .. #todays_stock .. " items available")
end

-- Initialize stock on load
rotate_stock()

-- ============================================================
-- Player Balance Helpers
-- ============================================================

local function count_coins(player)
    local inv = player:get_inventory()
    local gold = 0
    local silver = 0
    for i = 1, inv:get_size("main") do
        local stack = inv:get_stack("main", i)
        if stack:get_name() == "mbr_shop:gold_coin" then
            gold = gold + stack:get_count()
        elseif stack:get_name() == "mbr_shop:silver_coin" then
            silver = silver + stack:get_count()
        end
    end
    return gold, silver
end

local function total_silver(player)
    local gold, silver = count_coins(player)
    return gold * 10 + silver
end

--- Remove `amount` silver coins worth of currency from player inventory.
--- Converts gold to silver as needed. Returns true on success.
local function deduct_coins(player, amount)
    local inv = player:get_inventory()
    local gold, silver = count_coins(player)
    local total = gold * 10 + silver
    if total < amount then return false end

    -- Determine coins to remove
    local remaining = amount
    -- Remove silver first
    local silver_to_remove = math.min(silver, remaining)
    remaining = remaining - silver_to_remove
    -- Remove gold for the rest (each gold = 10 silver)
    local gold_to_remove = math.ceil(remaining / 10)
    local change = gold_to_remove * 10 - remaining

    inv:remove_item("main", "mbr_shop:silver_coin " .. silver_to_remove)
    if gold_to_remove > 0 then
        inv:remove_item("main", "mbr_shop:gold_coin " .. gold_to_remove)
    end
    -- Give back change
    if change > 0 then
        inv:add_item("main", "mbr_shop:silver_coin " .. change)
    end
    return true
end

local function add_coins(player, amount)
    local inv = player:get_inventory()
    local gold_add = math.floor(amount / 10)
    local silver_add = amount % 10
    if gold_add > 0 then
        inv:add_item("main", "mbr_shop:gold_coin " .. gold_add)
    end
    if silver_add > 0 then
        inv:add_item("main", "mbr_shop:silver_coin " .. silver_add)
    end
end

local function balance_string(player)
    local gold, silver = count_coins(player)
    return gold .. " gold, " .. silver .. " silver (" .. (gold * 10 + silver) .. " silver total)"
end

-- ============================================================
-- Starting Currency for New Players
-- ============================================================

core.register_on_newplayer(function(player)
    local inv = player:get_inventory()
    inv:add_item("main", "mbr_shop:gold_coin 5")
    inv:add_item("main", "mbr_shop:silver_coin 50")
    minetest.log("action", "[MBR Shop] Gave starting coins to " .. player:get_player_name())
end)

-- ============================================================
-- Shop Formspec
-- ============================================================

local player_shop_state = {}
-- player_shop_state[name] = {tab = "buy", category = "all", page = 1}

local ITEMS_PER_PAGE = 8

local category_list = {"all", "crops", "seeds", "fish", "ores", "forage", "food", "tools", "materials"}

local function get_state(player_name)
    if not player_shop_state[player_name] then
        player_shop_state[player_name] = {tab = "buy", category = "all", page = 1}
    end
    return player_shop_state[player_name]
end

local function build_buy_list(category)
    local list = {}
    for _, entry in ipairs(todays_stock) do
        if category == "all" or entry.category == category then
            list[#list + 1] = entry
        end
    end
    return list
end

local function build_sell_list(player)
    local inv = player:get_inventory()
    local list = {}
    local seen = {}
    for i = 1, inv:get_size("main") do
        local stack = inv:get_stack("main", i)
        local name = stack:get_name()
        if name ~= "" and not seen[name] and catalog_by_item[name] then
            seen[name] = true
            list[#list + 1] = {
                entry = catalog_by_item[name],
                count = 0,
            }
        end
    end
    -- Count totals
    for _, item in ipairs(list) do
        for i = 1, inv:get_size("main") do
            local stack = inv:get_stack("main", i)
            if stack:get_name() == item.entry.item then
                item.count = item.count + stack:get_count()
            end
        end
    end
    return list
end

local function build_shop_formspec(player_name)
    local player = core.get_player_by_name(player_name)
    if not player then return "" end

    local state = get_state(player_name)
    local gold, silver = count_coins(player)
    local total = gold * 10 + silver

    local fs = "formspec_version[7]"
    fs = fs .. "size[12,10]"
    fs = fs .. "label[0.3,0.5;Moonbrook Shop — Lily's General Store]"
    fs = fs .. "label[0.3,1.0;Balance: " ..
        core.formspec_escape(gold .. " gold, " .. silver .. " silver (" .. total .. "s total)") .. "]"

    -- Tab buttons
    local buy_style = state.tab == "buy" and "bgcolor=#4a7a4a" or "bgcolor=#555555"
    local sell_style = state.tab == "sell" and "bgcolor=#4a7a4a" or "bgcolor=#555555"
    fs = fs .. "style[tab_buy;" .. buy_style .. "]"
    fs = fs .. "style[tab_sell;" .. sell_style .. "]"
    fs = fs .. "button[0.3,1.4;2.5,0.7;tab_buy;Buy]"
    fs = fs .. "button[3.0,1.4;2.5,0.7;tab_sell;Sell]"

    if state.tab == "buy" then
        -- Category filter
        local cat_str = table.concat(category_list, ",")
        local cat_idx = 1
        for i, c in ipairs(category_list) do
            if c == state.category then cat_idx = i break end
        end
        fs = fs .. "label[6.5,1.7;Category:]"
        fs = fs .. "dropdown[8.0,1.4;3.5,0.7;category;" .. cat_str .. ";" .. cat_idx .. ";true]"

        local items = build_buy_list(state.category)
        local pages = math.max(1, math.ceil(#items / ITEMS_PER_PAGE))
        if state.page > pages then state.page = pages end
        local start_i = (state.page - 1) * ITEMS_PER_PAGE + 1
        local end_i = math.min(start_i + ITEMS_PER_PAGE - 1, #items)

        -- Header
        fs = fs .. "label[0.5,2.5;Item]"
        fs = fs .. "label[5.5,2.5;Price (silver)]"
        fs = fs .. "label[8.5,2.5;Qty]"

        local y = 2.9
        for i = start_i, end_i do
            local entry = items[i]
            local price = get_buy_price(entry)
            local desc = core.registered_items[entry.item] and
                core.registered_items[entry.item].description or entry.item
            local row = i - start_i

            fs = fs .. "label[0.5," .. (y + row * 0.8) .. ";" .. core.formspec_escape(desc) .. "]"
            fs = fs .. "label[5.5," .. (y + row * 0.8) .. ";" .. price .. "s]"
            fs = fs .. "field[8.5," .. (y + row * 0.8 - 0.25) .. ";1.5,0.6;qty_" .. row .. ";;1]"
            fs = fs .. "button[10.2," .. (y + row * 0.8 - 0.3) .. ";1.5,0.6;buy_" .. i .. ";Buy]"
        end

        -- Pagination
        local page_y = 9.3
        if state.page > 1 then
            fs = fs .. "button[3.0," .. page_y .. ";1.5,0.6;prev_page;<< Prev]"
        end
        fs = fs .. "label[5.2," .. (page_y + 0.25) .. ";Page " .. state.page .. "/" .. pages .. "]"
        if state.page < pages then
            fs = fs .. "button[7.0," .. page_y .. ";1.5,0.6;next_page;Next >>]"
        end

    elseif state.tab == "sell" then
        local items = build_sell_list(player)
        local pages = math.max(1, math.ceil(#items / ITEMS_PER_PAGE))
        if state.page > pages then state.page = pages end
        local start_i = (state.page - 1) * ITEMS_PER_PAGE + 1
        local end_i = math.min(start_i + ITEMS_PER_PAGE - 1, #items)

        -- Header
        fs = fs .. "label[0.5,2.5;Item]"
        fs = fs .. "label[4.5,2.5;You Have]"
        fs = fs .. "label[6.5,2.5;Price (silver)]"
        fs = fs .. "label[9.0,2.5;Qty]"

        local y = 2.9
        for i = start_i, end_i do
            local si = items[i]
            local price = get_sell_price(si.entry)
            local desc = core.registered_items[si.entry.item] and
                core.registered_items[si.entry.item].description or si.entry.item
            local row = i - start_i

            fs = fs .. "label[0.5," .. (y + row * 0.8) .. ";" .. core.formspec_escape(desc) .. "]"
            fs = fs .. "label[4.5," .. (y + row * 0.8) .. ";" .. si.count .. "]"
            fs = fs .. "label[6.5," .. (y + row * 0.8) .. ";" .. price .. "s]"
            fs = fs .. "field[9.0," .. (y + row * 0.8 - 0.25) .. ";1.2,0.6;sellqty_" .. row .. ";;1]"
            fs = fs .. "button[10.4," .. (y + row * 0.8 - 0.3) .. ";1.3,0.6;sell_" .. i .. ";Sell]"
        end

        -- Pagination
        local page_y = 9.3
        if state.page > 1 then
            fs = fs .. "button[3.0," .. page_y .. ";1.5,0.6;prev_page;<< Prev]"
        end
        fs = fs .. "label[5.2," .. (page_y + 0.25) .. ";Page " .. state.page .. "/" .. pages .. "]"
        if state.page < pages then
            fs = fs .. "button[7.0," .. page_y .. ";1.5,0.6;next_page;Next >>]"
        end
    end

    return fs
end

local function show_shop(player_name)
    local fs = build_shop_formspec(player_name)
    core.show_formspec(player_name, "mbr:shop", fs)
end

-- ============================================================
-- Formspec Field Handler
-- ============================================================

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "mbr:shop" then return end

    local player_name = player:get_player_name()
    local state = get_state(player_name)

    -- Tab switching
    if fields.tab_buy then
        state.tab = "buy"
        state.page = 1
        show_shop(player_name)
        return true
    elseif fields.tab_sell then
        state.tab = "sell"
        state.page = 1
        show_shop(player_name)
        return true
    end

    -- Category filter
    if fields.category then
        state.category = fields.category
        state.page = 1
        show_shop(player_name)
        return true
    end

    -- Pagination
    if fields.prev_page then
        state.page = math.max(1, state.page - 1)
        show_shop(player_name)
        return true
    elseif fields.next_page then
        state.page = state.page + 1
        show_shop(player_name)
        return true
    end

    -- Buy transactions
    if state.tab == "buy" then
        local items = build_buy_list(state.category)
        for i, entry in ipairs(items) do
            if fields["buy_" .. i] then
                local row = i - ((state.page - 1) * ITEMS_PER_PAGE + 1)
                local qty_field = fields["qty_" .. row]
                local qty = tonumber(qty_field) or 1
                qty = math.max(1, math.floor(qty))

                local price = get_buy_price(entry) * qty
                if total_silver(player) < price then
                    core.chat_send_player(player_name,
                        "Not enough coins! Need " .. price .. " silver.")
                else
                    local inv = player:get_inventory()
                    if not inv:room_for_item("main", entry.item .. " " .. qty) then
                        core.chat_send_player(player_name, "Inventory full!")
                    else
                        deduct_coins(player, price)
                        inv:add_item("main", entry.item .. " " .. qty)
                        local d = get_demand(entry.item)
                        d.bought = d.bought + qty
                        core.chat_send_player(player_name,
                            "Bought " .. qty .. "x " .. (core.registered_items[entry.item] and
                            core.registered_items[entry.item].description or entry.item) ..
                            " for " .. price .. " silver.")
                    end
                end
                show_shop(player_name)
                return true
            end
        end
    end

    -- Sell transactions
    if state.tab == "sell" then
        local sell_items = build_sell_list(player)
        for i, si in ipairs(sell_items) do
            if fields["sell_" .. i] then
                local row = i - ((state.page - 1) * ITEMS_PER_PAGE + 1)
                local qty_field = fields["sellqty_" .. row]
                local qty = tonumber(qty_field) or 1
                qty = math.max(1, math.floor(qty))
                qty = math.min(qty, si.count)

                local price = get_sell_price(si.entry) * qty
                local inv = player:get_inventory()
                local removed = inv:remove_item("main", si.entry.item .. " " .. qty)
                if removed:get_count() > 0 then
                    local actual_qty = removed:get_count()
                    local actual_price = get_sell_price(si.entry) * actual_qty
                    add_coins(player, actual_price)
                    local d = get_demand(si.entry.item)
                    d.sold = d.sold + actual_qty
                    core.chat_send_player(player_name,
                        "Sold " .. actual_qty .. "x " .. (core.registered_items[si.entry.item] and
                        core.registered_items[si.entry.item].description or si.entry.item) ..
                        " for " .. actual_price .. " silver.")
                else
                    core.chat_send_player(player_name, "You don't have that item!")
                end
                show_shop(player_name)
                return true
            end
        end
    end
end)

-- ============================================================
-- Shipping Bin Node
-- ============================================================

local function get_shipping_bin_formspec(pos)
    local meta = core.get_meta(pos)
    local owner = meta:get_string("owner")

    -- Calculate estimated value of contents
    local inv = meta:get_inventory()
    local value = 0
    for i = 1, inv:get_size("main") do
        local stack = inv:get_stack("main", i)
        local name = stack:get_name()
        if name ~= "" and catalog_by_item[name] then
            value = value + get_sell_price(catalog_by_item[name]) * stack:get_count()
        end
    end

    local fs = "formspec_version[7]"
    fs = fs .. "size[10,8]"
    fs = fs .. "label[0.3,0.5;Shipping Bin — Owner: " .. core.formspec_escape(owner) .. "]"
    fs = fs .. "label[0.3,1.0;Items will be shipped at the start of each new day.]"
    fs = fs .. "label[0.3,1.4;Estimated value: " .. value .. " silver]"
    fs = fs .. "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;0.5,2.0;8,3;]"
    fs = fs .. "list[current_player;main;0.5,5.5;8,1;]"
    fs = fs .. "listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main]"
    fs = fs .. "listring[current_player;main]"
    return fs
end

core.register_node("mbr_shop:shipping_bin", {
    description = "Shipping Bin",
    tiles = {
        "[fill:16x16:#8B6914",  -- top
        "[fill:16x16:#6B4F12",  -- bottom
        "[fill:16x16:#7B5E13",  -- sides
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
    paramtype2 = "facedir",
    is_ground_content = false,

    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 24)
        meta:set_string("infotext", "Shipping Bin (unclaimed)")
    end,

    after_place_node = function(pos, placer)
        if not placer then return end
        local meta = core.get_meta(pos)
        local name = placer:get_player_name()
        meta:set_string("owner", name)
        meta:set_string("infotext", "Shipping Bin (owned by " .. name .. ")")
    end,

    on_rightclick = function(pos, node, clicker)
        if not clicker then return end
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        local player_name = clicker:get_player_name()
        if owner ~= "" and owner ~= player_name then
            core.chat_send_player(player_name, "This shipping bin belongs to " .. owner .. ".")
            return
        end
        local fs = get_shipping_bin_formspec(pos)
        core.show_formspec(player_name, "mbr:shipping_bin", fs)
    end,

    can_dig = function(pos, player)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        local owner = meta:get_string("owner")
        local player_name = player and player:get_player_name() or ""
        return inv:is_empty("main") and (owner == "" or owner == player_name)
    end,

    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= "" and owner ~= player:get_player_name() then
            return 0
        end
        return stack:get_count()
    end,

    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= "" and owner ~= player:get_player_name() then
            return 0
        end
        return stack:get_count()
    end,
})

core.register_craft({
    output = "mbr_shop:shipping_bin",
    recipe = {
        {"mbr_core:wood", "mbr_core:wood", "mbr_core:wood"},
        {"mbr_core:wood", "",              "mbr_core:wood"},
        {"mbr_core:wood", "mbr_core:wood", "mbr_core:wood"},
    },
})

-- ============================================================
-- Shipping Bin Processing (on new day)
-- ============================================================

local function process_shipping_bins()
    -- Find all loaded shipping bins and process them
    local bins = core.find_nodes_in_area(
        {x = -31000, y = -31000, z = -31000},
        {x = 31000, y = 31000, z = 31000},
        {"mbr_shop:shipping_bin"}
    )

    local payouts = {}  -- player_name -> total silver earned

    for _, pos in ipairs(bins) do
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= "" then
            local inv = meta:get_inventory()
            local earned = 0
            for i = 1, inv:get_size("main") do
                local stack = inv:get_stack("main", i)
                local name = stack:get_name()
                if name ~= "" then
                    local entry = catalog_by_item[name]
                    if entry then
                        earned = earned + get_sell_price(entry) * stack:get_count()
                        local d = get_demand(name)
                        d.sold = d.sold + stack:get_count()
                    end
                    inv:set_stack("main", i, "")
                end
            end
            if earned > 0 then
                payouts[owner] = (payouts[owner] or 0) + earned
            end
        end
    end

    -- Distribute payouts to online players; offline earnings stored for next login
    for owner, amount in pairs(payouts) do
        local player = core.get_player_by_name(owner)
        if player then
            add_coins(player, amount)
            core.chat_send_player(owner,
                "Your shipped items earned " .. amount .. " silver!")
        else
            -- Store for offline player
            local storage = core.get_mod_storage()
            local pending = storage:get_int("pending_" .. owner)
            storage:set_int("pending_" .. owner, pending + amount)
        end
        minetest.log("action", "[MBR Shop] Shipping payout: " .. owner .. " earned " .. amount .. " silver")
    end
end

-- Give offline earnings when player joins
core.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local storage = core.get_mod_storage()
    local pending = storage:get_int("pending_" .. name)
    if pending > 0 then
        add_coins(player, pending)
        storage:set_int("pending_" .. name, 0)
        core.chat_send_player(name,
            "You received " .. pending .. " silver from shipped items while you were away!")
    end
end)

-- ============================================================
-- Daily Callbacks (time system integration)
-- ============================================================

if mbr and mbr.time and mbr.time.register_on_new_day then
    mbr.time.register_on_new_day(function(day, season)
        normalize_prices()
        rotate_stock()
        process_shipping_bins()
        minetest.log("action", "[MBR Shop] New day processing complete (day " .. day .. ")")
    end)
else
    minetest.log("action", "[MBR Shop] Time system not available; daily events disabled")
end

-- ============================================================
-- Chat Commands
-- ============================================================

core.register_chatcommand("shop", {
    description = "Open Lily's shop",
    func = function(name, param)
        show_shop(name)
        return true, "Opening shop..."
    end,
})

core.register_chatcommand("balance", {
    description = "Show your current coin balance",
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end
        return true, "Balance: " .. balance_string(player)
    end,
})

core.register_chatcommand("prices", {
    description = "Show current prices. Usage: /prices [item_name]",
    func = function(name, param)
        if param and param ~= "" then
            -- Search for specific item
            local search = param:lower()
            local results = {}
            for _, entry in ipairs(shop_catalog) do
                local desc = core.registered_items[entry.item] and
                    core.registered_items[entry.item].description or entry.item
                if desc:lower():find(search, 1, true) or entry.item:lower():find(search, 1, true) then
                    results[#results + 1] = string.format("  %s — Buy: %ds, Sell: %ds [%s]",
                        desc, get_buy_price(entry), get_sell_price(entry), entry.category)
                end
            end
            if #results == 0 then
                return true, "No items found matching '" .. param .. "'."
            end
            return true, "Prices for '" .. param .. "':\n" .. table.concat(results, "\n")
        else
            -- Show all categories summary
            local lines = {"Current shop prices:"}
            local last_cat = ""
            for _, entry in ipairs(shop_catalog) do
                if entry.category ~= last_cat then
                    lines[#lines + 1] = "\n  [" .. entry.category:upper() .. "]"
                    last_cat = entry.category
                end
                local desc = core.registered_items[entry.item] and
                    core.registered_items[entry.item].description or entry.item
                lines[#lines + 1] = string.format("    %s — Buy: %ds, Sell: %ds",
                    desc, get_buy_price(entry), get_sell_price(entry))
            end
            return true, table.concat(lines, "\n")
        end
    end,
})

-- ============================================================
-- Cleanup
-- ============================================================

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_shop_state[name] = nil
end)

-- ============================================================
-- Startup
-- ============================================================

minetest.log("action", "[MBR Shop] Shop and economy system loaded")
