package com.textchat;

import com.textchat.validation.ApiErrorCode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.validation.Errors;
import org.springframework.validation.Validator;

@Component
public class UpdateContactRequestValidator implements Validator {
    private PhoneNumberLookupService phoneNumberLookupService;

    @Autowired
    public UpdateContactRequestValidator(PhoneNumberLookupService phoneNumberLookupService) {
        this.phoneNumberLookupService = phoneNumberLookupService;
    }

    @Override
    public boolean supports(Class<?> clazz) {
        return UpdateContactRequest.class.equals(clazz);
    }

    @Override
    public void validate(Object target, Errors errors) {
        UpdateContactRequest createContactRequest = (UpdateContactRequest) target;

        String phoneNumber = createContactRequest.getPhoneNumber();

        if (phoneNumberLookupService.lookup(phoneNumber) == null) {
            errors.rejectValue("phoneNumber", ApiErrorCode.INVALID_PHONE_NUMBER.getCode());
        }
    }
}
