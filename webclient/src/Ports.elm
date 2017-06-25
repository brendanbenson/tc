port module Ports exposing (..)

import Json.Encode


type alias TextMessageRequest =
    { body : String
    , toPhoneNumber : String
    }


port subscribeToTextMessages : () -> Cmd msg


port receiveTextMessages : (String -> msg) -> Sub msg


port saveAuthToken : Maybe String -> Cmd msg


port saveOpenThreads : Json.Encode.Value -> Cmd msg
