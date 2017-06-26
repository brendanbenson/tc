module Contacts.Encoders exposing (..)

import Contacts.Models exposing (Contact)
import Json.Encode exposing (Value, object)


createContactRequest : String -> Value
createContactRequest phoneNumber =
    object
        [ ( "phoneNumber", Json.Encode.string phoneNumber )
        ]


editContactRequest : Contact -> Value
editContactRequest contact =
    object
        [ ( "id", Json.Encode.int contact.id )
        , ( "phoneNumber", Json.Encode.string contact.phoneNumber )
        , ( "label", Json.Encode.string contact.label )
        ]
