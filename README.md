# GOKZ-myranks

A desperate attempt to get the ranks from KZTimer into GOKZ, to close the feature gap a bit. While it tries to copy the
same method as KZTimer does, there is one large difference. In KZTimer the plugin does thousands of SQL queries to
calculate the rank for a player that has finished many maps. This is the main reason why the rank calculation is so
slow.

myranks solves this, by utilizing stored procedures in the SQL server, which means that one query can trigger all the
calculations that are needed to get a rank, which should (?) be a lot quicker.

*This unfortunately means that SQL Lite databases are not supported!*

Oh... And this ranking does not (at least at the moment) care about anything else than pure map times. So you will not
get extra points from challenges, you will not get extra points from LJs, or extra points from completing the same map
1000 times.