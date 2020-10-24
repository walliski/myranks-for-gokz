#include <sourcemod>

#include <autoexecconfig>
#include <gokz/core>
#include <myranks>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
    name = "Myranks Kicker",
    author = "Walliski",
    description = "Kicks players based on Score/Skillgroup",
    version = MYRANK_VERSION,
    url = "https://github.com/walliski/myranks-for-gokz"
};

ConVar gCV_myrank_minimum_allowed_skillgroup;
ConVar gCV_myrank_minimum_allowed_score;

public void OnPluginStart()
{
    LoadTranslations("myranks-kicker.phrases");

    CreateConVars();
}

void CreateConVars()
{
    AutoExecConfig_SetFile("myranks-kicker", "sourcemod/myranks");
    AutoExecConfig_SetCreateFile(true);

    gCV_myrank_minimum_allowed_skillgroup = AutoExecConfig_CreateConVar("myrank_minimum_allowed_skillgroup", "0", "This skillgroup and higher will not be kicked. First skillgroup in skillgroup.cfg is number 0.", _, true, 0.0);
    gCV_myrank_minimum_allowed_score = AutoExecConfig_CreateConVar("myrank_minimum_allowed_score", "0", "This score and higher will not be kicked.", _, true, 0.0);

    AutoExecConfig_ExecuteFile();
    AutoExecConfig_CleanFile();
}

public void Myrank_OnInitialScoreLoad(int client, int newScore, int mode)
{
    if (mode != GOKZ_GetDefaultMode() || CheckCommandAccess(client, "myrank_kicker_immunity", ADMFLAG_RESERVATION)) {
        return;
    }

    if (newScore < gCV_myrank_minimum_allowed_score.IntValue) {
        KickClient(client, "%t", "Score Kick", gC_ModeNamesShort[mode], gCV_myrank_minimum_allowed_score.IntValue);
    }

    int skillGroup = Myrank_GetSkillGroup(newScore, mode);

    char skillGroupName[MYRANK_SG_NAME_MAXLENGTH];
    Myrank_GetSkillGroupName(skillGroup, skillGroupName);

    if (skillGroup < gCV_myrank_minimum_allowed_skillgroup.IntValue) {
        KickClient(client, "%t", "Skillgroup Kick", gC_ModeNamesShort[mode], skillGroupName);
    }
}