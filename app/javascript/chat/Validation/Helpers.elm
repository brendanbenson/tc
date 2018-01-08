module Validation.Helpers exposing (..)

import StringUtils
import Validation.Models exposing (FieldError, GlobalError, ValidationErrors)


allErrorDescriptions : ValidationErrors -> List String
allErrorDescriptions validationErrors =
    List.concat
        [ List.map errorForField validationErrors.fieldErrors
        , List.map globalErrorDescription validationErrors.globalErrors
        ]


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



-- message_limit_exceeded


globalErrorDescription : GlobalError -> String
globalErrorDescription globalError =
    case globalError.code of
        "message_limit_exceeded" ->
            "You have exceeded the outbound message limit for your plan. Please upgrade your plan for more messages."

        c ->
            "An error occurred. Please try again. Message code: " ++ c
