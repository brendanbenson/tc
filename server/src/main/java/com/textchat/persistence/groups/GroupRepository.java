package com.textchat.persistence.groups;

import com.textchat.persistence.contacts.Contact;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface GroupRepository extends CrudRepository<Group, Long> {
    @Query("SELECT g FROM Group g " +
            "WHERE lower(g.label) LIKE lower(CONCAT('%',:q,'%')) " +
            "ORDER BY g.label")
    List<Group> search(@Param("q") String q);
}
