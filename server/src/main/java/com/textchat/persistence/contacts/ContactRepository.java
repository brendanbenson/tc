package com.textchat.persistence.contacts;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ContactRepository extends CrudRepository<Contact, Long> {
    Contact findByPhoneNumber(String phoneNumber);

    @Query("SELECT c FROM Contact c " +
            "WHERE lower(c.label) LIKE CONCAT('%',:q,'%') " +
            "OR lower(c.phoneNumber) LIKE CONCAT('%',:q,'%')")
    List<Contact> search(@Param("q") String q);
}
