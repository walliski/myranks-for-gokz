void DB_SetupClient(int client)
{
    if (IsFakeClient(client))
    {
        return;
    }

    char query[1024];
    int steamID = GetSteamAccountID(client);

    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));
    data.WriteCell(steamID);

    Transaction txn = SQL_CreateTransaction();

    // For each of the GOKZ modes:
    for (int i = 0; i < MODE_COUNT; i++)
    {
        FormatEx(query, sizeof(query), player_insert, steamID, i);
        txn.AddQuery(query);

        FormatEx(query, sizeof(query), trigger_score_update, steamID, i);
        txn.AddQuery(query);

        FormatEx(query, sizeof(query), player_get_score, steamID, i);
        txn.AddQuery(query);
    }

    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SetupClient, DB_TxnFailure_Generic, data, DBPrio_High);
}

public void DB_TxnSuccess_SetupClient(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    delete data;

    // For each of the GOKZ modes:
    for (int i = 0; i < MODE_COUNT; i++)
    {
        int queryIndex = i * 3 + 2;
        if (SQL_FetchRow(results[queryIndex]))
        {
            gI_Score[i][client] = SQL_FetchInt(results[queryIndex], 0);
        }
    }
}