package com.textchat;

import com.textchat.textmessages.NullTextMessageGateway;
import com.textchat.textmessages.TextMessageGateway;
import com.textchat.twilio.TwilioTextMessageGateway;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.oauth2.client.EnableOAuth2Sso;
import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@SpringBootApplication
@EnableOAuth2Sso
public class ServerApplication extends WebSecurityConfigurerAdapter {
    public static void main(String[] args) {
        SpringApplication.run(ServerApplication.class, args);
    }

    @Bean
    public TextMessageGateway textMessageGateway(
            @Value("${twilio.accountSid}") String twilioAccountSid,
            @Value("${twilio.authToken}") String twilioAuthToken
    ) {
//        return new TwilioTextMessageGateway(twilioAccountSid, twilioAuthToken);
        return new NullTextMessageGateway();
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
                .antMatcher("/**").authorizeRequests()
                .antMatchers("/login**", "/receive-sms", "/**").permitAll()
                .anyRequest().authenticated()
                .and().logout().logoutSuccessUrl("/").permitAll()
                .and().csrf().disable();
    }
}
