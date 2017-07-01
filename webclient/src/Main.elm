module Main exposing (..)

import Contacts.Models exposing (emptyContact)
import Dict
import DomUtils exposing (focus)
import Maybe exposing (withDefault)
import Messages exposing (Msg(..))
import Models exposing (Model, ThreadState, UserMessage(ErrorMessage), Workflow(NewContact), newThreadState)
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


initialModel : Flags -> Route -> Model
initialModel flags route =
    { contactSearch = ""
    , messages = []
    , loadingContactMessages = False
    , contactSuggestions = []
    , loadingContactSuggestions = False
    , workflow = NewContact
    , contacts = Dict.empty
    , editingContact = False
    , contactEdits = emptyContact
    , savingContactEdits = False
    , createContactModalOpen = False
    , createContactName = ""
    , createContactPhoneNumber = ""
    , creatingFullContact = False
    , username = ""
    , password = ""
    , connectionData =
        { authToken = flags.authToken
        , baseUrl = flags.baseUrl
        }
    , authError = False
    , sendingAuth = False
    , route = route
    , userMessages = []
    }



-- TODO: use a JSON decoder for Flags


type alias Flags =
    { authToken : Maybe String
    , baseUrl : String
    }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            Routing.parseLocation location

        model =
            initialModel flags currentRoute
    in
        case model.connectionData.authToken of
            Nothing ->
                { model | route = LoginRoute } ! [ newUrl LoginRoute ]

            Just _ ->
                case currentRoute of
                    DashboardRoute ->
                        model
                            ! [ subscribeToTextMessages ()
                              , fetchLatestThreads model.connectionData
                              , focus "contact-search"
                              ]

                    LoginRoute ->
                        { model | route = DashboardRoute }
                            ! [ subscribeToTextMessages ()
                              , fetchLatestThreads model.connectionData
                              , focus "contact-search"
                              ]

                    _ ->
                        model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.receiveTextMessages ReceiveMessages
