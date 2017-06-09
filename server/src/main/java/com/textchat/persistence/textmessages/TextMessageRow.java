package com.textchat.persistence.textmessages;

import com.textchat.persistence.contacts.Contact;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "text_messages")
public class TextMessageRow {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String body;
    @Column(updatable = false, insertable = false)
    private Date createdAt;
    private Date deliveredAt;

    @ManyToOne(targetEntity = Contact.class)
    @JoinColumn(name = "to_contact_id", referencedColumnName = "id")
    private Contact toContact;

    @ManyToOne(targetEntity = Contact.class)
    @JoinColumn(name = "from_contact_id", referencedColumnName = "id")
    private Contact fromContact;

    public TextMessageRow() {
    }

    public TextMessageRow(String body, Contact toContact, Contact fromContact) {
        this.body = body;
        this.toContact = toContact;
        this.fromContact = fromContact;
    }

    public Long getId() {
        return id;
    }

    public String getBody() {
        return body;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public Date getDeliveredAt() {
        return deliveredAt;
    }

    public String getToPhoneNumber() {
        return this.toContact.getPhoneNumber();
    }

    public String getToLabel() {
        return this.toContact.getLabel();
    }
}
