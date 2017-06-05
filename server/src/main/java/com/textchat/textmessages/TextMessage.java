package com.textchat.textmessages;

public class TextMessage {
    private String body;
    private String toPhoneNumber;
    private String fromPhoneNumber;

    public TextMessage(String body, String toPhoneNumber, String fromPhoneNumber) {
        this.body = body;
        this.toPhoneNumber = toPhoneNumber;
        this.fromPhoneNumber = fromPhoneNumber;
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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        TextMessage that = (TextMessage) o;

        if (body != null ? !body.equals(that.body) : that.body != null) return false;
        if (toPhoneNumber != null ? !toPhoneNumber.equals(that.toPhoneNumber) : that.toPhoneNumber != null)
            return false;
        return fromPhoneNumber != null ? fromPhoneNumber.equals(that.fromPhoneNumber) : that.fromPhoneNumber == null;
    }

    @Override
    public int hashCode() {
        int result = body != null ? body.hashCode() : 0;
        result = 31 * result + (toPhoneNumber != null ? toPhoneNumber.hashCode() : 0);
        result = 31 * result + (fromPhoneNumber != null ? fromPhoneNumber.hashCode() : 0);
        return result;
    }
}
