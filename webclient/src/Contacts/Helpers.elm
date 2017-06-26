module Contacts.Helpers exposing (..)

import Contacts.Models exposing (Contact, ContactId, emptyContact)
import Dict exposing (Dict)
import Maybe exposing (withDefault)


updateContacts : Dict Int Contact -> List Contact -> Dict Int Contact
updateContacts =
    List.foldr updateContact


updateContact : Contact -> Dict Int Contact -> Dict Int Contact
updateContact contact =
    Dict.insert contact.id contact


getContact : Dict Int Contact -> ContactId -> Contact
getContact contacts id =
    Dict.get id contacts |> withDefault emptyContact
