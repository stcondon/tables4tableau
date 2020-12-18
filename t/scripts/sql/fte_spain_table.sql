INSERT INTO spain_home
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
INNER JOIN spain_names sn ON fte.team1 = sn.fte
INNER JOIN xpert.spain xs ON TO_DATE(xs."Date",'DD/MM/YY') = DATE(fte."date") AND sn.xpert = xs."HomeTeam"
GROUP BY
  1
;

INSERT INTO spain_away
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
INNER JOIN spain_names sn ON fte.team1 = sn.fte
INNER JOIN xpert.spain xs ON TO_DATE(xs."Date",'DD/MM/YY') = DATE(fte."date") AND sn.xpert = xs."HomeTeam"
GROUP BY
  1
;

TRUNCATE TABLE spain_home;

TRUNCATE TABLE spain_away;

DROP TABLE xpert.spain;

DROP TABLE fte.spi_matches;
