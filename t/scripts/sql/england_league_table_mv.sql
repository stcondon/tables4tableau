CREATE MATERIALIZED VIEW england_league_table AS (
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
);
