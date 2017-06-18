module TextMessages.Api exposing (..)

import Authentication.AuthToken exposing (AuthToken)
import Http
import HttpHelpers
import Messages exposing (Msg(FetchedListForContact))
import Models exposing (Contact)
import TextMessages.Decoders exposing (decodeTextMessageList)


fetchListForContact : AuthToken -> Contact -> Cmd Msg
fetchListForContact authToken contact =
    let
        url =
            "http://localhost:8080/contacts/" ++ (toString contact.id) ++ "/text-messages"

        request =
            HttpHelpers.get authToken url decodeTextMessageList
    in
        Http.send FetchedListForContact request
