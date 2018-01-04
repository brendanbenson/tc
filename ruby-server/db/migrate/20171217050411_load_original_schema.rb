class LoadOriginalSchema < ActiveRecord::Migration[5.1]
  def change
    execute <<SQL
create table text_messages
(
  id bigserial not null
    constraint text_messages_pkey
    primary key,
  body text not null,
  created_at timestamp default now() not null,
  delivered_at timestamp,
  to_contact_id bigint not null,
  from_contact_id bigint not null,
  incoming boolean not null
)
;

create table contacts
(
  id bigserial not null
    constraint contacts_pkey
    primary key,
  phone_number text not null,
  label text not null,
  created_at timestamp default now() not null
)
;

alter table text_messages
  add constraint text_messages_to_contact_id_fkey
foreign key (to_contact_id) references contacts
;

alter table text_messages
  add constraint text_messages_from_contact_id_fkey
foreign key (from_contact_id) references contacts
;

create table groups
(
  id bigserial not null
    constraint groups_pkey
    primary key,
  label text not null,
  created_at timestamp default now() not null
)
;

create table contacts_groups
(
  id bigserial not null
    constraint contacts_groups_pkey
    primary key,
  contact_id bigint not null
    constraint contacts_groups_contact_id_fkey
    references contacts,
  group_id bigint not null
    constraint contacts_groups_group_id_fkey
    references groups,
  created_at timestamp default now() not null,
  constraint contacts_groups_contact_id_group_id_key
  unique (contact_id, group_id)
)
;

create table group_text_messages
(
  id bigserial not null
    constraint group_text_messages_pkey
    primary key,
  body text not null,
  group_id bigint not null
    constraint group_text_messages_group_id_fkey
    references groups,
  created_at timestamp default now() not null
)
;


SQL
  end
end
