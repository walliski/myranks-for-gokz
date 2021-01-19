// This file is stole from GOKZ, and later modified to add the Myranks functionality

#include <sourcemod>

#include <cstrike>

#include <gokz/core>
#include <myranks>

#include <autoexecconfig>
#include <sourcemod-colors>

#undef REQUIRE_EXTENSIONS
#undef REQUIRE_PLUGIN
#include <basecomm>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
    name = "GOKZ Chat (Myranks edition)",
    author = "DanZay (& Myranks - Walliski)",
    description = "Handles client-triggered chat messages",
    version = MYRANK_VERSION,
    url = "https://github.com/walliski/myranks-for-gokz"
};

bool gB_BaseComm;

ConVar gCV_gokz_chat_processing;
ConVar gCV_gokz_connection_messages;
ConVar gCV_myranks_chattags_admin;
ConVar gCV_myranks_chattags_vip;



// =====[ PLUGIN EVENTS ]=====

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    RegPluginLibrary("myranks-chat");
    return APLRes_Success;
}

public void OnPluginStart()
{
    LoadTranslations("myranks-chat.phrases");

    CreateConVars();
    HookEvents();

    OnPluginStart_BlockRadio();
}

public void OnAllPluginsLoaded()
{
    gB_BaseComm = LibraryExists("basecomm");
}

public void OnLibraryAdded(const char[] name)
{
    gB_BaseComm = gB_BaseComm || StrEqual(name, "basecomm");
}

public void OnLibraryRemoved(const char[] name)
{
    gB_BaseComm = gB_BaseComm && !StrEqual(name, "basecomm");
}

// From Sourcebans++
// https://github.com/sbpp/sourcebans-pp/blob/315f08f35dda1c196ec544dd3f0160d148ec569f/game/addons/sourcemod/scripting/sbpp_main.sp
public void OnConfigsExecuted()
{
    char filename[200];
    BuildPath(Path_SM, filename, sizeof(filename), "plugins/gokz-chat.smx");
    if (FileExists(filename))
    {
        char newfilename[200];
        BuildPath(Path_SM, newfilename, sizeof(newfilename), "plugins/disabled/gokz-chat.smx");
        ServerCommand("sm plugins unload gokz-chat");
        if (FileExists(newfilename))
            DeleteFile(newfilename);
        RenameFile(newfilename, filename);
        LogError("plugins/gokz-chat.smx was unloaded and moved to plugins/disabled/gokz-chat.smx. Do not use both plugins at the same time.");
    }
}


// =====[ CLIENT EVENTS ]=====

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    if (gCV_gokz_chat_processing.BoolValue && IsClientInGame(client))
    {
        OnClientSayCommand_ChatProcessing(client, command, sArgs);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
    PrintConnectMessage(client);
}

public Action OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast) // player_disconnect pre hook
{
    event.BroadcastDisabled = true; // Block disconnection messages
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidClient(client))
    {
        PrintDisconnectMessage(client, event);
    }
    return Plugin_Continue;
}

public Action OnPlayerJoinTeam(Event event, const char[] name, bool dontBroadcast) // player_team pre hook
{
    event.SetBool("silent", true); // Block join team messages
    return Plugin_Continue;
}



// =====[ GENERAL ]=====

void CreateConVars()
{
    AutoExecConfig_SetFile("myranks-chat", "sourcemod/myranks");
    AutoExecConfig_SetCreateFile(true);

    gCV_gokz_chat_processing = AutoExecConfig_CreateConVar("gokz_chat_processing", "1", "Whether GOKZ processes player chat messages.", _, true, 0.0, true, 1.0);
    gCV_gokz_connection_messages = AutoExecConfig_CreateConVar("gokz_connection_messages", "1", "Whether GOKZ handles connection and disconnection messages.", _, true, 0.0, true, 1.0);

    gCV_myranks_chattags_admin = AutoExecConfig_CreateConVar("myranks_chattags_admin", "1", "Should the ADMIN tag be shown in chat?", _, true, 0.0, true, 1.0);
    gCV_myranks_chattags_vip = AutoExecConfig_CreateConVar("myranks_chattags_vip", "1", "Should the VIP tag be shown in chat?", _, true, 0.0, true, 1.0);

    AutoExecConfig_ExecuteFile();
    AutoExecConfig_CleanFile();
}

void HookEvents()
{
    HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);
    HookEvent("player_team", OnPlayerJoinTeam, EventHookMode_Pre);
}



// =====[ CHAT PROCESSING ]=====

