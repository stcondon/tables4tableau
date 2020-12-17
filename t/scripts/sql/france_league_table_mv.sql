DROP MATERIALIZED VIEW france_league_table;
CREATE MATERIALIZED VIEW france_league_table AS (
  SELECT
  	team,
    COALESCE(h.played, 0) + COALESCE(a.played, 0) AS played,
  	COALESCE(h.points, 0) + COALESCE(a.points, 0) AS points,
  	COALESCE(h.scored, 0) + COALESCE(a.scored, 0) AS scored,
  	COALESCE(h.conceded, 0) + COALESCE(a.conceded, 0) AS conceded
  FROM home
  LEFT JOIN away USING (team)
  ORDER BY
  	COALESCE(home.points,0) + COALESCE(away.points,0) DESC,
  	COALESCE(home.scored,0) + COALESCE(away.scored,0) - COALESCE(home.conceded,0) + COALESCE(away.conceded,0) DESC,
  	COALESCE(home.scored,0) + COALESCE(away.scored,0) DESC
);
