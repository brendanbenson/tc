module Update exposing (..)

import Contacts.Api exposing (editContact)
import Contacts.Helpers exposing (getContact)
import Contacts.Models exposing (Contact, ContactId)
import Contacts.ViewHelpers exposing (contactName)
import DomUtils exposing (focus)
import Groups.Api exposing (addToGroup, fetchGroup)
import Groups.Helpers
import Groups.Models exposing (Group, GroupId)
import Http exposing (Error(BadPayload, BadStatus, BadUrl, NetworkError, Timeout))
import Json.Decode exposing (decodeString)
import Messages exposing (Msg(..))
import Models exposing (Model, UserMessage(ErrorMessage, SuccessMessage), newContactThreadState, newGroupThreadState)
import Ports exposing (subscribeToTextMessages)
import Routing exposing (Route(ComposeRoute, ContactListRoute, ContactThreadRoute, GroupThreadRoute, NotFoundRoute), newUrl, parseLocation, toUrl)
import String exposing (isEmpty)
import TaskUtils exposing (delay)
import TextMessages.Api exposing (fetchContacts, fetchLatestThreads, fetchListForContact, fetchListForGroup, sendContactMessage, sendGroupMessage)
import TextMessages.Decoders exposing (decodeAugmentedTextMessageResponse, decodeTextMessage)
import TextMessages.Helpers
import TextMessages.Models exposing (GroupTextMessage, TextMessage)
import Time exposing (millisecond)
import Validation.Decoders
import Validation.Helpers


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputOmniSearch q ->
            if isEmpty q then
                { model | omniSearch = q, contactSuggestions = [], loadingContactSuggestions = False } ! []
            else
                { model | omniSearch = q, loadingContactSuggestions = True }
                    ! [ delay (Time.millisecond * 200) <| SearchContacts q ]

        SearchContacts q ->
            let
                cmd =
                    if model.omniSearch == q && (q |> not << isEmpty) then
                        Contacts.Api.search model.omniSearch
                    else
                        Cmd.none
            in
                model ! [ cmd ]

        SearchedContacts q (Ok contacts) ->
            if model.omniSearch == q then
                from
                    { model
                        | contactSuggestions = List.map .id contacts
                        , loadingContactSuggestions = False
                    }
                    |> updateContacts contacts
            else
                from model

        SearchedContacts q (Err e) ->
            if model.omniSearch == q then
                { model | loadingContactSuggestions = False } ! [] |> addHttpError e
            else
                from model

        FetchedLatestThreads (Ok response) ->
            from model |> updateContacts response.contacts |> addMessages response.textMessages

        FetchedLatestThreads (Err e) ->
            from model |> addHttpError e

        ReceiveMessages textMessageResponse ->
            case decodeString decodeAugmentedTextMessageResponse textMessageResponse of
                Ok response ->
                    from model
                        |> addMessages response.textMessages
                        |> updateContacts response.contacts
                        |> scrollToBottom "thread-body"
                        |> dingIf (List.any .incoming response.textMessages)

                Err e ->
                    Debug.log e <| (from model |> addStringError "An error occurred while receiving text messages.")

        Connected isConnected ->
            if model.connectedToServer == True && isConnected == False then
                { model | connectedToServer = isConnected } ! [] |> addStringError "Disconnected from server."
            else if model.connectedToServer == False && isConnected == True then
                { model | connectedToServer = isConnected }
                    ! [ fetchLatestThreads ]
                    |> addSuccessMessage "Connected to server."
            else
                model ! []

        OpenContactThread contactId ->
            model ! [ newUrl <| ContactThreadRoute contactId ]

        OpenGroupThread groupId ->
            model ! [ newUrl <| GroupThreadRoute groupId ]

        StartComposing ->
            model ! [ newUrl <| ComposeRoute ]

        ListContacts ->
            model ! [ newUrl <| ContactListRoute ]

        FetchedContacts (Ok contacts) ->
            from model |> updateContacts contacts

        FetchedContacts (Err e) ->
            from model |> addHttpError e

        CreateContact phoneNumber ->
            from model |> createContact ContactCreated "" phoneNumber

        ContactCreated (Ok contact) ->
            model
                ! [ newUrl <| ContactThreadRoute contact.id ]
                |> updateContact contact
                |> addSuccessMessage ("New contact created: " ++ (contactName contact))

        ContactCreated (Err e) ->
            from model |> addHttpError e

        StartEditingContact id contact ->
            from { model | editingContact = True, contactEdits = contact } |> focus id

        InputContactLabel label ->
            let
                originalContactEdits =
                    model.contactEdits
            in
                { model | contactEdits = { originalContactEdits | label = label } } ! []

        InputContactPhoneNumber phoneNumber ->
            let
                originalContactEdits =
                    model.contactEdits
            in
                { model | contactEdits = { originalContactEdits | phoneNumber = phoneNumber } } ! []

        EditContact contact ->
            { model | savingContactEdits = True } ! [ editContact contact ]

        EditedContact (Ok contact) ->
            from { model | savingContactEdits = False, editingContact = False } |> updateContact contact

        EditedContact (Err e) ->
            from { model | savingContactEdits = False } |> addHttpError e

        OpenCreateContactModal name ->
            let
                focusField =
                    case name of
                        "" ->
                            "create-contact-name"

                        _ ->
                            "create-contact-phone-number"
            in
                from
                    { model
                        | createContactModalOpen = True
                        , createContactName = name
                        , createContactPhoneNumber = ""
                    }
                    |> focus focusField

        CloseCreateContactModal ->
            { model | createContactModalOpen = False } ! []

        InputCreateContactName name ->
            { model | createContactName = name } ! []

        InputCreateContactPhoneNumber phoneNumber ->
            { model | createContactPhoneNumber = phoneNumber } ! []

        CreateFullContact label phoneNumber ->
            from { model | creatingFullContact = True }
                |> createContact FullContactCreated label phoneNumber

        FullContactCreated (Ok contact) ->
            { model | creatingFullContact = False }
                ! [ newUrl <| ContactThreadRoute contact.id ]
                |> updateContact contact
                |> closeCreateContactModal
                |> addSuccessMessage ("New contact created: " ++ (contactName contact))

        FullContactCreated (Err e) ->
            from { model | creatingFullContact = False } |> addHttpError e

        FetchedTextMessagesForContact (Ok fetchedMessages) ->
            from { model | loadingContactMessages = False }
                |> addMessages fetchedMessages
                |> scrollToBottom "thread-body"

        FetchedTextMessagesForContact (Err e) ->
            { model | loadingContactMessages = False } ! [] |> addHttpError e

        FetchedTextMessagesForGroup (Ok fetchedMessages) ->
            from { model | loadingGroupMessages = False }
                |> addGroupMessages fetchedMessages
                |> scrollToBottom "thread-body"

        FetchedTextMessagesForGroup (Err e) ->
            { model | loadingGroupMessages = False } ! [] |> addHttpError e

        FetchedContactsForGroup (Ok contacts) ->
            from { model | groupContacts = List.map .id contacts }
                |> updateContacts contacts

        FetchedContactsForGroup (Err e) ->
            from model |> addHttpError e

        InputThreadMessage contactThreadState messageBody ->
            { model | contactThreadState = { contactThreadState | draftMessage = messageBody } }
                ! []

        InputGroupThreadMessage groupThreadState messageBody ->
            { model | groupThreadState = { groupThreadState | draftMessage = messageBody } }
                ! []

        DeleteGroupMembership contactId groupId ->
            model ! [ Groups.Api.deleteGroupMembership (GroupMembershipDeleted contactId) contactId groupId ]

        GroupMembershipDeleted contactId (Ok group) ->
            let
                contact =
                    Contacts.Helpers.getContact model.contacts contactId

                updatedGroups =
                    List.filter (not << ((==) group.id) << .id) contact.groups

                updatedContact =
                    { contact | groups = updatedGroups }

                updatedGroupContacts =
                    List.filter (not << ((==) contactId)) model.groupContacts
            in
                from { model | groupContacts = updatedGroupContacts }
                    |> updateContact updatedContact
                    |> addSuccessMessage ((contactName contact) ++ " removed from " ++ group.label)

        GroupMembershipDeleted contactId (Err e) ->
            from model |> addHttpError e

        SendMessage contactThreadState ->
            { model | contactThreadState = { contactThreadState | sendingMessage = True } }
                ! [ sendContactMessage
                        contactThreadState.to
                        contactThreadState.draftMessage
                        (SentMessage contactThreadState)
                  ]
                |> scrollToBottom "thread-body"

        SentMessage contactThreadState (Ok textMessage) ->
            from
                { model
                    | contactThreadState =
                        { contactThreadState
                            | draftMessage = ""
                            , sendingMessage = False
                        }
                }
                |> scrollToBottom "thread-body"
                |> focus "message-input"
                |> addMessage textMessage

        SentMessage contactThreadState (Err e) ->
            from { model | contactThreadState = { contactThreadState | sendingMessage = False } }
                |> focus "message-input"

        SendGroupMessage groupThreadState ->
            { model | groupThreadState = { groupThreadState | sendingMessage = True } }
                ! [ sendGroupMessage
                        groupThreadState.to
                        groupThreadState.draftMessage
                        (SentGroupMessage groupThreadState)
                  ]
                |> scrollToBottom "thread-body"

        SentGroupMessage groupThreadState (Ok groupTextMessage) ->
            from
                { model
                    | groupThreadState =
                        { groupThreadState
                            | draftMessage = ""
                            , sendingMessage = False
                        }
                }
                |> scrollToBottom "thread-body"
                |> focus "message-input"
                |> addGroupMessage groupTextMessage

        SentGroupMessage groupThreadState (Err e) ->
            from { model | groupThreadState = { groupThreadState | sendingMessage = False } }
                |> addHttpError e
                |> focus "message-input"

        InputThreadSearch q ->
            { model | threadSearch = q } ! []

        InputAddToGroupSearch contact q ->
            if isEmpty q then
                { model
                    | addToGroupSearch = q
                    , groupAddSuggestions = []
                    , loadingGroupSuggestions = False
                }
                    ! []
            else
                { model
                    | addToGroupSearch = q
                    , loadingGroupSuggestions = True
                }
                    ! [ delay (Time.millisecond * 200) <| SearchGroups contact q ]

        InputAddToGroupContactSearch group q ->
            if isEmpty q then
                { model
                    | addToGroupContactSearch = q
                    , groupAddContactSuggestions = []
                    , loadingGroupContactSuggestions = False
                }
                    ! []
            else
                { model
                    | addToGroupContactSearch = q
                    , loadingGroupContactSuggestions = True
                }
                    ! [ delay (Time.millisecond * 200) <| SuggestContactsForGroup group q ]

        SuggestContactsForGroup group q ->
            let
                cmd =
                    if model.addToGroupContactSearch == q && (q |> not << isEmpty) then
                        Groups.Api.suggestContactsForGroup group.id q
                    else
                        Cmd.none
            in
                model ! [ cmd ]

        SuggestedContactsForGroup q (Ok contacts) ->
            { model
                | groupAddContactSuggestions = List.map .id contacts
                , loadingGroupContactSuggestions = False
            }
                ! []
                |> updateContacts contacts

        SuggestedContactsForGroup q (Err e) ->
            from { model | loadingGroupContactSuggestions = False } |> addHttpError e

        SearchGroups contact q ->
            let
                cmd =
                    if model.addToGroupSearch == q && (q |> not << isEmpty) then
                        Groups.Api.search contact.id q
                    else
                        Cmd.none
            in
                model ! [ cmd ]

        SearchedGroups q (Ok groups) ->
            if model.addToGroupSearch == q then
                from
                    { model
                        | groupAddSuggestions = List.map .id groups
                        , loadingGroupSuggestions = False
                    }
                    |> updateGroups groups
            else
                model ! []

        SearchedGroups q (Err e) ->
            from { model | loadingGroupSuggestions = False } |> addHttpError e

        AddToGroup contactId group ->
            { model
                | addToGroupSearch = ""
                , groupAddSuggestions = []
                , addToGroupContactSearch = ""
                , groupAddContactSuggestions = []
            }
                ! [ addToGroup (AddedToGroup contactId) contactId group.id ]

        AddedToGroup contactId (Ok group) ->
            let
                contact =
                    getContact model.contacts contactId
            in
                from { model | groupContacts = contact.id :: model.groupContacts }
                    |> updateContact { contact | groups = group :: contact.groups }
                    |> addSuccessMessage (contact.label ++ " added to " ++ group.label)

        AddedToGroup contactId (Err e) ->
            from model |> addHttpError e

        GroupFetched (Ok group) ->
            from model |> updateGroup group

        GroupFetched (Err e) ->
            from model |> addHttpError e

        UserMessageExpired ->
            from
                { model
                    | userMessages =
                        List.take (List.length model.userMessages - 1) model.userMessages
                }

        NoOp ->
            from model

        OnLocationChange location ->
            let
                route =
                    parseLocation location
            in
                case route of
                    ComposeRoute ->
                        from model |> updateRoute route |> openDashboard

                    ContactListRoute ->
                        from model |> updateRoute route |> openContacts

                    ContactThreadRoute contactId ->
                        from model |> updateRoute route |> openThread contactId

                    GroupThreadRoute groupId ->
                        from model |> updateRoute route |> openGroupThread groupId

                    NotFoundRoute ->
                        from model |> updateRoute route


