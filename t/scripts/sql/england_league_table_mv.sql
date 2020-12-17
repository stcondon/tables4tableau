CREATE MATERIALIZED VIEW england_league_table AS (
  SELECT
  	team,
  	h.played + a.played AS played,
  	h.points + a.points AS points,
  	h.scored + a.scored AS scored,
  	h.conceded + a.conceded AS conceded
  FROM england_home
  LEFT JOIN england_away USING (team)
  ORDER BY
  	h.points + a.points DESC,
  	h.scored + a.scored - h.conceded + a.conceded DESC,
  	h.scored + a.scored DESC
);
