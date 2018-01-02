port module Ports exposing (..)


port subscribeToTextMessages : () -> Cmd msg


port connectedToTextMessages : (Bool -> msg) -> Sub msg


port receiveTextMessages : (String -> msg) -> Sub msg


port ding : () -> Cmd msg
