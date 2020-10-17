# MyRanks for GOKZ

A desperate attempt to get the ranks from KZTimer into GOKZ, to close the feature gap a bit. While it tries to copy the
same method as KZTimer does, there is one large difference. In KZTimer the plugin does thousands of SQL queries to
calculate the rank for a player that has finished many maps. This is the main reason why the rank calculation is so
slow.

MyRanks solves this, by utilizing stored procedures in the SQL server, which means that one query can trigger all the
calculations that are needed to get a rank, which should (?) be a lot quicker.

*This unfortunately means that SQL Lite databases are not supported!*

Oh... And this ranking does not (at least at the moment) care about anything else than pure map times. So you will not
get extra points from challenges, you will not get extra points from LJs, or extra points from completing the same map
1000 times, etc, etc.

## Features

* Shitty code (although a bit cleaned up...)!
* Automatic calculation of score when you join!
* Difficult plugin updates!
* !score command that tells you your score, but not your rank!

## Credits

Have taken example from a lot of things from GOKZ Plugin, and mangled it. Most noticeable the queries used in the stored
procedures.

## Installation

Compile the plugin, it should only require GOKZ, nothing more. Copy it over to your server. Remember the translations!

Make sure you are running MySQL/MariaDB. Put in the stored procedures from the `.sql` files in the `sql` folder into
your GOKZ database. Then watch the world burn, because this is not tested with anything else than a random MariaDB
version in Docker...

## TODO

What else could be done for this, to make it less of a POC, and more like a real thing? In no particular order:

* "Named" ranks
    * Define ranks in config (as % of max points?)
    * Show ranks in chat
    * Show ranks on scoreboard
    * !ranks command that shows all the ranks and points needed?
* !rank improvements
  * Enable targeting of player
  * Open menu that shows all gamemodes?
* Foreign keys with delete cascade for the Myrank table?
