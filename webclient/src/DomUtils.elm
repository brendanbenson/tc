module DomUtils exposing (..)

import Dom
import Dom.Scroll
import Messages exposing (Msg(NoOp))
import Task


scrollToBottom : String -> Cmd Msg
scrollToBottom id =
    Task.attempt (always NoOp) <| Dom.Scroll.toBottom id


focus : String -> Cmd Msg
focus id =
    Task.attempt (always NoOp) <| Dom.focus id
