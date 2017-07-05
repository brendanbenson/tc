create table groups (
  id BIGSERIAL PRIMARY KEY,
  label TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE contacts_groups (
  id BIGSERIAL PRIMARY KEY,
  contact_id BIGINT NOT NULL REFERENCES contacts (id),
  group_id BIGINT NOT NULL REFERENCES groups(id),
  created_at TIMESTAMP NOT NULL DEFAULT now()
);
