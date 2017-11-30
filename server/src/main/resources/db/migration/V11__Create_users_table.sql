CREATE TABLE users (
  id                  BIGSERIAL PRIMARY KEY,
  username            TEXT      NOT NULL,
  password            TEXT      NOT NULL,
  email               TEXT      NOT NULL,
  last_password_reset TIMESTAMP,
  authorities         TEXT      NOT NULL,
  created_at          TIMESTAMP NOT NULL DEFAULT now()
);

-- INSERT INTO users (id, username, password, last_password_reset, authorities)
-- VALUES (users_seq.nextval, 'user', '$2a$08$UkVvwpULis18S19S5pZFn.YHPZt3oaqHZnDwqbCW9pft6uFtkXKDC', NULL, 'USER');