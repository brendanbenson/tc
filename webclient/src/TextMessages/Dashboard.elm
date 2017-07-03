module TextMessages.Dashboard exposing (view)

import Char exposing (isDigit)
import Contacts.Helpers exposing (getContact)
import Contacts.Models exposing (Contact, ContactId)
import Html exposing (Html, a, button, div, form, h1, h2, h3, header, i, input, label, span, text)
import Html.Attributes exposing (class, disabled, href, id, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import HtmlUtils exposing (spin)
import Messages exposing (Msg(..))
import Models exposing (Model, ThreadState, UserMessage(ErrorMessage), Workflow(NewContact, Thread))
import TextMessages.Helpers exposing (latestThreads, messagesForContactId)
import TextMessages.Models exposing (TextMessage, threadContactId)


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ userMessages model
        , header []
            [ div [ class "header-main" ]
                [ h1 [ class "app-title" ] [ text "TextChat" ]
                ]
            , a [ href "/logout", class "log-out" ] [ text "Log Out" ]
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
        , modal model.createContactModalOpen (createContactModal model)
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
        div [ class "contact-suggestion" ]
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
        div [ class "contact-suggestion", onClick (OpenThread contactId) ]
            [ span [ class "label" ] [ text "To: " ]
            , span [ class "body" ] [ text <| contactName contact ]
            ]


rawPhoneNumberSuggestion : Model -> Html Msg
rawPhoneNumberSuggestion model =
    case model.contactSearch of
        "" ->
            span [] []

        _ ->
            if String.any isDigit model.contactSearch == True then
                div [ class "contact-suggestion", onClick (CreateContact model.contactSearch) ]
                    [ span [ class "label" ] [ text "New message to: " ]
                    , span [ class "body" ] [ text <| String.filter isDigit model.contactSearch ]
                    ]
            else
                div [ class "contact-suggestion", onClick (OpenCreateContactModal model.contactSearch) ]
                    [ span [ class "label" ] [ text "Create new contact: " ]
                    , span [ class "body" ] [ text model.contactSearch ]
                    ]


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


messageLoadingView : ThreadState -> Html Msg
messageLoadingView threadState =
    if threadState.sendingMessage == True then
        div [ class "message-bubble outgoing loading" ]
            [ i [ class "fa fa-spin fa-circle-o-notch" ] []
            , text " "
            , text threadState.draftMessage
            ]
    else
        span [] []


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
                            [ loadingMessages model
                            , div [] (List.map messageView (messagesForContactId contact.id model.messages))
                            , messageLoadingView threadState
                            ]
                        ]
                    , div [ class "thread-footer" ]
                        [ form [ onSubmit (SendMessage threadState) ]
                            [ div [ class "input-container" ]
                                [ input
                                    [ type_ "text"
                                    , class "message-input"
                                    , id "message-input"
                                    , placeholder "Type your message here"
                                    , onInput (InputThreadMessage threadState)
                                    , value threadState.draftMessage
                                    , disabled threadState.sendingMessage
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


loadingMessages : Model -> Html Msg
loadingMessages model =
    if model.loadingContactMessages == True then
        div [ class "loading-messages" ]
            [ i [ class "fa fa-spin fa-circle-o-notch" ] []
            , text " Loading more..."
            ]
    else
        span [] []


contactDetails : Model -> Contact -> Html Msg
contactDetails model contact =
    let
        contactLabel =
            case contact.label of
                "" ->
                    h2 [ class "add-name", onClick <| StartEditingContact "edit-contact-label" contact ]
                        [ i [ class "fa fa-plus" ] []
                        , text " Add Name"
                        ]

                label ->
                    h2 [ onClick <| StartEditingContact "edit-contact-label" contact, class "hover-edit" ] [ text label ]
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
                            , id "edit-contact-label"
                            ]
                            []
                        , input
                            [ type_ "text"
                            , placeholder "Phone number"
                            , value model.contactEdits.phoneNumber
                            , onInput InputContactPhoneNumber
                            , id "edit-contact-phone-number"
                            ]
                            []
                        , button
                            [ type_ "submit"
                            , spin model.savingContactEdits
                            , disabled model.savingContactEdits
                            ]
                            [ text "Submit" ]
                        ]
                    ]

            False ->
                div [ class "contact-details" ]
                    [ contactLabel
                    , h3 [ onClick <| StartEditingContact "edit-contact-phone-number" contact, class "hover-edit" ] [ text contact.phoneNumber ]
                    ]


newContactView : Model -> Html Msg
newContactView model =
    div [ class "thread-container" ]
        [ label [ class "compose-field" ]
            [ input
                [ onInput InputContactSearch
                , value model.contactSearch
                , placeholder "Enter name or number"
                , id "contact-search"
                ]
                []
            ]
        , div [] [ recipientSuggestions model ]
        ]


userMessages : Model -> Html Msg
userMessages model =
    div [ class "user-messages-container" ]
        (List.map userMessage model.userMessages)


userMessage : UserMessage -> Html Msg
userMessage message =
    case message of
        ErrorMessage e ->
            div [ class "user-message error" ] [ text e ]
