# Testing MoonBrook Ridge Features

This guide shows you how to test all the implemented MoonBrook Ridge systems.

## Setup

1. Build Luanti from source (see main README.md and BUILDING.md)
2. Launch Luanti
3. Select "MoonBrook Ridge" from the games list
4. Create a new world
5. Start the game!

## Game Systems to Test

### 1. Time & Season System

The game has a dynamic time system with 4 seasons (Spring, Summer, Fall, Winter), each lasting 28 days.

**How to Test:**
- Look at the HUD - you should see the current season, day, and time
- Use `/time` command to check detailed time information
- The day/night cycle syncs with Luanti's timeofday
- Wait or use `/time set` to see season changes

**Expected Behavior:**
- HUD displays: "Spring Day 1 - 12:00" (or similar)
- Seasons cycle: Spring → Summer → Fall → Winter → Spring
- Callbacks trigger on new days and season changes

### 2. Survival Mechanics (Hunger & Thirst)

Players have hunger and thirst bars that deplete over time.

**How to Test:**
- Check the HUD for hunger and thirst stat bars
- Wait and watch them slowly decrease
- Dig or run to make them decrease faster
- Eat food items (bread, apple, cooked meat) to restore hunger
- Drink water bottles or milk to restore thirst
- Let stats drop to 0 to see critical warnings and damage

**Expected Behavior:**
- Hunger bar depletes every 60 seconds
- Thirst bar depletes every 45 seconds
- Speed debuff when stats are low
- HP damage when stats reach 0
- HUD shows critical warnings

**Items to Use:**
- `mbr_items:bread` - Restores 20 hunger
- `mbr_items:apple` - Restores 10 hunger, 5 thirst
- `mbr_items:cooked_meat` - Restores 30 hunger
- `mbr_items:water_bottle` - Restores 30 thirst
- `mbr_items:milk` - Restores 20 thirst, 10 hunger

### 3. Weather System

Dynamic weather with 8 types that change based on the season.

**How to Test:**
- Watch the sky - it will change colors based on weather
- Look for particle effects (rain, snow, storms)
- Use `/test_weather` command to cycle through weather types
- Weather changes automatically on season transitions

**Weather Types:**
- Clear - Normal sky
- Sunny - Bright, warm colors
- Cloudy - Gray sky, reduced light
- Rainy - Rain particles, darker sky
- Stormy - Heavy rain, lightning flashes
- Snowy - Snow particles (more common in winter)
- Windy - Clear but with movement effects
- Foggy - Reduced fog distance

### 4. Particle Effects

Various particle effects trigger on player actions.

**How to Test:**
- Dig different nodes to see auto-particles:
  - Dirt → dirt particles
  - Stone → rock particles
  - Wood → wood particles
  - Water → water splash
- Other effects are triggered by game systems (hearts, damage, healing, etc.)

### 5. NPC System

7 unique NPCs with relationship systems and gift preferences.

**How to Test:**
- Use `/npc_status` to view all NPCs and relationship levels
- The NPC system is implemented in builtin but needs spawn positions
- NPCs should appear in the world (implementation pending)
- Talk to NPCs to get dialogue based on relationship level
- Give gifts to increase relationship hearts (0-10 hearts)

**NPCs:**
1. Emma - The friendly farmer
2. Marcus - The wise elder
3. Lily - The cheerful florist
4. Oliver - The skilled blacksmith
5. Sarah - The kind healer
6. Jack - The adventurous explorer
7. Maya - The talented artist

### 6. Marriage & Family System

Marry NPCs at max relationship level and start a family.

**How to Test:**
- Get an NPC to max hearts (10 hearts)
- Use `/propose <npc_name>` to propose
- Accept the proposal in the formspec UI
- Use `/family` to check family status
- Spouse may help with daily tasks
- Children can be born and grow through stages

### 7. Diablo-Style Loot System

Items have rarities and random affixes for stat bonuses.

**How to Test:**
- Use `/iteminfo` while holding an item to see its stats
- Loot has 5 rarity tiers:
  - Common (white)
  - Magic (blue) - 1-2 affixes
  - Rare (yellow) - 2-3 affixes
  - Epic (purple) - 3-4 affixes
  - Legendary (orange) - 4-5 affixes
- Affixes provide offensive, defensive, or utility bonuses

**Affix Types:**
- Offensive: Extra damage, critical chance, attack speed
- Defensive: Extra armor, health, resistances
- Utility: Movement speed, luck, resource gain

### 8. Quality-Based Crafting System

Crafted items inherit quality from materials.

**How to Test:**
- Use `/craft` command to open crafting interface
- Materials have quality tiers:
  - Poor (0.75× stats)
  - Normal (1.0× stats)
  - Fine (1.25× stats)
  - Superior (1.5× stats)
  - Masterwork (2.0× stats)
- Output quality matches input material quality
- Crafted items also get random affixes from loot system

**Available Recipes:**
- Swords (wood, stone, copper, iron, gold, crystal tiers)
- Pickaxes (various tiers)
- Axes (various tiers)
- Hoes (various tiers)

## Basic Survival Tips

1. **Start by gathering wood** - Punch trees to get wood, craft planks
2. **Craft basic tools** - Make pickaxe, axe, and shovel
3. **Build a shelter** - Place blocks to create a house
4. **Manage your stats** - Keep food and water in inventory
5. **Explore the world** - Find resources and NPCs

## Commands Reference

| Command | Description |
|---------|-------------|
| `/time` | Check current game time and season |
| `/npc_status` | View all NPC relationships |
| `/family` | Check family/marriage status |
| `/propose <npc>` | Propose to an NPC at max hearts |
| `/iteminfo` | Inspect stats of held item |
| `/craft` | Open crafting station |
| `/give_supplies` | Get emergency food/water |
| `/test_weather` | Cycle through weather types |

## Troubleshooting

**Hunger/thirst not showing:**
- Make sure you started a new world after adding the game
- Check the HUD is not hidden (F1)

**No NPCs spawning:**
- NPC spawning is implemented but may need world initialization
- Use `/npc_status` to verify the NPC system is loaded

**Weather not changing:**
- Weather changes on season transitions
- Use `/test_weather` to manually test weather

**Loot system not working:**
- Craft an item using `/craft` to see quality and affixes
- Use `/iteminfo` on crafted or found items

## Next Steps

Once you've tested these systems, you can:
1. Help implement the farming system (crops, watering, seasons)
2. Add fishing mechanics
3. Create shop and economy systems
4. Design villages and place NPCs
5. Build quest systems
6. Add pet companions

See ROADMAP.md for the full development plan!
