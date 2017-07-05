module Update exposing (..)

import Authentication.Api exposing (authenticate)
import Contacts.Api exposing (editContact)
import Contacts.Helpers exposing (getContact)
import Contacts.Models exposing (Contact, ContactId)
import DomUtils exposing (focus)
import Groups.Api exposing (addToGroup)
import Http exposing (Error(BadPayload, BadStatus, BadUrl, NetworkError, Timeout))
import Json.Decode exposing (decodeString)
import Messages exposing (Msg(..))
import Models exposing (Model, UserMessage(ErrorMessage), Workflow(NewContact, Thread), newThreadState)
import Ports exposing (subscribeToTextMessages)
import Routing exposing (Route(ContactThreadRoute, DashboardRoute, LoginRoute), newUrl, parseLocation, toUrl)
import String exposing (isEmpty)
import TaskUtils exposing (delay)
import TextMessages.Api exposing (fetchLatestThreads, fetchListForContact, sendContactMessage)
import TextMessages.Decoders exposing (decodeTextMessage)
import TextMessages.Helpers
import TextMessages.Models exposing (TextMessage)
import Time exposing (millisecond)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputContactSearch q ->
            if isEmpty q then
                { model | contactSearch = q, contactSuggestions = [], loadingContactSuggestions = False } ! []
            else
                { model | contactSearch = q, loadingContactSuggestions = True }
                    ! [ delay (Time.millisecond * 200) <| SearchContacts q ]

        SearchContacts q ->
            let
                cmd =
                    if model.contactSearch == q && (q |> not << isEmpty) then
                        Contacts.Api.search model.contactSearch
                    else
                        Cmd.none
            in
                model ! [ cmd ]

        SearchedContacts q (Ok contacts) ->
            if model.contactSearch == q then
                from
                    { model
                        | contactSuggestions = List.map .id contacts
                        , loadingContactSuggestions = False
                    }
                    |> updateContacts contacts
            else
                from model

        SearchedContacts q (Err e) ->
            if model.contactSearch == q then
                { model | loadingContactSuggestions = False } ! [] |> addHttpError e
            else
                from model

        FetchedLatestThreads (Ok messages) ->
            let
                allContacts =
                    List.concat [ List.map .toContact messages, List.map .fromContact messages ]
            in
                from model |> updateContacts allContacts |> addMessages messages

        FetchedLatestThreads (Err e) ->
            from model |> addHttpError e

        ReceiveMessages textMessageResponse ->
            case decodeString decodeTextMessage textMessageResponse of
                Ok textMessage ->
                    from model
                        |> addMessage textMessage
                        |> updateContacts [ textMessage.toContact, textMessage.fromContact ]
                        |> scrollToBottom "thread-body"

                Err e ->
                    Debug.log e <| (from model |> addStringError "An error occurred while receiving text messages.")

        OpenThread contactId ->
            model ! [ newUrl <| ContactThreadRoute contactId ]

        StartComposing ->
            model ! [ newUrl <| DashboardRoute ]

        CreateContact phoneNumber ->
            from model |> createContact ContactCreated "" phoneNumber

        ContactCreated (Ok contact) ->
            from model |> updateContact contact |> openThread contact.id

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
            from
                { model
                    | createContactModalOpen = True
                    , createContactName = name
                    , createContactPhoneNumber = ""
                }
                |> focus "create-contact-phone-number"

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
            from
                { model | creatingFullContact = False }
                |> updateContact contact
                |> closeCreateContactModal
                |> openThread contact.id

        FullContactCreated (Err e) ->
            from { model | creatingFullContact = False } |> addHttpError e

        FetchedTextMessagesForContact (Ok fetchedMessages) ->
            from { model | loadingContactMessages = False }
                |> addMessages fetchedMessages
                |> scrollToBottom "thread-body"

        FetchedTextMessagesForContact (Err e) ->
            { model | loadingContactMessages = False } ! [] |> addHttpError e

        InputThreadMessage threadState messageBody ->
            { model | workflow = Thread { threadState | draftMessage = messageBody } }
                ! []

        SendMessage threadState ->
            { model | workflow = Thread { threadState | sendingMessage = True } }
                ! [ sendContactMessage
                        threadState.to
                        threadState.draftMessage
                        (SentMessage threadState)
                  ]
                |> scrollToBottom "thread-body"

        SentMessage threadState (Ok textMessage) ->
            from
                { model
                    | workflow =
                        Thread
                            { threadState
                                | draftMessage = ""
                                , sendingMessage = False
                            }
                }
                |> scrollToBottom "thread-body"
                |> addMessage textMessage

        SentMessage threadState (Err e) ->
            from { model | workflow = Thread { threadState | sendingMessage = False } }
                |> addHttpError e

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
                { model | groupAddSuggestions = groups, loadingGroupSuggestions = False } ! []
            else
                model ! []

        SearchedGroups q (Err e) ->
            from { model | loadingGroupSuggestions = False } |> addHttpError e

        AddToGroup contact group ->
            model ! [ addToGroup (AddedToGroup contact.id) contact.id group.id ]

        AddedToGroup contactId (Ok group) ->
            let
                contact =
                    getContact model.contacts contactId
            in
                from model |> updateContact { contact | groups = group :: contact.groups }

        AddedToGroup contactId (Err e) ->
            from model |> addHttpError e

        InputUsername newUsername ->
            { model | username = newUsername } ! []

        InputPassword newPassword ->
            { model | password = newPassword } ! []

        SubmitLogin ->
            { model | sendingAuth = True } ! [ authenticate model ]

        SubmittedLogin (Ok authenticationResponse) ->
            -- TODO: remove this
            model ! []

        SubmittedLogin (Err _) ->
            from { model | authError = True, sendingAuth = False }

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
                    DashboardRoute ->
                        from model |> updateRoute route |> openDashboard

                    ContactThreadRoute contactId ->
                        from model |> updateRoute route |> openThread contactId

                    r ->
                        from model |> updateRoute route


