package com.textchat;

import com.textchat.persistence.contacts.Contact;
import com.textchat.persistence.contacts.ContactRepository;
import com.textchat.persistence.groups.ContactGroup;
import com.textchat.persistence.groups.ContactGroupRepository;
import com.textchat.persistence.groups.Group;
import com.textchat.persistence.groups.GroupRepository;
import com.textchat.textmessages.ContactResponse;
import com.textchat.textmessages.GroupResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
public class GroupController {
    private GroupRepository groupRepository;
    private ContactRepository contactRepository;
    private ContactGroupRepository contactGroupRepository;

    @Autowired
    public GroupController(
            GroupRepository groupRepository,
            ContactRepository contactRepository,
            ContactGroupRepository contactGroupRepository
    ) {
        this.groupRepository = groupRepository;
        this.contactRepository = contactRepository;
        this.contactGroupRepository = contactGroupRepository;
    }

    @GetMapping("/groups/{groupId}")
    public GroupResponse show(@PathVariable Long groupId) {
        Group group = groupRepository.findOne(groupId);

        return new GroupResponse(group);
    }

    @GetMapping("/contacts/{contactId}/suggest-groups")
    public List<GroupResponse> suggestGroups(@PathVariable Long contactId, @RequestParam String q) {
        Contact contact = contactRepository.findOne(contactId);
        List<Group> existingGroups = contact.getGroups();

        return groupRepository
                .search(q)
                .stream()
                .filter(group -> !existingGroups.contains(group))
                .map(GroupResponse::new)
                .collect(Collectors.toList());
    }

    @GetMapping("/groups/{groupId}/suggest-contacts")
    public List<ContactResponse> suggestContacts(@PathVariable Long groupId, @RequestParam String q) {
        Group group = groupRepository.findOne(groupId);
        List<Contact> existingContacts = group.getContacts();

        return contactRepository
                .search(q)
                .stream()
                .filter(contact -> !existingContacts.contains(contact))
                .map(ContactResponse::new)
                .collect(Collectors.toList());
    }

    @PostMapping("/contacts/{contactId}/groups")
    public GroupResponse search(@PathVariable Long contactId, @RequestBody AddToGroupRequest addToGroupRequest) {
        Contact contact = contactRepository.findOne(contactId);
        Group group = groupRepository.findOne(addToGroupRequest.getGroupId());

        ContactGroup contactGroup = new ContactGroup(contact, group);

        contactGroupRepository.save(contactGroup);

        return new GroupResponse(group);
    }

    @DeleteMapping("/contacts/{contactId}/groups/{groupId}")
    public GroupResponse delete(@PathVariable Long contactId, @PathVariable Long groupId) {
        Contact contact = contactRepository.findOne(contactId);
        Group group = groupRepository.findOne(groupId);
        ContactGroup contactGroup = contactGroupRepository.findByContactAndGroup(contact, group);
        contactGroupRepository.delete(contactGroup);

        return new GroupResponse(group);
    }

    private static class AddToGroupRequest {
        private Long groupId;

        public Long getGroupId() {
            return groupId;
        }
    }
}
