package com.textchat.textmessages;

import com.textchat.persistence.textmessages.TextMessageRow;

class TextMessageResponse {
    private Long id;
    private String body;
    private ContactResponse toContact;
    private ContactResponse fromContact;

    public TextMessageResponse() {
    }

    public TextMessageResponse(Long id, String body, ContactResponse toContact, ContactResponse fromContact) {
        this.id = id;
        this.body = body;
        this.toContact = toContact;
        this.fromContact = fromContact;
    }

    public TextMessageResponse(TextMessageRow textMessageRow) {
        this(
                textMessageRow.getId(),
                textMessageRow.getBody(),
                new ContactResponse(textMessageRow.getToContact()),
                new ContactResponse(textMessageRow.getFromContact())
        );
    }

    public Long getId() {
        return id;
    }

    public String getBody() {
        return body;
    }

    public ContactResponse getToContact() {
        return toContact;
    }

    public ContactResponse getFromContact() {
        return fromContact;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        TextMessageResponse that = (TextMessageResponse) o;

        if (id != null ? !id.equals(that.id) : that.id != null) return false;
        if (body != null ? !body.equals(that.body) : that.body != null) return false;
        if (toContact != null ? !toContact.equals(that.toContact) : that.toContact != null) return false;
        return fromContact != null ? fromContact.equals(that.fromContact) : that.fromContact == null;
    }

    @Override
    public int hashCode() {
        int result = id != null ? id.hashCode() : 0;
        result = 31 * result + (body != null ? body.hashCode() : 0);
        result = 31 * result + (toContact != null ? toContact.hashCode() : 0);
        result = 31 * result + (fromContact != null ? fromContact.hashCode() : 0);
        return result;
    }
}
