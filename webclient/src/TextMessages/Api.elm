module TextMessages.Api exposing (..)

import Contacts.Decoders exposing (decodeContactList)
import Contacts.Models exposing (ContactId)
import Groups.Models exposing (GroupId)
import Http exposing (Error, jsonBody)
import Messages exposing (Msg(FetchedContacts, FetchedLatestThreads, FetchedTextMessagesForContact, FetchedTextMessagesForGroup))
import TextMessages.Decoders exposing (decodeAugmentedTextMessageResponse, decodeGroupTextMessage, decodeGroupTextMessageList, decodeTextMessage, decodeTextMessageList)
import TextMessages.Encoders exposing (createTextMessageRequest)
import TextMessages.Models exposing (GroupTextMessage, TextMessage)


fetchLatestThreads : Cmd Msg
fetchLatestThreads =
    let
        url =
            "/api/text-messages"

        request =
            Http.get url decodeAugmentedTextMessageResponse
    in
        Http.send FetchedLatestThreads request


fetchContacts : Cmd Msg
fetchContacts =
    let
        url =
            "/api/contacts"

        request =
            Http.get url decodeContactList
    in
        Http.send FetchedContacts request


fetchListForContact : ContactId -> Cmd Msg
fetchListForContact contactId =
    let
        url =
            "/api/contacts/" ++ (toString contactId) ++ "/text-messages"

        request =
            Http.get url decodeTextMessageList
    in
        Http.send FetchedTextMessagesForContact request


fetchListForGroup : GroupId -> Cmd Msg
fetchListForGroup groupId =
    let
        url =
            "/api/groups/" ++ (toString groupId) ++ "/text-messages"

        request =
            Http.get url decodeGroupTextMessageList
    in
        Http.send FetchedTextMessagesForGroup request


sendContactMessage : ContactId -> String -> (Result Error TextMessage -> Msg) -> Cmd Msg
sendContactMessage contactId body handler =
    let
        url =
            "/api/contacts/" ++ (toString contactId) ++ "/text-messages"

        requestBody =
            createTextMessageRequest body |> jsonBody

        request =
            Http.post url requestBody decodeTextMessage
    in
        Http.send handler request


sendGroupMessage : GroupId -> String -> (Result Error GroupTextMessage -> Msg) -> Cmd Msg
sendGroupMessage groupId body handler =
    let
        url =
            "/api/groups/" ++ (toString groupId) ++ "/text-messages"

        requestBody =
            createTextMessageRequest body |> jsonBody

        request =
            Http.post url requestBody decodeGroupTextMessage
    in
        Http.send handler request
