DROP MATERIALIZED VIEW spain_league_table;
CREATE MATERIALIZED VIEW spain_league_table AS (
  SELECT
  	team,
  	h.played + a.played AS played,
  	h.points + a.points AS points,
  	h.scored + a.scored AS scored,
  	h.conceded + a.conceded AS conceded,
    mh.tie_breaker + ma.tie_breaker
  FROM spain_home h
  LEFT JOIN spain_away a USING (team)
  LEFT JOIN spain_mini_home mh USING (team)
  LEFT JOIN spain_mini_away ma USING (team)
  ORDER BY
  	h.points + a.points DESC,
    mh.tie_breaker + ma.tie_breaker DESC
);
