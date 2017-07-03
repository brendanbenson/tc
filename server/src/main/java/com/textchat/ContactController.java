package com.textchat;

import com.textchat.persistence.contacts.Contact;
import com.textchat.persistence.contacts.ContactRepository;
import com.textchat.textmessages.ContactResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.stream.Collectors;

@RestController
public class ContactController {
    private ContactRepository contactRepository;

    @Autowired
    public ContactController(ContactRepository contactRepository) {
        this.contactRepository = contactRepository;
    }

    @PostMapping("/contacts")
    public ContactResponse create(@RequestBody CreateContactRequest createContactRequest) {
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

    private static class CreateContactRequest {
        private String label;
        private String phoneNumber;

        public String getPhoneNumber() {
            return phoneNumber;
        }

        public String getLabel() {
            return label;
        }
    }
}
