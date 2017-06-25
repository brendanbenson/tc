module Update exposing (..)

import Authentication.Api exposing (authenticate)
import Contacts.Api
import Contacts.Helpers exposing (getContact, updateContacts)
import Contacts.Models exposing (ContactId, Recipient(KnownContact, RawPhoneNumber))
import Encoders exposing (threadStateToValue, threadStatesToValue)
import Maybe exposing (withDefault)
import Messages exposing (Msg(..))
import Models exposing (Model, newThreadState)
import Ports exposing (saveAuthToken, saveOpenThreads, subscribeToTextMessages)
import Routing exposing (Route(DashboardRoute, LoginRoute), newUrl, parseLocation)
import String exposing (isEmpty)
import TaskUtils exposing (delay)
import TextMessages.Api exposing (fetchLatestThreads, fetchListForContact, sendContactMessage, sendRawPhoneNumberMessage)
import TextMessages.Decoders exposing (decodeTextMessageResponse)
import TextMessages.Helpers exposing (updateThreadState)
import TextMessages.Models exposing (threadContactId)
import Time exposing (millisecond)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputPhoneNumber newPhoneNumber ->
            if isEmpty newPhoneNumber then
                { model | toPhoneNumber = newPhoneNumber, contactSuggestions = [] } ! []
            else
                { model | toPhoneNumber = newPhoneNumber }
                    ! [ delay (Time.millisecond * 500) <| SearchContacts newPhoneNumber ]

        SearchContacts phoneNumberToSearch ->
            let
                cmd =
                    if
                        model.toPhoneNumber
                            == phoneNumberToSearch
                            && (phoneNumberToSearch |> not << isEmpty)
                    then
                        Contacts.Api.search model.authToken model.toPhoneNumber
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
            -- TODO: clean this up
            -- TODO: just receive a single text message at a time
            let
                messages =
                    decodeTextMessageResponse textMessageResponse

                allContacts =
                    List.concat [ List.map .toContact messages, List.map .fromContact messages ]

                contacts =
                    Contacts.Helpers.updateContacts model.contacts allContacts

                updatedMessages =
                    TextMessages.Helpers.addMessages model.messages messages

                ( updatedModel, fetchCmd ) =
                    -- TODO: the initial message fetch should really just be an HTTP request with a different Msg handler
                    -- Hack to see if it is a recently-received message vs just fetching all the messages
                    if (List.length messages) == 1 then
                        case List.head messages of
                            Just textMessage ->
                                if textMessage.incoming == True then
                                    openThread model (KnownContact (threadContactId textMessage))
                                else
                                    ( model, Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )
                    else
                        ( model, Cmd.none )
            in
                { updatedModel | messages = updatedMessages, contacts = contacts } ! [ fetchCmd ]

        OpenThread recipient ->
            let
                ( newModel, cmd ) =
                    openThread model recipient
            in
                { newModel | toPhoneNumber = "", contactSuggestions = [] } ! [ cmd ]

        CloseThread uid ->
            let
                openThreads =
                    List.filter (not << (==) uid << .uid) model.openThreads
            in
                { model | openThreads = openThreads } ! [ saveOpenThreads (threadStatesToValue openThreads) ]

        FetchedListForContact (Ok fetchedMessages) ->
            ( { model | messages = TextMessages.Helpers.addMessages model.messages fetchedMessages }, Cmd.none )

        FetchedListForContact (Err _) ->
            model ! []

        InputThreadMessage threadState messageBody ->
            { model | openThreads = updateThreadState { threadState | draftMessage = messageBody } model.openThreads }
                ! []

        SendThreadMessage recipient threadState ->
            --TODO: clean this up
            case recipient of
                KnownContact contactId ->
                    let
                        contact =
                            getContact model.contacts contactId
                    in
                        { model | openThreads = updateThreadState { threadState | draftMessage = "" } model.openThreads }
                            ! [ sendContactMessage model.authToken contact.id threadState.draftMessage SentContactMessage ]

                --                            ! [ Ports.sendTextMessage { body = threadState.draftMessage, toPhoneNumber = contact.phoneNumber } ]
                RawPhoneNumber phoneNumber ->
                    { model | openThreads = updateThreadState { threadState | draftMessage = "" } model.openThreads }
                        ! [ sendRawPhoneNumberMessage
                                model.authToken
                                phoneNumber
                                threadState.draftMessage
                                (SentRawPhoneNumberMessage threadState.uid)
                          ]

        SentContactMessage _ ->
            -- TODO: handle the success and error states
            model ! []

        SentRawPhoneNumberMessage uid (Ok textMessage) ->
            let
                openThreads =
                    updateThreadState (newThreadState (KnownContact textMessage.toContact.id) uid) model.openThreads
            in
                -- TODO: save the new text message in the model (avoiding duplicates)
                { model
                    | contacts = updateContacts model.contacts [ textMessage.toContact ]
                    , openThreads = openThreads
                }
                    ! [ saveOpenThreads (threadStatesToValue openThreads) ]

        SentRawPhoneNumberMessage uid (Err e) ->
            Debug.log (toString e) (model ! [])

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


openThread : Model -> Recipient -> ( Model, Cmd Msg )
openThread model recipient =
    --TODO: clean this up
    case recipient of
        KnownContact contactId ->
            let
                openThreads =
                    if List.any (\t -> t.to == KnownContact contactId) model.openThreads then
                        model.openThreads
                    else
                        List.append model.openThreads [ newThreadState (KnownContact contactId) model.uid ]
            in
                { model | openThreads = openThreads, uid = model.uid + 1 }
                    ! [ fetchListForContact model.authToken contactId, saveOpenThreads (threadStatesToValue openThreads) ]

        RawPhoneNumber phoneNumber ->
            let
                openThreads =
                    if List.any (\t -> t.to == RawPhoneNumber phoneNumber) model.openThreads then
                        model.openThreads
                    else
                        List.append model.openThreads [ newThreadState (RawPhoneNumber phoneNumber) model.uid ]
            in
                { model | openThreads = openThreads, uid = model.uid + 1 }
                    ! [ saveOpenThreads (threadStatesToValue openThreads) ]
