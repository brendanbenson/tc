package com.textchat.persistence.contacts;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "contacts")
public class Contact {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(unique = true)
    private String phoneNumber;
    private String label;
    @Column(updatable = false, insertable = false)
    private Date createdAt;

    public Contact() {
    }

    public Contact(String phoneNumber, String label) {
        this.phoneNumber = phoneNumber;
        this.label = label;
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

    public void setLabel(String label) {
        this.label = label;
    }

    public Date getCreatedAt() {
        return createdAt;
    }
}
