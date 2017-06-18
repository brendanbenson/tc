-- Username: user
-- Password: password
INSERT INTO users (username, password, last_password_reset, authorities, email)
VALUES ('user', '$2a$08$UkVvwpULis18S19S5pZFn.YHPZt3oaqHZnDwqbCW9pft6uFtkXKDC', NULL, 'USER', 'user@example.com');

-- Username: admin
-- Password: admin
INSERT INTO users (username, password, last_password_reset, authorities, email)
VALUES
  ('admin', '$2a$08$lDnHPz7eUkSi6ao14Twuau08mzhWrL4kyZGGU5xfiGALO/Vxd5DOi', NULL, 'ADMIN, ROOT', 'admin@example.com');

INSERT INTO users (username, password, last_password_reset, authorities, email) VALUES
  ('expired', '$2a$10$PZ.A0IuNG958aHnKDzILyeD9k44EOi1Ny0VlAn.ygrGcgmVcg8PRK',
   NULL, 'USER', 'expired@example.com');

