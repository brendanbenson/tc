module StringUtils exposing (..)

import Char


capitalizeFirst : String -> String
capitalizeFirst str =
    case String.uncons str of
        Nothing ->
            str

        Just ( firstLetter, rest ) ->
            let
                newFirstLetter =
                    Char.toUpper firstLetter
            in
                String.cons newFirstLetter rest
