static float lastCommandTime[MAXPLAYERS + 1];

void RegisterCommands() {
    RegConsoleCmd("sm_rank", Command_Rank, "[KZ] Gets your rank for your current gamemode");
}

public Action Command_Rank(int client, int args)
{
    if (IsSpammingCommands(client))
    {
        return Plugin_Handled;
    }

    int mode = GOKZ_GetCoreOption(client, Option_Mode);
    int steamID = GetSteamAccountID(client);

    DB_GetPlayerRank(client, steamID, mode);

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