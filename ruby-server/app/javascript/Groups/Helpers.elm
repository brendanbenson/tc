module Groups.Helpers exposing (..)

import Dict exposing (Dict)
import Groups.Models exposing (Group, GroupId, emptyGroup)
import Maybe exposing (withDefault)


updateGroups : Dict Int Group -> List Group -> Dict Int Group
updateGroups =
    List.foldr updateGroup


updateGroup : Group -> Dict Int Group -> Dict Int Group
updateGroup group =
    Dict.insert group.id group


getGroup : Dict Int Group -> GroupId -> Group
getGroup groups id =
    Dict.get id groups |> withDefault emptyGroup
