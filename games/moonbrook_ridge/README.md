# MoonBrook Ridge

A cozy farming and life-simulation game built on the Luanti engine.

## Overview

**MoonBrook Ridge is a complete, standalone game** - not a mod or game selection. When you build and run MoonBrook Ridge, you're running the full game. All the farming, survival, weather, NPC, and crafting systems are fully integrated into the game's core.

## Features

- **Time & Seasons**: 4 seasons with 28-day cycles
- **Survival Mechanics**: Hunger & thirst systems
- **Dynamic Weather**: Rain, snow, storms, and fog
- **NPCs**: 7 unique characters with relationships
- **Marriage & Family**: Build relationships and start a family
- **Loot System**: Diablo-style items with rarities and affixes
- **Quality Crafting**: Material quality affects crafted items

## Getting Started

1. Build MoonBrook Ridge from source (see main [BUILDING.md](../../BUILDING.md))
2. Launch the game: `./bin/moonbrook_ridge`
3. Create a new world - the game is ready to play!

## About the Integration

MoonBrook Ridge is **fully integrated** into the game engine:

## Testing Features

See [TESTING.md](TESTING.md) for a comprehensive guide on how to test all implemented features.

Quick start commands:
- `/time` - Check current game time and season
- `/npc_status` - View NPC relationships
- `/family` - Check family status
- `/iteminfo` - Inspect held item stats
- `/craft` - Open crafting interface
- `/give_supplies` - Get emergency food and water

## Game Structure

The game consists of these mods:

- **mbr_core** - Basic nodes (stone, dirt, grass, water, trees, sand, gravel)
- **mbr_items** - Food, drinks, and consumable items
- **mbr_tools** - Pickaxes, axes, shovels for mining and gathering
- **mbr_mapgen** - World generation with grassland biome and trees
- **mbr_content** - NPCs, test items, welcome messages, and helper commands

## MoonBrook Ridge Systems

The core game systems are built into the Luanti engine (in `builtin/game/mbr_*.lua`):

- `mbr_time.lua` - Time and season system
- `mbr_survival.lua` - Hunger and thirst mechanics
- `mbr_weather.lua` - Dynamic weather system
- `mbr_particles.lua` - Particle effects
- `mbr_npcs.lua` - NPC relationship system
- `mbr_marriage.lua` - Marriage and family mechanics
- `mbr_loot.lua` - Diablo-style loot with rarities and affixes
- `mbr_crafting.lua` - Quality-based crafting system

These systems are automatically loaded when running this game.

## Credits & Licensing

MoonBrook Ridge is built on the [Luanti](https://www.luanti.org/) (formerly
Minetest) voxel engine, licensed under the LGPL 2.1 (or later).  All Luanti
contributors are gratefully acknowledged.

See [CREDITS.md](CREDITS.md) for the full list of credits, third-party
libraries, and license details.

## Contributing

See the main [ROADMAP.md](../../ROADMAP.md) for planned features and development priorities.
