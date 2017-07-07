package com.textchat;

import com.twilio.exception.ApiException;
import com.twilio.rest.lookups.v1.PhoneNumber;
import com.twilio.rest.lookups.v1.PhoneNumberFetcher;
import org.springframework.stereotype.Service;

@Service
public class PhoneNumberLookupService {
    public ValidPhoneNumber lookup(String phoneNumber) {
        PhoneNumberFetcher phoneNumberFetcher = PhoneNumber.fetcher(
                new com.twilio.type.PhoneNumber(phoneNumber)
        );


        PhoneNumber fetchedPhoneNumber = null;

        try {
            fetchedPhoneNumber = phoneNumberFetcher.fetch();
        } catch (ApiException ignored) {
        }


        if (fetchedPhoneNumber != null) {
            return new ValidPhoneNumber(fetchedPhoneNumber.getNationalFormat());
        }

        return null;
    }
}
