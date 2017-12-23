module Contacts.Models exposing (..)

import Groups.Models exposing (Group)
import String exposing (slice)


type alias ContactId =
    Int


type alias Contact =
    { id : ContactId
    , phoneNumber : String
    , label : String
    , groups : List Group
    }


emptyContact : Contact
emptyContact =
    { id = 0
    , phoneNumber = ""
    , label = ""
    , groups = []
    }
