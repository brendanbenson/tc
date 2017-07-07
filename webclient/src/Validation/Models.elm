module Validation.Models exposing (..)


type alias FieldError =
    { field : String
    , code : String
    , rejectedValue : String
    }


type alias GlobalError =
    { code : String
    }


type alias ValidationErrors =
    { fieldErrors : List FieldError
    , globalErrors : List GlobalError
    }
