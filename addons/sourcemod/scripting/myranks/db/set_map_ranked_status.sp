void DB_SetMapRankedStatus(int mapID)
{
    char query[1024];
    Transaction txn = SQL_CreateTransaction();

    FormatEx(query, sizeof(query), map_ranked_count_per_mapid, mapID);
    txn.AddQuery(query);

    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SetMapRankedStatus, DB_TxnFailure_Generic, _, DBPrio_High);
}

public void DB_TxnSuccess_SetMapRankedStatus(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    if (SQL_FetchRow(results[0]))
    {
        int mapCount = SQL_FetchInt(results[0], 0);

        if (mapCount > 0) {
            gB_mapInRanked = true;
        }
    }
}