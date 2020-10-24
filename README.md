# MyRanks for GOKZ

An attempt to bring Local ranks into GOKZ. The ranking system that this plugin uses is very similar to the one that
KZTimer has, but also has some differences. The KZTimer ranking system spams the SQL server with a massive amounts of
queries to calculate the player rank, which makes it very slow for players that have completed a lot of maps. This
plugin instead utilizes Stored Procedures in the SQL server, so that we can make a few queries, but still large
calculations in the SQL server itself.

**This unfortunately means that SQLite databases are not supported!**

![Myranks Screenshot](https://github.com/walliski/myranks-for-gokz/blob/main/myrank_screenshots.png?raw=true)

The score calculation has also been changed. KZTimer takes points from finished maps, LJ stats, challenges, and amount
of map completions. In this plugin, the rank is calculated based on map finishes only. Biggest part of the points comes
from which rank you get on the map itself, with a bonus if you are in the top 20, and a small participation award for
first time completions.

The skillgroups (TRAINEE, REGULAR, SEMIPRO, etc.) are based on a percentage (set in config) of the average score of the
top 5 players in each mode. This means that it will jump quite a bit in the beginning, but will smooth out over time. It
is after all a ranking, and not a progression system, so the player that has the most score will always have the best
rank, be it 100 score or 100 000.

The plugin requires GOKZ Localranks to be in use, and that maps that you want to calculate rank based on should be in
the `cfg/sourcemod/gokz/gokz-localranks-mappool.cfg` file, and you run `!updatemappool` to mark them as ranked maps.
Note that this marks them in the DB, so if you have multiple servers on the same DB, they will share the same pool and
you only have to do this on one server.

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

### Myranks Kicker

This plugin will kick players that do not fulfill requirements on either score, skillgroup or both. In case you do not
have a server that is limited to any Score/Skillgroup, you do not need to use this plugin.

Configuration file will be generated in `cfg/sourcemod/myranks/myranks-kicker.cfg`:

```
// This skillgroup and higher will not be kicked. First skillgroup in skillgroup.cfg is number 0.
// -
// Default: "0"
// Minimum: "0.000000"
myrank_minimum_allowed_skillgroup "0"

// This score and higher will not be kicked.
// -
// Default: "0"
// Minimum: "0.000000"
myrank_minimum_allowed_score "0"
```

## Installation / Update

1. Compile the plugin (requires GOKZ, sourcemod-colors and autoexecconfig), or download this repository.
2. Run the SQL files in the `sql` folder on your MySQL/MariaDB server in your GOKZ database, to create the stored
   procedures. The `.sql` files do not need to go to your game server!
3. Optionally manually run the `PopulateBasedOnCompletedMaps(100,2)` stored procedure (first argument is top X players, 
   second is the mode (vnl 0, skz 1, kzt 2), run it for each mode), to populate score for the players that have most
   records on your server. This will make the ranks less volatile in the beginning.
3. Place the files in their correct folders. Remember translations and config files!

## Changelog

* **1.0.1** 20.10.2020  
  Fix max score/skillgroup calculation when player with max score gains more.
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
* Spam protection for chat?
* !profile command
  * Content:
    * Player name
    * Steamid
    * Last Seen
    * Rank
    * Score (skillgroup)
    * Next skillgroup
    * How many pro times?
    * How many tp times? (based on what? Ranked maps? How about Vanilla?)
  * List finished maps
  * List unfinished maps
* Check if map is in ranked pool, and show a different message on finish if it isnt?
* Minimum points for skillgroup?
* Add "minimum rank" for the Kicker plugin.