from : Model -> ( Model, Cmd Msg )
from model =
    model ! []


openDashboard : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
openDashboard ( model, cmd ) =
    model
        ! [ cmd
          , subscribeToTextMessages ()
          , fetchLatestThreads
          ]
        |> focus "omni-search"


openContacts : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
openContacts ( model, cmd ) =
    model ! [ cmd, fetchContacts ]


openThread : ContactId -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
openThread contactId ( model, cmd ) =
    { model
        | contactThreadState = newContactThreadState contactId
        , editingContact = False
        , loadingContactMessages = True
        , threadSearch = ""
        , addToGroupSearch = ""
        , groupAddSuggestions = []
    }
        ! [ cmd
          , subscribeToTextMessages ()
          , fetchListForContact contactId
          ]
        |> focus "message-input"
        |> scrollToBottom "thread-body"


openGroupThread : GroupId -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
openGroupThread groupId ( model, cmd ) =
    { model
        | groupThreadState = newGroupThreadState groupId
        , loadingGroupMessages = True
        , threadSearch = ""
    }
        ! [ cmd
          , subscribeToTextMessages ()
          , fetchGroup GroupFetched groupId
          , fetchListForGroup groupId
          , Contacts.Api.fetchForGroup groupId
          ]
        |> focus "message-input"
        |> scrollToBottom "thread-body"


