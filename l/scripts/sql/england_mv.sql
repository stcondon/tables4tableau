WITH home AS (
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
	inner join england_names en ON fte.team1 = en.fte
	inner join xpert.england xe ON TO_DATE(xe."Date",'DD/MM/YYYY') = DATE(fte."date") AND en.xpert = xe."HomeTeam"
	GROUP BY 1
)
, away as (
	SELECT
		team2 AS team,
		COUNT (DISTINCT fte."index") AS played,
		SUM ( CASE
			WHEN score1 < score2 THEN 3
			WHEN score1 = score2 THEN 1
			ELSE 0
		END) AS points,
		SUM(score2) AS scored,
		SUM(score1) AS conceded
	FROM fte.spi_matches fte
	inner join england_names en ON fte.team1 = en.fte
	inner join xpert.england xe ON TO_DATE(xe."Date",'DD/MM/YYYY') = DATE(fte."date") AND en.xpert = xe."HomeTeam"
	GROUP BY 1
)
SELECT
	team,
	home.played + away.played AS played,
	home.points + away.points AS points,
	home.scored + away.scored AS scored,
	home.conceded + away.conceded AS conceded
FROM home
LEFT JOIN away USING (team)
ORDER BY
	home.points + away.points DESC,
	home.scored + away.scored - home.conceded + away.conceded DESC,
	home.scored + away.scored DESC
