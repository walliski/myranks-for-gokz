DELIMITER //

DROP PROCEDURE IF EXISTS GetMapScore //
CREATE PROCEDURE GetMapScore(
    IN p_SteamID32 INT(10),
    IN p_MapCourseID INT(10),
    IN p_Mode TINYINT(3),
    OUT p_Score SMALLINT(5)
)

BEGIN
    DECLARE `Rank` INT;
    DECLARE TotalCount INT;
    DECLARE RankPro INT;
    DECLARE TotalCountPro INT;
    DECLARE Percent DECIMAL(6,4);
    DECLARE PercentPro DECIMAL(6,4);
    DECLARE Score INT DEFAULT 0;

    -- SQL Queries borrowed from GOKZ Localranks
    -- https://bitbucket.org/kztimerglobalteam/gokz/src/master/addons/sourcemod/scripting/gokz-localranks/db/sql.sp
    SELECT COUNT(DISTINCT Times.SteamID32)
    FROM Times
    INNER JOIN Players ON Players.SteamID32=Times.SteamID32
    WHERE Players.Cheater=0 AND Times.MapCourseID=p_MapCourseID
    AND Times.Mode=p_Mode AND Times.Teleports=0
    AND Times.RunTime <=
        (SELECT MIN(Times.RunTime)
        FROM Times
        INNER JOIN Players ON Players.SteamID32=Times.SteamID32
        WHERE Players.Cheater=0 AND Times.SteamID32=p_SteamID32 AND Times.MapCourseID=p_MapCourseID
        AND Times.Mode=p_Mode AND Times.Teleports=0)
    INTO RankPro;

    SELECT COUNT(DISTINCT Times.SteamID32)
    FROM Times
        INNER JOIN Players ON Players.SteamID32=Times.SteamID32
        WHERE Players.Cheater=0 AND Times.MapCourseID=p_MapCourseID
        AND Times.Mode=p_Mode
        AND Times.RunTime <=
            (SELECT MIN(Times.RunTime)
            FROM Times
            INNER JOIN Players ON Players.SteamID32=Times.SteamID32
            WHERE Players.Cheater=0 AND Times.SteamID32=p_SteamID32 AND Times.MapCourseID=p_MapCourseID
            AND Times.Mode=p_Mode)
    INTO `Rank`;

    SELECT COUNT(DISTINCT Times.SteamID32)
    FROM Times
    INNER JOIN Players ON Players.SteamID32=Times.SteamID32
    WHERE Players.Cheater=0
    AND Times.MapCourseID=p_MapCourseID AND Times.Mode=p_Mode AND Times.Teleports=0
    INTO TotalCountPro;

    SELECT COUNT(DISTINCT Times.SteamID32)
    FROM Times
    INNER JOIN Players ON Players.SteamID32=Times.SteamID32
    WHERE Players.Cheater=0
    AND Times.MapCourseID=p_MapCourseID AND Times.Mode=p_Mode
    INTO TotalCount;

    SET Percent = 1.0 + (1.0/CAST(TotalCount AS DECIMAL)) - (CAST(`Rank` AS DECIMAL) / CAST(TotalCount AS DECIMAL));

    -- Its not a given that a player has a PRO time
    IF RankPro > 0 THEN
        -- Participation award
        SET Score = Score + 50;

        SET PercentPro = 1.0 + (1.0/CAST(TotalCountPro AS DECIMAL)) - (CAST(RankPro AS DECIMAL) / CAST(TotalCountPro AS DECIMAL));
        SET Score = Score + CEILING(200.0 * PercentPro);

        CASE RankPro
            WHEN 1 THEN SET Score = Score + 600;
            WHEN 2 THEN SET Score = Score + 500;
            WHEN 3 THEN SET Score = Score + 400;
            WHEN 4 THEN SET Score = Score + 375;
            WHEN 5 THEN SET Score = Score + 350;
            WHEN 6 THEN SET Score = Score + 325;
            WHEN 7 THEN SET Score = Score + 300;
            WHEN 8 THEN SET Score = Score + 275;
            WHEN 9 THEN SET Score = Score + 250;
            WHEN 10 THEN SET Score = Score + 225;
            WHEN 11 THEN SET Score = Score + 200;
            WHEN 12 THEN SET Score = Score + 175;
            WHEN 13 THEN SET Score = Score + 150;
            WHEN 14 THEN SET Score = Score + 125;
            WHEN 15 THEN SET Score = Score + 100;
            WHEN 16 THEN SET Score = Score + 90;
            WHEN 17 THEN SET Score = Score + 80;
            WHEN 18 THEN SET Score = Score + 70;
            WHEN 19 THEN SET Score = Score + 60;
            WHEN 20 THEN SET Score = Score + 50;
            ELSE SET Score = Score;
        END CASE;
    END IF; -- End PRO block

    -- Participation award
    SET Score = Score + 25;

    -- But he always has a TP time if he has finished
    SET Score = Score + CEILING(100.0 * Percent);

    CASE `Rank`
        WHEN 1 THEN SET Score = Score + 400;
        WHEN 2 THEN SET Score = Score + 300;
        WHEN 3 THEN SET Score = Score + 200;
        WHEN 4 THEN SET Score = Score + 190;
        WHEN 5 THEN SET Score = Score + 180;
        WHEN 6 THEN SET Score = Score + 170;
        WHEN 7 THEN SET Score = Score + 160;
        WHEN 8 THEN SET Score = Score + 150;
        WHEN 9 THEN SET Score = Score + 140;
        WHEN 10 THEN SET Score = Score + 130;
        WHEN 11 THEN SET Score = Score + 120;
        WHEN 12 THEN SET Score = Score + 110;
        WHEN 13 THEN SET Score = Score + 100;
        WHEN 14 THEN SET Score = Score + 90;
        WHEN 15 THEN SET Score = Score + 80;
        WHEN 16 THEN SET Score = Score + 60;
        WHEN 17 THEN SET Score = Score + 40;
        WHEN 18 THEN SET Score = Score + 20;
        WHEN 19 THEN SET Score = Score + 10;
        WHEN 20 THEN SET Score = Score + 5;
        ELSE SET Score = Score;
    END CASE;

    SET p_Score = Score;

    -- SELECT Rank,RankPro,TotalCount,TotalCountPro,Percent,PercentPro,Score;
END;
//

DELIMITER ;

-- CALL GetMapScore(20935526, 3, 2, @score);