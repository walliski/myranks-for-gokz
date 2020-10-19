# MyRanks for GOKZ

An attempt to bring Local ranks into GOKZ. The ranking system that this plugin uses is very similar to the one that
KZTimer has, but also has some differences. The KZTimer ranking system spams the SQL server with a massive amounts of
queries to calculate the player rank, which makes it very slow for players that have completed a lot of maps. This
plugin instead utilizes Stored Procedures in the SQL server, so that we can make a few queries, but still large
calculations in the SQL server itself.

**This unfortunately means that SQLite databases are not supported!**

The score calculation has also been changed. KZTimer takes points from finished maps, LJ stats, challenges, and amount
of map completions. In this plugin, the rank is calculated based on map finishes only. Biggest part of the points comes
from which rank you get on the map itself, with a bonus if you are in the top 20, and a small participation award for
first time completions.

## Plugins & Commands

This plugin consists of three main plugins.

### Myranks

This is the main plugin that handles calculating score for players, parsing of skillgroups etc. With this plugin you
will get access to the following commands:

* `sm_rank <player>` - Opens a menu that shows the rank of a player on the server, or yourself if no player specified.
* `sm_ranks` - Shows the "skillgroups", and how many points you need for them, in your current mode.
* `sm_ranktop` - Opens a menu for you to browse the top ranked players in each mode.

Admin commands:

* `sm_recalculate_top` - Recalculates Top 100 ranks in each mode.

### Myranks Chat

This is a copy of the GOKZ Chat processing plugin. It takes care of adding your current mode and skillgroup in front of
your name in the chat. When using this, do not use `gokz-chat.smx` at the same time. Configuration happens the same way
as for GOKZ-Chat plugin.

### Myranks Clantags

This is a copy of the GOKZ Clantags plugin. It changes the clantag of players in the scoreboard to contain their current
selected mode, and the skillgroup for that mode. When using this, do not use `gokz-clantags.smx` at the same time.

## Installation / Update

1. Compile the plugin (requires GOKZ, sourcemod-colors and autoexecconfig), or download this repository.
2. Run the SQL files in the `sql` folder on your MySQL/MariaDB server in your GOKZ database, to create the stored
   procedures. The `.sql` files do not need to go to your game server!
3. Place the files in their correct folders. Remember translations and config files!

## Changelog

* **1.0.0** 20.10.2020
  Initial Release

## Credits

A large part of SQL queries and code in this plugin has been copy-pasted and changed from the original GOKZ plugins. I
have tried my best to mark these in places where the code has been used, and in the git history.

## TODO / Other ideas

Some other ideas that could be implemented for this plugin:

* Enable DB search for player !rank. Currently only for in-game players.
* Foreign keys with delete cascade for the Myrank table?
* Stored procedures as a part of the plugin?
