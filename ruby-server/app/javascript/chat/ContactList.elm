module ContactList exposing (view)

import Contacts.Models exposing (Contact)
import Contacts.ViewHelpers exposing (contactName)
import Dict
import Html exposing (Html, div, h1, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Messages exposing (Msg(OpenContactThread, OpenCreateContactModal))
import Models exposing (Model)


view : Model -> Html Msg
view model =
    div [ class "thread-container" ] <|
        List.concat
            [ [ newContactCell ]
            , (List.map contactCell <| List.sortBy .label <| Dict.values model.contacts)
            ]


newContactCell : Html Msg
newContactCell =
    div [ class "suggestion", onClick (OpenCreateContactModal "") ]
        [ span [ class "body" ] [ text "Create new contact" ]
        ]


contactCell : Contact -> Html Msg
contactCell c =
    div [ class "suggestion", onClick (OpenContactThread c.id) ]
        [ span [ class "body" ] [ text <| contactName c ]
        ]
