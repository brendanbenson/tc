module Validation.Helpers exposing (..)

import StringUtils
import Validation.Models exposing (FieldError, ValidationErrors)


allErrorDescriptions : ValidationErrors -> List String
allErrorDescriptions validationErrors =
    List.map errorForField validationErrors.fieldErrors


errorsForField : ValidationErrors -> String -> List String
errorsForField validationErrors field =
    List.filter (((==) field) << .field) validationErrors.fieldErrors
        |> List.map errorForField


errorForField : FieldError -> String
errorForField fieldError =
    case fieldError.code of
        "InvalidPhoneNumber" ->
            fieldError.rejectedValue ++ " is not a valid phone number."

        "NotBlank" ->
            StringUtils.capitalizeFirst (fieldName fieldError.field) ++ " cannot be blank."

        _ ->
            "Validation error " ++ fieldError.code ++ " for value " ++ fieldError.rejectedValue


fieldName : String -> String
fieldName field =
    case field of
        "phoneNumber" ->
            "phone number"

        _ ->
            field
