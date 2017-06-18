module Authentication.Encoders exposing (..)

import Json.Encode exposing (Value, object)
import Models exposing (Model)


authenticationRequest : Model -> Value
authenticationRequest model =
    object
        [ ( "username", Json.Encode.string model.username )
        , ( "password", Json.Encode.string model.password )
        ]
