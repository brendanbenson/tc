module Contacts.Models exposing (..)

import String exposing (slice)


type alias ContactId =
    Int


type alias Contact =
    { id : ContactId
    , phoneNumber : String
    , label : String
    }
