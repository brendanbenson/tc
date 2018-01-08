module Users.Decoders exposing (..)

import Json.Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (decode, required)
import Users.Models exposing (User)


decodeUser : Decoder User
decodeUser =
    decode User
        |> required "id" int
        |> required "email" string
        |> required "name" string
