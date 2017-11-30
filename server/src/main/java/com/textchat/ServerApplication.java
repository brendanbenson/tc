package com.textchat;

import com.textchat.textmessages.NullTextMessageGateway;
import com.textchat.textmessages.TextMessageGateway;
import com.textchat.twilio.TwilioTextMessageGateway;
import com.twilio.Twilio;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.oauth2.client.EnableOAuth2Sso;
import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

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
        Twilio.init(twilioAccountSid, twilioAuthToken);
//        return new TwilioTextMessageGateway(twilioAccountSid, twilioAuthToken);
        return new NullTextMessageGateway();
    }
}
