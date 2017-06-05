package com.textchat.persistence.textmessages;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "text_messages")
public class TextMessageRow {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String body;
    private String toPhoneNumber;
    private String fromPhoneNumber;
    @Column(updatable = false, insertable = false)
    private Date createdAt;
    private Date deliveredAt;

    protected TextMessageRow() {
    }

    public TextMessageRow(String body, String toPhoneNumber, String fromPhoneNumber) {
        this.body = body;
        this.toPhoneNumber = toPhoneNumber;
        this.fromPhoneNumber = fromPhoneNumber;
    }

    public Long getId() {
        return id;
    }

    public String getBody() {
        return body;
    }

    public String getToPhoneNumber() {
        return toPhoneNumber;
    }

    public String getFromPhoneNumber() {
        return fromPhoneNumber;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public Date getDeliveredAt() {
        return deliveredAt;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        TextMessageRow that = (TextMessageRow) o;

        if (id != null ? !id.equals(that.id) : that.id != null) return false;
        if (body != null ? !body.equals(that.body) : that.body != null) return false;
        if (toPhoneNumber != null ? !toPhoneNumber.equals(that.toPhoneNumber) : that.toPhoneNumber != null)
            return false;
        if (fromPhoneNumber != null ? !fromPhoneNumber.equals(that.fromPhoneNumber) : that.fromPhoneNumber != null)
            return false;
        if (createdAt != null ? !createdAt.equals(that.createdAt) : that.createdAt != null) return false;
        return deliveredAt != null ? deliveredAt.equals(that.deliveredAt) : that.deliveredAt == null;
    }

    @Override
    public int hashCode() {
        int result = id != null ? id.hashCode() : 0;
        result = 31 * result + (body != null ? body.hashCode() : 0);
        result = 31 * result + (toPhoneNumber != null ? toPhoneNumber.hashCode() : 0);
        result = 31 * result + (fromPhoneNumber != null ? fromPhoneNumber.hashCode() : 0);
        result = 31 * result + (createdAt != null ? createdAt.hashCode() : 0);
        result = 31 * result + (deliveredAt != null ? deliveredAt.hashCode() : 0);
        return result;
    }
}
