module Contacts.Decoders exposing (..)

import Json.Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, required)
import Models exposing (Contact)


decodeContactList : Decoder (List Contact)
decodeContactList =
    list decodeContact


decodeContact : Decoder Contact
decodeContact =
    decode Contact
        |> required "id" int
        |> required "phoneNumber" string
        |> required "label" string
