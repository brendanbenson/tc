module TextMessages.Decoders exposing (..)

import Contacts.Decoders exposing (decodeContactList)
import Groups.Decoders exposing (decodeGroup)
import Json.Decode exposing (Decoder, bool, decodeString, int, list, maybe, string)
import Json.Decode.Pipeline exposing (decode, required)
import TextMessages.Models exposing (AugmentedTextMessageResponse, GroupTextMessage, TextMessage)


decodeTextMessageList : Decoder (List TextMessage)
decodeTextMessageList =
    list decodeTextMessage


decodeTextMessage : Decoder TextMessage
decodeTextMessage =
    decode TextMessage
        |> required "id" int
        |> required "body" string
        |> required "incoming" bool
        |> required "toContactId" int
        |> required "fromContactId" int
        |> required "user_id" (maybe int)


decodeGroupTextMessageList : Decoder (List GroupTextMessage)
decodeGroupTextMessageList =
    list decodeGroupTextMessage


decodeGroupTextMessage : Decoder GroupTextMessage
decodeGroupTextMessage =
    decode GroupTextMessage
        |> required "id" int
        |> required "body" string
        |> required "group" decodeGroup


decodeAugmentedTextMessageResponse : Decoder AugmentedTextMessageResponse
decodeAugmentedTextMessageResponse =
    decode AugmentedTextMessageResponse
        |> required "textMessages" (decodeTextMessageList)
        |> required "contacts" (decodeContactList)
