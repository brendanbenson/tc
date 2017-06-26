module Messages exposing (..)

import Authentication.Models exposing (AuthenticationResponse)
import Contacts.Models exposing (Contact, ContactId)
import Http
import Models exposing (ThreadState)
import Navigation exposing (Location)
import TextMessages.Models exposing (TextMessage)


type
    Msg
    --
    -- Contact auto-complete
    = InputContactSearch String
    | SearchContacts String
    | SearchedContacts (Result Http.Error (List Contact))
      --
      -- Text messages
    | ReceiveMessages String
      --
      -- Threads
    | OpenThread ContactId
    | FetchedTextMessagesForContact (Result Http.Error (List TextMessage))
    | StartComposing
    | InputThreadMessage ThreadState String
    | SendMessage ThreadState
    | SentMessage (Result Http.Error TextMessage)
      --
      -- Thread summaries
    | FetchedLatestThreads (Result Http.Error (List TextMessage))
      --
      -- Contact management
    | CreateContact String
    | ContactCreated (Result Http.Error Contact)
    | StartEditingContact Contact
    | InputContactLabel String
    | InputContactPhoneNumber String
    | EditContact Contact
    | EditedContact (Result Http.Error Contact)
      --
      -- Util
    | OnLocationChange Location
    | NoOp
      --
      -- Login
    | InputUsername String
    | InputPassword String
    | SubmitLogin
    | SubmittedLogin (Result Http.Error AuthenticationResponse)
