module View exposing (..)

import Authentication.Login
import Compose
import ContactList
import Html exposing (Html, text)
import Messages exposing (Msg)
import Models exposing (Model)
import NotFound
import Routing exposing (Route(..))
import TextMessages.Dashboard
import ContactThread
import GroupThread


view : Model -> Html Msg
view model =
    case model.route of
        LoginRoute ->
            Authentication.Login.view model

        ComposeRoute ->
            TextMessages.Dashboard.view model (Compose.view model)

        ContactListRoute ->
            TextMessages.Dashboard.view model (ContactList.view model)

        ContactThreadRoute contactId ->
            TextMessages.Dashboard.view model (ContactThread.view model)

        GroupThreadRoute groupId ->
            TextMessages.Dashboard.view model (GroupThread.view model)

        NotFoundRoute ->
            NotFound.view
