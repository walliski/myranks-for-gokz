-- Updates the top X amount of players in a mode

DELIMITER //

CREATE OR REPLACE PROCEDURE UpdateTopScore(
    IN p_TopAmount INT(10),
    IN p_Mode TINYINT(3)
)

BEGIN
    DECLARE Done INT DEFAULT FALSE;
    DECLARE SteamID INT(10);

    DECLARE topPlayers CURSOR
    FOR
        SELECT Myrank.SteamID32
        FROM Myrank
            INNER JOIN Players ON Players.SteamID32=Myrank.SteamID32
            WHERE Players.Cheater=0
            AND Myrank.Mode=p_Mode
            ORDER BY Score DESC
            LIMIT p_TopAmount;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET Done = TRUE;

    open topPlayers;
    read_loop: LOOP
        FETCH topPlayers INTO SteamID;

        IF Done THEN
            LEAVE read_loop;
        END IF;

        CALL UpdatePlayerScore(SteamID, p_Mode);
    END LOOP;

    CLOSE topPlayers;
END;
//

DELIMITER ;

-- CALL UpdateTopScore(10, 2);
