INSERT INTO england_home
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
INNER JOIN england_names en ON fte.team1 = en.fte
INNER JOIN xpert.england xe ON TO_DATE(xe."Date",'DD/MM/YYYY') = DATE(fte."date") AND en.xpert = xe."HomeTeam"
GROUP BY
  1
;

INSERT INTO england_away
  (team, played, points, scored, conceded)
SELECT
	team2 AS team,
	COUNT (DISTINCT fte."index") AS played,
	SUM (
    CASE
    	WHEN score1 < score2 THEN 3
    	WHEN score1 = score2 THEN 1
    	ELSE 0
	  END) AS points,
	SUM(score2) AS scored,
	SUM(score1) AS conceded
FROM fte.spi_matches fte
INNER JOIN england_names en ON fte.team1 = en.fte
INNER JOIN xpert.england xe ON TO_DATE(xe."Date",'DD/MM/YYYY') = DATE(fte."date") AND en.xpert = xe."HomeTeam"
GROUP BY
  1
;

REFRESH MATERIALIZED VIEW england_league_table;

TRUNCATE TABLE england_home;

TRUNCATE TABLE england_away;
