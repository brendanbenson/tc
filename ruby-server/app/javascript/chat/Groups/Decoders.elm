module Groups.Decoders exposing (..)

import Groups.Models exposing (Group)
import Json.Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, required)


decodeGroupList : Decoder (List Group)
decodeGroupList =
    list decodeGroup


decodeGroup : Decoder Group
decodeGroup =
    decode Group
        |> required "id" int
        |> required "label" string
