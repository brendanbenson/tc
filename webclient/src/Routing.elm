module Routing exposing (..)

import Contacts.Models exposing (ContactId)
import Groups.Models exposing (GroupId)
import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = LoginRoute
    | ComposeRoute
    | ContactListRoute
    | ContactThreadRoute ContactId
    | GroupThreadRoute GroupId
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map LoginRoute (s "login")
        , map ContactListRoute (s "contacts")
        , map ContactThreadRoute (s "contacts" </> int)
        , map GroupThreadRoute (s "groups" </> int)
        , map ComposeRoute top
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


toUrl : Route -> String
toUrl route =
    let
        hashPage =
            case route of
                LoginRoute ->
                    "/login"

                ComposeRoute ->
                    "/"

                ContactListRoute ->
                    "/contacts"

                ContactThreadRoute contactId ->
                    "/contacts/" ++ (toString contactId)

                GroupThreadRoute contactId ->
                    "/groups/" ++ (toString contactId)

                NotFoundRoute ->
                    "/not-found"
    in
        "#" ++ hashPage


newUrl : Route -> Cmd msg
newUrl =
    Navigation.newUrl << toUrl
