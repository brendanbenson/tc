package com.textchat.persistence.groups;

import com.textchat.persistence.contacts.Contact;
import org.springframework.data.repository.CrudRepository;

public interface ContactGroupRepository extends CrudRepository<ContactGroup, Long> {
    ContactGroup findByContactAndGroup(Contact contact, Group group);
}
