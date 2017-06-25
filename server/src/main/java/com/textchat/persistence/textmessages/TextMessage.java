package com.textchat.persistence.textmessages;

import com.textchat.persistence.contacts.Contact;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "text_messages")
public class TextMessage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String body;
    private Boolean incoming;
    @Column(updatable = false, insertable = false)
    private Date createdAt;
    private Date deliveredAt;

    @ManyToOne(targetEntity = Contact.class)
    @JoinColumn(name = "to_contact_id", referencedColumnName = "id")
    private Contact toContact;

    @ManyToOne(targetEntity = Contact.class)
    @JoinColumn(name = "from_contact_id", referencedColumnName = "id")
    private Contact fromContact;

    public TextMessage() {
    }

    public TextMessage(
            String body,
            Boolean incoming,
            Contact toContact,
            Contact fromContact
    ) {
        this.body = body;
        this.incoming = incoming;
        this.toContact = toContact;
        this.fromContact = fromContact;
    }

    public Long getId() {
        return id;
    }

    public String getBody() {
        return body;
    }

    public Boolean getIncoming() {
        return incoming;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public Date getDeliveredAt() {
        return deliveredAt;
    }

    public Contact getToContact() {
        return toContact;
    }

    public Contact getFromContact() {
        return fromContact;
    }

    public String getToPhoneNumber() {
        return getToContact().getPhoneNumber();
    }

    public String getFromPhoneNumber() {
        return getFromContact().getPhoneNumber();
    }

    public void setDeliveredAt(Date deliveredAt) {
        this.deliveredAt = deliveredAt;
    }
}
