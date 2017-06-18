module Authentication.Decoders exposing (..)

import Authentication.Models exposing (AuthenticationResponse)
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)


decodeAuthentication : Decoder AuthenticationResponse
decodeAuthentication =
    decode AuthenticationResponse
        |> required "token" string
