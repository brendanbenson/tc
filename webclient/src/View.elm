module View exposing (..)

import Authentication.Login
import Html exposing (Html)
import Messages exposing (Msg)
import Models exposing (Model, TextMessage)
import NotFound
import Routing exposing (Route(..))
import TextMessages.Dashboard


view : Model -> Html Msg
view model =
    case model.route of
        LoginRoute ->
            Authentication.Login.view model

        DashboardRoute ->
            TextMessages.Dashboard.view model

        NotFoundRoute ->
            NotFound.view
