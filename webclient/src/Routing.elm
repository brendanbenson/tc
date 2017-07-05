module Routing exposing (..)

import Contacts.Models exposing (ContactId)
import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = LoginRoute
    | ComposeRoute
    | ContactThreadRoute ContactId
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map LoginRoute (s "login")
        , map ContactThreadRoute (s "contacts" </> int)
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

                ContactThreadRoute contactId ->
                    "/contacts/" ++ (toString contactId)

                NotFoundRoute ->
                    "/not-found"
    in
        "#" ++ hashPage


newUrl : Route -> Cmd msg
newUrl =
    Navigation.newUrl << toUrl
