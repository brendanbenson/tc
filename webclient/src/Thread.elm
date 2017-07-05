module Thread exposing (view)

import Contacts.Helpers
import Contacts.Models exposing (Contact)
import Contacts.ViewHelpers exposing (contactName)
import Groups.Models exposing (Group)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import HtmlUtils exposing (spin)
import Messages exposing (Msg(..))
import Models exposing (Model, ThreadState)
import TextMessages.Helpers exposing (messagesForContactId)
import TextMessages.Models exposing (TextMessage, bodyMatchesString)


view : Model -> Html Msg
view model =
    let
        threadState =
            model.threadState

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
                        [ threadMessages model threadState contact
                        ]
                    , div [ class "thread-footer" ]
                        [ Html.form [ onSubmit (SendMessage threadState) ]
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
                    , h2 [ class "section-break" ]
                        [ text "Options" ]
                    , div [ class "content-block" ]
                        [ input
                            [ type_ "text"
                            , placeholder "Search in thread"
                            , onInput InputThreadSearch
                            , value model.threadSearch
                            , class "thread-search"
                            ]
                            []
                        ]
                    , h2 [ class "section-break" ] [ text "Groups" ]
                    , groups contact
                    , div [ class "content-block" ] [ addToGroupSearch contact model ]
                    , div [] [ loadingAddToGroupSuggestions model, addToGroupSuggestions contact model.groupAddSuggestions ]
                    ]
                ]
            ]


threadMessages : Model -> ThreadState -> Contact -> Html Msg
threadMessages model threadState contact =
    div [ class "thread-messages" ]
        [ loadingMessages model
        , div []
            (messagesForContactId contact.id model.messages
                |> List.map messageView
                << List.filter (bodyMatchesString model.threadSearch)
            )
        , messageLoadingView threadState
        ]


loadingMessages : Model -> Html Msg
loadingMessages model =
    if model.loadingContactMessages == True then
        div [ class "info-message" ]
            [ i [ class "fa fa-spin fa-circle-o-notch" ] []
            , text " Loading more..."
            ]
    else
        span [] []


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
                div [ class "contact-details content-block" ]
                    [ Html.form [ onSubmit <| EditContact model.contactEdits ]
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
                div [ class "contact-details content-block" ]
                    [ contactLabel
                    , h3
                        [ onClick <| StartEditingContact "edit-contact-phone-number" contact
                        , class "hover-edit"
                        ]
                        [ text contact.phoneNumber ]
                    ]


loadingAddToGroupSuggestions : Model -> Html Msg
loadingAddToGroupSuggestions model =
    if model.loadingGroupSuggestions == True then
        div [ class "suggestion" ]
            [ span [ class "loading" ]
                [ i [ class "fa fa-spin fa-circle-o-notch" ] []
                , text " Loading groups..."
                ]
            ]
    else
        span [] []


groups : Contact -> Html Msg
groups contact =
    div [] (List.map group contact.groups)


group : Group -> Html Msg
group group_ =
    div [ class "suggestion" ] [ div [ class "body" ] [ text group_.label ] ]


addToGroupSearch : Contact -> Model -> Html Msg
addToGroupSearch contact model =
    input
        [ type_ "text"
        , placeholder "Add to group"
        , value model.addToGroupSearch
        , onInput (InputAddToGroupSearch contact)
        ]
        []


addToGroupSuggestions : Contact -> List Group -> Html Msg
addToGroupSuggestions contact groups =
    div [] (List.map (addToGroupSuggestion contact) groups)


addToGroupSuggestion : Contact -> Group -> Html Msg
addToGroupSuggestion contact group_ =
    div [ class "suggestion", onClick (AddToGroup contact group_) ]
        [ span [ class "label" ] [ text "Add to: " ]
        , span [ class "body" ] [ text group_.label ]
        ]
