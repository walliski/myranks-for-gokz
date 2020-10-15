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

void RegisterCommands() {
    RegConsoleCmd("sm_score", Command_Score, "Shows your score");
}

public Action Command_Score(int client, int args)
{
    int steamID = GetSteamAccountID(client);
    char query[1024];

    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));

    FormatEx(query, sizeof(query), player_get_score, steamID);

    Transaction txn = SQL_CreateTransaction();
    txn.AddQuery(query);
    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_GetPlayerScore, DB_TxnFailure_Generic, data, _);

    return Plugin_Handled;
}

public void DB_TxnSuccess_GetPlayerScore(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    int score;
    delete data;

    if (SQL_FetchRow(results[0]))
    {
        score = SQL_FetchInt(results[0], 0);
    }

    PrintToChat(client, "Your score is: %d", score);
}