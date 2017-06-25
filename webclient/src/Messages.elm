module Messages exposing (..)

import Authentication.Models exposing (AuthenticationResponse)
import Contacts.Models exposing (Contact, ContactId, Recipient)
import Http
import Models exposing (ThreadState, Uid)
import Navigation exposing (Location)
import TextMessages.Models exposing (TextMessage)


type Msg
    = InputPhoneNumber String
    | SearchedContacts (Result Http.Error (List Contact))
    | SearchContacts String
    | ReceiveMessages String
    | OpenThread Recipient
    | CloseThread Uid
    | FetchedListForContact (Result Http.Error (List TextMessage))
    | FetchedLatestThreads (Result Http.Error (List TextMessage))
    | InputThreadMessage ThreadState String
    | SendThreadMessage Recipient ThreadState
    | SentRawPhoneNumberMessage Uid (Result Http.Error TextMessage)
    | SentContactMessage (Result Http.Error TextMessage)
    | OnLocationChange Location
    | InputUsername String
    | InputPassword String
    | SubmitLogin
    | SubmittedLogin (Result Http.Error AuthenticationResponse)
