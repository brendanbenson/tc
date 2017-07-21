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
    private UpdateContactRequestValidator updateContactRequestValidator;

    @Autowired
    public ContactController(
            ContactRepository contactRepository,
            GroupRepository groupRepository,
            CreateContactRequestValidator createContactRequestValidator,
            UpdateContactRequestValidator updateContactRequestValidator
    ) {
        this.contactRepository = contactRepository;
        this.groupRepository = groupRepository;
        this.createContactRequestValidator = createContactRequestValidator;
        this.updateContactRequestValidator = updateContactRequestValidator;
    }

    @InitBinder("createContactRequest")
    public void initCreateBinder(WebDataBinder binder) {
        binder.addValidators(createContactRequestValidator);
    }

    @InitBinder("updateContactRequest")
    public void initUpdateValidator(WebDataBinder binder) {
        binder.addValidators(updateContactRequestValidator);
    }

    @PostMapping("/contacts")
    public ContactResponse create(@Valid @RequestBody CreateContactRequest createContactRequest) {
        Contact contact = new Contact(createContactRequest.getPhoneNumber(), createContactRequest.getLabel());
        Contact savedContact = contactRepository.save(contact);

        return new ContactResponse(savedContact);
    }

    @PutMapping("/contacts")
    public ContactResponse update(@Valid @RequestBody UpdateContactRequest updateContactRequest) {
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
}
