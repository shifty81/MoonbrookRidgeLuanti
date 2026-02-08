# MoonBrook Ridge Game

A cozy farming and life-simulation game for Luanti.

## Features

- **Time & Seasons**: 4 seasons with 28-day cycles
- **Survival Mechanics**: Hunger & thirst systems
- **Dynamic Weather**: Rain, snow, storms, and fog
- **NPCs**: 7 unique characters with relationships
- **Marriage & Family**: Build relationships and start a family
- **Loot System**: Diablo-style items with rarities and affixes
- **Quality Crafting**: Material quality affects crafted items

## Getting Started

1. Build the Luanti engine from source (see main README.md and BUILDING.md)
2. Launch Luanti and select "MoonBrook Ridge" from the games list
3. Create a new world and start playing!

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

## Contributing

See the main [ROADMAP.md](../../ROADMAP.md) for planned features and development priorities.
