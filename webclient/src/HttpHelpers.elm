module HttpHelpers exposing (..)

import Authentication.AuthToken exposing (AuthToken)
import Http exposing (Body, Header, Request, emptyBody, expectJson, expectStringResponse, header, request)
import Json.Decode
import Maybe exposing (withDefault)
import Models exposing (ConnectionData)


put : ConnectionData -> String -> Body -> Json.Decode.Decoder a -> Request a
put connectionData url body decoder =
    request
        { method = "PUT"
        , headers = [ authHeader connectionData.authToken ]
        , url = connectionData.baseUrl ++ url
        , body = body
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


post : ConnectionData -> String -> Body -> Json.Decode.Decoder a -> Request a
post connectionData url body decoder =
    request
        { method = "POST"
        , headers = [ authHeader connectionData.authToken ]
        , url = connectionData.baseUrl ++ url
        , body = body
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


get : ConnectionData -> String -> Json.Decode.Decoder a -> Request a
get connectionData url decoder =
    request
        { method = "GET"
        , headers = [ authHeader connectionData.authToken ]
        , url = connectionData.baseUrl ++ url
        , body = emptyBody
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


authHeader : AuthToken -> Header
authHeader authToken =
    header "X-Auth-Token" (withDefault "" authToken)
