module Messages exposing (..)

import Authentication.Models exposing (AuthenticationResponse)
import Contacts.Models exposing (Contact, ContactId)
import Groups.Models exposing (Group)
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
    | SearchedContacts String (Result Http.Error (List Contact))
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
    | SentMessage ThreadState (Result Http.Error TextMessage)
    | InputThreadSearch String
      --
      -- Groups
    | InputAddToGroupSearch Contact String
    | SearchGroups Contact String
    | SearchedGroups String (Result Http.Error (List Group))
    | AddToGroup Contact Group
    | AddedToGroup ContactId (Result Http.Error Group)
      --
      -- Thread summaries
    | FetchedLatestThreads (Result Http.Error (List TextMessage))
      --
      -- Contact management
    | CreateContact String
    | ContactCreated (Result Http.Error Contact)
    | StartEditingContact String Contact
    | InputContactLabel String
    | InputContactPhoneNumber String
    | EditContact Contact
    | EditedContact (Result Http.Error Contact)
    | OpenCreateContactModal String
    | CloseCreateContactModal
    | InputCreateContactName String
    | InputCreateContactPhoneNumber String
    | CreateFullContact String String
    | FullContactCreated (Result Http.Error Contact)
      --
      -- Util
    | OnLocationChange Location
    | NoOp
    | UserMessageExpired
      --
      -- Login (may get removed)
    | InputUsername String
    | InputPassword String
    | SubmitLogin
    | SubmittedLogin (Result Http.Error AuthenticationResponse)
