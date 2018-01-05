module Models exposing (..)

import Contacts.Models exposing (Contact, ContactId)
import Dict exposing (Dict)
import Groups.Models exposing (Group, GroupId)
import Routing exposing (Route)
import TextMessages.Models exposing (GroupTextMessage, TextMessage)
import Users.Models exposing (User)


type alias Model =
    { contacts : Dict ContactId Contact
    , contactSuggestions : List ContactId
    , loadingContactSuggestions : Bool
    , omniSearch : String
    , editingContact : Bool
    , contactEdits : Contact
    , savingContactEdits : Bool
    , createContactModalOpen : Bool
    , createContactName : String
    , createContactPhoneNumber : String
    , creatingFullContact : Bool
    , contactThreadState : ContactThreadState
    , groupThreadState : GroupThreadState
    , messages : List TextMessage
    , groupMessages : List GroupTextMessage
    , threadSearch : String
    , addToGroupSearch : String
    , loadingGroupSuggestions : Bool
    , groupAddSuggestions : List GroupId
    , addToGroupContactSearch : String
    , groupAddContactSuggestions : List ContactId
    , loadingGroupContactSuggestions : Bool
    , groups : Dict GroupId Group
    , groupContacts : List ContactId
    , loadingContactMessages : Bool
    , loadingGroupMessages : Bool
    , users : List User
    , route : Route
    , authError : Bool
    , sendingAuth : Bool
    , userMessages : List UserMessage
    , connectedToServer : Bool
    }


type UserMessage
    = ErrorMessage String
    | SuccessMessage String


type alias ContactThreadState =
    { to : ContactId
    , draftMessage : String
    , sendingMessage : Bool
    }


newContactThreadState : ContactId -> ContactThreadState
newContactThreadState contactId =
    { to = contactId
    , draftMessage = ""
    , sendingMessage = False
    }


type alias GroupThreadState =
    { to : GroupId
    , draftMessage : String
    , sendingMessage : Bool
    }


newGroupThreadState : GroupId -> GroupThreadState
newGroupThreadState groupId =
    { to = groupId
    , draftMessage = ""
    , sendingMessage = False
    }
