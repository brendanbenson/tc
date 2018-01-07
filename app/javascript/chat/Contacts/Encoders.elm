module Contacts.Encoders exposing (..)

import Contacts.Models exposing (Contact)
import Json.Encode exposing (Value, object)


createContactRequest : String -> String -> Value
createContactRequest label phoneNumber =
    object
        [ ( "label", Json.Encode.string label )
        , ( "phoneNumber", Json.Encode.string phoneNumber )
        ]


editContactRequest : Contact -> Value
editContactRequest contact =
    object
        [ ( "id", Json.Encode.int contact.id )
        , ( "phoneNumber", Json.Encode.string contact.phoneNumber )
        , ( "label", Json.Encode.string contact.label )
        ]
