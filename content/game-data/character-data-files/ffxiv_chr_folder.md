# Character data folder
*[Last updated FFXIV 6.58]

This folder, called `FFXIV_CHRxxxx` where `xxxx` is a unique ID for the character, contains all of the client side data related to one or another of the characters played.

Following is a list of the data files found in this folder. 

*Note: most of the information in here is taken from [this reddit post](https://www.reddit.com/r/ffxiv/comments/2o9axc/ffxiv_character_data_files/) without doublechekcing for now.*

*TODO: figure out the format for each file.*
- ACQ.DAT: The list of recent `/tell` contacts. Binary format
- ADDON.DAT: This stores your UI settings such as HUD layouts and window sizes. Binary format
- COMMON.DAT: This stores your Character Settings. Plain text format.
- CONTROL0.DAT: This stores Keyboard/Mouse Settings. Plain text format.
- CONTROL1.DAT: This stores Gamepay Settings. Plain text format.
- GEARSET.DAT: This contains your Gear sets. Binary format.
- GS.DAT: Unknown. Binary format.
- HOTBAR.DAT: This contains the contents of your Hotbars, but not their positions or such. Binary format.
- ITEMFDR.DAT: Item search index, used when searching for similar items. Binary format.
- ITEMODR.DAT: This contains Inventory and Retainer item sort positions. Binary format.
- KEYBIND.DAT: This contains your Keybinds. Binary format.
- LOGFLTR.DAT:	This contains your Chat log filters. Binairy format.
- MACRO.DAT: This is your Macros. Binary format.
- UISAVE.DAT: This contains timers such as the retainer venture timer, possibly other stuff. Binary format.
- ["log" folder](character-data-folder/chat-log.md) : The game writes your chat history to disk each time its internal buffer overflows, which potentially allows you to retrieve chat history in longer play sessions.
