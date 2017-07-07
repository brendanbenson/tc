module Groups.Models exposing (..)


type alias GroupId =
    Int


type alias Group =
    { id : GroupId
    , label : String
    }


emptyGroup : Group
emptyGroup =
    { id = 0
    , label = ""
    }
