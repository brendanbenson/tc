module HttpHelpers exposing (..)

import Authentication.AuthToken exposing (AuthToken)
import Http exposing (Body, Header, Request, emptyBody, expectJson, expectStringResponse, header, request)
import Json.Decode
import Maybe exposing (withDefault)


put : AuthToken -> String -> Body -> Request ()
put authToken url body =
    request
        { method = "PUT"
        , headers = [ authHeader authToken ]
        , url = url
        , body = body
        , expect = expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }


get : AuthToken -> String -> Json.Decode.Decoder a -> Request a
get authToken url decoder =
    request
        { method = "GET"
        , headers = [ authHeader authToken ]
        , url = url
        , body = emptyBody
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


authHeader : AuthToken -> Header
authHeader authToken =
    header "X-Auth-Token" (withDefault "" authToken)
