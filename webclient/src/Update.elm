module Update exposing (..)

import Authentication.Api exposing (authenticate)
import Contacts.Helpers
import Maybe exposing (withDefault)
import Messages exposing (Msg(..))
import Models exposing (Model, TextMessage, newThreadState)
import Ports exposing (setAuthToken)
import Routing exposing (Route(DashboardRoute, LoginRoute), newUrl, parseLocation)
import TextMessages.Api exposing (fetchListForContact)
import TextMessages.Decoders exposing (decodeTextMessageResponse)
import TextMessages.Helpers exposing (updateThreadState)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputBody newBody ->
            { model | body = newBody } ! []

        InputPhoneNumber newPhoneNumber ->
            { model | toPhoneNumber = newPhoneNumber } ! []

        Send ->
            { model | body = "", toPhoneNumber = "" }
                ! [ Ports.sendTextMessage
                        { body = model.body
                        , toPhoneNumber = model.toPhoneNumber
                        }
                  ]

        ReceiveMessages textMessageResponse ->
            let
                messages =
                    decodeTextMessageResponse textMessageResponse

                allContacts =
                    List.concat [ List.map .toContact messages, List.map .fromContact messages ]

                contacts =
                    Contacts.Helpers.updateContacts model.contacts allContacts

                updatedMessages =
                    TextMessages.Helpers.addMessages model.messages messages
            in
                { model | messages = updatedMessages, contacts = contacts } ! []

        OpenThread contact ->
            let
                openThreads =
                    if List.any ((==) contact.id << .contactId) model.openThreads then
                        model.openThreads
                    else
                        List.append model.openThreads [ newThreadState contact.id model.uid ]
            in
                { model | openThreads = openThreads, uid = model.uid + 1 }
                    ! [ fetchListForContact model.authToken contact ]

        CloseThread uid ->
            { model | openThreads = List.filter (not << (==) uid << .uid) model.openThreads } ! []

        FetchedListForContact (Ok fetchedMessages) ->
            ( { model | messages = TextMessages.Helpers.addMessages model.messages fetchedMessages }, Cmd.none )

        FetchedListForContact (Err _) ->
            model ! []

        InputThreadMessage threadState messageBody ->
            { model | openThreads = updateThreadState { threadState | draftMessage = messageBody } model.openThreads }
                ! []

        SendThreadMessage contact threadState ->
            { model | openThreads = updateThreadState { threadState | draftMessage = "" } model.openThreads }
                ! [ Ports.sendTextMessage { body = threadState.draftMessage, toPhoneNumber = contact.phoneNumber } ]

        OnLocationChange location ->
            { model | route = parseLocation location } ! []

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
                    ! [ newUrl DashboardRoute, setAuthToken authToken ]

        SubmittedLogin (Err _) ->
            { model | authError = True } ! []
