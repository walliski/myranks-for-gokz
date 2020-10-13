void RegisterCommands() {
    RegConsoleCmd("sm_rank", Command_Rank, "Shows rank");
    RegConsoleCmd("sm_ranktop", Command_RankTop, "Shows rank top");
}

public Action Command_Rank(int client, int args)
{
    PrintToServer("Rank:");

    return Plugin_Handled;
}

public Action Command_RankTop(int client, int args)
{
    PrintToServer("RankTop:");

    return Plugin_Handled;
}