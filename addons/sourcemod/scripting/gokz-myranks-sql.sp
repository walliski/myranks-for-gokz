char table_create_Myrank[] = "\
CREATE TABLE IF NOT EXISTS Myrank ( \
    SteamID32 INTEGER UNSIGNED NOT NULL, \
    Score INTEGER UNSIGNED NOT NULL DEFAULT 0, \
    LastUpdate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, \
    CONSTRAINT PK_Player PRIMARY KEY (SteamID32))";

char player_insert[] = "\
INSERT IGNORE INTO Myrank (SteamID32, Score, LastUpdate) \
    VALUES (%d, 0, CURRENT_TIMESTAMP)";

char trigger_score_update[] = "CALL UpdatePlayerScore(%d, %d)";