closeCreateContactModal : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
closeCreateContactModal ( model, cmd ) =
    { model | createContactModalOpen = False } ! [ cmd ]


createContact : (Result Http.Error Contact -> Msg) -> String -> String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
createContact callback label phoneNumber ( model, cmd ) =
    model ! [ cmd, Contacts.Api.createContact callback label phoneNumber ]


updateContact : Contact -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateContact contact ( model, cmd ) =
    { model | contacts = Contacts.Helpers.updateContact contact model.contacts }
        ! [ cmd ]
        |> updateGroups contact.groups


updateContacts : List Contact -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateContacts contacts ( model, cmd ) =
    { model | contacts = Contacts.Helpers.updateContacts model.contacts contacts }
        ! [ cmd ]
        |> updateGroups (List.concatMap .groups contacts)


updateGroup : Group -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateGroup group ( model, cmd ) =
    { model | groups = Groups.Helpers.updateGroup group model.groups } ! [ cmd ]


updateGroups : List Group -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateGroups groups ( model, cmd ) =
    { model | groups = Groups.Helpers.updateGroups model.groups groups } ! [ cmd ]


removeUserMessageCmd : Cmd Msg
removeUserMessageCmd =
    delay (Time.millisecond * 5000) <| UserMessageExpired


