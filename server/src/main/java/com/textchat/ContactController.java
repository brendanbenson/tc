package com.textchat;

import com.textchat.persistence.contacts.Contact;
import com.textchat.persistence.contacts.ContactRepository;
import com.textchat.textmessages.ContactResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@RestController
public class ContactController {
    private ContactRepository contactRepository;

    @Autowired
    public ContactController(ContactRepository contactRepository) {
        this.contactRepository = contactRepository;
    }

    @PutMapping("/contacts")
    @PreAuthorize("hasAuthority('USER')")
    public void update(@RequestBody UpdateContactRequest updateContactRequest) {
        Contact contact = contactRepository.findByPhoneNumber(updateContactRequest.getPhoneNumber());

        contact.setLabel(updateContactRequest.getLabel());

        contactRepository.save(contact);
    }

    @GetMapping("/contacts")
    @PreAuthorize("hasAuthority('USER')")
    public List<ContactResponse> list(@RequestParam String q) {
        return contactRepository
                .search(q)
                .stream()
                .map(ContactResponse::new)
                .collect(Collectors.toList());
    }

    private static class UpdateContactRequest {
        private String phoneNumber;
        private String label;

        public String getPhoneNumber() {
            return phoneNumber;
        }

        public String getLabel() {
            return label;
        }
    }
}
