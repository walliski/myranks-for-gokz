void DB_RecalculateTop(int client) {
    char query[1024];
    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));

    int topAmount = 100;

    Transaction txn = SQL_CreateTransaction();

    for (int i = 0; i < MODE_COUNT; i++)
    {
        FormatEx(query, sizeof(query), trigger_recalculate_top, topAmount, i);
        txn.AddQuery(query);
    }

    gB_RecalculationInProgess = true;
    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_RecalculateTop, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_RecalculateTop(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    delete data;

    gB_RecalculationInProgess = false;

    GOKZ_PrintToChat(client, true, "%t", "Recalculation Complete");
}