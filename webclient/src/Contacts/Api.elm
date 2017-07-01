module Contacts.Api exposing (..)

import Contacts.Decoders exposing (decodeContact, decodeContactList)
import Contacts.Encoders exposing (createContactRequest, editContactRequest)
import Contacts.Models exposing (Contact)
import Http exposing (jsonBody)
import HttpHelpers
import Messages exposing (Msg(ContactCreated, EditedContact, SearchedContacts))
import Models exposing (ConnectionData)


search : ConnectionData -> String -> Cmd Msg
search connectionData q =
    let
        url =
            "/contacts?q=" ++ Http.encodeUri q

        request =
            HttpHelpers.get connectionData url decodeContactList
    in
        Http.send (SearchedContacts q) request


createContact : ConnectionData -> (Result Http.Error Contact -> Msg) -> String -> String -> Cmd Msg
createContact connectionData callback label phoneNumber =
    let
        url =
            "/contacts"

        requestBody =
            jsonBody <| createContactRequest label phoneNumber

        request =
            HttpHelpers.post connectionData url requestBody decodeContact
    in
        Http.send callback request


editContact : ConnectionData -> Contact -> Cmd Msg
editContact connectionData contact =
    let
        url =
            "/contacts"

        requestBody =
            jsonBody <| editContactRequest contact

        request =
            HttpHelpers.put connectionData url requestBody decodeContact
    in
        Http.send EditedContact request
