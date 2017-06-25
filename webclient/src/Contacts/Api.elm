module Contacts.Api exposing (..)

import Authentication.AuthToken exposing (AuthToken)
import Contacts.Decoders exposing (decodeContactList)
import Http
import HttpHelpers
import Messages exposing (Msg(SearchedContacts))


search : AuthToken -> String -> Cmd Msg
search authToken q =
    let
        url =
            -- TODO: url encode the search string q
            "http://localhost:8080/contacts?q=" ++ q

        request =
            HttpHelpers.get authToken url decodeContactList
    in
        Http.send SearchedContacts request
