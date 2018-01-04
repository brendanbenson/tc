module StringUtils exposing (..)

import Char
import Phone


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


formatPhoneNumber : String -> String
formatPhoneNumber phoneNumber =
    Phone.format "us" <| String.dropLeft 1 phoneNumber
