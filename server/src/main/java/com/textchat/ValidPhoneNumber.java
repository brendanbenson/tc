package com.textchat;

public class ValidPhoneNumber {
    private String formattedNumber;

    public ValidPhoneNumber(String formattedNumber) {

        this.formattedNumber = formattedNumber;
    }

    public String getFormattedNumber() {
        return formattedNumber;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        ValidPhoneNumber that = (ValidPhoneNumber) o;

        return formattedNumber != null ? formattedNumber.equals(that.formattedNumber) : that.formattedNumber == null;
    }

    @Override
    public int hashCode() {
        return formattedNumber != null ? formattedNumber.hashCode() : 0;
    }
}
