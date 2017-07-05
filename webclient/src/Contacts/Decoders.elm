module Contacts.Decoders exposing (..)

import Contacts.Models exposing (Contact)
import Groups.Decoders exposing (decodeGroup)
import Json.Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, required)


decodeContactList : Decoder (List Contact)
decodeContactList =
    list decodeContact


decodeContact : Decoder Contact
decodeContact =
    decode Contact
        |> required "id" int
        |> required "phoneNumber" string
        |> required "label" string
        |> required "groups" (list decodeGroup)
