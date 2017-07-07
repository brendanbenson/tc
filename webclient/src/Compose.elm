module Compose exposing (..)

import Char exposing (isDigit)
import Contacts.Helpers exposing (getContact)
import Contacts.Models exposing (ContactId)
import Contacts.ViewHelpers exposing (contactName)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Messages exposing (Msg(CreateContact, InputOmniSearch, OpenCreateContactModal, OpenContactThread))
import Models exposing (Model)


view : Model -> Html Msg
view model =
    div [ class "thread-container" ]
        [ label [ class "compose-field" ]
            [ input
                [ onInput InputOmniSearch
                , value model.omniSearch
                , placeholder "Enter name or number"
                , id "contact-search"
                ]
                []
            ]
        , div [] [ recipientSuggestions model ]
        ]


recipientSuggestions : Model -> Html Msg
recipientSuggestions model =
    div []
        [ loadingSuggestions model
        , div [] ((List.map (contactSuggestion model)) model.contactSuggestions)
        , div [] [ rawPhoneNumberSuggestion model ]
        ]


loadingSuggestions : Model -> Html Msg
loadingSuggestions model =
    if model.loadingContactSuggestions == True then
        div [ class "suggestion" ]
            [ span [ class "loading" ]
                [ i [ class "fa fa-spin fa-circle-o-notch" ] []
                , text " Loading suggestions..."
                ]
            ]
    else
        span [] []


contactSuggestion : Model -> ContactId -> Html Msg
contactSuggestion model contactId =
    let
        contact =
            getContact model.contacts contactId
    in
        div [ class "suggestion", onClick (OpenContactThread contactId) ]
            [ span [ class "label" ] [ text "To: " ]
            , span [ class "body" ] [ text <| contactName contact ]
            ]


rawPhoneNumberSuggestion : Model -> Html Msg
rawPhoneNumberSuggestion model =
    case model.omniSearch of
        "" ->
            span [] []

        _ ->
            if String.any isDigit model.omniSearch == True then
                div [ class "suggestion", onClick (CreateContact model.omniSearch) ]
                    [ span [ class "label" ] [ text "New message to: " ]
                    , span [ class "body" ] [ text <| String.filter isDigit model.omniSearch ]
                    ]
            else
                div [ class "suggestion", onClick (OpenCreateContactModal model.omniSearch) ]
                    [ span [ class "label" ] [ text "Create new contact: " ]
                    , span [ class "body" ] [ text model.omniSearch ]
                    ]
