package com.textchat.textmessages;

import com.textchat.persistence.textmessages.TextMessage;

class TextMessageResponse {
    private Long id;
    private String body;
    private Boolean incoming;
    private ContactResponse toContact;
    private ContactResponse fromContact;
    private Boolean read;

    public TextMessageResponse() {
    }

    public TextMessageResponse(Long id, String body, Boolean incoming, ContactResponse toContact, ContactResponse fromContact, Boolean read) {
        this.id = id;
        this.body = body;
        this.incoming = incoming;
        this.toContact = toContact;
        this.fromContact = fromContact;
        this.read = read;
    }

    public TextMessageResponse(TextMessage textMessage, Boolean read) {
        this(
                textMessage.getId(),
                textMessage.getBody(),
                textMessage.getIncoming(),
                new ContactResponse(textMessage.getToContact()),
                new ContactResponse(textMessage.getFromContact()),
                read
        );
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

    public ContactResponse getToContact() {
        return toContact;
    }

    public ContactResponse getFromContact() {
        return fromContact;
    }

    public Boolean getRead() {
        return read;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        TextMessageResponse that = (TextMessageResponse) o;

        if (id != null ? !id.equals(that.id) : that.id != null) return false;
        if (body != null ? !body.equals(that.body) : that.body != null) return false;
        if (incoming != null ? !incoming.equals(that.incoming) : that.incoming != null) return false;
        if (toContact != null ? !toContact.equals(that.toContact) : that.toContact != null) return false;
        return fromContact != null ? fromContact.equals(that.fromContact) : that.fromContact == null;
    }

    @Override
    public int hashCode() {
        int result = id != null ? id.hashCode() : 0;
        result = 31 * result + (body != null ? body.hashCode() : 0);
        result = 31 * result + (incoming != null ? incoming.hashCode() : 0);
        result = 31 * result + (toContact != null ? toContact.hashCode() : 0);
        result = 31 * result + (fromContact != null ? fromContact.hashCode() : 0);
        return result;
    }
}
