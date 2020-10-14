#include <sourcemod>
#include <gokz/core>
#include <gokz/localdb>
#include <gokz/localranks>

#include "gokz-myranks-commands.sp"
#include "gokz-myranks-sql.sp"

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
    name = "GOKZ MyRank",
    author = "Walliski",
    description = "KZTimer-isch ranks for GOKZ on MySQL DB",
    version = "0.0.1",
    url = ""
};

Database gH_DB = null;
DatabaseType g_DBType = DatabaseType_None;

bool g_Calculating[MAXPLAYERS+1];
int g_Points[MAXPLAYERS+1];

public void OnPluginStart()
{
    // Register commands
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

void DB_SetupClient(int client)
{
    if (IsFakeClient(client))
    {
        return;
    }

    char query[1024];
    int steamID = GetSteamAccountID(client);

    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));
    data.WriteCell(steamID);

    FormatEx(query, sizeof(query), player_insert, steamID);

    Transaction txn = SQL_CreateTransaction();
    txn.AddQuery(query);
    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SetupClient, DB_TxnFailure_Generic, data, DBPrio_High);
}

public void DB_TxnSuccess_SetupClient(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    //int steamID = data.ReadCell();
    delete data;

    UpdateScore(client);
}

void UpdateScore(int client) {
    int steamID = GetSteamAccountID(client);
    int mode = 2;
    char query[1024];

    DataPack data = new DataPack();
    data.WriteCell(GetClientUserId(client));
    data.WriteCell(steamID);

    FormatEx(query, sizeof(query), trigger_score_update, steamID, mode);

    Transaction txn = SQL_CreateTransaction();
    txn.AddQuery(query);
    SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_UpdateScore, DB_TxnFailure_Generic, data, _);
}

public void DB_TxnSuccess_UpdateScore(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
    data.Reset();
    int client = GetClientOfUserId(data.ReadCell());
    int steamID = data.ReadCell();
    delete data;

    PrintToServer("I Did something for steamid: %d %d", client, steamID);
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

/* Error report callback for failed transactions */
// Stolen from GOKZ
public void DB_TxnFailure_Generic(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
    LogError("Database transaction error: %s", error);
}

void DB_CreateTables()
{
    Transaction txn = SQL_CreateTransaction();

    txn.AddQuery(table_create_Myrank);

    SQL_ExecuteTransaction(gH_DB, txn, _, DB_TxnFailure_Generic, _, DBPrio_High);
}
