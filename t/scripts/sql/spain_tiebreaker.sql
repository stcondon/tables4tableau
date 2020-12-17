CREATE OR REPLACE FUNCTION spain_tiebreaker()
  RETURNS TRIGGER
  LANGUAGE plpgsql
AS $$
DECLARE
  p RECORD;

BEGIN
  REFRESH MATERIALIZED VIEW spain_league_table; -- TO BE REPLACED WITH BETTER QUERY IN FOR LOOP
  FOR p IN (
    SELECT
    	points
    FROM spain_league_table
    GROUP BY 1
    HAVING COUNT (DISTINCT team) > 1
  )
  LOOP
    INSERT INTO spain_mini_home
      (team, played, points, scored, conceded)
    SELECT
    	team1 AS team,
    	COUNT (DISTINCT fte."index") AS played,
    	SUM (
        CASE
      		WHEN score1 > score2 THEN 3
      		WHEN score1 = score2 THEN 1
      		ELSE 0
    	  END) AS points,
    	SUM(score1) AS scored,
    	SUM(score2) AS conceded
    FROM fte.spi_matches fte
    INNER JOIN xpert.spain xs ON TO_DATE(xs."Date",'DD/MM/YY') = DATE(fte."date")
    INNER JOIN spain_league_table slt1 ON slt1.team = fte.team1
    INNER JOIN spain_league_table slt2 ON slt2.team = fte.team2
    WHERE 1 = 1
      AND slt1.points = p.points
			AND slt2.points = p.points
    GROUP BY
      1
    ;
    UPDATE spain_home sh
      SET tie_breaker = 1
    FROM spain_mini_home smh
    WHERE sh.team = smh.team
    ;
    TRUNCATE spain_mini_home;
  END LOOP;
  REFRESH MATERIALIZED VIEW spain_league_table;
  RETURN NULL;
END $$;

-- CREATE TRIGGER refresh_england_trigger
-- AFTER INSERT ON spain_away
-- FOR EACH STATEMENT
-- EXECUTE PROCEDURE spain_tiebreaker();
