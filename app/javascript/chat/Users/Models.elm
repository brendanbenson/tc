module Users.Models exposing (..)


type alias UserId =
    Int


type alias User =
    { id : Int
    , email : String
    , name : String
    }
