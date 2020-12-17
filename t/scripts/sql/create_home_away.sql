CREATE TABLE england_home(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER
);

CREATE TABLE england_away(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER
);

CREATE TABLE france_home(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER
);

CREATE TABLE france_away(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER
);

CREATE TABLE spain_home(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER,
  tie_breaker INTEGER
);

CREATE TABLE spain_away(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER,
  tie_breaker INTEGER
);
CREATE TABLE spain_mini_home(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER
);

CREATE TABLE spain_mini_away(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER
);
CREATE TABLE germany_home(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER,
  tie_breaker INTEGER
);

CREATE TABLE germany_away(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER,
  tie_breaker INTEGER
);
CREATE TABLE germany_mini_home(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER
);

CREATE TABLE germany_mini_away(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER
);
CREATE TABLE italy_home(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER,
  tie_breaker INTEGER
);

CREATE TABLE italy_away(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER,
  tie_breaker INTEGER
);
CREATE TABLE italy_mini_home(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER
);

CREATE TABLE italy_mini_away(
  id SERIAL PRIMARY KEY,
  team TEXT,
  played INTEGER,
  points INTEGER,
  scored INTEGER,
  conceded INTEGER
);
