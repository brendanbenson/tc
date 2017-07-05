module TextMessages.Api exposing (..)

import Contacts.Models exposing (ContactId)
import Http exposing (Error, jsonBody)
import Messages exposing (Msg(FetchedLatestThreads, FetchedTextMessagesForContact))
import TextMessages.Decoders exposing (decodeTextMessage, decodeTextMessageList)
import TextMessages.Encoders exposing (createTextMessageRequest)
import TextMessages.Models exposing (TextMessage)


fetchLatestThreads : Cmd Msg
fetchLatestThreads =
    let
        url =
            "/text-messages"

        request =
            Http.get url decodeTextMessageList
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
