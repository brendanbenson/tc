module Main exposing (..)

import Contacts.Models exposing (emptyContact)
import Dict
import DomUtils exposing (focus)
import Messages exposing (Msg(..))
import Models exposing (Model, ThreadState, UserMessage(ErrorMessage), Workflow(NewContact), newThreadState)
import Navigation exposing (Location)
import Ports exposing (subscribeToTextMessages)
import Routing exposing (Route(..), newUrl)
import Update exposing (from, openDashboard, openThread, update)
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
    { contactSearch = ""
    , messages = []
    , threadSearch = ""
    , addToGroupSearch = ""
    , loadingGroupSuggestions = False
    , groupAddSuggestions = []
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
    , authError = False
    , sendingAuth = False
    , route = route
    , userMessages = []
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
            DashboardRoute ->
                from model |> openDashboard

            ContactThreadRoute contactId ->
                model ! [ fetchLatestThreads ] |> openThread contactId

            LoginRoute ->
                model ! []

            NotFoundRoute ->
                model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.receiveTextMessages ReceiveMessages
