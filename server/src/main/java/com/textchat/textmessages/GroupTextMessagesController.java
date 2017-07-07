package com.textchat.textmessages;

import com.textchat.persistence.groups.Group;
import com.textchat.persistence.groups.GroupRepository;
import com.textchat.persistence.grouptextmessages.GroupTextMessage;
import com.textchat.persistence.grouptextmessages.GroupTextMessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static java.util.stream.Collectors.toList;

@RestController
public class GroupTextMessagesController {
    private GroupTextMessageRepository groupTextMessageRepository;
    private GroupRepository groupRepository;
    private TextMessageService textMessageService;

    @Autowired
    public GroupTextMessagesController(
            GroupTextMessageRepository groupTextMessageRepository,
            GroupRepository groupRepository,
            TextMessageService textMessageService) {
        this.groupTextMessageRepository = groupTextMessageRepository;
        this.groupRepository = groupRepository;
        this.textMessageService = textMessageService;
    }

    @PostMapping("/groups/{groupId}/text-messages")
    public GroupTextMessageResponse create(
            @PathVariable Long groupId,
            @RequestBody SendMessageRequest sendMessageRequest
    ) {
        Group group = groupRepository.findOne(groupId);
        GroupTextMessage groupTextMessage = new GroupTextMessage(sendMessageRequest.getBody(), group);
        GroupTextMessage savedMessage = groupTextMessageRepository.save(groupTextMessage);

        textMessageService.send(group, sendMessageRequest.getBody());

        return new GroupTextMessageResponse(savedMessage);
    }

    @GetMapping("/groups/{groupId}/text-messages")
    public List<GroupTextMessageResponse> create(@PathVariable Long groupId
    ) {
        Group group = groupRepository.findOne(groupId);

        return groupTextMessageRepository
                .findAllByGroup(group)
                .stream()
                .map(GroupTextMessageResponse::new)
                .collect(toList());
    }
}
