void DB_CreateTables()
{
    Transaction txn = SQL_CreateTransaction();

    txn.AddQuery(table_create_Myrank);

    SQL_ExecuteTransaction(gH_DB, txn, _, DB_TxnFailure_Generic, _, DBPrio_High);
}