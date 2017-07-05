module Groups.Api exposing (..)

import Contacts.Models exposing (ContactId)
import Groups.Decoders exposing (decodeGroup, decodeGroupList)
import Groups.Encoders exposing (addToGroupRequest)
import Groups.Models exposing (Group, GroupId)
import Http exposing (jsonBody)
import Messages exposing (Msg(SearchedGroups))


search : ContactId -> String -> Cmd Msg
search contactId q =
    let
        url =
            "/contacts/" ++ (toString contactId) ++ "/groups?q=" ++ Http.encodeUri q

        request =
            Http.get url decodeGroupList
    in
        Http.send (SearchedGroups q) request


addToGroup : (Result Http.Error Group -> Msg) -> ContactId -> GroupId -> Cmd Msg
addToGroup callback contactId groupId =
    let
        url =
            "/contacts/" ++ (toString contactId) ++ "/groups"

        requestBody =
            jsonBody <| addToGroupRequest groupId

        request =
            Http.post url requestBody decodeGroup
    in
        Http.send callback request
