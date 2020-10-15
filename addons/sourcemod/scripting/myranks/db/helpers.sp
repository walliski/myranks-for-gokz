/* Error report callback for failed transactions */
// Stolen from GOKZ Plugin
public void DB_TxnFailure_Generic(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
    LogError("Database transaction error: %s", error);
}