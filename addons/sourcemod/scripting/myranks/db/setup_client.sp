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

    Transaction txn = SQL_CreateTransaction();

    // For each of the GOKZ modes:
    for (int i = 0; i < MODE_COUNT; i++)
    {
        FormatEx(query, sizeof(query), player_insert, steamID, i);
        txn.AddQuery(query);
    }

    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SetupClient, DB_TxnFailure_Generic, data, DBPrio_High);
}

public void DB_TxnSuccess_SetupClient(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    delete data;

    DB_SetupClientScore(client);
}

void DB_SetupClientScore(int client)
{
    if (IsFakeClient(client))
    {
        return;
    }

    char query[1024];
    int steamID = GetSteamAccountID(client);

    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));

    Transaction txn = SQL_CreateTransaction();

    // For each of the GOKZ modes:
    for (int i = 0; i < MODE_COUNT; i++)
    {
        FormatEx(query, sizeof(query), trigger_score_update, steamID, i);
        txn.AddQuery(query);

        FormatEx(query, sizeof(query), player_get_score, steamID, i);
        txn.AddQuery(query);
    }

    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SetupClientScore, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_SetupClientScore(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    delete data;

    // For each of the GOKZ modes:
    for (int i = 0; i < MODE_COUNT; i++)
    {
        int queryIndex = i * 2 + 1;

        if (SQL_FetchRow(results[queryIndex]))
        {
            int score = SQL_FetchInt(results[queryIndex], 0);
            gI_Score[i][client] = score;
            Call_OnScoreChange(client, score, i);
            Call_OnInitialScoreLoad(client, score, i);
        }
    }
}