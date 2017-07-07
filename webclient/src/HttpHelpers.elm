module HttpHelpers exposing (..)

import Authentication.AuthToken exposing (AuthToken)
import Http exposing (Body, Header, Request, emptyBody, expectJson, expectStringResponse, header, request)
import Json.Decode
import Maybe exposing (withDefault)


put : String -> Body -> Json.Decode.Decoder a -> Request a
put url body decoder =
    request
        { method = "PUT"
        , headers = []
        , url = url
        , body = body
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


delete : String -> Body -> Json.Decode.Decoder a -> Request a
delete url body decoder =
    request
        { method = "DELETE"
        , headers = []
        , url = url
        , body = body
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }
