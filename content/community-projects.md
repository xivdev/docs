---
description: Various open source resources and projects
---

This is a list of various open source resources and projects related to FFXIV. Please [leave an issue](https://github.com/xivdev/docs/issues) if your project is listed here and you'd like to remove it.

## Programs

### XIVLauncher

|          |                                                  |
|----------|--------------------------------------------------|
| link     | <https://github.com/goatcorp/FFXIVQuickLauncher> |
| language | C#                                               |

A popular custom launcher with extra features. Good reference for the login flow (including Steam/Free Trial accounts) and the patching system.

### Dalamud

|          |                                       |
|----------|---------------------------------------|
| link     | <https://github.com/goatcorp/Dalamud> |
| language | C#                                    |

A plugin framework and API, meant to be used with XIVLauncher. Almost all official plugins are open source.

## Libraries

### Lumina

|          |                                     |
|----------|-------------------------------------|
| link     | <https://github.com/NotAdam/Lumina> |
| language | C#                                  |

Library for reading and interacting with FFXIV game files and Excel data.

### SaintCoinach

|          |                                          |
|----------|------------------------------------------|
| link     | <https://github.com/xivapi/SaintCoinach> |
| language | C#                                       |

Another library for reading and interacting with game files/Excel data. Provides community maintained metadata on Excel data types.

### Ironworks

|          |                                        |
|----------|----------------------------------------|
| link     | <https://github.com/ackwell/ironworks> |
| language | Rust                                   |

Yet another library for game data, but in Rust.

### kobold

|          |                                     |
|----------|-------------------------------------|
| link     | <https://github.com/ackwell/kobold> |
| language | TypeScript                          |

*Another* library for game data, in TypeScript.

### FFXIVClientStructs

|          |                                              |
|----------|----------------------------------------------|
| link     | <https://github.com/aers/FFXIVClientStructs> |
| language | C#, Python                                   |

A C# library containing community-maintained structs in the client, and Python scripts to help reverse engineer the game binary in IDA/Ghidra.

## Tools

### SaintCoinach.Cmd

|          |                                          |
|----------|------------------------------------------|
| link     | <https://github.com/xivapi/SaintCoinach> |
| language | C#                                       |

A command line interface for SaintCoinach. Features commands to export raw game files, the UI images, and music.

### Godbert

|          |                                          |
|----------|------------------------------------------|
| link     | <https://github.com/xivapi/SaintCoinach> |
| language | C#                                       |

A GUI interface for browsing Excel data and viewing territories, powered by SaintCoinach.

### FFXIV Explorer

|          |                                                      |
|----------|------------------------------------------------------|
| link     | <https://bitbucket.org/Ioncannon/ffxiv-explorer/src> |
| language | Java                                                 |

A GUI for browsing the game files. You may be interested in [this fork](https://github.com/goaaats/ffxiv-explorer-fork/) adding more features.

## Websites & APIs

### Thaliak

|        |                                       |
|--------|---------------------------------------|
| link   | <http://thaliak.xiv.dev/>             |
| source | <https://github.com/avafloww/Thaliak> |

An API for game versions and patch information.

### ResLogger2

|        |                                           |
|--------|-------------------------------------------|
| link   | <https://rl2.perchbird.dev/>              |
| source | <https://github.com/lmcintyre/ResLogger2> |

A list of file paths in the game files, crowdsourced via a Dalamud plugin.

### XIVAPI

|        |                                        |
|--------|----------------------------------------|
| link   | <https://xivapi.com/>                  |
| source | <https://github.com/xivapi/xivapi.com> |

A general-purpose API for FFXIV. Most useful if you can't embed a library into your application or need Lodestone information.

## Networking

### Sapphire

|          |                                              |
|----------|----------------------------------------------|
| link     | <https://github.com/SapphireServer/Sapphire> |
| language | C++                                          |

A server emulator. Not always up to date, but still a great reference on many things.

### Machina

|          |                                     |
|----------|-------------------------------------|
| link     | <https://github.com/ravahn/machina> |
| language | C#                                  |

A general library for packet capture with specialized FFXIV functionality.

### Velcro

|          |                                        |
|----------|----------------------------------------|
| link     | <https://github.com/velcro-xiv/velcro> |
| language | Go, C#                                 |

A set of tools to capture network data and store it into an SQLite database.

### Nari

|          |                                   |
|----------|-----------------------------------|
| link     | <https://github.com/xivlogs/nari> |
| language | Python                            |

A library to parse ACT logs.
