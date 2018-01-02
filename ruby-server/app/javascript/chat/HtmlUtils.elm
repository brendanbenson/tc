module HtmlUtils exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (attribute)


spin : Bool -> Attribute msg
spin shouldSpin =
    if shouldSpin == True then
        attribute "spin" "true"
    else
        attribute "spin" "false"
