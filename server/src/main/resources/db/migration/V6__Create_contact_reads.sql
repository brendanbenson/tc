create table contact_reads (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users (id),
  contact_id BIGINT NOT NULL REFERENCES contacts (id),
  read_at TIMESTAMP NOT NULL DEFAULT now()
);