module Main exposing (..)

import Dict
import Maybe exposing (withDefault)
import Messages exposing (Msg(..))
import Models exposing (Model, ThreadState, Workflow(NewContact), newThreadState)
import Navigation exposing (Location)
import Ports exposing (subscribeToTextMessages)
import Routing exposing (Route(..), newUrl)
import Update exposing (update)
import View exposing (view)
import Platform.Cmd exposing (Cmd)
import TextMessages.Api exposing (fetchLatestThreads, fetchLatestThreads, fetchListForContact)


main : Program Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initialModel : Maybe String -> Route -> Model
initialModel authToken route =
    { toPhoneNumber = ""
    , messages = []
    , contactSuggestions = []
    , workflow = NewContact
    , contacts = Dict.empty
    , username = ""
    , password = ""
    , authToken = authToken
    , authError = False
    , route = route
    }



-- TODO: use a JSON decoder for Flags


type alias Flags =
    { authToken : Maybe String
    }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            Routing.parseLocation location

        model =
            initialModel flags.authToken currentRoute
    in
        case model.authToken of
            Nothing ->
                { model | route = LoginRoute } ! [ newUrl LoginRoute ]

            Just _ ->
                case currentRoute of
                    DashboardRoute ->
                        model
                            ! [ subscribeToTextMessages ()
                              , fetchLatestThreads model.authToken
                              ]

                    _ ->
                        model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.receiveTextMessages ReceiveMessages
