char table_create_Myrank[] = "\
CREATE TABLE IF NOT EXISTS Myrank ( \
    SteamID32 INTEGER UNSIGNED NOT NULL, \
    Score INTEGER UNSIGNED NOT NULL DEFAULT 0, \
    LastUpdate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, \
    CONSTRAINT PK_Player PRIMARY KEY (SteamID32))";

char player_insert[] = "\
INSERT IGNORE INTO Myrank (SteamID32, Score, LastUpdate) \
    VALUES (%d, 0, CURRENT_TIMESTAMP)";

char player_get_rank[] = "\
SELECT COUNT(Myrank.SteamID32) \
FROM Myrank \
    INNER JOIN Players ON Players.SteamID32=Myrank.SteamID32 \
    WHERE Players.Cheater=0 \
    AND Score >= \
        (SELECT Score \
        FROM Myrank \
        INNER JOIN Players ON Players.SteamID32=Myrank.SteamID32 \
        WHERE Players.Cheater=0 AND Myrank.SteamID32=%d) \
";

char player_get_lowest_rank[] = "\
SELECT COUNT(Myrank.SteamID32) \
FROM Myrank \
    INNER JOIN Players ON Players.SteamID32=Myrank.SteamID32 \
    WHERE Players.Cheater=0 \
    AND Myrank.Score > 0 \
";

char player_get_score[] = "SELECT Score FROM Myrank WHERE SteamID32=%d";

char trigger_score_update[] = "CALL UpdatePlayerScore(%d, %d)";
