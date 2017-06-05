port module Ports exposing (..)

import Models exposing (TextMessage)


port sendTextMessage : TextMessage -> Cmd msg


port receiveTextMessages : (String -> msg) -> Sub msg
