port module Ports exposing (..)


type alias TextMessageRequest =
    { body : String
    , toPhoneNumber : String
    }


port sendTextMessage : TextMessageRequest -> Cmd msg


port receiveTextMessages : (String -> msg) -> Sub msg


port setAuthToken : Maybe String -> Cmd msg
