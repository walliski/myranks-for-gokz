-- Get all Times for the maps that a player has run

DELIMITER //

CREATE OR REPLACE PROCEDURE UpdatePlayerScore(
    IN p_SteamID32 INT(10),
    IN p_Mode TINYINT(3)
)

BEGIN
    DECLARE Done INT DEFAULT FALSE;
    DECLARE Map INT(10);
    DECLARE Teleports SMALLINT(5);
    DECLARE Score INT DEFAULT 0;

    DECLARE maplist CURSOR
    FOR
        SELECT t.MapCourseID, t.Teleports
        FROM
            (SELECT mc.MapCourseID
            FROM Maps m
            LEFT JOIN MapCourses mc
            ON m.MapID = mc.MapID
            WHERE mc.Course = 0
            AND m.InRankedPool != 0) ids
        LEFT JOIN Times t
        ON ids.MapCourseID = t.MapCourseID
        WHERE t.Mode = p_Mode
        AND t.SteamID32 = p_SteamID32
        AND t.Style = 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET Done = TRUE;

    open maplist;
    read_loop: LOOP
        FETCH maplist INTO Map, Teleports;

        IF Done THEN
            LEAVE read_loop;
        END IF;

        CALL GetMapScore(p_SteamID32, Map, p_Mode, Teleports, @score);
        SET Score = Score + @score;
    END LOOP;

    CLOSE maplist;

    UPDATE Myrank SET Score=Score, LastUpdate=CURRENT_TIMESTAMP WHERE SteamID32 = p_SteamID32 AND Mode = p_Mode;
END;
//

DELIMITER ;

-- CALL UpdatePlayerScore(20935526, 2);


