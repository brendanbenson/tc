create table text_messages (
  id BIGSERIAL PRIMARY KEY,
  body TEXT NOT NULL,
  to_phone_number TEXT NOT NULL,
  from_phone_number TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  delivered_at TIMESTAMP
);