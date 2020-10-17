public void DB_GetPlayerScore(int client, int mode)
{
    int steamID = GetSteamAccountID(client);
    char query[1024];

    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));
    data.WriteCell(mode);

    FormatEx(query, sizeof(query), player_get_score, steamID, mode);

    Transaction txn = SQL_CreateTransaction();
    txn.AddQuery(query);
    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_GetPlayerScore, DB_TxnFailure_Generic, data, _);
}

public void DB_TxnSuccess_GetPlayerScore(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    int mode = data.ReadCell();
    int score;
    delete data;

    if (SQL_FetchRow(results[0]))
    {
        score = SQL_FetchInt(results[0], 0);
    }

    GOKZ_PrintToChat(client, true, "%t", "Your Score Is", score, gC_ModeNamesShort[mode]);
}