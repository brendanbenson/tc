module Groups.Api exposing (..)

import Contacts.Decoders exposing (decodeContactList)
import Contacts.Models exposing (ContactId)
import Groups.Decoders exposing (decodeGroup, decodeGroupList)
import Groups.Encoders exposing (addToGroupRequest)
import Groups.Models exposing (Group, GroupId)
import Http exposing (emptyBody, jsonBody)
import HttpHelpers
import Messages exposing (Msg(SearchedGroups, SuggestedContactsForGroup))


search : ContactId -> String -> Cmd Msg
search contactId q =
    let
        url =
            "/api/contacts/" ++ (toString contactId) ++ "/suggest-groups?q=" ++ Http.encodeUri q

        request =
            Http.get url decodeGroupList
    in
        Http.send (SearchedGroups q) request


suggestContactsForGroup : GroupId -> String -> Cmd Msg
suggestContactsForGroup groupId q =
    let
        url =
            "/api/groups/" ++ (toString groupId) ++ "/suggest-contacts?q=" ++ Http.encodeUri q

        request =
            Http.get url decodeContactList
    in
        Http.send (SuggestedContactsForGroup q) request


addToGroup : (Result Http.Error Group -> Msg) -> ContactId -> GroupId -> Cmd Msg
addToGroup callback contactId groupId =
    let
        url =
            "/api/contacts/" ++ (toString contactId) ++ "/groups"

        requestBody =
            jsonBody <| addToGroupRequest groupId

        request =
            Http.post url requestBody decodeGroup
    in
        Http.send callback request


fetchGroup : (Result Http.Error Group -> Msg) -> GroupId -> Cmd Msg
fetchGroup callback groupId =
    let
        url =
            "/api/groups/" ++ (toString groupId)

        request =
            Http.get url decodeGroup
    in
        Http.send callback request


deleteGroupMembership : (Result Http.Error Group -> Msg) -> ContactId -> GroupId -> Cmd Msg
deleteGroupMembership callback contactId groupId =
    let
        url =
            "/api/contacts/" ++ (toString contactId) ++ "/groups/" ++ (toString groupId)

        request =
            HttpHelpers.delete url emptyBody decodeGroup
    in
        Http.send callback request
