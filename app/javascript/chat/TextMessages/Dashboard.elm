module TextMessages.Dashboard exposing (..)

import Contacts.Helpers exposing (getContact)
import Contacts.ViewHelpers exposing (contactName)
import Html exposing (Html, a, button, div, form, h1, h2, h3, header, i, input, label, span, text)
import Html.Attributes exposing (attribute, class, disabled, href, id, placeholder, rel, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import HtmlUtils exposing (spin)
import Messages exposing (Msg(..))
import Models exposing (Model, ContactThreadState, UserMessage(ErrorMessage))
import TextMessages.Helpers exposing (latestThreads, messagesForContactId)
import TextMessages.Models exposing (TextMessage, bodyMatchesString, threadContactId)
import UserMessages exposing (userMessages)


view : Model -> Html Msg -> Html Msg
view model content =
    div [ class "main" ]
        [ userMessages model
        , header []
            [ div [ class "header-main" ] [ h1 [ class "app-title" ] [ text "TextChat" ] ]
            , a [ onClick ListContacts, class "nav-link" ] [ text "Contacts" ]
            , a
                [ href "users/sign_out"
                , class "nav-link"
                , attribute "data-method" "delete"
                , rel "nofollow"
                ]
                [ text "Log Out" ]
            ]
        , div [ class "dashboard" ]
            [ div [ class "latest-messages-container" ]
                [ div [ class "latest-messages-header" ]
                    [ div [ class "new-message" ]
                        [ button
                            [ onClick StartComposing
                            , class "button feature"
                            ]
                            [ text "New Message" ]
                        ]
                    , h2 [ class "section-break" ] [ text "Recent" ]
                    ]
                , div [ class "latest-messages-content" ]
                    [ latestMessagesContent model ]
                ]
            , content
            ]
        , modal model.createContactModalOpen (createContactModal model)
        , modal (not model.connectedToServer) (disconnectMessage)
        ]


latestMessagesContent : Model -> Html Msg
latestMessagesContent model =
    let
        theLatestThreads =
            latestThreads model.messages
    in
        case List.length theLatestThreads of
            0 ->
                div [ class "thread-summary" ] [ text "No messages. Click \"New Message\" to send one." ]

            _ ->
                div [] (List.map (threadSummary model) (latestThreads model.messages))


disconnectMessage : Html Msg
disconnectMessage =
    div []
        [ h2 [] [ i [ class "fa fa-spin fa-circle-o-notch" ] [], text " Connecting to server..." ]
        ]


createContactModal : Model -> Html Msg
createContactModal model =
    div []
        [ a [ onClick CloseCreateContactModal, class "modal-close" ]
            [ i [ class "fa fa-close" ] []
            , text " Cancel"
            ]
        , h2 [] [ text "Create Contact" ]
        , form [ onSubmit (CreateFullContact model.createContactName model.createContactPhoneNumber) ]
            [ input
                [ type_ "text"
                , placeholder "Name"
                , id "create-contact-name"
                , value model.createContactName
                , onInput InputCreateContactName
                ]
                []
            , input
                [ type_ "text"
                , placeholder "Phone number"
                , id "create-contact-phone-number"
                , value model.createContactPhoneNumber
                , onInput InputCreateContactPhoneNumber
                ]
                []
            , button
                [ type_ "submit"
                , disabled model.creatingFullContact
                , spin model.creatingFullContact
                ]
                [ text "Submit" ]
            ]
        ]


modal : Bool -> Html Msg -> Html Msg
modal shouldDisplay content =
    if shouldDisplay == True then
        div [ class "modal-container" ]
            [ div [ class "modal" ] [ content ]
            ]
    else
        span [] []


threadSummary : Model -> TextMessage -> Html Msg
threadSummary model textMessage =
    let
        contactId =
            (threadContactId textMessage)

        contact =
            Contacts.Helpers.getContact model.contacts contactId
    in
        div
            [ class "thread-summary"
            , onClick (OpenContactThread contactId)
            ]
            [ div [ class "thread-summary-title" ] [ text <| contactName contact ]
            , div [ class "thread-summary-body" ] [ text textMessage.body ]
            ]
