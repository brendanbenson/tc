module Messages exposing (..)

import Contacts.Models exposing (Contact, ContactId)
import Groups.Models exposing (Group, GroupId)
import Http
import Models exposing (ContactThreadState, GroupThreadState)
import Navigation exposing (Location)
import TextMessages.Models exposing (AugmentedTextMessageResponse, GroupTextMessage, TextMessage)


type
    Msg
    --
    -- Compose auto-complete
    = InputOmniSearch String
    | SearchContacts String
    | SearchedContacts String (Result Http.Error (List Contact))
      --
      -- Text messages
    | ReceiveMessages String
    | Connected Bool
      --
      -- Contact Threads
    | OpenContactThread ContactId
    | FetchedTextMessagesForContact (Result Http.Error (List TextMessage))
    | StartComposing
    | InputThreadMessage ContactThreadState String
    | SendMessage ContactThreadState
    | SentMessage ContactThreadState (Result Http.Error TextMessage)
    | InputThreadSearch String
      --
      -- Groups
    | InputAddToGroupSearch Contact String
    | SearchGroups Contact String
    | SearchedGroups String (Result Http.Error (List Group))
    | AddToGroup ContactId Group
    | AddedToGroup ContactId (Result Http.Error Group)
    | OpenGroupThread GroupId
    | GroupFetched (Result Http.Error Group)
    | SendGroupMessage GroupThreadState
    | SentGroupMessage GroupThreadState (Result Http.Error GroupTextMessage)
    | InputGroupThreadMessage GroupThreadState String
    | FetchedTextMessagesForGroup (Result Http.Error (List GroupTextMessage))
    | FetchedContactsForGroup (Result Http.Error (List Contact))
    | DeleteGroupMembership ContactId GroupId
    | GroupMembershipDeleted ContactId (Result Http.Error Group)
    | InputAddToGroupContactSearch Group String
    | SuggestContactsForGroup Group String
    | SuggestedContactsForGroup String (Result Http.Error (List Contact))
      --
      -- Thread summaries
    | FetchedLatestThreads (Result Http.Error AugmentedTextMessageResponse)
      --
      -- Contact management
    | ListContacts
    | FetchedContacts (Result Http.Error (List Contact))
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
      -- Phone number management
    | ListPhoneNumbers
      --
      -- Util
    | OnLocationChange Location
    | NoOp
    | UserMessageExpired
