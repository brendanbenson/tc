module Update exposing (..)

import Authentication.Api exposing (authenticate)
import Contacts.Api exposing (editContact)
import Contacts.Helpers exposing (getContact)
import Contacts.Models exposing (Contact, ContactId)
import DomUtils exposing (focus)
import Http exposing (Error(BadPayload, BadStatus, BadUrl, NetworkError, Timeout))
import Json.Decode exposing (decodeString)
import Maybe exposing (withDefault)
import Messages exposing (Msg(..))
import Models exposing (Model, UserMessage(ErrorMessage), Workflow(NewContact, Thread), newThreadState)
import Ports exposing (saveAuthToken, subscribeToTextMessages, unsubscribeFromTextMessages)
import Routing exposing (Route(DashboardRoute, LoginRoute), newUrl, parseLocation)
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
        InputContactSearch newPhoneNumber ->
            if isEmpty newPhoneNumber then
                { model | contactSearch = newPhoneNumber, contactSuggestions = [] } ! []
            else
                { model | contactSearch = newPhoneNumber }
                    ! [ delay (Time.millisecond * 200) <| SearchContacts newPhoneNumber ]

        SearchContacts contactSearch ->
            let
                cmd =
                    if
                        model.contactSearch
                            == contactSearch
                            && (contactSearch |> not << isEmpty)
                    then
                        Contacts.Api.search model.connectionData model.contactSearch
                    else
                        Cmd.none
            in
                { model | loadingContactSuggestions = True } ! [ cmd ]

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
                    -- TODO: handle errors
                    Debug.log e <| model ! []

        OpenThread contactId ->
            from { model | contactSearch = "", contactSuggestions = [] }
                |> scrollToBottom "thread-body"
                |> openThread contactId

        StartComposing ->
            from { model | workflow = NewContact } |> focus "contact-search"

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
            { model | savingContactEdits = True } ! [ editContact model.connectionData contact ]

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
                        model.connectionData
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

        OnLocationChange location ->
            case parseLocation location of
                DashboardRoute ->
                    { model | route = DashboardRoute } ! [ subscribeToTextMessages () ]

                r ->
                    { model | route = r } ! []

        InputUsername newUsername ->
            { model | username = newUsername } ! []

        InputPassword newPassword ->
            { model | password = newPassword } ! []

        SubmitLogin ->
            { model | sendingAuth = True } ! [ authenticate model ]

        SubmittedLogin (Ok authenticationResponse) ->
            let
                authToken =
                    Just authenticationResponse.token

                currentConnectionData =
                    model.connectionData

                newConnectionData =
                    { currentConnectionData | authToken = authToken }
            in
                { model | connectionData = newConnectionData, sendingAuth = False }
                    ! [ newUrl DashboardRoute
                      , saveAuthToken authToken
                      , fetchLatestThreads newConnectionData
                      ]
                    |> focus "contact-search"

        SubmittedLogin (Err _) ->
            from { model | authError = True, sendingAuth = False }

        LogOut ->
            let
                currentConnectionData =
                    model.connectionData
            in
                { model | connectionData = { currentConnectionData | authToken = Nothing } }
                    ! [ newUrl LoginRoute
                      , saveAuthToken Nothing
                      , unsubscribeFromTextMessages ()
                      ]

        UserMessageExpired ->
            from
                { model
                    | userMessages =
                        List.take (List.length model.userMessages - 1) model.userMessages
                }

        NoOp ->
            from model


from : Model -> ( Model, Cmd Msg )
from model =
    model ! []


openThread : ContactId -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
openThread contactId ( model, cmd ) =
    { model
        | workflow = Thread (newThreadState contactId)
        , editingContact = False
        , loadingContactMessages = True
    }
        ! [ cmd, fetchListForContact model.connectionData contactId ]
        |> focus "message-input"


closeCreateContactModal : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
closeCreateContactModal ( model, cmd ) =
    { model | createContactModalOpen = False } ! [ cmd ]


createContact : (Result Http.Error Contact -> Msg) -> String -> String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
createContact callback label phoneNumber ( model, cmd ) =
    model ! [ cmd, Contacts.Api.createContact model.connectionData callback label phoneNumber ]


updateContact : Contact -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateContact contact ( model, cmd ) =
    { model | contacts = Contacts.Helpers.updateContact contact model.contacts } ! [ cmd ]


updateContacts : List Contact -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateContacts contacts ( model, cmd ) =
    { model | contacts = Contacts.Helpers.updateContacts model.contacts contacts } ! [ cmd ]


addHttpError : Http.Error -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addHttpError e ( model, cmd ) =
    let
        removeCmd =
            delay (Time.millisecond * 5000) <| UserMessageExpired
    in
        case e of
            BadUrl errorMessage ->
                Debug.log errorMessage
                    ({ model
                        | userMessages =
                            (ErrorMessage "An error occurred. Please try again.") :: model.userMessages
                     }
                        ! [ cmd, removeCmd ]
                    )

            Timeout ->
                { model
                    | userMessages =
                        (ErrorMessage "An network timeout occurred. Please try again.") :: model.userMessages
                }
                    ! [ cmd, removeCmd ]

            NetworkError ->
                { model
                    | userMessages =
                        (ErrorMessage "An network error occurred. Please check your connection and try again.")
                            :: model.userMessages
                }
                    ! [ cmd, removeCmd ]

            BadStatus response ->
                { model
                    | userMessages =
                        (ErrorMessage "The action failed. Please try again.") :: model.userMessages
                }
                    ! [ cmd, removeCmd ]

            BadPayload errorMessage response ->
                Debug.log errorMessage
                    ({ model
                        | userMessages =
                            (ErrorMessage "An error occurred. Please try again.") :: model.userMessages
                     }
                        ! [ cmd, removeCmd ]
                    )


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
