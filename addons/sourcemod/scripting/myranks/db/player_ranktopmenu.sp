// This is mostly stolen from GOKZ Top menu, and redone for Myrank

void DB_OpenRankTop(int client, int mode)
{
    char query[1024];

    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));
    data.WriteCell(mode);

    Transaction txn = SQL_CreateTransaction();

    // Get top players
    FormatEx(query, sizeof(query), player_get_top, mode, MYRANK_RANKTOP_CUTOFF);
    txn.AddQuery(query);

    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OpenRankTop, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenRankTop(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    int mode = data.ReadCell();
    delete data;

    if (!IsValidClient(client))
    {
        return;
    }

    Menu menu = new Menu(MenuHandler_RankTopSubmenu);
    menu.Pagination = 5;

    // Set submenu title
    menu.SetTitle("%T", "Rank Top Submenu - Title", client,
        MYRANK_RANKTOP_CUTOFF, gC_ModeNames[mode]);

    // Add submenu items
    char display[256];
    int rank = 0;
    while (SQL_FetchRow(results[0]))
    {
        rank++;
        char playerString[33];
        SQL_FetchString(results[0], 1, playerString, sizeof(playerString));
        FormatEx(display, sizeof(display), "#%-2d   %s (%d)", rank, playerString, SQL_FetchInt(results[0], 2));
        menu.AddItem(IntToStringEx(SQL_FetchInt(results[0], 0)), display, ITEMDRAW_DISABLED);
    }

    menu.Display(client, MENU_TIME_FOREVER);
}



// =====[ MENUS ]=====

void DisplayRankTopModeMenu(int client)
{
    Menu menu = new Menu(MenuHandler_RankTopMode);
    menu.SetTitle("%T", "Player Rank Top Mode Menu - Title", client);
    GOKZ_MenuAddModeItems(client, menu, false);
    menu.Display(client, MENU_TIME_FOREVER);
}


// =====[ MENU HANLDERS ]=====

public int MenuHandler_RankTopMode(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        DB_OpenRankTop(param1, param2);
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

public int MenuHandler_RankTopSubmenu(Menu menu, MenuAction action, int param1, int param2)
{
    // Menu item info is player's SteamID32, but is currently not used
    if (action == MenuAction_Cancel && param2 == MenuCancel_Exit)
    {
        DisplayRankTopModeMenu(param1);
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}