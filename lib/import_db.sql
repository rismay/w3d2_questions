CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  fname VARCHAR(10) NOT NULL,
  lname VARCHAR(15) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER  NOT NULL REFERENCES users(id)
);

CREATE TABLE question_followers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  question_id INTEGER NOT NULL REFERENCES questions(id),
  user_id INTEGER NOT NULL REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  question_id INTEGER REFERENCES questions(id),
  parent_id INTEGER REFERENCES replies(id),
  author_id INTEGER NOT NULL REFERENCES users(id),
  body TEXT NOT NULL
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES users(id),
  question_id INTEGER NOT NULL REFERENCES questions(id)
);

INSERT INTO users (fname, lname) VALUES('ris', 'may'), ('frank', 'kotsianas');

INSERT INTO questions (title, body, author_id) VALUES
  ('When is this over?', 'Really, this is taking a while.', 1),
  ('Five members of the Wu-Tang Clan?', 'For reals: I need this for an interview.', 2)
;

INSERT INTO question_followers (question_id, user_id) VALUES
  (1,2),
  (2,1)
;

INSERT INTO replies (question_id, parent_id, author_id, body) VALUES
  (1, NULL, 2, 'Neva, Neva.'),
  (2, NULL, 1, 'Method Man, RZA, GZA, Raekwon and Gostface Killah.'),
  (2, 2,    1, 'Nothing but a G thang.')
;

INSERT INTO question_likes (user_id, question_id) VALUES
  (1, 1),
  (1, 2),
  (2, 1)
;
