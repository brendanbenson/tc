create table group_text_messages (
  id BIGSERIAL PRIMARY KEY,
  body TEXT NOT NULL,
  group_id BIGINT NOT NULL REFERENCES groups(id),
  created_at TIMESTAMP NOT NULL DEFAULT now()
);