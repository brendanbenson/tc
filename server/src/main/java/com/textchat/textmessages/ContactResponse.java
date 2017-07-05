package com.textchat.textmessages;

import com.textchat.persistence.contacts.Contact;

import java.util.List;

import static java.util.stream.Collectors.toList;

public class ContactResponse {
    private Long id;
    private String phoneNumber;
    private String label;
    private List<GroupResponse> groups;

    public ContactResponse() {
    }

    public ContactResponse(Long id, String phoneNumber, String label, List<GroupResponse> groups) {
        this.id = id;
        this.phoneNumber = phoneNumber;
        this.label = label;
        this.groups = groups;
    }

    public ContactResponse(Contact contact) {
        this(
                contact.getId(),
                contact.getPhoneNumber(),
                contact.getLabel(),
                contact.getGroups().stream().map(GroupResponse::new).collect(toList())
        );
    }

    public Long getId() {
        return id;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public String getLabel() {
        return label;
    }

    public List<GroupResponse> getGroups() {
        return groups;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        ContactResponse that = (ContactResponse) o;

        if (id != null ? !id.equals(that.id) : that.id != null) return false;
        if (phoneNumber != null ? !phoneNumber.equals(that.phoneNumber) : that.phoneNumber != null) return false;
        return label != null ? label.equals(that.label) : that.label == null;
    }

    @Override
    public int hashCode() {
        int result = id != null ? id.hashCode() : 0;
        result = 31 * result + (phoneNumber != null ? phoneNumber.hashCode() : 0);
        result = 31 * result + (label != null ? label.hashCode() : 0);
        return result;
    }
}
