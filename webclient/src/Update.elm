module Update exposing (..)

import Authentication.Api exposing (authenticate)
import Contacts.Api exposing (createContact, editContact)
import Contacts.Helpers exposing (getContact, updateContact, updateContacts)
import Contacts.Models exposing (ContactId)
import Dom.Scroll
import Json.Decode exposing (decodeString)
import Maybe exposing (withDefault)
import Messages exposing (Msg(..))
import Models exposing (Model, Workflow(NewContact, Thread), newThreadState)
import Ports exposing (saveAuthToken, subscribeToTextMessages)
import Routing exposing (Route(DashboardRoute, LoginRoute), newUrl, parseLocation)
import String exposing (isEmpty)
import Task
import TaskUtils exposing (delay)
import TextMessages.Api exposing (fetchLatestThreads, fetchListForContact, sendContactMessage)
import TextMessages.Decoders exposing (decodeTextMessage)
import TextMessages.Helpers
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

        SearchContacts phoneNumberToSearch ->
            let
                cmd =
                    if
                        model.contactSearch
                            == phoneNumberToSearch
                            && (phoneNumberToSearch |> not << isEmpty)
                    then
                        Contacts.Api.search model.authToken model.contactSearch
                    else
                        Cmd.none
            in
                model ! [ cmd ]

        SearchedContacts (Ok contacts) ->
            { model
                | contactSuggestions = List.map .id contacts
                , contacts = updateContacts model.contacts contacts
            }
                ! []

        SearchedContacts (Err _) ->
            model ! []

        FetchedLatestThreads (Ok messages) ->
            let
                allContacts =
                    List.concat [ List.map .toContact messages, List.map .fromContact messages ]
            in
                { model
                    | messages = TextMessages.Helpers.addMessages model.messages messages
                    , contacts = Contacts.Helpers.updateContacts model.contacts allContacts
                }
                    ! []

        FetchedLatestThreads (Err _) ->
            model ! []

        ReceiveMessages textMessageResponse ->
            case decodeString decodeTextMessage textMessageResponse of
                Ok textMessage ->
                    let
                        allContacts =
                            [ textMessage.toContact, textMessage.fromContact ]

                        contacts =
                            Contacts.Helpers.updateContacts model.contacts allContacts

                        updatedMessages =
                            TextMessages.Helpers.addMessages model.messages [ textMessage ]
                    in
                        { model | messages = updatedMessages, contacts = contacts }
                            ! [ scrollToBottom ]

                Err e ->
                    Debug.log e <| model ! []

        OpenThread contactId ->
            { model | contactSearch = "", contactSuggestions = [] } ! [ scrollToBottom ] |> openThread contactId

        StartComposing ->
            { model | workflow = NewContact } ! []

        CreateContact phoneNumber ->
            model ! [ createContact model.authToken phoneNumber ]

        ContactCreated (Ok contact) ->
            { model | contacts = updateContact contact model.contacts } ! [] |> openThread contact.id

        ContactCreated (Err e) ->
            -- TODO: implement error handling
            model ! []

        StartEditingContact contact ->
            { model | editingContact = True, contactEdits = contact } ! []

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
            model ! [ editContact model.authToken contact ]

        EditedContact (Ok contact) ->
            { model | editingContact = False, contacts = updateContact contact model.contacts } ! []

        EditedContact (Err e) ->
            -- TODO: implement error handling
            model ! []

        FetchedTextMessagesForContact (Ok fetchedMessages) ->
            { model | messages = TextMessages.Helpers.addMessages model.messages fetchedMessages }
                ! [ scrollToBottom ]

        FetchedTextMessagesForContact (Err _) ->
            model ! []

        InputThreadMessage threadState messageBody ->
            { model | workflow = Thread { threadState | draftMessage = messageBody } }
                ! []

        SendMessage threadState ->
            let
                contact =
                    getContact model.contacts threadState.to
            in
                { model | workflow = Thread { threadState | draftMessage = "" } }
                    ! [ sendContactMessage model.authToken contact.id threadState.draftMessage SentMessage ]

        SentMessage (Ok textMessage) ->
            { model | messages = TextMessages.Helpers.addMessages model.messages [ textMessage ] } ! []

        SentMessage (Err e) ->
            model ! []

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
            ( model, authenticate model )

        SubmittedLogin (Ok authenticationResponse) ->
            let
                authToken =
                    Just authenticationResponse.token
            in
                { model | authToken = authToken }
                    ! [ newUrl DashboardRoute, saveAuthToken authToken, fetchLatestThreads authToken ]

        SubmittedLogin (Err _) ->
            { model | authError = True } ! []

        NoOp ->
            model ! []


openThread : ContactId -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
openThread contactId ( model, cmd ) =
    { model
        | workflow = Thread (newThreadState contactId)
        , editingContact = False
    }
        ! [ cmd, fetchListForContact model.authToken contactId ]


scrollToBottom : Cmd Msg
scrollToBottom =
    Task.attempt (always NoOp) <| Dom.Scroll.toBottom "thread-body"
