module Contacts.ViewHelpers exposing (..)

import Contacts.Models exposing (Contact)


contactName : Contact -> String
contactName contact =
    case contact.label of
        "" ->
            contact.phoneNumber

        label ->
            label
