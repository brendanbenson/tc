module Groups.Encoders exposing (..)

import Groups.Models exposing (GroupId)
import Json.Encode exposing (Value, object)


addToGroupRequest : GroupId -> Value
addToGroupRequest groupId =
    object
        [ ( "groupId", Json.Encode.int groupId )
        ]
