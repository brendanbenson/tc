package com.textchat.textmessages;

import com.textchat.persistence.contacts.Contact;
import com.textchat.persistence.contacts.ContactRepository;
import com.textchat.persistence.textmessages.TextMessage;
import com.textchat.persistence.textmessages.TextMessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

import static java.util.Collections.singletonList;
import static java.util.stream.Collectors.toList;

@RestController
public class OtherTextMessagesController {
    private TextMessageRepository textMessageRepository;
    private ContactRepository contactRepository;
    private SimpMessagingTemplate simpMessagingTemplate;
    private TextMessageService textMessageService;

    @Autowired
    public OtherTextMessagesController(
            TextMessageRepository textMessageRepository,
            ContactRepository contactRepository,
            SimpMessagingTemplate simpMessagingTemplate,
            TextMessageService textMessageService
    ) {
        this.textMessageRepository = textMessageRepository;
        this.contactRepository = contactRepository;
        this.simpMessagingTemplate = simpMessagingTemplate;
        this.textMessageService = textMessageService;
    }

    @GetMapping("/text-messages")
    @PreAuthorize("hasAuthority('USER')")
    public List<TextMessageResponse> list() {
        return textMessageRepository
                .findLatestThreads()
                .stream()
                .map(TextMessageResponse::new)
                .collect(toList());
    }

    @GetMapping("/contacts/{contactId}/text-messages")
    @PreAuthorize("hasAuthority('USER')")
    public List<TextMessageResponse> listTextMessagesForContact(@PathVariable Long contactId) {
        Contact contact = contactRepository.findOne(contactId);

        return textMessageRepository
                .findAllByToContactOrderByCreatedAtDesc(contact)
                .stream()
                .map(TextMessageResponse::new)
                .collect(toList());
    }

    @PostMapping("/text-messages")
    @PreAuthorize("hasAuthority('USER')")
    public TextMessageResponse create(@RequestBody SendMessageRequest sendMessageRequest) {
        TextMessage textMessage = textMessageService.send(
                sendMessageRequest.getToPhoneNumber(),
                sendMessageRequest.getBody()
        );

        simpMessagingTemplate.convertAndSend("/text-messages", singletonList(textMessage));

        return new TextMessageResponse(textMessage);
    }

    @PostMapping("/contacts/{contactId}/text-messages")
    @PreAuthorize("hasAuthority('USER')")
    public TextMessageResponse createForContact(
            @RequestBody SendContactMessageRequest sendContactMessageRequest,
            @PathVariable Long contactId
    ) {
        Contact contact = contactRepository.findOne(contactId);

        TextMessage textMessage = textMessageService.send(
                contact.getPhoneNumber(),
                sendContactMessageRequest.getBody()
        );

        simpMessagingTemplate.convertAndSend("/text-messages", singletonList(textMessage));

        return new TextMessageResponse(textMessage);
    }

    @PostMapping("/receive-sms")
    @PreAuthorize("permitAll()")
    public void receiveTextMessage(HttpServletRequest httpServletRequest) {
        String body = httpServletRequest.getParameter("Body");
        String to = httpServletRequest.getParameter("To");
        String from = httpServletRequest.getParameter("From");

        TextMessage textMessage = textMessageService.recordReceipt(from, to, body);

        simpMessagingTemplate.convertAndSend("/text-messages", singletonList(textMessage));
    }
}
