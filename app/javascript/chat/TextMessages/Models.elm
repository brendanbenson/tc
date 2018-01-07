module TextMessages.Models exposing (..)

import Contacts.Models exposing (Contact, ContactId)
import Groups.Models exposing (Group)
import String exposing (contains, toLower)
import Users.Models exposing (UserId)


type alias TextMessage =
    { id : Int
    , body : String
    , incoming : Bool
    , toContactId : ContactId
    , fromContactId : ContactId
    , userId : Maybe UserId
    }


type alias GroupTextMessage =
    { id : Int
    , body : String
    , group : Group
    }


type alias AugmentedTextMessageResponse =
    { textMessages : List TextMessage
    , contacts : List Contact
    }


threadContactId : TextMessage -> ContactId
threadContactId textMessage =
    if textMessage.incoming == True then
        textMessage.fromContactId
    else
        textMessage.toContactId


bodyMatchesString : String -> TextMessage -> Bool
bodyMatchesString q textMessage =
    contains (toLower q) (toLower textMessage.body)
