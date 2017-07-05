module NotFound exposing (..)

import Html exposing (Html, a, div, h2, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Messages exposing (Msg(StartComposing))


view : Html Msg
view =
    div [ class "fill-page" ]
        [ div [ class "fill-panel" ]
            [ h2 [] [ text "Error" ]
            , p []
                [ text "The URL is incorrect. "
                , a [ onClick StartComposing ] [ text "Click here" ]
                , text " to go home."
                ]
            ]
        ]