from : Model -> ( Model, Cmd Msg )
from model =
    model ! []


openDashboard : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
openDashboard ( model, cmd ) =
    { model | workflow = NewContact }
        ! [ cmd
          , subscribeToTextMessages ()
          , fetchLatestThreads
          ]
        |> focus "contact-search"


openThread : ContactId -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
openThread contactId ( model, cmd ) =
    { model
        | workflow = Thread (newThreadState contactId)
        , editingContact = False
        , loadingContactMessages = True
        , threadSearch = ""
    }
        ! [ cmd
          , subscribeToTextMessages ()
          , fetchListForContact contactId
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
    { model | contacts = Contacts.Helpers.updateContact contact model.contacts } ! [ cmd ]


updateContacts : List Contact -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateContacts contacts ( model, cmd ) =
    { model | contacts = Contacts.Helpers.updateContacts model.contacts contacts } ! [ cmd ]


removeUserMessageCmd : Cmd Msg
removeUserMessageCmd =
    delay (Time.millisecond * 5000) <| UserMessageExpired


addHttpError : Http.Error -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addHttpError e ( model, cmd ) =
    case e of
        BadUrl errorMessage ->
            Debug.log errorMessage
                ({ model
                    | userMessages =
                        (ErrorMessage "An error occurred. Please try again.") :: model.userMessages
                 }
                    ! [ cmd, removeUserMessageCmd ]
                )

        Timeout ->
            { model
                | userMessages =
                    (ErrorMessage "An network timeout occurred. Please try again.") :: model.userMessages
            }
                ! [ cmd, removeUserMessageCmd ]

        NetworkError ->
            { model
                | userMessages =
                    (ErrorMessage "An network error occurred. Please check your connection and try again.")
                        :: model.userMessages
            }
                ! [ cmd, removeUserMessageCmd ]

        BadStatus response ->
            { model
                | userMessages =
                    (ErrorMessage "The action failed. Please try again.") :: model.userMessages
            }
                ! [ cmd, removeUserMessageCmd ]

        BadPayload errorMessage response ->
            Debug.log errorMessage
                ({ model
                    | userMessages =
                        (ErrorMessage "An error occurred. Please try again.") :: model.userMessages
                 }
                    ! [ cmd, removeUserMessageCmd ]
                )


addStringError : String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addStringError e ( model, cmd ) =
    { model | userMessages = ErrorMessage e :: model.userMessages }
        ! [ cmd, removeUserMessageCmd ]


addMessages : List TextMessage -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addMessages messages ( model, cmd ) =
    { model | messages = TextMessages.Helpers.addMessages model.messages messages } ! [ cmd ]


addMessage : TextMessage -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addMessage message ( model, cmd ) =
    { model | messages = TextMessages.Helpers.addMessage message model.messages } ! [ cmd ]


scrollToBottom : String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
scrollToBottom id ( model, cmd ) =
    model ! [ cmd, DomUtils.scrollToBottom id ]


focus : String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
focus id ( model, cmd ) =
    model ! [ cmd, DomUtils.focus id ]


updateRoute : Route -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateRoute route ( model, cmd ) =
    { model | route = route } ! [ cmd ]
