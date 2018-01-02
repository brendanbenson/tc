module GroupThread exposing (..)

import Contacts.Helpers
import Contacts.Models exposing (Contact, ContactId)
import Contacts.ViewHelpers exposing (contactName)
import Groups.Helpers
import Groups.Models exposing (Group)
import Html exposing (..)
import Html.Attributes exposing (class, disabled, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Messages exposing (Msg(AddToGroup, DeleteGroupMembership, InputAddToGroupContactSearch, InputGroupThreadMessage, OpenContactThread, SendGroupMessage))
import Models exposing (GroupThreadState, Model)
import TextMessages.Helpers exposing (messagesForGroupId)
import TextMessages.Models exposing (GroupTextMessage)


view : Model -> Html Msg
view model =
    let
        group =
            Groups.Helpers.getGroup model.groups model.groupThreadState.to
    in
        div [ class "thread-container" ]
            [ div [ class "thread-title" ]
                [ h2 [] [ text <| "Group message: " ++ group.label ]
                ]
            , div [ class "thread-content" ]
                [ div [ class "thread-messages-pane" ]
                    [ div [ class "thread-body", id "thread-body" ]
                        [ threadMessages model group
                        ]
                    , div [ class "thread-footer" ]
                        [ Html.form [ onSubmit (SendGroupMessage model.groupThreadState) ]
                            [ div [ class "input-container" ]
                                [ input
                                    [ type_ "text"
                                    , class "message-input"
                                    , id "message-input"
                                    , placeholder "Type your message here"
                                    , onInput (InputGroupThreadMessage model.groupThreadState)
                                    , value model.groupThreadState.draftMessage
                                    , disabled model.groupThreadState.sendingMessage
                                    ]
                                    []
                                ]
                            ]
                        ]
                    ]
                , div [ class "thread-contact-pane" ]
                    [ div [ class "content-block" ] [ h2 [] [ text group.label ] ]
                    , h2 [ class "section-break" ] [ text "Members" ]
                    , groupContacts model group
                    , h2 [ class "section-break spaced" ] [ text "Add Members" ]
                    , div [ class "content-block" ] [ addMemberSearch group model ]
                    , loadingAddToGroupSuggestions model
                    , contactSuggestionsView model
                    ]
                ]
            ]


loadingAddToGroupSuggestions : Model -> Html Msg
loadingAddToGroupSuggestions model =
    if model.loadingGroupContactSuggestions == True then
        div [ class "suggestion" ]
            [ span [ class "loading" ]
                [ i [ class "fa fa-spin fa-circle-o-notch" ] []
                , text " Loading contacts..."
                ]
            ]
    else
        span [] []


addMemberSearch : Group -> Model -> Html Msg
addMemberSearch group model =
    input
        [ type_ "text"
        , placeholder "Type a contact name"
        , value model.addToGroupContactSearch
        , onInput (InputAddToGroupContactSearch group)
        ]
        []


contactSuggestionsView : Model -> Html Msg
contactSuggestionsView model =
    div [] (List.map (contactSuggestionView model) model.groupAddContactSuggestions)


contactSuggestionView : Model -> ContactId -> Html Msg
contactSuggestionView model contactId =
    let
        contact =
            Contacts.Helpers.getContact model.contacts contactId

        group =
            Groups.Helpers.getGroup model.groups model.groupThreadState.to
    in
        div [ class "suggestion", onClick (AddToGroup contactId group) ]
            [ div [ class "body" ] [ text <| contactName contact ] ]


threadMessages : Model -> Group -> Html Msg
threadMessages model group =
    div [ class "thread-messages" ]
        [ loadingMessages model
        , div []
            (messagesForGroupId group.id model.groupMessages
                |> List.map messageView
            )
        , messageLoadingView model.groupThreadState
        ]


messageView : GroupTextMessage -> Html Msg
messageView groupTextMessage =
    div [ class "message-bubble outgoing" ] [ text groupTextMessage.body ]


loadingMessages : Model -> Html Msg
loadingMessages model =
    if model.loadingGroupMessages == True then
        div [ class "info-message" ]
            [ i [ class "fa fa-spin fa-circle-o-notch" ] []
            , text " Loading more..."
            ]
    else
        span [] []


messageLoadingView : GroupThreadState -> Html Msg
messageLoadingView contactThreadState =
    if contactThreadState.sendingMessage == True then
        div [ class "message-bubble outgoing loading" ]
            [ i [ class "fa fa-spin fa-circle-o-notch" ] []
            , text " "
            , text contactThreadState.draftMessage
            ]
    else
        span [] []


groupContacts : Model -> Group -> Html Msg
groupContacts model group =
    case List.length model.groupContacts of
        0 ->
            div [ class "content-block" ] [ text "No contacts in this group" ]

        _ ->
            let
                contacts =
                    List.map (Contacts.Helpers.getContact model.contacts) model.groupContacts
                        |> List.sortBy (String.toLower << contactName)
            in
                div [] (List.map (groupContact group) contacts)


groupContact : Group -> Contact -> Html Msg
groupContact group contact =
    div [ class "suggestion" ]
        [ div [ class "body", onClick (OpenContactThread contact.id) ] [ text <| contactName contact ]
        , div [ class "actions" ]
            [ a [ onClick (DeleteGroupMembership contact.id group.id) ]
                [ i [ class "fa fa-close" ] []
                ]
            ]
        ]
