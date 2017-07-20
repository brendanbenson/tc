package com.textchat.textmessages;

import com.textchat.persistence.textmessages.TextMessage;

class TextMessageResponse {
    private Long id;
    private String body;
    private Boolean incoming;
    private Long toContactId;
    private Long fromContactId;
    private Boolean read;

    public TextMessageResponse() {
    }

    public TextMessageResponse(
            Long id,
            String body,
            Boolean incoming,
            Long toContactId,
            Long fromContactId,
            Boolean read
    ) {
        this.id = id;
        this.body = body;
        this.incoming = incoming;
        this.toContactId = toContactId;
        this.fromContactId = fromContactId;
        this.read = read;
    }

    public TextMessageResponse(TextMessage textMessage, Boolean read) {
        this(
                textMessage.getId(),
                textMessage.getBody(),
                textMessage.getIncoming(),
                textMessage.getToContact().getId(),
                textMessage.getFromContact().getId(),
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

    public Long getToContactId() {
        return toContactId;
    }

    public Long getFromContactId() {
        return fromContactId;
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
        if (toContactId != null ? !toContactId.equals(that.toContactId) : that.toContactId != null) return false;
        if (fromContactId != null ? !fromContactId.equals(that.fromContactId) : that.fromContactId != null) return false;
        return read != null ? read.equals(that.read) : that.read == null;
    }

    @Override
    public int hashCode() {
        int result = id != null ? id.hashCode() : 0;
        result = 31 * result + (body != null ? body.hashCode() : 0);
        result = 31 * result + (incoming != null ? incoming.hashCode() : 0);
        result = 31 * result + (toContactId != null ? toContactId.hashCode() : 0);
        result = 31 * result + (fromContactId != null ? fromContactId.hashCode() : 0);
        result = 31 * result + (read != null ? read.hashCode() : 0);
        return result;
    }
}
