ALTER TABLE text_messages
  DROP COLUMN to_phone_number;

ALTER TABLE text_messages
  DROP COLUMN from_phone_number;

DROP TABLE aliases;

CREATE TABLE contacts (
  id           BIGSERIAL PRIMARY KEY,
  phone_number TEXT      NOT NULL UNIQUE,
  label        TEXT      NOT NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT now()
);

ALTER TABLE text_messages
  ADD COLUMN to_contact_id BIGINT NOT NULL REFERENCES contacts (id);

ALTER TABLE text_messages
  ADD COLUMN from_contact_id BIGINT NOT NULL REFERENCES contacts (id);
