module Models exposing (..)

import Authentication.AuthToken exposing (AuthToken)
import Dict exposing (Dict)
import Routing exposing (Route)
import Set exposing (Set)


type alias Model =
    { body : String
    , contacts : Dict ContactId Contact
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


type alias TextMessage =
    { id : Int
    , body : String
    , toContact : Contact
    , fromContact : Contact
    }


type alias Contact =
    { id : ContactId
    , phoneNumber : String
    , label : String
    }


type alias ThreadState =
    { contactId : ContactId
    , uid : Uid
    , draftMessage : String
    }


newThreadState : ContactId -> Uid -> ThreadState
newThreadState contactId uid =
    { contactId = contactId
    , uid = uid
    , draftMessage = ""
    }


type alias ContactId =
    Int
