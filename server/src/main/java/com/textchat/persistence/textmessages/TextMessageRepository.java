package com.textchat.persistence.textmessages;

import com.textchat.persistence.contacts.Contact;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.PagingAndSortingRepository;

import java.util.List;

public interface TextMessageRepository extends PagingAndSortingRepository<TextMessageRow, Long> {
    List<TextMessageRow> findAllByToContactOrderByCreatedAtDesc(Contact contact);

    @Query(nativeQuery = true,
            value = "SELECT m1.* FROM text_messages m1 " +
                    "LEFT JOIN text_messages m2 " +
                    "ON (m1.to_contact_id = m2.to_contact_id " +
                    "AND m1.created_at < m2.created_at) " +
                    "WHERE m2.id IS NULL " +
                    "ORDER BY m1.created_at DESC")
    List<TextMessageRow> findLatestThreads();
}
