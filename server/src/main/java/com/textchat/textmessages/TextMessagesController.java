package com.textchat.textmessages;

import com.textchat.persistence.contacts.Contact;
import com.textchat.persistence.contacts.ContactRepository;
import com.textchat.persistence.textmessages.TextMessage;
import com.textchat.persistence.textmessages.TextMessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.stream.Stream;

import static java.util.Arrays.asList;
import static java.util.Collections.singletonList;
import static java.util.stream.Collectors.toList;

@RestController
public class TextMessagesController {
    private TextMessageRepository textMessageRepository;
    private ContactRepository contactRepository;
    private SimpMessagingTemplate simpMessagingTemplate;
    private TextMessageService textMessageService;

    @Autowired
    public TextMessagesController(
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
    public AugmentedTextMessageResponse list() {
        List<TextMessage> latestThreads = textMessageRepository
                .findLatestThreads();

        List<TextMessageResponse> textMessageResponses = latestThreads
                .stream()
                .map(textMessage -> new TextMessageResponse(textMessage, false)) // TODO
                .collect(toList());

        List<ContactResponse> contactResponses = latestThreads
                .stream()
                .flatMap(textMessage ->
                        Stream.of(
                                new ContactResponse(textMessage.getToContact()),
                                new ContactResponse(textMessage.getFromContact())
                        )
                )
                .collect(toList());

        return new AugmentedTextMessageResponse(textMessageResponses, contactResponses);
    }

    @GetMapping("/contacts/{contactId}/text-messages")
    public List<TextMessageResponse> listTextMessagesForContact(@PathVariable Long contactId) {
        Contact contact = contactRepository.findOne(contactId);

        return textMessageRepository
                .findAllByToContactOrFromContactOrderByCreatedAtDesc(contact, contact)
                .stream()
                .map(textMessage -> new TextMessageResponse(textMessage, false)) // TODO
                .collect(toList());
    }

    @PostMapping("/contacts/{contactId}/text-messages")
    public TextMessageResponse createForContact(
            @RequestBody SendMessageRequest sendMessageRequest,
            @PathVariable Long contactId
    ) {

        TextMessage textMessage = textMessageService.send(
                contactRepository.findOne(contactId),
                sendMessageRequest.getBody()
        );

        TextMessageResponse textMessageResponse = new TextMessageResponse(textMessage, false);

        simpMessagingTemplate.convertAndSend("/text-messages",
                new AugmentedTextMessageResponse(
                        singletonList(textMessageResponse),
                        asList(
                                new ContactResponse(textMessage.getToContact()),
                                new ContactResponse(textMessage.getFromContact())
                        )
                )
        );

        return textMessageResponse; // TODO
    }

    // TODO: add some security here so random people can't hit this endpoint
    @PostMapping("/receive-sms")
    public void receiveTextMessage(HttpServletRequest httpServletRequest) {
        String body = httpServletRequest.getParameter("Body");
        String to = httpServletRequest.getParameter("To");
        String from = httpServletRequest.getParameter("From");

        TextMessage textMessage = textMessageService.recordReceipt(from, to, body);

        simpMessagingTemplate.convertAndSend("/text-messages", new AugmentedTextMessageResponse(
                singletonList(new TextMessageResponse(textMessage, false)),
                asList(
                        new ContactResponse(textMessage.getToContact()),
                        new ContactResponse(textMessage.getFromContact()))
                )
        );
    }
}
