-- Updates the top X amount of players in a mode

DELIMITER //

DROP PROCEDURE IF EXISTS PopulateBasedOnCompletedMaps;
CREATE PROCEDURE PopulateBasedOnCompletedMaps(
    IN p_TopAmount INT(10),
    IN p_Mode TINYINT(3)
)

BEGIN
    DECLARE Done INT DEFAULT FALSE;
    DECLARE SteamID INT(10);
    DECLARE RCount INT(10);

    DECLARE topPlayers CURSOR
    FOR
        -- Get Top Players Query from GOKZ
        SELECT Players.SteamID32, COUNT(*) AS RecordCount
            FROM Times
            INNER JOIN
            (SELECT Times.MapCourseID, MIN(Times.RunTime) AS RecordTime
                FROM Times
                INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID
                INNER JOIN Maps ON Maps.MapID=MapCourses.MapID
                INNER JOIN Players ON Players.SteamID32=Times.SteamID32
                WHERE Players.Cheater=0 AND Maps.InRankedPool=1 AND MapCourses.Course=0
                AND Times.Mode=p_Mode
                GROUP BY Times.MapCourseID) Records
            ON Times.MapCourseID=Records.MapCourseID AND Times.RunTime=Records.RecordTime
            INNER JOIN Players ON Players.SteamID32=Times.SteamID32
            GROUP BY Players.SteamID32, Players.Alias
            ORDER BY RecordCount DESC
            LIMIT p_TopAmount;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET Done = TRUE;

    open topPlayers;
    read_loop: LOOP
        FETCH topPlayers INTO SteamID, RCount;

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

-- CALL PopulateBasedOnCompletedMaps(100, 2);
