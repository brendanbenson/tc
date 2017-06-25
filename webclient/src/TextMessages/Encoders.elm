module TextMessages.Encoders exposing (..)

import Json.Encode exposing (Value, object)


createTextMessageRequest : String -> String -> Value
createTextMessageRequest phoneNumber body =
    object
        [ ( "toPhoneNumber", Json.Encode.string phoneNumber )
        , ( "body", Json.Encode.string body )
        ]


createContactTextMessageRequest : String -> Value
createContactTextMessageRequest body =
    object
        [ ( "body", Json.Encode.string body )
        ]
