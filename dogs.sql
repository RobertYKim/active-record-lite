CREATE TABLE dogs (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  houses (id, address)
VALUES
  (1, "432 Park Ave"), (2, "598 Broadway");

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, "Peter", "Parker", 1),
  (2, "Mary", "Jane", 1),
  (3, "Jonathan", "Tamboer", 2),
  (4, "Dogless", "Human", NULL);

INSERT INTO
  dogs (id, name, owner_id)
VALUES
  (1, "Spot", 1),
  (2, "Clifford", 2),
  (3, "Lassie", 3),
  (4, "Pluto", 3),
  (5, "Stray Dog", NULL);
