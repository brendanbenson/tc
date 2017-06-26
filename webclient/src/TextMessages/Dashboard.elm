module TextMessages.Dashboard exposing (view)

import Char exposing (isDigit)
import Contacts.Helpers exposing (getContact)
import Contacts.Models exposing (Contact, ContactId)
import Html exposing (Html, a, button, div, form, h1, h2, h3, header, i, input, label, span, text)
import Html.Attributes exposing (class, href, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Messages exposing (Msg(..))
import Models exposing (Model, ThreadState, Workflow(NewContact, Thread))
import TextMessages.Helpers exposing (latestThreads, messagesForContactId)
import TextMessages.Models exposing (TextMessage, threadContactId)


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ header []
            [ h1 [ class "app-title" ] [ text "TextChat" ]
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
                    [ div [] (List.map (threadSummary model) (latestThreads model.messages))
                    ]
                ]
            , workflowView model
            ]
        ]


recipientSuggestions : Model -> Html Msg
recipientSuggestions model =
    div []
        [ div [] ((List.map (contactSuggestion model)) model.contactSuggestions)
        , div [] [ rawPhoneNumberSuggestion model ]
        ]


contactSuggestion : Model -> ContactId -> Html Msg
contactSuggestion model contactId =
    let
        contact =
            getContact model.contacts contactId
    in
        div []
            [ text "To: "
            , a
                [ onClick (OpenThread contactId)
                ]
                [ text <| contactName contact ]
            ]


rawPhoneNumberSuggestion : Model -> Html Msg
rawPhoneNumberSuggestion model =
    if String.any isDigit model.contactSearch == True then
        div []
            [ text "New message to: "
            , a
                [ onClick (CreateContact model.contactSearch)
                ]
                [ text model.contactSearch ]
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
            , onClick (OpenThread contactId)
            ]
            [ div [ class "thread-summary-title" ] [ text <| contactName contact ]
            , div [ class "thread-summary-body" ] [ text textMessage.body ]
            ]


contactName : Contact -> String
contactName contact =
    case contact.label of
        "" ->
            contact.phoneNumber

        label ->
            label


messageView : TextMessage -> Html Msg
messageView textMessage =
    if textMessage.incoming == True then
        div [ class "message-bubble" ] [ text textMessage.body ]
    else
        div [ class "message-bubble outgoing" ] [ text textMessage.body ]


workflowView : Model -> Html Msg
workflowView model =
    case model.workflow of
        Thread threadState ->
            threadView model threadState

        NewContact ->
            newContactView model


threadView : Model -> ThreadState -> Html Msg
threadView model threadState =
    let
        contact =
            Contacts.Helpers.getContact model.contacts threadState.to
    in
        div [ class "thread-container" ]
            [ div [ class "thread-title" ]
                [ h2 [] [ text <| contactName contact, span [] [ text " " ] ]
                ]
            , div [ class "thread-content" ]
                [ div [ class "thread-messages-pane" ]
                    [ div [ class "thread-body", id "thread-body" ]
                        [ div [ class "thread-messages" ]
                            [ div [] (List.map messageView (messagesForContactId contact.id model.messages))
                            ]
                        ]
                    , div [ class "thread-footer" ]
                        [ form [ onSubmit (SendMessage threadState) ]
                            [ div [ class "input-container" ]
                                [ input
                                    [ type_ "text"
                                    , class "message-input"
                                    , placeholder "Type your message here"
                                    , onInput (InputThreadMessage threadState)
                                    , value threadState.draftMessage
                                    ]
                                    []
                                ]
                            ]
                        ]
                    ]
                , div [ class "thread-contact-pane" ]
                    [ contactDetails model contact
                    , h2 [ class "section-break" ] [ text "Options" ]
                    ]
                ]
            ]


contactDetails : Model -> Contact -> Html Msg
contactDetails model contact =
    let
        contactLabel =
            case contact.label of
                "" ->
                    h2 [ class "add-name", onClick <| StartEditingContact contact ]
                        [ i [ class "fa fa-plus" ] []
                        , text " Add Name"
                        ]

                label ->
                    h2 [ onClick <| StartEditingContact contact, class "hover-edit" ] [ text label ]
    in
        case model.editingContact of
            True ->
                div [ class "contact-details" ]
                    [ form [ onSubmit <| EditContact model.contactEdits ]
                        [ input
                            [ type_ "text"
                            , placeholder "Name"
                            , value model.contactEdits.label
                            , onInput InputContactLabel
                            ]
                            []
                        , input
                            [ type_ "text"
                            , placeholder "Phone number"
                            , value model.contactEdits.phoneNumber
                            , onInput InputContactPhoneNumber
                            ]
                            []
                        , button [ type_ "submit" ] [ text "Submit" ]
                        ]
                    ]

            False ->
                div [ class "contact-details" ]
                    [ contactLabel
                    , h3 [ onClick <| StartEditingContact contact, class "hover-edit" ] [ text contact.phoneNumber ]
                    ]


newContactView : Model -> Html Msg
newContactView model =
    div [ class "thread-container" ]
        [ label [ class "compose-field" ]
            [ input [ onInput InputContactSearch, value model.contactSearch, placeholder "Enter name or number" ] []
            ]
        , div [] [ recipientSuggestions model ]
        ]
