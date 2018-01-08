module ContactThread exposing (view)

import Contacts.Helpers
import Contacts.Models exposing (Contact)
import Contacts.ViewHelpers exposing (contactName)
import Groups.Helpers
import Groups.Models exposing (Group, GroupId)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import HtmlUtils exposing (spin)
import ListUtils exposing (lastElem)
import Messages exposing (Msg(..))
import Models exposing (Model, ContactThreadState)
import StringUtils exposing (formatPhoneNumber)
import TextMessages.Helpers exposing (messagesForContactId)
import TextMessages.Models exposing (TextMessage, bodyMatchesString)
import Users.Helpers exposing (getUser)


view : Model -> Html Msg
view model =
    let
        contact =
            Contacts.Helpers.getContact model.contacts model.contactThreadState.to

        textMessages =
            messagesForContactId contact.id model.messages
    in
        div [ class "thread-container" ]
            [ div [ class "thread-title" ]
                [ h2 [] [ text <| contactName contact ]
                , threadStatus model textMessages
                ]
            , div [ class "thread-content" ]
                [ div [ class "thread-messages-pane" ]
                    [ div [ class "thread-body", id "thread-body" ]
                        [ threadMessages model contact
                        ]
                    , div [ class "thread-footer" ]
                        [ Html.form [ onSubmit (SendMessage model.contactThreadState) ]
                            [ div [ class "input-container" ]
                                [ input
                                    [ type_ "text"
                                    , class "message-input"
                                    , id "message-input"
                                    , placeholder "Type your message here"
                                    , onInput (InputThreadMessage model.contactThreadState)
                                    , value model.contactThreadState.draftMessage
                                    , disabled model.contactThreadState.sendingMessage
                                    , autocomplete False
                                    ]
                                    []
                                ]
                            ]
                        ]
                    ]
                , div [ class "thread-contact-pane" ]
                    [ contactDetails model contact
                    , h2 [ class "section-break" ]
                        [ text "Search Messages" ]
                    , div [ class "content-block" ]
                        [ input
                            [ type_ "text"
                            , placeholder "Type a search term"
                            , onInput InputThreadSearch
                            , value model.threadSearch
                            , class "thread-search"
                            ]
                            []
                        ]
                    , h2 [ class "section-break" ] [ text "Group Membership" ]
                    , groups contact
                    , h2 [ class "section-break spaced" ] [ text "Add to Group" ]
                    , div [ class "content-block" ] [ addToGroupSearch contact model ]
                    , div []
                        [ loadingAddToGroupSuggestions model
                        , addToGroupSuggestions model contact model.groupAddSuggestions
                        ]
                    ]
                ]
            ]


threadMessages : Model -> Contact -> Html Msg
threadMessages model contact =
    div [ class "thread-messages" ]
        [ loadingMessages model
        , div []
            (messagesForContactId contact.id model.messages
                |> List.map messageView
                << List.filter (bodyMatchesString model.threadSearch)
            )
        , messageLoadingView model.contactThreadState
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


messageLoadingView : ContactThreadState -> Html Msg
messageLoadingView contactThreadState =
    if contactThreadState.sendingMessage == True then
        div [ class "message-bubble outgoing loading" ]
            [ i [ class "fa fa-spin fa-circle-o-notch" ] []
            , text " "
            , text contactThreadState.draftMessage
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
                        [ text <| formatPhoneNumber contact.phoneNumber ]
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
    case List.length contact.groups of
        0 ->
            div [ class "content-block" ] [ text "No groups assigned" ]

        _ ->
            div [ class "suggestions" ] (List.map (group contact) (List.sortBy (String.toLower << .label) contact.groups))


group : Contact -> Group -> Html Msg
group contact group_ =
    div [ class "suggestion" ]
        [ div [ class "body", onClick (OpenGroupThread group_.id) ] [ text group_.label ]
        , div [ class "actions" ] [ a [ onClick (DeleteGroupMembership contact.id group_.id) ] [ i [ class "fa fa-close" ] [] ] ]
        ]


addToGroupSearch : Contact -> Model -> Html Msg
addToGroupSearch contact model =
    input
        [ type_ "text"
        , placeholder "Type a group name"
        , value model.addToGroupSearch
        , onInput (InputAddToGroupSearch contact)
        ]
        []


addToGroupSuggestions : Model -> Contact -> List GroupId -> Html Msg
addToGroupSuggestions model contact groupIds =
    div [ class "suggestions" ] (List.map (addToGroupSuggestion model contact) groupIds)


addToGroupSuggestion : Model -> Contact -> GroupId -> Html Msg
addToGroupSuggestion model contact groupId =
    let
        group =
            Groups.Helpers.getGroup model.groups groupId
    in
        div [ class "suggestion", onClick (AddToGroup model.contactThreadState.to group) ]
            [ span [ class "label" ] [ text "Add to: " ]
            , span [ class "body" ] [ text group.label ]
            ]


threadStatus : Model -> List TextMessage -> Html Msg
threadStatus model textMessages =
    let
        lastMessage =
            lastElem textMessages
    in
        case lastMessage of
            Just textMessage ->
                case textMessage.userId of
                    Just userId ->
                        agentHasResponded model userId

                    Nothing ->
                        waitingForResponse

            Nothing ->
                span [] []


agentHasResponded : Model -> Int -> Html Msg
agentHasResponded model userId =
    case getUser model userId of
        Just user ->
            span [ class "success-message" ]
                [ span [ class "fa fa-check" ] []
                , span [] [ text <| " " ++ user.name ++ " has responded" ]
                ]

        Nothing ->
            span [ class "success-message" ]
                [ span [ class "fa fa-check" ] []
                , span [] [ text "An agent has responded" ]
                ]


waitingForResponse : Html Msg
waitingForResponse =
    span [ class "pending-message" ]
        [ span [ class "fa fa-warning" ] []
        , span [] [ text " Waiting for a response" ]
        ]
