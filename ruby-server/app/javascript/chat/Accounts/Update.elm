module Accounts.Update exposing (..)

import Accounts.Api exposing (getAccount)
import Messages exposing (Msg)
import Models exposing (Model)


fetchAccount : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
fetchAccount ( model, cmd ) =
    model ! [ cmd, getAccount ]
