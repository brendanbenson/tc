module Contacts.Api exposing (..)

import Contacts.Decoders exposing (decodeContact, decodeContactList)
import Contacts.Encoders exposing (createContactRequest, editContactRequest)
import Contacts.Models exposing (Contact)
import Groups.Models exposing (GroupId)
import Http exposing (emptyBody, jsonBody)
import HttpHelpers
import Messages exposing (Msg(ContactCreated, EditedContact, FetchedContactsForGroup, SearchedContacts))


search : String -> Cmd Msg
search q =
    let
        url =
            "/api/contacts?q=" ++ Http.encodeUri q

        request =
            Http.get url decodeContactList
    in
        Http.send (SearchedContacts q) request


fetchForGroup : GroupId -> Cmd Msg
fetchForGroup groupId =
    let
        url =
            "/api/groups/" ++ (toString groupId) ++ "/contacts"

        request =
            Http.get url decodeContactList
    in
        Http.send FetchedContactsForGroup request


createContact : (Result Http.Error Contact -> Msg) -> String -> String -> Cmd Msg
createContact callback label phoneNumber =
    let
        url =
            "/api/contacts"

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
            "/api/contacts"

        requestBody =
            jsonBody <| editContactRequest contact

        request =
            HttpHelpers.put url requestBody decodeContact
    in
        Http.send EditedContact request
