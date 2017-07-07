module Main exposing (..)

import Contacts.Models exposing (emptyContact)
import Dict
import Messages exposing (Msg(..))
import Models exposing (ContactThreadState, Model, UserMessage(ErrorMessage), newContactThreadState, newGroupThreadState)
import Navigation exposing (Location)
import Ports exposing (subscribeToTextMessages)
import Routing exposing (Route(..), newUrl)
import Update exposing (from, openDashboard, openGroupThread, openThread, update)
import View exposing (view)
import Platform.Cmd exposing (Cmd)
import TextMessages.Api exposing (fetchLatestThreads, fetchLatestThreads, fetchListForContact)


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initialModel : Route -> Model
initialModel route =
    { omniSearch = ""
    , messages = []
    , groupMessages = []
    , groupContacts = []
    , threadSearch = ""
    , addToGroupSearch = ""
    , loadingGroupSuggestions = False
    , groupAddSuggestions = []
    , addToGroupContactSearch = ""
    , loadingGroupContactSuggestions = False
    , groupAddContactSuggestions = []
    , loadingContactMessages = False
    , loadingGroupMessages = False
    , contactSuggestions = []
    , loadingContactSuggestions = False
    , contactThreadState = newContactThreadState 0
    , groupThreadState = newGroupThreadState 0
    , contacts = Dict.empty
    , groups = Dict.empty
    , editingContact = False
    , contactEdits = emptyContact
    , savingContactEdits = False
    , createContactModalOpen = False
    , createContactName = ""
    , createContactPhoneNumber = ""
    , creatingFullContact = False
    , username = ""
    , password = ""
    , authError = False
    , sendingAuth = False
    , route = route
    , userMessages = []
    , connectedToServer = False
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            Routing.parseLocation location

        model =
            initialModel currentRoute
    in
        case currentRoute of
            ComposeRoute ->
                from model |> openDashboard

            ContactThreadRoute contactId ->
                model ! [ fetchLatestThreads ] |> openThread contactId

            GroupThreadRoute groupId ->
                model ! [ fetchLatestThreads ] |> openGroupThread groupId

            LoginRoute ->
                model ! []

            NotFoundRoute ->
                model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.receiveTextMessages ReceiveMessages
        , Ports.connectedToTextMessages Connected
        ]
