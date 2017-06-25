module TextMessages.Api exposing (..)

import Authentication.AuthToken exposing (AuthToken)
import Http exposing (Error, jsonBody)
import HttpHelpers
import Messages exposing (Msg(FetchedLatestThreads, FetchedListForContact, SentRawPhoneNumberMessage))
import Models exposing (ContactId)
import TextMessages.Decoders exposing (decodeTextMessage, decodeTextMessageList)
import TextMessages.Encoders exposing (createContactTextMessageRequest, createTextMessageRequest)
import TextMessages.Models exposing (TextMessage)


fetchLatestThreads : AuthToken -> Cmd Msg
fetchLatestThreads authToken =
    let
        url =
            "http://localhost:8080/text-messages"

        request =
            HttpHelpers.get authToken url decodeTextMessageList
    in
        Http.send FetchedLatestThreads request


fetchListForContact : AuthToken -> ContactId -> Cmd Msg
fetchListForContact authToken contactId =
    let
        url =
            "http://localhost:8080/contacts/" ++ (toString contactId) ++ "/text-messages"

        request =
            HttpHelpers.get authToken url decodeTextMessageList
    in
        Http.send FetchedListForContact request


sendRawPhoneNumberMessage : AuthToken -> String -> String -> (Result Error TextMessage -> Msg) -> Cmd Msg
sendRawPhoneNumberMessage authToken phoneNumber body handler =
    let
        url =
            "http://localhost:8080/text-messages"

        requestBody =
            createTextMessageRequest phoneNumber body |> jsonBody

        request =
            HttpHelpers.post authToken url requestBody decodeTextMessage
    in
        Http.send handler request


sendContactMessage : AuthToken -> ContactId -> String -> (Result Error TextMessage -> Msg) -> Cmd Msg
sendContactMessage authToken contactId body handler =
    let
        url =
            "http://localhost:8080/contacts/" ++ (toString contactId) ++ "/text-messages"

        requestBody =
            createContactTextMessageRequest body |> jsonBody

        request =
            HttpHelpers.post authToken url requestBody decodeTextMessage
    in
        Http.send handler request
