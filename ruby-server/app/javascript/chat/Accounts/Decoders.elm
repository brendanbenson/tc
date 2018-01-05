module Accounts.Decoders exposing (..)

import Accounts.Models exposing (Account)
import Json.Decode exposing (Decoder, int, list)
import Json.Decode.Pipeline exposing (decode, required)
import Users.Decoders exposing (decodeUser)
import Users.Models exposing (User)


type alias AccountResponse =
    { account : Account
    , users : List User
    }


decodeAccountResponse : Decoder AccountResponse
decodeAccountResponse =
    decode AccountResponse
        |> required "account" decodeAccount
        |> required "users" (list decodeUser)


decodeAccount : Decoder Account
decodeAccount =
    decode Account
        |> required "id" int
