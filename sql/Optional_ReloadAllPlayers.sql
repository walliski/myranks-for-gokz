-- Reload all players in the DB. 35k players (of which 7k with more than 0 score), took around 8 minutes.
-- Call it with different modes (0 VNL, 1 SKZ, 2 KZT)

DELIMITER //

DROP PROCEDURE IF EXISTS ReloadAllPlayers;
CREATE PROCEDURE ReloadAllPlayers(
    IN p_Mode TINYINT(3)
)

BEGIN
    DECLARE Done INT DEFAULT FALSE;
    DECLARE SteamID INT(10);

    DECLARE topPlayers CURSOR
    FOR
        -- Get Top Players Query from GOKZ
        SELECT SteamID32 from Players;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET Done = TRUE;

    open topPlayers;
    read_loop: LOOP
        FETCH topPlayers INTO SteamID;

        IF Done THEN
            LEAVE read_loop;
        END IF;

        INSERT IGNORE INTO Myrank (SteamID32, Mode, Score, LastUpdate) VALUES (SteamID, p_Mode, 0, CURRENT_TIMESTAMP);
        CALL UpdatePlayerScore(SteamID, p_Mode);
    END LOOP;

    CLOSE topPlayers;
END;
//

DELIMITER ;

-- CALL ReloadAllPlayers(2);