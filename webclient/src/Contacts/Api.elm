module Contacts.Api exposing (..)

import Authentication.AuthToken exposing (AuthToken)
import Contacts.Decoders exposing (decodeContact, decodeContactList)
import Contacts.Encoders exposing (createContactRequest, editContactRequest)
import Contacts.Models exposing (Contact)
import Http exposing (jsonBody)
import HttpHelpers
import Messages exposing (Msg(ContactCreated, EditedContact, SearchedContacts))


search : AuthToken -> String -> Cmd Msg
search authToken q =
    let
        url =
            "http://localhost:8080/contacts?q=" ++ Http.encodeUri q

        request =
            HttpHelpers.get authToken url decodeContactList
    in
        Http.send SearchedContacts request


createContact : AuthToken -> String -> Cmd Msg
createContact authToken phoneNumber =
    let
        url =
            "http://localhost:8080/contacts"

        requestBody =
            jsonBody <| createContactRequest phoneNumber

        request =
            HttpHelpers.post authToken url requestBody decodeContact
    in
        Http.send ContactCreated request


editContact : AuthToken -> Contact -> Cmd Msg
editContact authToken contact =
    let
        url =
            "http://localhost:8080/contacts"

        requestBody =
            jsonBody <| editContactRequest contact

        request =
            HttpHelpers.put authToken url requestBody decodeContact
    in
        Http.send EditedContact request
