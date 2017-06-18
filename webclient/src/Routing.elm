module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = LoginRoute
    | DashboardRoute
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map LoginRoute top
        , map DashboardRoute (s "dashboard")
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
                    "/"

                DashboardRoute ->
                    "/dashboard"

                NotFoundRoute ->
                    "/not-found"
    in
        "#" ++ hashPage


newUrl : Route -> Cmd msg
newUrl =
    Navigation.newUrl << toUrl
