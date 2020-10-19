// This file is stole from GOKZ, and later modified to add the Myranks functionality

#include <sourcemod>

#include <cstrike>

#include <gokz/core>
#include <myranks>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = 
{
    name = "GOKZ Clan Tags (Myranks edition)", 
    author = "DanZay (& Myranks - Walliski)", 
    description = "Sets the clan tags of players", 
    version = MYRANK_VERSION, 
    url = "https://github.com/walliski/myranks-for-gokz"
};

#define TAG_MAX_LENGTH 15

// =====[ CLIENT EVENTS ]=====

// From Sourcebans++
// https://github.com/sbpp/sourcebans-pp/blob/315f08f35dda1c196ec544dd3f0160d148ec569f/game/addons/sourcemod/scripting/sbpp_main.sp
public void OnConfigsExecuted()
{
    char filename[200];
    BuildPath(Path_SM, filename, sizeof(filename), "plugins/gokz-clantags.smx");
    if (FileExists(filename))
    {
        char newfilename[200];
        BuildPath(Path_SM, newfilename, sizeof(newfilename), "plugins/disabled/gokz-clantags.smx");
        ServerCommand("sm plugins unload gokz-clantags");
        if (FileExists(newfilename))
            DeleteFile(newfilename);
        RenameFile(newfilename, filename);
        LogError("plugins/gokz-clantags.smx was unloaded and moved to plugins/disabled/gokz-clantags.smx. Do not use both plugins at the same time.");
    }
}

public void OnClientPutInServer(int client)
{
    UpdateClanTag(client);
}

public void GOKZ_OnOptionChanged(int client, const char[] option, any newValue)
{
    Option coreOption;
    if (!GOKZ_IsCoreOption(option, coreOption))
    {
        return;
    }
    
    if (coreOption == Option_Mode)
    {
        UpdateClanTag(client);
    }
}

public void Myrank_OnScoreChange(int client, int newScore, int mode)
{
    UpdateClanTag(client);
}

public void Myrank_OnMaxScoreChange(int newScore, int mode)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client) && !IsFakeClient(client))
        {
            int clientMode = GOKZ_GetCoreOption(client, Option_Mode);

            if (clientMode == mode) {
                UpdateClanTag(client);
            }
        }
    }
}

void UpdateClanTag(int client)
{
    if (IsClientInGame(client) && !IsFakeClient(client))
    {
        int mode = GOKZ_GetCoreOption(client, Option_Mode);
        int score = Myrank_GetScore(client, mode);
        int skillGroup = Myrank_GetSkillGroup(score, mode);

        char skillGroupName[MYRANK_SG_NAME_MAXLENGTH];
        Myrank_GetSkillGroupName(skillGroup, skillGroupName);

        char buffer[TAG_MAX_LENGTH];
        Format(buffer, TAG_MAX_LENGTH, "%s | %s", gC_ModeNamesShort[mode], skillGroupName);

        CS_SetClientClanTag(client, buffer);
    }
}
