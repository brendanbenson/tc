module TextMessages.Encoders exposing (..)

import Json.Encode exposing (Value, object)


createTextMessageRequest : String -> Value
createTextMessageRequest body =
    object
        [ ( "body", Json.Encode.string body )
        ]
