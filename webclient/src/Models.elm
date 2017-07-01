module Models exposing (..)

import Authentication.AuthToken exposing (AuthToken)
import Contacts.Models exposing (Contact)
import Dict exposing (Dict)
import Routing exposing (Route)
import TextMessages.Models exposing (TextMessage)


type alias Model =
    { contacts : Dict ContactId Contact
    , contactSuggestions : List ContactId
    , loadingContactSuggestions : Bool
    , contactSearch : String
    , editingContact : Bool
    , contactEdits : Contact
    , savingContactEdits : Bool
    , createContactModalOpen : Bool
    , createContactName : String
    , createContactPhoneNumber : String
    , creatingFullContact : Bool
    , messages : List TextMessage
    , loadingContactMessages : Bool
    , workflow : Workflow
    , route : Route
    , username : String
    , password : String
    , connectionData : ConnectionData
    , authError : Bool
    , sendingAuth : Bool
    , userMessages : List UserMessage
    }


type UserMessage
    = ErrorMessage String


type Workflow
    = Thread ThreadState
    | NewContact


type alias ThreadState =
    { to : ContactId
    , draftMessage : String
    , sendingMessage : Bool
    }


newThreadState : ContactId -> ThreadState
newThreadState contactId =
    { to = contactId
    , draftMessage = ""
    , sendingMessage = False
    }


type alias ContactId =
    Int


type alias ConnectionData =
    { authToken : AuthToken
    , baseUrl : String
    }
