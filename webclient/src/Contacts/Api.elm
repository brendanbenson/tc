module Contacts.Api exposing (..)

import Contacts.Decoders exposing (decodeContact, decodeContactList)
import Contacts.Encoders exposing (createContactRequest, editContactRequest)
import Contacts.Models exposing (Contact)
import Http exposing (jsonBody)
import HttpHelpers
import Messages exposing (Msg(ContactCreated, EditedContact, SearchedContacts))


search : String -> Cmd Msg
search q =
    let
        url =
            "/contacts?q=" ++ Http.encodeUri q

        request =
            Http.get url decodeContactList
    in
        Http.send (SearchedContacts q) request


createContact : (Result Http.Error Contact -> Msg) -> String -> String -> Cmd Msg
createContact callback label phoneNumber =
    let
        url =
            "/contacts"

        requestBody =
            jsonBody <| createContactRequest label phoneNumber

        request =
            Http.post url requestBody decodeContact
    in
        Http.send callback request


editContact : Contact -> Cmd Msg
editContact contact =
    let
        url =
            "/contacts"

        requestBody =
            jsonBody <| editContactRequest contact

        request =
            HttpHelpers.put url requestBody decodeContact
    in
        Http.send EditedContact request
