port module Ports exposing (..)


port subscribeToTextMessages : () -> Cmd msg


port receiveTextMessages : (String -> msg) -> Sub msg
