module NotFound exposing (..)

import Html exposing (Html, div, text)
import Messages exposing (Msg)


view : Html Msg
view =
    div [] [ text "Not found" ]
