package com.textchat;

import com.textchat.textmessages.NullTextMessageGateway;
import com.textchat.textmessages.TextMessageGateway;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;

@SpringBootApplication
public class ServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ServerApplication.class, args);
    }

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurerAdapter() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry
                        .addMapping("/*")
                        .allowedOrigins("*")
                        .allowedMethods("GET", "HEAD", "POST", "PUT");
            }
        };
    }

    @Bean
    public TextMessageGateway textMessageGateway(
            @Value("${twilio.accountSid}") String twilioAccountSid,
            @Value("${twilio.authToken}") String twilioAuthToken
    ) {
//        return new TwilioTextMessageGateway(twilioAccountSid, twilioAuthToken);
        return new NullTextMessageGateway();
    }
}
