CREATE TABLE home(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER
);

CREATE TABLE away(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER
);
