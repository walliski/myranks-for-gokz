// Client is caller, steamID is rank target
void DB_OpenPlayerRank(int client, int steamID) {
    char query[1024];
    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));

    Transaction txn = SQL_CreateTransaction();

    FormatEx(query, sizeof(query), player_get_name, steamID);
    txn.AddQuery(query);

    for (int i = 0; i < MODE_COUNT; i++)
    {
        FormatEx(query, sizeof(query), player_get_score, steamID, i);
        txn.AddQuery(query);

        FormatEx(query, sizeof(query), player_get_rank, i, i, steamID);
        txn.AddQuery(query);

        FormatEx(query, sizeof(query), player_get_lowest_rank, i);
        txn.AddQuery(query);
    }

    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OpenPlayerRank, DB_TxnFailure_Generic, data, DBPrio_Low);
}


public void DB_TxnSuccess_OpenPlayerRank(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    delete data;

    if (!IsValidClient(client))
    {
        return;
    }

    char playerName[MAX_NAME_LENGTH];
    if (SQL_FetchRow(results[0])) {
        SQL_FetchString(results[0], 0, playerName, sizeof(playerName));
    }

    Menu menu = new Menu(MenuHandler_PlayerRankMenu);
    menu.Pagination = 1; //TODO: Why does this not work?

    // Set submenu title
    menu.SetTitle("%T", "Player Rank - Title", client, playerName);

    // Add submenu items
    char display[512];
    int score;
    int rank;
    int lowestRank;
    for (int i = 0; i < MODE_COUNT; i++)
    {
        int queryIndex = 1+(i*3);
        if (SQL_FetchRow(results[queryIndex]))
        {
            score = SQL_FetchInt(results[queryIndex], 0);
        }

        if (SQL_FetchRow(results[queryIndex + 1]))
        {
            rank = SQL_FetchInt(results[queryIndex + 1], 0);
            rank += 1; // SQL counts amount of players with more score than you.
        }

        if (SQL_FetchRow(results[queryIndex + 2]))
        {
            lowestRank = SQL_FetchInt(results[queryIndex + 2], 0);
        }

        // If you have 0 score, SQL for lowestRank and your rank, will both return all players that have rank, so same amount.
        // The +1 for rank that normally works, will make your rank bigger than the total amount of ranked players, as
        // you are unranked, and not included in the total amount of ranked player count. So we increase the total amount
        // of ranked players.
        if (rank > lowestRank) {
            lowestRank = rank;
        }

        FormatEx(display, sizeof(display), "%T", "Player Rank - Content", client, gC_ModeNames[i], rank, lowestRank, score);
        menu.AddItem(IntToStringEx(i), display, ITEMDRAW_DISABLED);
    }

    menu.Display(client, MENU_TIME_FOREVER);
}


public int MenuHandler_PlayerRankMenu(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_End)
    {
        delete menu;
    }
}
