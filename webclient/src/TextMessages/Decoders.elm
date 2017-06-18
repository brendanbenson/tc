module TextMessages.Decoders exposing (decodeTextMessageResponse, decodeTextMessageList)

import Json.Decode exposing (Decoder, decodeString, int, list, maybe, string)
import Json.Decode.Pipeline exposing (decode, required)
import Models exposing (Contact, TextMessage)


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
        |> required "toContact" decodeContact
        |> required "fromContact" decodeContact


decodeContact : Decoder Contact
decodeContact =
    decode Contact
        |> required "id" int
        |> required "phoneNumber" string
        |> required "label" string
