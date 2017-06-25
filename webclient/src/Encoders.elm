module Encoders exposing (..)

import Contacts.Models exposing (ContactId, Recipient(KnownContact, RawPhoneNumber))
import Json.Encode exposing (int, object, string)
import Models exposing (ThreadState)


threadStatesToValue : List ThreadState -> Json.Encode.Value
threadStatesToValue =
    Json.Encode.list << List.map threadStateToValue


threadStateToValue : ThreadState -> Json.Encode.Value
threadStateToValue threadState =
    object
        [ ( "uid", int threadState.uid )
        , ( "draftMessage", string threadState.draftMessage )
        , ( "to", recipientToValue threadState.to )
        ]


recipientToValue : Recipient -> Json.Encode.Value
recipientToValue recipient =
    case recipient of
        KnownContact contactId ->
            knownContactToValue contactId

        RawPhoneNumber phoneNumber ->
            rawPhoneNumberToValue phoneNumber


knownContactToValue : ContactId -> Json.Encode.Value
knownContactToValue contactId =
    object
        [ ( "recipientType", string "knownContact" )
        , ( "contactId", int contactId )
        ]


rawPhoneNumberToValue : String -> Json.Encode.Value
rawPhoneNumberToValue phoneNumber =
    object
        [ ( "recipientType", string "rawPhoneNumber" )
        , ( "phoneNumber", string phoneNumber )
        ]