addHttpError : Http.Error -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addHttpError e ( model, cmd ) =
    case e of
        BadUrl errorMessage ->
            Debug.log errorMessage (( model, cmd ) |> addStringError "An error occurred. Please try again.")

        Timeout ->
            ( model, cmd ) |> addStringError "An network timeout occurred. Please try again."

        NetworkError ->
            ( model, cmd ) |> addStringError "An network error occurred. Please check your connection and try again."

        BadStatus response ->
            case decodeString Validation.Decoders.decodeValidationErrors response.body of
                Ok validationErrors ->
                    List.foldr addStringError ( model, cmd ) (Validation.Helpers.allErrorDescriptions validationErrors)

                Err e ->
                    Debug.log "Could not parse errors" (( model, cmd ) |> addStringError "Action failed. Please try again.")

        BadPayload errorMessage response ->
            Debug.log errorMessage (( model, cmd ) |> addStringError "An error occurred. Please try again.")


addStringError : String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addStringError e ( model, cmd ) =
    { model | userMessages = ErrorMessage e :: model.userMessages }
        ! [ cmd, removeUserMessageCmd ]


addSuccessMessage : String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addSuccessMessage m ( model, cmd ) =
    { model | userMessages = SuccessMessage m :: model.userMessages } ! [ cmd, removeUserMessageCmd ]


addMessages : List TextMessage -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addMessages messages ( model, cmd ) =
    { model | messages = TextMessages.Helpers.addMessages model.messages messages } ! [ cmd ]


addMessage : TextMessage -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addMessage message ( model, cmd ) =
    { model | messages = TextMessages.Helpers.addMessage message model.messages } ! [ cmd ]


addGroupMessages : List GroupTextMessage -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addGroupMessages message ( model, cmd ) =
    { model | groupMessages = TextMessages.Helpers.addGroupMessages message model.groupMessages } ! [ cmd ]


addGroupMessage : GroupTextMessage -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addGroupMessage message ( model, cmd ) =
    { model | groupMessages = TextMessages.Helpers.addGroupMessage message model.groupMessages } ! [ cmd ]


scrollToBottom : String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
scrollToBottom id ( model, cmd ) =
    model ! [ cmd, DomUtils.scrollToBottom id ]


focus : String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
focus id ( model, cmd ) =
    model ! [ cmd, DomUtils.focus id ]


updateRoute : Route -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateRoute route ( model, cmd ) =
    { model | route = route } ! [ cmd ]


dingIf : Bool -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
dingIf shouldDing ( model, cmd ) =
    if shouldDing then
        model ! [ cmd, Ports.ding () ]
    else
        model ! [ cmd ]
