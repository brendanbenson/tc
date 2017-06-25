module Decoders exposing (..)

import Contacts.Models exposing (Recipient(KnownContact, RawPhoneNumber))
import Json.Decode exposing (Decoder, andThen, fail, int, list, string, succeed)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Models exposing (ThreadState)


threadStatesDecoder : Decoder (List ThreadState)
threadStatesDecoder =
    list decodeThreadState


decodeThreadState : Decoder ThreadState
decodeThreadState =
    decode ThreadState
        |> required "to" decodeRecipient
        |> required "uid" int
        |> required "draftMessage" string


decodeRecipient : Decoder Recipient
decodeRecipient =
    decodeRecipientJson |> andThen recipientJsonToRecipient


decodeRecipientJson : Decoder RecipientJson
decodeRecipientJson =
    decode RecipientJson
        |> required "recipientType" string
        |> optional "phoneNumber" string ""
        |> optional "contactId" int 0


recipientJsonToRecipient : RecipientJson -> Decoder Recipient
recipientJsonToRecipient recipientJson =
    case recipientJson.recipientType of
        "knownContact" ->
            succeed (KnownContact recipientJson.contactId)

        "rawPhoneNumber" ->
            succeed (RawPhoneNumber recipientJson.phoneNumber)

        _ ->
            fail (recipientJson.recipientType ++ "is not a recognized tag for type Recipient")


type alias RecipientJson =
    { recipientType : String
    , phoneNumber : String
    , contactId : Int
    }
