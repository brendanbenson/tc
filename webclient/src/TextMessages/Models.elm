module TextMessages.Models exposing (..)

import Contacts.Models exposing (Contact, ContactId)
import String exposing (contains, toLower)


type alias TextMessage =
    { id : Int
    , body : String
    , incoming : Bool
    , toContact : Contact
    , fromContact : Contact
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
