#include <sourcemod>
#include <gokz/core>
#include <gokz/localdb>
#include <gokz/localranks>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
    name = "MyRanks for GOKZ",
    author = "Walliski",
    description = "KZTimer-isch ranks for GOKZ on MySQL DB",
    version = "0.0.1",
    url = ""
};

Database gH_DB = null;
DatabaseType g_DBType = DatabaseType_None;
int gI_Score[MODE_COUNT][MAXPLAYERS + 1];
int gI_OldScore[MODE_COUNT][MAXPLAYERS + 1];

#include "myranks/db/sql.sp"
#include "myranks/db/helpers.sp"
#include "myranks/db/setup_client.sp"
#include "myranks/db/setup_database.sp"
#include "myranks/db/get_player_rank.sp"
#include "myranks/db/player_on_new_record.sp"
#include "myranks/commands.sp"

public void OnPluginStart()
{
    LoadTranslations("myranks.phrases");

    RegisterCommands();
}

public void OnAllPluginsLoaded()
{
    gH_DB = GOKZ_DB_GetDatabase();
    if (gH_DB != null)
    {
        g_DBType = GOKZ_DB_GetDatabaseType();
        if (g_DBType != DatabaseType_MySQL) {
            SetFailState("Only MySQL/MariaDB databases are supported!");
        }

        DB_CreateTables();
    }
}

public void OnClientAuthorized(int client, const char[] auth)
{
    DB_SetupClient(client);
}

public void GOKZ_DB_OnDatabaseConnect(DatabaseType DBType)
{
    gH_DB = GOKZ_DB_GetDatabase();
    g_DBType = DBType;

    if (g_DBType != DatabaseType_MySQL) {
        SetFailState("Only MySQL/MariaDB databases are supported!");
    }

    DB_CreateTables();
}

public void GOKZ_LR_OnTimeProcessed(
    int client,
    int steamID,
    int mapID,
    int course,
    int mode,
    int style,
    float runTime,
    int teleportsUsed,
    bool firstTime,
    float pbDiff,
    int rank,
    int maxRank,
    bool firstTimePro,
    float pbDiffPro,
    int rankPro,
    int maxRankPro
)
{
    if (course != 0) {
        return;
    }

    if (pbDiff < 0 || pbDiffPro < 0 || firstTime || firstTimePro) // Negative diffs means new best time!
    {
        DB_OnNewRecord(client, steamID, mode);
    }
}

