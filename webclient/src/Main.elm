module Main exposing (..)

import Dict
import Maybe exposing (withDefault)
import Messages exposing (Msg(..))
import Models exposing (Model, TextMessage)
import Navigation exposing (Location)
import Ports
import Routing exposing (Route(..), newUrl, parseLocation)
import Update exposing (update)
import View exposing (view)


main : Program Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initialModel : Flags -> Route -> Model
initialModel flags route =
    { body = ""
    , toPhoneNumber = ""
    , messages = []
    , openThreads = []
    , contacts = Dict.empty
    , username = ""
    , password = ""
    , authToken = flags.authToken
    , authError = False
    , route = route
    , uid = 0
    }


type alias Flags =
    { authToken : Maybe String
    }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            Routing.parseLocation location

        model =
            initialModel flags currentRoute
    in
        case model.authToken of
            Nothing ->
                ( { model | route = LoginRoute }, newUrl LoginRoute )

            Just _ ->
                ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.receiveTextMessages ReceiveMessages
