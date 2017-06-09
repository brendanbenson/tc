package com.textchat.persistence.contacts;

import org.springframework.data.repository.CrudRepository;

public interface ContactRepository extends CrudRepository<Contact, Long> {
    Contact findByPhoneNumber(String phoneNumber);
}
