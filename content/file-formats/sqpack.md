---
description: 'Everything sqpack: indexes, dat files'
---

# sqpack

sqpack\(s\) are formed from the following concepts, in which order 'matters':

1. Repositories
2. Categories
3. A file index
4. 1-n data files

### Repositories

Repositories are essentially a collection of categories and there's not much to know here. As of writing, there's 4, one for the base game \(`ffxiv`\) and one for each expansion \(`ex1`, `ex2`, etc.\). Consider the following directory structure:

```text
sqpack/
    ex1/
    ex2/
    ex3/
    ffxiv/
```

Each folder inside `sqpack/` is it's own repository. As an aside, when the game tries to access files, it distinguishes which repository to find a file in by parsing the file path and pulling out 2 segments, the repository name and the category.

For example:

| Path | Repository | Category |
| :--- | :--- | :--- |
| `bg/ex3/01_nvt_n4/twn/n4t1/bgparts/n4t1_a1_chr03.mdl` | `ex3` | `bg` |
| `music/ex2/bgm_ex2_system_title.scd` | `ex2` | `music` |
| `chara/weapon/w0501/obj/body/b0018/vfx/texture/uv_cryst_128s.atex` | `ffxiv` | `chara` |

The first two paths explicitly define their repository in their file path, and it's always the second segment - if it's omitted it defaults to the `ffxiv` repository. Category is always the first segment and must be present for a path to resolve.

### Categories

Categories are just logical separations of game data. The following categories exist:

| ID | Name | Notes |
| :--- | :--- | :--- |
| `0` | `common` |  |
| `1` | `bgcommon` |  |
| `2` | `bg` |  |
| `3` | `cut` |  |
| `4` | `chara` |  |
| `5` | `shader` |  |
| `6` | `ui` |  |
| `7` | `sound` |  |
| `8` | `vfx` |  |
| `9` | `ui_script` |  |
| `A` | `exd` |  |
| `B` | `game_script` |  |
| `C` | `music` |  |
| `12` | `sqpack_test` | Category missing in retail client/no files. |
| `13` | `debug` | Category missing in retail client/no files. |

Every game path will start with one of the above names and it defines which index to search to find a file.

