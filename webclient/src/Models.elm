module Models exposing (..)

import Authentication.AuthToken exposing (AuthToken)
import Contacts.Models exposing (Recipient)
import Dict exposing (Dict)
import Routing exposing (Route)
import TextMessages.Models exposing (TextMessage)


type alias Model =
    { contacts : Dict ContactId Contact
    , contactSuggestions : List ContactId
    , toPhoneNumber : String
    , messages : List TextMessage
    , openThreads : List ThreadState
    , route : Route
    , username : String
    , password : String
    , authToken : AuthToken
    , authError : Bool
    , uid : Uid
    }


type alias Uid =
    Int


type alias Contact =
    { id : ContactId
    , phoneNumber : String
    , label : String
    }


type alias ThreadState =
    { to : Recipient
    , uid : Uid
    , draftMessage : String
    }


newThreadState : Recipient -> Uid -> ThreadState
newThreadState recipient uid =
    { to = recipient
    , uid = uid
    , draftMessage = ""
    }


type alias ContactId =
    Int
