package com.textchat.persistence.contacts;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "contact_reads")
public class ContactRead {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Contact contact;

//    @ManyToOne
//    private User user;

    private Date readAt;

//    public ContactRead(Contact contact, User user, Date readAt) {
//        this.contact = contact;
//        this.user = user;
//        this.readAt = readAt;
//    }

    public Long getId() {

        return id;
    }

    public Contact getContact() {
        return contact;
    }

//    public User getUser() {
//        return user;
//    }

    public Date getReadAt() {
        return readAt;
    }

    public void setReadAt(Date readAt) {
        this.readAt = readAt;
    }
//
//    @Override
//    public boolean equals(Object o) {
//        if (this == o) return true;
//        if (o == null || getClass() != o.getClass()) return false;
//
//        ContactRead that = (ContactRead) o;
//
//        if (id != null ? !id.equals(that.id) : that.id != null) return false;
//        if (contact != null ? !contact.equals(that.contact) : that.contact != null) return false;
//        if (user != null ? !user.equals(that.user) : that.user != null) return false;
//        return readAt != null ? readAt.equals(that.readAt) : that.readAt == null;
//    }
//
//    @Override
//    public int hashCode() {
//        int result = id != null ? id.hashCode() : 0;
//        result = 31 * result + (contact != null ? contact.hashCode() : 0);
//        result = 31 * result + (user != null ? user.hashCode() : 0);
//        result = 31 * result + (readAt != null ? readAt.hashCode() : 0);
//        return result;
//    }
}
