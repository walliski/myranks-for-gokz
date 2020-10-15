#include <sourcemod>
#include <gokz/core>
#include <gokz/localdb>
#include <gokz/localranks>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
    name = "MyRank for GOKZ",
    author = "Walliski",
    description = "KZTimer-isch ranks for GOKZ on MySQL DB",
    version = "0.0.1",
    url = ""
};

Database gH_DB = null;
DatabaseType g_DBType = DatabaseType_None;

#include "myranks/db/sql.sp"
#include "myranks/db/helpers.sp"
#include "myranks/db/setup_client.sp"
#include "myranks/db/setup_database.sp"
#include "myranks/db/get_player_score.sp"
#include "myranks/commands.sp"

public void OnPluginStart()
{
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

