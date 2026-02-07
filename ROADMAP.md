# MoonBrook Ridge — Development Roadmap

> A farming & life-simulation game built on the Luanti engine.
> This roadmap tracks every planned feature. Items are grouped into phases and
> checked off as they are merged into the main branch.

---

## Phase 1 — Core Engine Systems *(mostly complete)*

These systems form the foundation that every other feature depends on.

- [x] **Time & Season System** (`mbr_time.lua`)
  - [x] Dynamic day/night cycle synced to Luanti `timeofday`
  - [x] 4 seasons (Spring, Summer, Fall, Winter), 28 days each
  - [x] Year tracking, total-day helper
  - [x] HUD clock display (season, day, year, hour:minute)
  - [x] Callback hooks: `register_on_new_day`, `register_on_season_change`

- [x] **Survival Mechanics** (`mbr_survival.lua`)
  - [x] Hunger & Thirst stats (0–100) with HUD stat-bars
  - [x] Passive decay (hunger every 60 s, thirst every 45 s)
  - [x] Activity-based drain (running, digging)
  - [x] Speed debuff at low hunger/thirst
  - [x] Critical warning HUD text
  - [x] Starvation/dehydration damage (HP drain every 10 s)
  - [x] Respawn reset logic
  - [x] `register_food` / `register_drink` API with starter items

- [x] **Weather System** (`mbr_weather.lua`)
  - [x] 8 weather types (clear, sunny, cloudy, rainy, stormy, snowy, windy, foggy)
  - [x] Season-weighted random transitions
  - [x] Sky colour overrides, fog distance
  - [x] Rain / snow / storm particle effects
  - [x] Lightning flash during storms
  - [x] Speed multiplier exposed for other systems
  - [x] HUD weather indicator
  - [x] Season-change hook triggers weather change

- [x] **Particle Effects** (`mbr_particles.lua`)
  - [x] 10 built-in effect types (dirt, water, rock, wood, sparkle, splash, heart, levelup, damage, heal)
  - [x] Per-player or proximity-based spawning
  - [x] Auto-particle on node dig based on node groups

- [x] **NPC System** (`mbr_npcs.lua`)
  - [x] 7 unique NPCs (Emma, Marcus, Lily, Oliver, Sarah, Jack, Maya)
  - [x] 10-heart relationship system with `get_hearts` / `add_hearts`
  - [x] Gift system with loved / liked / neutral preferences
  - [x] Chat-bubble HUD with auto-remove
  - [x] Friendship-level branching dialogue (low / medium / high / max)
  - [x] Daily schedule system with hourly position updates
  - [x] `/npc_status` chat command

- [x] **Marriage & Family** (`mbr_marriage.lua`)
  - [x] Proposal at max hearts with formspec UI
  - [x] Wedding ceremony with announcement & heart particles
  - [x] Daily spouse benefits (30 % chance: water crops / feed animals / repair fences / cook food)
  - [x] Children system (baby → toddler → child), max 2
  - [x] Child interactions (play, gift, teach, hug)
  - [x] `/family` and `/propose` chat commands

---

## Phase 2 — Farming & Resource Gathering

- [ ] **Farming System**
  - [ ] Crop nodes (wheat, corn, tomato, potato, carrot, pumpkin, strawberry)
  - [ ] Growth stages (seed → sprout → mature → harvestable)
  - [ ] Watering mechanic (manual + rain auto-water integration)
  - [ ] Seasonal crop availability
  - [ ] Soil preparation with hoe
  - [ ] Fertiliser to speed growth
  - [ ] Crop quality tiers (normal / silver / gold)

- [ ] **Fishing System**
  - [ ] Fishing rod tool with cast / reel mechanic
  - [ ] Fish species per biome / season
  - [ ] Fishing mini-game (timing-based)
  - [ ] Bait items that affect catch rates
  - [ ] Legendary rare catches

- [ ] **Mining & Cave Exploration**
  - [ ] Ore nodes (copper, iron, silver, gold, crystal)
  - [ ] Gem nodes for crafting & gifting
  - [ ] Cave generation with procedural layouts
  - [ ] Mining tool tiers (stone → copper → iron → gold → crystal)
  - [ ] Cave hazards (collapse, gas, lava)

- [ ] **Foraging & Gathering**
  - [ ] Wild herbs, mushrooms, berries (biome-specific)
  - [ ] Seasonal spawn variation
  - [ ] Rare forageables for crafting recipes

---

## Phase 3 — Economy & Crafting

- [ ] **Crafting System (Enhanced UI)**
  - [ ] Crafting station node with formspec
  - [ ] Recipe discovery / unlock system
  - [ ] Category tabs (food, tools, furniture, decor, potions)
  - [ ] Craft-queue animation / progress

- [ ] **Shop System**
  - [ ] Buy / sell formspec with currency
  - [ ] NPC merchant inventories that rotate daily
  - [ ] Supply-and-demand price adjustments
  - [ ] Shipping bin for bulk selling

