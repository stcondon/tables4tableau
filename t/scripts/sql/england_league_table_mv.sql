DROP MATERIALIZED VIEW england_league_table;
CREATE MATERIALIZED VIEW england_league_table AS (
  SELECT
  	team,
    COALESCE(h.played, 0) + COALESCE(a.played, 0) AS played,
  	COALESCE(h.points, 0) + COALESCE(a.points, 0) AS points,
  	COALESCE(h.scored, 0) + COALESCE(a.scored, 0) AS scored,
  	COALESCE(h.conceded, 0) + COALESCE(a.conceded, 0) AS conceded
  FROM england_home h
  LEFT JOIN england_away a USING (team)
  ORDER BY
  	COALESCE(h.points,0) + COALESCE(a.points,0) DESC,
  	COALESCE(h.scored,0) + COALESCE(a.scored,0) - COALESCE(h.conceded,0) + COALESCE(a.conceded,0) DESC,
  	COALESCE(h.scored,0) + COALESCE(a.scored,0) DESC
);
