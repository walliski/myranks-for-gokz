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

    FormatEx(query, sizeof(query), player_insert, steamID);

    Transaction txn = SQL_CreateTransaction();
    txn.AddQuery(query);
    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SetupClient, DB_TxnFailure_Generic, data, DBPrio_High);
}

public void DB_TxnSuccess_SetupClient(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    //int steamID = data.ReadCell();
    delete data;

    UpdateScore(client);
}

void UpdateScore(int client) {
    int steamID = GetSteamAccountID(client);
    int mode = GOKZ_GetDefaultMode();
    char query[1024];

    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));
    data.WriteCell(steamID);

    FormatEx(query, sizeof(query), trigger_score_update, steamID, mode);

    Transaction txn = SQL_CreateTransaction();
    txn.AddQuery(query);
    SQL_ExecuteTransaction(gH_DB, txn, _, DB_TxnFailure_Generic, data, _);
}