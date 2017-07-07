module TextMessages.Models exposing (..)

import Contacts.Models exposing (Contact, ContactId)
import Groups.Models exposing (Group)
import String exposing (contains, toLower)


type alias TextMessage =
    { id : Int
    , body : String
    , incoming : Bool
    , toContact : Contact
    , fromContact : Contact
    }


type alias GroupTextMessage =
    { id : Int
    , body : String
    , group : Group
    }


threadContactId : TextMessage -> ContactId
threadContactId textMessage =
    if textMessage.incoming == True then
        textMessage.fromContact.id
    else
        textMessage.toContact.id


bodyMatchesString : String -> TextMessage -> Bool
bodyMatchesString q textMessage =
    contains (toLower q) (toLower textMessage.body)
