CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(30),
  last_name VARCHAR(30),
  user_name VARCHAR(30) UNIQUE
);
INSERT INTO users (first_name, last_name, user_name) VALUES ('ivan', 'ivanov', 'ivan1');
INSERT INTO users (first_name, last_name, user_name) VALUES ('ivan', 'ivanov', 'ivan2');
INSERT INTO users (first_name, last_name, user_name) VALUES ('ivan', 'ivanov', 'ivan3');
INSERT INTO users (first_name, last_name, user_name) VALUES ('ivan', 'ivanov', 'ivan4');

CREATE TABLE calls (
  id SERIAL PRIMARY KEY,
  caller_id INTEGER,
  receiver_id INTEGER,
  duration INTEGER,
  call_date DATE
);
INSERT INTO calls (caller_id, receiver_id, duration, call_date) VALUES ('1', '2', '3', now());
INSERT INTO calls (caller_id, receiver_id, duration, call_date) VALUES ('2', '3', '3', now());
INSERT INTO calls (caller_id, receiver_id, duration, call_date) VALUES ('4', '1', '3', now());
INSERT INTO calls (caller_id, receiver_id, duration, call_date) VALUES ('4', '3', '3', now());
INSERT INTO calls (caller_id, receiver_id, duration, call_date) VALUES ('3', '4', '3', now());
INSERT INTO calls (caller_id, receiver_id, duration, call_date) VALUES ('1', '1', '3', now());
INSERT INTO calls (caller_id, receiver_id, duration, call_date) VALUES ('4', '3', '3', now());

CREATE TABLE contracts (
  user_id INTEGER,
  id SERIAL PRIMARY KEY,
  tarrif_id INTEGER
);
INSERT INTO contracts (user_id, tarrif_id) VALUES ('1', '1');
INSERT INTO contracts (user_id, tarrif_id) VALUES ('2', '1');
INSERT INTO contracts (user_id, tarrif_id) VALUES ('3', '1');
INSERT INTO contracts (user_id, tarrif_id) VALUES ('4', '1');
