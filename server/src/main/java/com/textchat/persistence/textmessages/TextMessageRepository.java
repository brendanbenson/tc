package com.textchat.persistence.textmessages;

import org.springframework.data.repository.CrudRepository;

public interface TextMessageRepository extends CrudRepository<TextMessageRow, Long> {
}
