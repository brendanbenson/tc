package com.textchat;

import com.textchat.textmessages.NullTextMessageGateway;
import com.textchat.textmessages.TextMessageGateway;
import com.textchat.twilio.TwilioTextMessageGateway;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class ServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ServerApplication.class, args);
    }

    @Bean
    public TextMessageGateway textMessageGateway(
            @Value("${twilio.accountSid}") String twilioAccountSid,
            @Value("${twilio.authToken}") String twilioAuthToken
    ) {
        return new TwilioTextMessageGateway(twilioAccountSid, twilioAuthToken);
//        return new NullTextMessageGateway();
    }
}
