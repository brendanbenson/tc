module TextMessages.Dashboard exposing (view)

import Contacts.Helpers exposing (getContact)
import Contacts.Models exposing (Contact, ContactId, Recipient(KnownContact, RawPhoneNumber))
import Html exposing (Html, a, button, div, form, h1, h2, h3, header, i, input, label, span, text)
import Html.Attributes exposing (class, href, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Messages exposing (Msg(..))
import Models exposing (Model, ThreadState)
import TextMessages.Helpers exposing (latestThreads, messagesForContactId)
import TextMessages.Models exposing (TextMessage, threadContactId)


view : Model -> Html Msg
view model =
    div []
        [ header []
            [ h1 [ class "app-title" ] [ text "TextChat" ]
            ]
        , div [ class "dashboard" ]
            [ div [ class "latest-messages-container" ]
                [ form [ class "new-message-form" ]
                    [ label [ class "compose-field" ]
                        [ input [ onInput InputPhoneNumber, value model.toPhoneNumber, placeholder "Enter name or number" ] []
                        ]
                    , div [] [ recipientSuggestions model ]
                    ]
                , h2 [] [ text "Recent" ]
                , div [] (List.map (threadSummary model) (latestThreads model.messages))
                ]
            , div [ class "all-threads-container" ] <|
                (model.openThreads |> List.map (threadView model))
            ]
        ]


recipientSuggestions : Model -> Html Msg
recipientSuggestions model =
    div []
        [ div [] ((List.map (knownContactSuggestion model)) model.contactSuggestions)
        , div [] [ rawPhoneNumberSuggestion model ]
        ]


knownContactSuggestion : Model -> ContactId -> Html Msg
knownContactSuggestion model contactId =
    let
        contact =
            getContact model.contacts contactId
    in
        div []
            [ text "To: "
            , a
                [ onClick (OpenThread (KnownContact contactId))
                ]
                [ text <| contactName contact ]
            ]


rawPhoneNumberSuggestion : Model -> Html Msg
rawPhoneNumberSuggestion model =
    case model.toPhoneNumber of
        "" ->
            span [] []

        _ ->
            case model.contactSuggestions of
                [] ->
                    div []
                        [ text "New message to: "
                        , a
                            [ onClick (OpenThread (RawPhoneNumber model.toPhoneNumber))
                            ]
                            [ text model.toPhoneNumber ]
                        ]

                _ ->
                    span [] []


recipientSuggestion : Model -> Recipient -> Html Msg
recipientSuggestion model recipient =
    case recipient of
        KnownContact contactId ->
            let
                contact =
                    getContact model.contacts contactId
            in
                a [ onClick (OpenThread recipient) ] [ text <| contactName contact ]

        RawPhoneNumber phoneNumber ->
            text phoneNumber


threadSummary : Model -> TextMessage -> Html Msg
threadSummary model textMessage =
    let
        contact =
            Contacts.Helpers.getContact model.contacts (threadContactId textMessage)
    in
        div
            [ class "thread-summary"
            , onClick (OpenThread (KnownContact (threadContactId textMessage)))
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
    div [ class "message-bubble" ] [ text textMessage.body ]


threadView : Model -> ThreadState -> Html Msg
threadView model threadState =
    case threadState.to of
        KnownContact contact ->
            knownContactThreadView model threadState contact

        RawPhoneNumber phoneNumber ->
            rawPhoneNumberThreadView model threadState phoneNumber


knownContactThreadView : Model -> ThreadState -> ContactId -> Html Msg
knownContactThreadView model threadState contactId =
    let
        contact =
            Contacts.Helpers.getContact model.contacts contactId
    in
        div [ class "thread" ]
            [ h2 [] [ text <| contactName contact, span [] [ text " " ], a [ onClick (CloseThread threadState.uid) ] [ text " [X]" ] ]
            , div [ class "thread-messages" ]
                [ div [] (List.map messageView (messagesForContactId contact.id model.messages))
                ]
            , form [ onSubmit (SendThreadMessage (KnownContact contactId) threadState) ]
                [ input
                    [ type_ "text"
                    , placeholder "Type your message here"
                    , onInput (InputThreadMessage threadState)
                    , value threadState.draftMessage
                    ]
                    []
                ]
            ]


rawPhoneNumberThreadView : Model -> ThreadState -> String -> Html Msg
rawPhoneNumberThreadView model threadState phoneNumber =
    div [ class "thread" ]
        [ h2 []
            [ text phoneNumber
            , span [] [ text " " ]
            , a [ onClick (CloseThread threadState.uid) ] [ text " [X]" ]
            ]
        , div [] []
        , form [ onSubmit (SendThreadMessage (RawPhoneNumber phoneNumber) threadState) ]
            [ input
                [ type_ "text"
                , placeholder "Type your message here"
                , onInput (InputThreadMessage threadState)
                , value threadState.draftMessage
                ]
                []
            ]
        ]
