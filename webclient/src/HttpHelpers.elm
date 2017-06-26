module HttpHelpers exposing (..)

import Authentication.AuthToken exposing (AuthToken)
import Http exposing (Body, Header, Request, emptyBody, expectJson, expectStringResponse, header, request)
import Json.Decode
import Maybe exposing (withDefault)


put : AuthToken -> String -> Body -> Json.Decode.Decoder a -> Request a
put authToken url body decoder =
    request
        { method = "PUT"
        , headers = [ authHeader authToken ]
        , url = url
        , body = body
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


post : AuthToken -> String -> Body -> Json.Decode.Decoder a -> Request a
post authToken url body decoder =
    request
        { method = "POST"
        , headers = [ authHeader authToken ]
        , url = url
        , body = body
        , expect = expectJson decoder
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