void OnClientSayCommand_ChatProcessing(int client, const char[] command, const char[] message)
{
    if (gB_BaseComm && BaseComm_IsClientGagged(client)
         || UsedBaseChat(client, command, message))
    {
        return;
    }

    // Resend messages that may have been a command with capital letters
    if ((message[0] == '!' || message[0] == '/') && IsCharUpper(message[1]))
    {
        char loweredMessage[128];
        String_ToLower(message, loweredMessage, sizeof(loweredMessage));
        FakeClientCommand(client, "say %s", loweredMessage);
        return;
    }

    char sanitisedMessage[128];
    strcopy(sanitisedMessage, sizeof(sanitisedMessage), message);
    SanitiseChatInput(sanitisedMessage, sizeof(sanitisedMessage));

    char sanitisedName[MAX_NAME_LENGTH];
    GetClientName(client, sanitisedName, sizeof(sanitisedName));
    SanitiseChatInput(sanitisedName, sizeof(sanitisedName));

    int mode = GOKZ_GetCoreOption(client, Option_Mode);
    int score = Myrank_GetScore(client, mode);
    int skillGroup = Myrank_GetSkillGroup(score, mode);

    char skillGroupName[MYRANK_SG_NAME_MAXLENGTH];
    Myrank_GetSkillGroupName(skillGroup, skillGroupName);
    char skillGroupColor[MYRANK_SG_NAME_MAXLENGTH];
    Myrank_GetSkillGroupColor(skillGroup, skillGroupColor);

    char isSpec[3];
    if (IsSpectating(client))
        strcopy(isSpec, sizeof(isSpec), "* ");
    else
        strcopy(isSpec, sizeof(isSpec), "");

    char chattag[40];
    if (gCV_myranks_chattags_admin.BoolValue && CheckCommandAccess(client, "myranks_tags_admin", ADMFLAG_GENERIC))
        strcopy(chattag, sizeof(chattag), " {default}| {darkred}ADMIN{default}");
    else if (gCV_myranks_chattags_vip.BoolValue && CheckCommandAccess(client, "myranks_tags_vip", ADMFLAG_RESERVATION))
        strcopy(chattag, sizeof(chattag), " {default}| {gold}VIP{default}");
    else
        strcopy(chattag, sizeof(chattag), "");

    if (TrimString(sanitisedMessage) == 0)
    {
        return;
    }

    GOKZ_PrintToChatAll(false, "[{purple}%s {default}| %s%s{default}%s] %s{lime}%s{default} : %s", gC_ModeNamesShort[mode], skillGroupColor, skillGroupName, chattag, isSpec, sanitisedName, sanitisedMessage);
    PrintToConsoleAll("%s%s : %s", isSpec, sanitisedName, sanitisedMessage);
    PrintToServer("%s%s : %s", isSpec, sanitisedName, sanitisedMessage);
}

bool UsedBaseChat(int client, const char[] command, const char[] message)
{
    // Assuming base chat is in use, check if message will get processed by basechat
    if (message[0] != '@')
    {
        return false;
    }

    if (strcmp(command, "say_team", false) == 0)
    {
        return true;
    }
    else if (strcmp(command, "say", false) == 0 && CheckCommandAccess(client, "sm_say", ADMFLAG_CHAT))
    {
        return true;
    }

    return false;
}

void SanitiseChatInput(char[] message, int maxlength)
{
    Color_StripFromChatText(message, message, maxlength);
    CRemoveColors(message, maxlength);
    // Chat gets double formatted, so replace '%' with '%%%%' to end up with '%'
    ReplaceString(message, maxlength, "%", "%%%%");
}



// =====[ CONNECTION MESSAGES ]=====

void PrintConnectMessage(int client)
{
    if (!gCV_gokz_connection_messages.BoolValue || IsFakeClient(client))
    {
        return;
    }

    GOKZ_PrintToChatAll(false, "%t", "Client Connection Message", client);
}

void PrintDisconnectMessage(int client, Event event) // Hooked to player_disconnect event
{
    if (!gCV_gokz_connection_messages.BoolValue || IsFakeClient(client))
    {
        return;
    }

    char reason[128];
    event.GetString("reason", reason, sizeof(reason));
    GOKZ_PrintToChatAll(false, "%t", "Client Disconnection Message", client, reason);
}



// =====[ BLOCK RADIO ]=====

static char radioCommands[][] =
{
    "coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go",
    "fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot",
    "needbackup", "sectorclear", "inposition", "reportingin", "getout", "negative",
    "enemydown", "compliment", "thanks", "cheer", "go_a", "go_b", "sorry", "needrop"
};

public void OnPluginStart_BlockRadio()
{
    for (int i = 0; i < sizeof(radioCommands); i++)
    {
        AddCommandListener(CommandBlock, radioCommands[i]);
    }
}

public Action CommandBlock(int client, const char[] command, int argc)
{
    return Plugin_Handled;
}