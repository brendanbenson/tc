package com.textchat;

import com.textchat.persistence.contacts.Contact;
import com.textchat.persistence.contacts.ContactRepository;
import com.textchat.persistence.groups.Group;
import com.textchat.persistence.groups.GroupRepository;
import com.textchat.textmessages.ContactResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.security.Principal;
import java.util.List;
import java.util.stream.Collectors;

import static java.util.Comparator.comparing;
import static java.util.Comparator.nullsLast;

@RestController
public class ContactController {
    private ContactRepository contactRepository;
    private GroupRepository groupRepository;
    private CreateContactRequestValidator createContactRequestValidator;

    @Autowired
    public ContactController(
            ContactRepository contactRepository,
            GroupRepository groupRepository,
            CreateContactRequestValidator createContactRequestValidator
    ) {
        this.contactRepository = contactRepository;
        this.groupRepository = groupRepository;
        this.createContactRequestValidator = createContactRequestValidator;
    }

    @InitBinder
    public void setupBinder(WebDataBinder binder) {
        binder.addValidators(createContactRequestValidator);
    }

    @PostMapping("/contacts")
    public ContactResponse create(@Valid @RequestBody CreateContactRequest createContactRequest) {
        Contact contact = new Contact(createContactRequest.getPhoneNumber(), createContactRequest.getLabel());
        Contact savedContact = contactRepository.save(contact);

        return new ContactResponse(savedContact);
    }

    @PutMapping("/contacts")
    public ContactResponse update(@RequestBody UpdateContactRequest updateContactRequest) {
        Contact contact = contactRepository.findOne(updateContactRequest.getId());

        contact.setLabel(updateContactRequest.getLabel());
        contact.setPhoneNumber(updateContactRequest.getPhoneNumber());

        Contact savedContact = contactRepository.save(contact);

        return new ContactResponse(savedContact);
    }

    @GetMapping("/contacts")
    public List<ContactResponse> search(@RequestParam String q, Principal principal) {
        return contactRepository
                .search(q)
                .stream()
                .map(ContactResponse::new)
                .collect(Collectors.toList());
    }

    @GetMapping("/groups/{groupId}/contacts")
    public List<ContactResponse> getForGroup(@PathVariable Long groupId) {
        Group group = groupRepository.findOne(groupId);

        return group
                .getContacts()
                .stream()
                .sorted(nullsLast(comparing(Contact::getLabel))
                        .thenComparing(Contact::getPhoneNumber))
                .map(ContactResponse::new)
                .collect(Collectors.toList());
    }

    private static class UpdateContactRequest {
        private Long id;
        private String phoneNumber;
        private String label;

        public Long getId() {
            return id;
        }

        public String getPhoneNumber() {
            return phoneNumber;
        }

        public String getLabel() {
            return label;
        }
    }

}
