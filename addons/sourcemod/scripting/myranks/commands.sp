void RegisterCommands() {
    RegConsoleCmd("sm_score", Command_Score, "Shows your score");
}

public Action Command_Score(int client, int args)
{
    DB_GetPlayerScore(client);

    return Plugin_Handled;
}
