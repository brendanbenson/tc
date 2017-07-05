module View exposing (..)

import Authentication.Login
import Compose
import Html exposing (Html)
import Messages exposing (Msg)
import Models exposing (Model)
import NotFound
import Routing exposing (Route(..))
import TextMessages.Dashboard
import Thread


view : Model -> Html Msg
view model =
    case model.route of
        LoginRoute ->
            Authentication.Login.view model

        ComposeRoute ->
            TextMessages.Dashboard.view model (Compose.view model)

        ContactThreadRoute contactId ->
            TextMessages.Dashboard.view model (Thread.view model)

        NotFoundRoute ->
            NotFound.view
