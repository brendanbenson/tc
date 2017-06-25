module TextMessages.Decoders exposing (..)

import Contacts.Decoders exposing (decodeContact)
import Json.Decode exposing (Decoder, bool, decodeString, int, list, maybe, string)
import Json.Decode.Pipeline exposing (decode, required)
import TextMessages.Models exposing (TextMessage)


decodeTextMessageResponse : String -> List TextMessage
decodeTextMessageResponse rawJson =
    case decodeString decodeTextMessageList rawJson of
        Ok stuff ->
            stuff

        Err _ ->
            []


decodeTextMessageList : Decoder (List TextMessage)
decodeTextMessageList =
    list decodeTextMessage


decodeTextMessage : Decoder TextMessage
decodeTextMessage =
    decode TextMessage
        |> required "id" int
        |> required "body" string
        |> required "incoming" bool
        |> required "toContact" decodeContact
        |> required "fromContact" decodeContact
