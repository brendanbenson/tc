module TextMessages.Api exposing (..)

import Http exposing (Error, jsonBody)
import HttpHelpers
import Messages exposing (Msg(FetchedLatestThreads, FetchedTextMessagesForContact))
import Models exposing (ConnectionData, ContactId)
import TextMessages.Decoders exposing (decodeTextMessage, decodeTextMessageList)
import TextMessages.Encoders exposing (createTextMessageRequest)
import TextMessages.Models exposing (TextMessage)


fetchLatestThreads : ConnectionData -> Cmd Msg
fetchLatestThreads connectionData =
    let
        url =
            "/text-messages"

        request =
            HttpHelpers.get connectionData url decodeTextMessageList
    in
        Http.send FetchedLatestThreads request


fetchListForContact : ConnectionData -> ContactId -> Cmd Msg
fetchListForContact connectionData contactId =
    let
        url =
            "/contacts/" ++ (toString contactId) ++ "/text-messages"

        request =
            HttpHelpers.get connectionData url decodeTextMessageList
    in
        Http.send FetchedTextMessagesForContact request


sendContactMessage : ConnectionData -> ContactId -> String -> (Result Error TextMessage -> Msg) -> Cmd Msg
sendContactMessage connectionData contactId body handler =
    let
        url =
            "/contacts/" ++ (toString contactId) ++ "/text-messages"

        requestBody =
            createTextMessageRequest body |> jsonBody

        request =
            HttpHelpers.post connectionData url requestBody decodeTextMessage
    in
        Http.send handler request
