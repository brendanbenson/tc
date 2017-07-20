module TextMessages.Api exposing (..)

import Contacts.Models exposing (ContactId)
import Groups.Models exposing (GroupId)
import Http exposing (Error, jsonBody)
import Messages exposing (Msg(FetchedLatestThreads, FetchedTextMessagesForContact, FetchedTextMessagesForGroup))
import TextMessages.Decoders exposing (decodeAugmentedTextMessageResponse, decodeGroupTextMessage, decodeGroupTextMessageList, decodeTextMessage, decodeTextMessageList)
import TextMessages.Encoders exposing (createTextMessageRequest)
import TextMessages.Models exposing (GroupTextMessage, TextMessage)


fetchLatestThreads : Cmd Msg
fetchLatestThreads =
    let
        url =
            "/text-messages"

        request =
            Http.get url decodeAugmentedTextMessageResponse
    in
        Http.send FetchedLatestThreads request


fetchListForContact : ContactId -> Cmd Msg
fetchListForContact contactId =
    let
        url =
            "/contacts/" ++ (toString contactId) ++ "/text-messages"

        request =
            Http.get url decodeTextMessageList
    in
        Http.send FetchedTextMessagesForContact request


fetchListForGroup : GroupId -> Cmd Msg
fetchListForGroup groupId =
    let
        url =
            "/groups/" ++ (toString groupId) ++ "/text-messages"

        request =
            Http.get url decodeGroupTextMessageList
    in
        Http.send FetchedTextMessagesForGroup request


sendContactMessage : ContactId -> String -> (Result Error TextMessage -> Msg) -> Cmd Msg
sendContactMessage contactId body handler =
    let
        url =
            "/contacts/" ++ (toString contactId) ++ "/text-messages"

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
            "/groups/" ++ (toString groupId) ++ "/text-messages"

        requestBody =
            createTextMessageRequest body |> jsonBody

        request =
            Http.post url requestBody decodeGroupTextMessage
    in
        Http.send handler request
