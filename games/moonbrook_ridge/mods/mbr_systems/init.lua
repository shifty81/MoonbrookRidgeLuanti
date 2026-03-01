-- MoonBrook Ridge: Core Systems Mod
-- Loads all integrated game systems in dependency order.

local modpath = core.get_modpath("mbr_systems") .. "/"

-- Utilities must load first (provides clamp, format_hearts)
dofile(modpath .. "mbr_utils.lua")

-- Time system (seasons, day/night cycle)
dofile(modpath .. "mbr_time.lua")

-- Survival (hunger/thirst) — uses utils
dofile(modpath .. "mbr_survival.lua")

-- Weather — uses time
dofile(modpath .. "mbr_weather.lua")

-- Particle effects
dofile(modpath .. "mbr_particles.lua")

-- NPCs — uses utils, time
dofile(modpath .. "mbr_npcs.lua")

-- Marriage — uses utils, time, npcs
dofile(modpath .. "mbr_marriage.lua")

-- Loot system — uses utils
dofile(modpath .. "mbr_loot.lua")

-- Quality crafting — uses utils, loot, particles
dofile(modpath .. "mbr_crafting.lua")

minetest.log("action", "[MBR Systems] All core systems loaded")
