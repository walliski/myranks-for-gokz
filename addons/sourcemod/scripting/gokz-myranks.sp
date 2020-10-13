#include <sourcemod>
#include <gokz/core>
#include <gokz/localdb>
#include <gokz/localranks>

//#include <gokz-myranks-sql.sp>
#include "gokz-myranks-commands.sp"

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
    }
}

public void GOKZ_DB_OnDatabaseConnect(DatabaseType DBType)
{
    gH_DB = GOKZ_DB_GetDatabase();
    g_DBType = DBType;

    if (g_DBType != DatabaseType_MySQL) {
        SetFailState("Only MySQL/MariaDB databases are supported!");
    }

    DB_CreateTables();
    DB_CreateProcedures();
}

void DB_CreateTables()
{
    // Transaction txn = SQL_CreateTransaction();
    
    // txn.AddQuery(someQueryName);
    // }
    
    // SQL_ExecuteTransaction(gH_DB, txn, _, _, _, DBPrio_High);
} 

void DB_CreateProcedures()
{
    // Transaction txn = SQL_CreateTransaction();
    
    // txn.AddQuery(someQueryName);
    // }
    
    // SQL_ExecuteTransaction(gH_DB, txn, _, _, _, DBPrio_High);
}
