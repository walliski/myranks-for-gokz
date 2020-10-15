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

    SQL_ExecuteTransaction(gH_DB, txn, _, DB_TxnFailure_Generic, _, DBPrio_High);
}
