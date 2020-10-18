static float lastCommandTime[MAXPLAYERS + 1];

void RegisterCommands() {
    RegConsoleCmd("sm_rank", Command_Rank, "[KZ] Gets your rank for your current gamemode");
    RegConsoleCmd("sm_ranktop", Command_RankTop, "[KZ] Opens menu to view rank top");

    RegAdminCmd("sm_recalculate_top", Command_Recalculate_Top, ADMFLAG_ROOT, "[KZ] Recalculates player profiles in TOP list");
}

public Action Command_Rank(int client, int args)
{
    if (IsSpammingCommands(client))
    {
        return Plugin_Handled;
    }

    int steamID = GetSteamAccountID(client);

    DB_OpenPlayerRank(client, steamID);

    return Plugin_Handled;
}

public Action Command_RankTop(int client, int args)
{
    if (IsSpammingCommands(client))
    {
        return Plugin_Handled;
    }

    DisplayRankTopModeMenu(client);
    return Plugin_Handled;
}

public Action Command_Recalculate_Top(int client, int args)
{
    if (gB_RecalculationInProgess)
    {
        GOKZ_PrintToChat(client, true, "%t", "Recalculation In Progress");
        return Plugin_Handled;
    }

    DB_RecalculateTop(client);

    return Plugin_Handled;
}

// =====[ PRIVATE ]=====
// Spamming check stolen from GOKZ plugin:
// https://bitbucket.org/kztimerglobalteam/gokz/src/master/addons/sourcemod/scripting/gokz-localranks/commands.sp

bool IsSpammingCommands(int client, bool printMessage = true)
{
    float currentTime = GetEngineTime();
    float timeSinceLastCommand = currentTime - lastCommandTime[client];
    if (timeSinceLastCommand < LR_COMMAND_COOLDOWN)
    {
        if (printMessage)
        {
            GOKZ_PrintToChat(client, true, "%t", "Please Wait Before Using Command", LR_COMMAND_COOLDOWN - timeSinceLastCommand + 0.1);
        }
        return true;
    }

    // Not spamming commands - all good!
    lastCommandTime[client] = currentTime;
    return false;
}