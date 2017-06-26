module Contacts.Encoders exposing (..)

import Json.Encode exposing (Value, object)


createContactRequest : String -> Value
createContactRequest phoneNumber =
    object
        [ ( "phoneNumber", Json.Encode.string phoneNumber )
        ]
