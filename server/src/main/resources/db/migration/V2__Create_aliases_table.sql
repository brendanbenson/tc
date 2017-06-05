create table aliases (
  id BIGSERIAL PRIMARY KEY,
  phone_number TEXT NOT NULL,
  label TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);