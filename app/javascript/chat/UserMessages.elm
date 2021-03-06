module UserMessages exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Messages exposing (Msg)
import Models exposing (Model, UserMessage(..))


userMessages : Model -> Html Msg
userMessages model =
    div [ class "user-messages-container" ]
        (List.map userMessage model.userMessages)


userMessage : UserMessage -> Html Msg
userMessage message =
    case message of
        ErrorMessage e ->
            div [ class "user-message error" ] [ div [ class "label" ] [ text "Error:" ], text <| " " ++ e ]

        SuccessMessage m ->
            div [ class "user-message success" ] [ text m ]
