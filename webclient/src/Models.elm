module Models exposing (..)

import Authentication.AuthToken exposing (AuthToken)
import Contacts.Models exposing (Contact)
import Dict exposing (Dict)
import Routing exposing (Route)
import TextMessages.Models exposing (TextMessage)


type alias Model =
    { contacts : Dict ContactId Contact
    , contactSuggestions : List ContactId
    , contactSearch : String
    , editingContact : Bool
    , contactEdits : Contact
    , messages : List TextMessage
    , workflow : Workflow
    , route : Route
    , username : String
    , password : String
    , authToken : AuthToken
    , authError : Bool
    }


type Workflow
    = Thread ThreadState
    | NewContact


type alias ThreadState =
    { to : ContactId
    , draftMessage : String
    }


newThreadState : ContactId -> ThreadState
newThreadState contactId =
    { to = contactId
    , draftMessage = ""
    }


type alias ContactId =
    Int
