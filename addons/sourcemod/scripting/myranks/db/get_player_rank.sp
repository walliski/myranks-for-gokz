void DB_GetPlayerRank(int client, int steamID, int mode) {
    char query[1024];
    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));
    data.WriteCell(mode);

    Transaction txn = SQL_CreateTransaction();

    FormatEx(query, sizeof(query), player_get_score, steamID, mode);
    txn.AddQuery(query);

    FormatEx(query, sizeof(query), player_get_rank, mode, mode, steamID);
    txn.AddQuery(query);

    FormatEx(query, sizeof(query), player_get_lowest_rank, mode);
    txn.AddQuery(query);

    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_GetPlayerRank, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_GetPlayerRank(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    int mode = data.ReadCell();
    int score;
    int rank;
    int lowestRank;
    delete data;

    if (SQL_FetchRow(results[0]))
    {
        score = SQL_FetchInt(results[0], 0);
    }

    if (SQL_FetchRow(results[1]))
    {
        rank = SQL_FetchInt(results[1], 0);
    }

    if (SQL_FetchRow(results[2]))
    {
        lowestRank = SQL_FetchInt(results[2], 0);
    }

    gI_Score[mode][client] = score;

    GOKZ_PrintToChatAll(true, "%t", "You Are Ranked", rank, lowestRank, score, gC_ModeNamesShort[mode]);
}