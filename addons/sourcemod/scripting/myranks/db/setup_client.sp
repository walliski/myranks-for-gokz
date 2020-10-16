void DB_SetupClient(int client)
{
    if (IsFakeClient(client))
    {
        return;
    }

    char query[1024];
    int steamID = GetSteamAccountID(client);
    int mode = GOKZ_GetDefaultMode();

    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));
    data.WriteCell(steamID);

    Transaction txn = SQL_CreateTransaction();

    FormatEx(query, sizeof(query), player_insert, steamID);
    txn.AddQuery(query);

    FormatEx(query, sizeof(query), trigger_score_update, steamID, mode);
    txn.AddQuery(query);

    FormatEx(query, sizeof(query), player_get_score, steamID);
    txn.AddQuery(query);

    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SetupClient, DB_TxnFailure_Generic, data, DBPrio_High);
}

public void DB_TxnSuccess_SetupClient(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    int score;
    delete data;

    if (SQL_FetchRow(results[2]))
    {
        score = SQL_FetchInt(results[2], 0);
    }

    gI_Score[client] = score;
}