void DB_OnNewRecord(int client, int steamID) {
    char query[1024];
    int mode = GOKZ_GetDefaultMode();
    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));

    gI_OldScore[client] = gI_Score[client];

    Transaction txn = SQL_CreateTransaction();

    FormatEx(query, sizeof(query), trigger_score_update, steamID, mode);
    txn.AddQuery(query);

    FormatEx(query, sizeof(query), player_get_score, steamID);
    txn.AddQuery(query);

    FormatEx(query, sizeof(query), player_get_rank, steamID);
    txn.AddQuery(query);

    FormatEx(query, sizeof(query), player_get_lowest_rank, steamID);
    txn.AddQuery(query);

    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OnNewRecord, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_OnNewRecord(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    int mode = GOKZ_GetDefaultMode();
    int score;
    int rank;
    int lowestRank;
    int gainedScore;
    delete data;

    if (SQL_FetchRow(results[1]))
    {
        score = SQL_FetchInt(results[1], 0);
    }

    if (SQL_FetchRow(results[2]))
    {
        rank = SQL_FetchInt(results[2], 0);
    }

    if (SQL_FetchRow(results[3]))
    {
        lowestRank = SQL_FetchInt(results[3], 0);
    }

    gI_Score[client] = score;

    gainedScore = gI_Score[client] - gI_OldScore[client];

    // If someone would happen to steal a rank while this is running update?
    if (gainedScore < 0) {
        gainedScore = 0;
    }

    GOKZ_PrintToChatAll(true, "%t", "Player Finished Map", client, gainedScore, score, rank, lowestRank, gC_ModeNamesShort[mode]);
}