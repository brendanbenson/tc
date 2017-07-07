ALTER TABLE contacts_groups
  ADD UNIQUE (contact_id, group_id);
