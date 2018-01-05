module Users.Helpers exposing (..)

import Models exposing (Model)
import Users.Models exposing (User)


getUser : Model -> Int -> Maybe User
getUser model userId =
    List.filter (((==) userId) << .id) model.users |> List.head
