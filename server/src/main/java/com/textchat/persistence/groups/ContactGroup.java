package com.textchat.persistence.groups;

import com.textchat.persistence.contacts.Contact;

import javax.persistence.*;
import java.util.List;

@Entity
@Table(name = "contacts_groups")
public class ContactGroup {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Contact contact;

    @ManyToOne
    private Group group;

    public ContactGroup() {
    }

    public ContactGroup(Contact contact, Group group) {
        this.contact = contact;
        this.group = group;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        ContactGroup that = (ContactGroup) o;

        if (id != null ? !id.equals(that.id) : that.id != null) return false;
        if (contact != null ? !contact.equals(that.contact) : that.contact != null) return false;
        return group != null ? group.equals(that.group) : that.group == null;
    }

    @Override
    public int hashCode() {
        int result = id != null ? id.hashCode() : 0;
        result = 31 * result + (contact != null ? contact.hashCode() : 0);
        result = 31 * result + (group != null ? group.hashCode() : 0);
        return result;
    }
}
