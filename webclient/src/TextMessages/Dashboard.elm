module TextMessages.Dashboard exposing (view)

import Contacts.Helpers exposing (getContact)
import Dict
import Html exposing (Html, a, button, div, form, h1, h2, input, label, span, text)
import Html.Attributes exposing (class, href, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Messages exposing (Msg(..))
import Models exposing (Contact, ContactId, Model, TextMessage, ThreadState)
import Set
import TextMessages.Helpers exposing (latestThreads, messagesForContactId)
import Tuple exposing (first)


view : Model -> Html Msg
view model =
    div [ class "dashboard" ]
        [ div [ class "latest-messages-container" ]
            [ h2 [] [ text "New message" ]
            , div [ class "new-message-form" ]
                [ label []
                    [ input [ onInput InputPhoneNumber, value model.toPhoneNumber, placeholder "Phone number" ] []
                    ]
                , label []
                    [ input [ onInput InputBody, value model.body, placeholder "Message" ] []
                    ]
                , button [ onClick Send ] [ text "Send" ]
                ]
            , h2 [] [ text "Recent" ]
            , div [] (List.map (threadSummary model) (latestThreads model.messages))
            ]
        , div [ class "all-threads-container" ] <|
            (model.openThreads |> List.map (threadView model))
        ]


threadSummary : Model -> TextMessage -> Html Msg
threadSummary model textMessage =
    let
        contact =
            Contacts.Helpers.getContact model.contacts textMessage.toContact.id
    in
        div []
            [ div []
                [ a [ onClick (OpenThread textMessage.toContact) ] [ text <| contactName contact ] ]
            , div [] [ text textMessage.body ]
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
    let
        contact =
            Contacts.Helpers.getContact model.contacts threadState.contactId
    in
        div [ class "thread" ]
            [ h2 [] [ text <| contactName contact ]
            , div [ onClick (CloseThread threadState.uid) ] [ text "(X) Close" ]
            , div [] (List.map messageView (messagesForContactId contact.id model.messages))
            , form [ onSubmit (SendThreadMessage contact threadState) ]
                [ input
                    [ type_ "text"
                    , placeholder "Type your message here"
                    , onInput (InputThreadMessage threadState)
                    , value threadState.draftMessage
                    ]
                    []
                ]
            ]
