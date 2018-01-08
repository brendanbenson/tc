module Validation.Decoders exposing (..)

import Json.Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (decode, required)
import Validation.Models exposing (FieldError, GlobalError, ValidationErrors)


decodeValidationErrors : Decoder ValidationErrors
decodeValidationErrors =
    decode ValidationErrors
        |> required "field_errors" (list decodeFieldError)
        |> required "global_errors" (list decodeGlobalError)


decodeFieldError : Decoder FieldError
decodeFieldError =
    decode FieldError
        |> required "field" string
        |> required "code" string
        |> required "rejected_value" string


decodeGlobalError : Decoder GlobalError
decodeGlobalError =
    decode GlobalError
        |> required "code" string
