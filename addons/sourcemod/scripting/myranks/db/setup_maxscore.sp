void DB_SetupMaxScore()
{
    char query[1024];

    Transaction txn = SQL_CreateTransaction();

    // For each of the GOKZ modes:
    for (int i = 0; i < MODE_COUNT; i++)
    {
        FormatEx(query, sizeof(query), mode_get_max_score, i);
        txn.AddQuery(query);
    }

    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SetupMaxScore, DB_TxnFailure_Generic, _, DBPrio_High);
}

public void DB_TxnSuccess_SetupMaxScore(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    // For each of the GOKZ modes:
    for (int i = 0; i < MODE_COUNT; i++)
    {
        int queryIndex = i;
        if (SQL_FetchRow(results[queryIndex]))
        {
            int score = SQL_FetchInt(results[queryIndex], 0);
            gI_MaxScore[i] = score;
            Call_OnMaxScoreChange(score, i);
        }
    }

    SetSkillGroups();
}