- [ ] **Tool Upgrade System**
  - [ ] 6 upgradeable tools: hoe, watering can, axe, pickaxe, fishing rod, scythe
  - [ ] Upgrade tiers (basic → copper → iron → gold → crystal)
  - [ ] Upgrade station node with material cost
  - [ ] Upgraded tools work faster / wider area

---

## Phase 4 — Building & World

- [ ] **Building Construction**
  - [ ] Placeable structures (barn, silo, coop, greenhouse, well)
  - [ ] Blueprint system (preview ghost before placing)
  - [ ] Material requirements for each building
  - [ ] Building upgrades (capacity, efficiency)

- [ ] **Multi-Village World** *(8 biome villages)*
  - [ ] MoonBrook Valley (Grassland) — home farming community
  - [ ] Pinewood Village (Forest) — lumberjacks, hunters, nature magic
  - [ ] Stonehelm Village (Mountain) — dwarven miners, master blacksmiths
  - [ ] Sandshore Village (Desert) — trading outpost, fire mages, treasure hunters
  - [ ] Frostpeak Village (Frozen) — ice fishing, cold-weather survival
  - [ ] Marshwood Village (Swamp) — alchemists, poison experts, healers
  - [ ] Crystalgrove Village (Crystal Cave) — magical academy, enchanters
  - [ ] Ruinwatch Village (Ruins) — archaeological expedition, lore keepers
  - [ ] Village reputation system (discounts, rewards)
  - [ ] Inter-village ally / rival relations
  - [ ] Fast-travel unlocks between discovered villages

---

## Phase 5 — Quests & Events

- [ ] **Quest System**
  - [ ] Quest journal formspec with tracking
  - [ ] Cave quests (extermination, boss hunting, resource gathering, exploration)
  - [ ] Farm quests (crop delivery, animal products, quality challenges)
  - [ ] Trading quests (buy / sell orders, arbitrage between villages)
  - [ ] Courier quests (package delivery, escort missions)
  - [ ] Hybrid multi-step quests combining multiple types
  - [ ] Village-specific quests based on biome & culture
  - [ ] Quest rewards (items, currency, reputation, recipes)

- [ ] **Events & Festivals**
  - [ ] 8 seasonal festivals (2 per season)
  - [ ] Festival mini-games & contests
  - [ ] Seasonal decorations & special items
  - [ ] Festival-exclusive NPC dialogue

---

## Phase 6 — Pet Companion System

- [ ] **Pet Taming & Types**
  - [ ] Find wild pets in biome-specific spawns
  - [ ] Taming mechanic (approach, feed, befriend)
  - [ ] Combat pets: Wolf, Hawk
  - [ ] Support pets: Fairy, Spirit
  - [ ] Utility pets: Dog, Cat, Owl

- [ ] **Pet Levelling & Skills**
  - [ ] Pet XP and level-up system
  - [ ] 3 skill trees per pet (Offensive / Defensive / Utility)
  - [ ] Passive bonuses from pet type
  - [ ] Active abilities triggered in combat

- [ ] **Pet Charms & Gear**
  - [ ] Craftable charms that enhance pet stats
  - [ ] Weapon synergy bonuses
  - [ ] Charm slot management UI

---

## Phase 7 — Combat & Progression

- [ ] **Combat System**
  - [ ] Melee & ranged weapon types
  - [ ] Enemy mobs with AI (per biome)
  - [ ] Boss encounters in caves / dungeons
  - [ ] Dodge / block mechanics
  - [ ] Damage types (physical, elemental, poison)

- [ ] **Player Progression**
  - [ ] Skill levels (farming, mining, fishing, combat, foraging, cooking)
  - [ ] XP gain from relevant activities
  - [ ] Skill perks at milestones
  - [ ] Achievement / milestone tracking

---

## Phase 8 — Polish & Content

- [ ] **Custom Textures & Models**
  - [ ] Replace placeholder `[fill:...]` textures with pixel-art assets
  - [ ] NPC character models
  - [ ] Pet models & animations
  - [ ] Crop growth stage sprites
  - [ ] UI / formspec skin

- [ ] **Sound & Music**
  - [ ] Ambient biome sounds
  - [ ] Seasonal music tracks
  - [ ] Action SFX (dig, plant, fish, craft)
  - [ ] Weather audio (rain, thunder, wind)

- [ ] **Save / Load Persistence**
  - [ ] Serialize `mbr.*` state to mod storage on shutdown
  - [ ] Restore state on server start
  - [ ] Per-player data saved across sessions

- [ ] **Performance & QA**
  - [ ] Profile globalstep callbacks
  - [ ] Throttle particle spawners
  - [ ] Automated Lua unit tests for core systems
  - [ ] Multiplayer stress testing

---

## How to Contribute

1. Pick an unchecked item from the roadmap.
2. Open an issue referencing the roadmap item.
3. Submit a PR — Copilot or a maintainer will review it.
4. Once merged, the checkbox will be ticked and the roadmap updated.

> **This is a living document.** New features will be added as ideas emerge.
