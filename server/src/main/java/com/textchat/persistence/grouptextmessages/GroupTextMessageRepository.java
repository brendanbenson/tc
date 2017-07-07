package com.textchat.persistence.grouptextmessages;

import com.textchat.persistence.groups.Group;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface GroupTextMessageRepository extends CrudRepository<GroupTextMessage, Long> {
    List<GroupTextMessage> findAllByGroup(Group group);
}
