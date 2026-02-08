# MoonBrook Ridge - Full Integration Documentation

## What Is This?

MoonBrook Ridge is **NOT a mod** - it is a complete, standalone game built on the Luanti (formerly Minetest) voxel engine. This is analogous to:
- Stardew Valley using the MonoGame engine
- Minecraft using their custom Java/C++ engine
- Any game using Unity or Unreal Engine

The game IS the product. The engine is the foundation.

## Architecture

```
┌─────────────────────────────────────────┐
│     MoonBrook Ridge (The Game)          │
│  Version 0.1.0-dev                      │
│                                         │
│  • Farming & Life Simulation            │
│  • Survival Mechanics                   │
│  • Dynamic Weather & Seasons            │
│  • NPC Relationships & Marriage         │
│  • Diablo-Style Loot System             │
│  • Quality-Based Crafting               │
│                                         │
├─────────────────────────────────────────┤
│     Luanti Voxel Engine                 │
│  Version 5.16.0                         │
│                                         │
│  • 3D Rendering (Irrlicht/OpenGL)       │
│  • Networking                           │
│  • World Generation                     │
│  • Modding API                          │
│  • Physics & Collision                  │
│  • Audio System                         │
└─────────────────────────────────────────┘
```

## Integration Approach

### 1. Core Systems in builtin/game/
All MoonBrook Ridge systems are integrated into the engine's `builtin/game/` directory:

- `mbr_time.lua` - Time and season tracking
- `mbr_survival.lua` - Hunger and thirst mechanics  
- `mbr_weather.lua` - Dynamic weather system
- `mbr_particles.lua` - Particle effects
- `mbr_npcs.lua` - NPC relationship system
- `mbr_marriage.lua` - Marriage and family mechanics
- `mbr_loot.lua` - Diablo-style loot with rarities
- `mbr_crafting.lua` - Quality-based crafting

These are loaded automatically by the engine's `builtin/game/init.lua`.

### 2. Game Content in games/moonbrook_ridge/
The game-specific mods provide the actual content:

- `mbr_core` - Basic world blocks (stone, dirt, grass, water, trees)
- `mbr_items` - Food and drink items
- `mbr_tools` - Mining and gathering tools
- `mbr_mapgen` - World generation
- `mbr_content` - Quests, NPCs, welcome messages

### 3. Project Branding
The project itself has been rebranded:

**Before:**
- Project name: `luanti`
- Binary: `./bin/luanti`
- Window title: "Luanti"
- Multiple games to choose from

**After:**
- Project name: `moonbrook_ridge`  
- Binary: `./bin/moonbrook_ridge`
- Window title: "MoonBrook Ridge"
- Single integrated game

## Build Configuration

### CMakeLists.txt Changes:
```cmake
project(moonbrook_ridge)
set(PROJECT_NAME_CAPITALIZED "MoonBrook Ridge")
set(VERSION_MAJOR 0)
set(VERSION_MINOR 1)
set(VERSION_PATCH 0)
```

### Executable Names:
- Client: `moonbrook_ridge` (or `moonbrook_ridge.exe` on Windows)
- Server: `moonbrook_ridgeserver` (or `moonbrook_ridgeserver.exe` on Windows)

### Game Installation:
The MoonBrook Ridge game is automatically installed by CMake:
```cmake
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/games/moonbrook_ridge" 
    DESTINATION "${SHAREDIR}/games/")
```

## Comparison: Mod vs. Integrated Game

| Aspect | Mod Approach | Integrated Approach (Current) |
|--------|--------------|-------------------------------|
| Installation | User installs mod separately | Game is built-in |
| Game selection | User must select game | Automatic - it's THE game |
| Updates | Mod updates separate from engine | Game and engine updated together |
| Branding | Shows engine name (Luanti) | Shows game name (MoonBrook Ridge) |
| Experience | "Playing Luanti with MBR mod" | "Playing MoonBrook Ridge" |
| Distribution | Engine + mod files | Single integrated package |

## User Experience

### Before (Mod Approach):
1. Download Luanti engine
2. Download MoonBrook Ridge mod
3. Install mod in games/ directory
4. Launch Luanti
5. Select "MoonBrook Ridge" from game list
6. Create world

### After (Integrated Approach):
1. Download MoonBrook Ridge
2. Launch MoonBrook Ridge
3. Create world
4. Play!

## Development Workflow

Developers work with:
- Engine code in `src/` (C++)
- Core game systems in `builtin/game/mbr_*.lua` (Lua)
- Game content in `games/moonbrook_ridge/mods/` (Lua)

Building:
```bash
cmake . -DRUN_IN_PLACE=TRUE -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)
./bin/moonbrook_ridge
```

## Credits & Licensing

MoonBrook Ridge is built on the Luanti engine:
- **Engine**: Luanti (LGPL 2.1 or later)
- **Game**: MoonBrook Ridge (your license choice)
- **Credits**: All Luanti contributors are credited in the About screen

The engine is open source and can be used by anyone. MoonBrook Ridge is a specific game implementation using that engine.

## Why This Approach?

1. **Professional Identity**: The game has its own brand and identity
2. **Simplified Distribution**: Single package, not engine + mod
3. **Integrated Experience**: Everything works together seamlessly  
4. **Clear Purpose**: Users know they're playing MoonBrook Ridge
5. **Easier Updates**: Game and engine updated as one unit
6. **Better Marketing**: Can market "MoonBrook Ridge" as a product

## Technical Benefits

1. **Performance**: Core systems compiled into binary, not loaded as mods
2. **Stability**: No mod conflicts or loading order issues
3. **Integration**: Deep engine integration for features
4. **Optimization**: Can optimize engine specifically for game needs
5. **Control**: Complete control over game experience

## Analogy

Think of it this way:
- **Unity** is an engine, **Among Us** is a game built with Unity
- **Unreal Engine** is an engine, **Fortnite** is a game built with Unreal
- **Luanti** is an engine, **MoonBrook Ridge** is a game built with Luanti

Players don't say "I'm playing Unity with Among Us mod" - they say "I'm playing Among Us."
Similarly, players will say "I'm playing MoonBrook Ridge" - a complete game experience.

## Future Possibilities

With this integrated approach, you can:
- Add MoonBrook Ridge to Steam, itch.io, etc. as a standalone game
- Create trailers and marketing materials for "MoonBrook Ridge"
- Build a community around the game (not just a mod)
- Sell the game or add DLC/expansions
- Fork and customize the engine for specific game needs
- Create sequels or spin-offs using the same foundation

## Summary

MoonBrook Ridge is now a **complete, integrated game** - not a collection of mods for an engine. It's a professional game product built on a solid open-source foundation, ready for distribution, marketing, and sale.
