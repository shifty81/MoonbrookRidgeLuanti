<div align="center">
    <img src="textures/base/pack/logo.png" width="32%">
    <h1>🌙 MoonBrook Ridge</h1>
    <p><em>A farming &amp; life-simulation game built on the Luanti engine</em></p>
</div>
<br>

## 🎮 Quick Start

**Want to play MoonBrook Ridge?**

1. Build the engine from source (see [Compiling](#compiling) section below)
2. Launch Luanti: `./bin/luanti`
3. Select **"MoonBrook Ridge"** from the games list
4. Create a new world and start playing!

📖 See [games/moonbrook_ridge/TESTING.md](games/moonbrook_ridge/TESTING.md) for a full guide to testing all features.

---

## About MoonBrook Ridge

MoonBrook Ridge is a cozy farming, life-simulation, and adventure game built
on the [Luanti](https://www.luanti.org/) (formerly Minetest) voxel engine.
Grow crops, raise animals, befriend villagers, explore caves, tame pets, and
build the homestead of your dreams — all inside a procedurally generated world
with dynamic seasons and weather.

### Current Features

| System | Status |
|--------|--------|
| Time & Seasons (4 seasons, 28-day cycles) | ✅ Implemented & Testable |
| Hunger & Thirst survival mechanics | ✅ Implemented & Testable |
| Dynamic weather (rain, snow, storms, fog) | ✅ Implemented & Testable |
| Particle effects for actions | ✅ Implemented & Testable |
| 7 unique NPCs with relationships & gifts | ✅ Implemented |
| Marriage & family system | ✅ Implemented |
| Diablo-style loot system (5 rarity tiers, random affixes) | ✅ Implemented & Testable |
| Quality-based crafting (material quality → output quality) | ✅ Implemented & Testable |
| **Playable game with basic world & items** | ✅ **Ready to Test!** |
| Farming, fishing, mining | 🔜 Planned |
| Shop & economy | 🔜 Planned |
| Multi-village world (8 biomes) | 🔜 Planned |
| Quest system | 🔜 Planned |
| Pet companion system | 🔜 Planned |
| Combat & player progression | 🔜 Planned |

👉 **See [ROADMAP.md](ROADMAP.md) for the full development plan.**

---

## Luanti Engine

Luanti is a free open-source voxel game engine with easy modding and game creation.

Copyright (C) 2010-2026 Perttu Ahola <celeron55@gmail.com>
and contributors (see source file comments and the version control log)

Table of Contents
------------------

1. [Further Documentation](#further-documentation)
2. [Default Controls](#default-controls)
3. [Paths](#paths)
4. [Configuration File](#configuration-file)
5. [Command-line Options](#command-line-options)
6. [Compiling](#compiling)
7. [Docker](#docker)
8. [Version Scheme](#version-scheme)


Further documentation
----------------------
- Website: https://www.luanti.org/
- Luanti Documentation: https://docs.luanti.org/
- Forum: https://forum.luanti.org/
- GitHub: https://github.com/luanti-org/luanti/
- [Developer documentation](doc/developing/)
- [doc/](doc/) directory of source distribution

Default controls
----------------
All controls are re-bindable using settings.
Some can be changed in the key config dialog in the settings tab.

| Button                        | Action                                                         |
|-------------------------------|----------------------------------------------------------------|
| Move mouse                    | Look around                                                    |
| W, A, S, D                    | Move                                                           |
| Space                         | Jump/move up                                                   |
| Shift                         | Sneak/move down                                                |
| Q                             | Drop itemstack                                                 |
| Shift + Q                     | Drop single item                                               |
| Left mouse button             | Dig/punch/use                                                  |
| Right mouse button            | Place/use                                                      |
| Shift + right mouse button    | Build (without using)                                          |
| I                             | Inventory menu                                                 |
| Mouse wheel                   | Select item                                                    |
| 0-9                           | Select item                                                    |
| Z                             | Zoom (needs zoom privilege)                                    |
| T                             | Chat                                                           |
| /                             | Command                                                        |
| Esc                           | Pause menu/abort/exit (pauses only singleplayer game)          |
| +                             | Increase view range                                            |
| -                             | Decrease view range                                            |
| K                             | Enable/disable fly mode (needs fly privilege)                  |
| J                             | Enable/disable fast mode (needs fast privilege)                |
| H                             | Enable/disable noclip mode (needs noclip privilege)            |
| E                             | Aux1 (Move fast in fast mode. Games may add special features)  |
| C                             | Cycle through camera modes                                     |
| V                             | Cycle through minimap modes                                    |
| Shift + V                     | Change minimap orientation                                     |
| F1                            | Hide/show HUD                                                  |
| F2                            | Hide/show chat                                                 |
| F3                            | Disable/enable fog                                             |
| F4                            | Disable/enable camera update (Mapblocks are not updated anymore when disabled, disabled in release builds)  |
| F5                            | Cycle through debug information screens                        |
| F6                            | Cycle through profiler info screens                            |
| F10                           | Show/hide console                                              |
| F12                           | Take screenshot                                                |

Paths
-----
Locations:

* `bin`   - Compiled binaries
* `share` - Distributed read-only data
* `user`  - User-created modifiable data

Where each location is on each platform:

* Windows .zip / RUN_IN_PLACE source:
    * `bin`   = `bin`
    * `share` = `.`
    * `user`  = `.`
* Windows installed:
    * `bin`   = `C:\Program Files\Minetest\bin (Depends on the install location)`
    * `share` = `C:\Program Files\Minetest (Depends on the install location)`
    * `user`  = `%APPDATA%\Minetest` or `%MINETEST_USER_PATH%`
* Linux installed:
    * `bin`   = `/usr/bin`
    * `share` = `/usr/share/minetest`
    * `user`  = `~/.minetest` or `$MINETEST_USER_PATH`
* macOS:
    * `bin`   = `Contents/MacOS`
    * `share` = `Contents/Resources`
    * `user`  = `Contents/User` or `~/Library/Application Support/minetest` or `$MINETEST_USER_PATH`

Worlds can be found as separate folders in: `user/worlds/`

Configuration file
------------------
- Default location:
    `user/minetest.conf`
- This file is created by closing Luanti for the first time.
- A specific file can be specified on the command line:
    `--config <path-to-file>`
- A run-in-place build will look for the configuration file in
    `location_of_exe/../minetest.conf` and also `location_of_exe/../../minetest.conf`

Command-line options
--------------------
- Use `--help`

Compiling
---------

- [Compiling - common information](doc/compiling/README.md)
- [Compiling on GNU/Linux](doc/compiling/linux.md)
- [Compiling on Windows](doc/compiling/windows.md)
- [Compiling on MacOS](doc/compiling/macos.md)

Docker
------

- [Developing minetestserver with Docker](doc/developing/docker.md)
- [Running a server with Docker](doc/docker_server.md)

Version scheme
--------------
We use `major.minor.patch` since 5.0.0-dev. Prior to that we used `0.major.minor`.

- Major is incremented when the release contains breaking changes, all other
numbers are set to 0.
- Minor is incremented when the release contains new non-breaking features,
patch is set to 0.
- Patch is incremented when the release only contains bugfixes and very
minor/trivial features considered necessary.

Since 5.0.0-dev and 0.4.17-dev, the dev notation refers to the next release,
i.e.: 5.0.0-dev is the development version leading to 5.0.0.
Prior to that we used `previous_version-dev`.
