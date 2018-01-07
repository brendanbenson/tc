module Contacts.ViewHelpers exposing (..)

import Contacts.Models exposing (Contact)
import StringUtils exposing (formatPhoneNumber)


contactName : Contact -> String
contactName contact =
    case contact.label of
        "" ->
            formatPhoneNumber contact.phoneNumber

        label ->
            label
