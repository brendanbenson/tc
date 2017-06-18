module Authentication.Api exposing (..)

import Authentication.Decoders exposing (decodeAuthentication)
import Authentication.Encoders exposing (authenticationRequest)
import Http exposing (jsonBody, post)
import Messages exposing (Msg(SubmittedLogin))
import Models exposing (Model)


authenticate : Model -> Cmd Msg
authenticate model =
    let
        url =
            "http://localhost:8080/auth"

        body =
            jsonBody (authenticationRequest model)

        request =
            Http.post url body decodeAuthentication
    in
        Http.send SubmittedLogin request
