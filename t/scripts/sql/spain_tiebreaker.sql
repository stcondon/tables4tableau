CREATE OR REPLACE FUNCTION spain_tiebreaker()
  RETURNS TRIGGER
  LANGUAGE plpgsql
AS $$
DECLARE
  p RECORD;
  game_count INTEGER;
  team_count INTEGER;

BEGIN
  -- REFRESH MATERIALIZED VIEW spain_league_table; -- TO BE REPLACED WITH BETTER QUERY IN FOR LOOP
  FOR p IN (
    WITH point_count AS (
    	SELECT
    		team,
    		COALESCE(h.points, 0) + COALESCE(a.points, 0) AS points
    	FROM spain_home h
    	LEFT JOIN spain_away a USING (team)
    )
    SELECT
    	points
    FROM point_count
    GROUP BY 1
    HAVING COUNT (DISTINCT team) > 1
  )
  LOOP
    WITH mini_home AS (
      SELECT
        fte."index",
        team1 AS team,
      	score1,
        score2
      FROM fte.spi_matches fte
      INNER JOIN xpert.spain xs ON TO_DATE(xs."Date",'DD/MM/YY') = DATE(fte."date")
      INNER JOIN spain_names sn1 ON fte.team1 = sn1.fte
      INNER JOIN spain_names sn2 ON fte.team1 = sn2.fte
      -- INNER JOIN spain_league_table slt1 ON slt1.team = fte.team1
      -- INNER JOIN spain_league_table slt2 ON slt2.team = fte.team2
      WHERE 1 = 1
        AND slt1.points = p.points
  			AND slt2.points = p.points
      GROUP BY
        fte."index",
        team1,
        score1,
        score2
    )
    INSERT INTO spain_mini_home
      (team, played, points, scored, conceded)
    SELECT
    	team,
    	COUNT (DISTINCT "index") AS played,
    	SUM (
        CASE
      		WHEN score1 > score2 THEN 3
      		WHEN score1 = score2 THEN 1
      		ELSE 0
    	  END) AS points,
    	SUM(score1) AS scored,
    	SUM(score2) AS conceded
    FROM mini_home
    GROUP BY
      1
    ;
    WITH mini_away AS (
      SELECT
        fte."index",
        team2 AS team,
        score1,
        score2
      FROM fte.spi_matches fte
      INNER JOIN xpert.spain xs ON TO_DATE(xs."Date",'DD/MM/YY') = DATE(fte."date")
      INNER JOIN spain_names sn1 ON fte.team1 = sn1.fte
      INNER JOIN spain_names sn2 ON fte.team1 = sn2.fte
      -- INNER JOIN spain_league_table slt1 ON slt1.team = fte.team1
      -- INNER JOIN spain_league_table slt2 ON slt2.team = fte.team2
      WHERE 1 = 1
        AND slt1.points = p.points
        AND slt2.points = p.points
      GROUP BY
        fte."index",
        team2,
        score1,
        score2
    )
    INSERT INTO spain_mini_away
      (team, played, points, scored, conceded)
    SELECT
    	team,
    	COUNT (DISTINCT "index") AS played,
    	SUM (
        CASE
      		WHEN score1 < score2 THEN 3
      		WHEN score1 = score2 THEN 1
      		ELSE 0
    	  END) AS points,
    	SUM(score2) AS scored,
    	SUM(score1) AS conceded
    FROM mini_away
    GROUP BY
      1
    ;
    WITH mini_teams AS (
      SELECT team FROM spain_mini_home
      UNION
      SELECT team FROM spain_mini_away
    )
    SELECT COUNT (DISTINCT team) INTO team_count FROM mini_teams;
    WITH mini_games AS (
      SELECT played FROM spain_mini_away
      UNION
      SELECT played FROM spain_mini_home
    )
    SELECT SUM(played) INTO game_count FROM mini_games
    ;
    IF game_count = 2 * (team_count * (team_count - 1)) THEN
      WITH tb AS (
        SELECT
          team,
          COALESCE(h.played, 0) + COALESCE(a.played, 0) AS played,
          COALESCE(h.points, 0) + COALESCE(a.points, 0) AS points,
          COALESCE(h.scored,0) + COALESCE(a.scored,0) - COALESCE(h.conceded,0) + COALESCE(a.conceded,0) AS difference,
          RANK() OVER (
            ORDER BY
            COALESCE(h.points, 0) + COALESCE(a.points, 0) DESC,
            COALESCE(h.scored,0) + COALESCE(a.scored,0) - COALESCE(h.conceded,0) + COALESCE(a.conceded,0) DESC
          ) AS place
        FROM spain_mini_home h
        LEFT JOIN spain_mini_away a USING (team)
        GROUP BY
          1,2,3,4
        ORDER BY
          COALESCE(h.points, 0) + COALESCE(a.points, 0) DESC,
          COALESCE(h.scored,0) + COALESCE(a.scored,0) - COALESCE(h.conceded,0) + COALESCE(a.conceded,0) DESC
      )
      UPDATE spain_home sh
        SET tie_breaker = tb.place
      FROM tb
      WHERE sh.team = tb.team
      ;
    END IF;
    TRUNCATE spain_mini_home;
    TRUNCATE spain_mini_away;
  END LOOP;
  REFRESH MATERIALIZED VIEW spain_league_table;
  RETURN NULL;
END $$;

-- CREATE TRIGGER refresh_england_trigger
-- AFTER INSERT ON spain_away
-- FOR EACH STATEMENT
-- EXECUTE PROCEDURE spain_tiebreaker();
