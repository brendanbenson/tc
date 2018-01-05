module Accounts.Api exposing (..)

import Accounts.Decoders exposing (decodeAccountResponse)
import Http
import Messages exposing (Msg(FetchedAccount))


getAccount : Cmd Msg
getAccount =
    let
        url =
            "/api/account"

        request =
            Http.get url decodeAccountResponse
    in
        Http.send FetchedAccount request
