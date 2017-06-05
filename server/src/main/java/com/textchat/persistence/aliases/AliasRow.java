package com.textchat.persistence.aliases;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "aliases")
public class AliasRow {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String phoneNumber;
    private String label;
    @Column(updatable = false, insertable = false)
    private Date createdAt;

    public AliasRow(String phoneNumber, String label) {
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

    public Date getCreatedAt() {
        return createdAt;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        AliasRow aliasRow = (AliasRow) o;

        if (id != null ? !id.equals(aliasRow.id) : aliasRow.id != null) return false;
        if (phoneNumber != null ? !phoneNumber.equals(aliasRow.phoneNumber) : aliasRow.phoneNumber != null)
            return false;
        if (label != null ? !label.equals(aliasRow.label) : aliasRow.label != null) return false;
        return createdAt != null ? createdAt.equals(aliasRow.createdAt) : aliasRow.createdAt == null;
    }

    @Override
    public int hashCode() {
        int result = id != null ? id.hashCode() : 0;
        result = 31 * result + (phoneNumber != null ? phoneNumber.hashCode() : 0);
        result = 31 * result + (label != null ? label.hashCode() : 0);
        result = 31 * result + (createdAt != null ? createdAt.hashCode() : 0);
        return result;
    }
}
