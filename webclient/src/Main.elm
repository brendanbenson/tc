module Main exposing (..)

import Contacts.Models exposing (ContactId, Recipient(KnownContact))
import Debug exposing (log)
import Decoders exposing (threadStatesDecoder)
import Dict
import Json.Decode
import Maybe exposing (withDefault)
import Messages exposing (Msg(..))
import Models exposing (Model, ThreadState)
import Navigation exposing (Location)
import Ports exposing (subscribeToTextMessages)
import Routing exposing (Route(..), newUrl, parseLocation)
import Update exposing (update)
import View exposing (view)
import Platform.Cmd exposing (Cmd)
import TextMessages.Api exposing (fetchLatestThreads, fetchListForContact)


main : Program Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initialModel : Maybe String -> List ThreadState -> Route -> Model
initialModel authToken openThreads route =
    { toPhoneNumber = ""
    , messages = []
    , contactSuggestions = []
    , openThreads = openThreads
    , contacts = Dict.empty
    , username = ""
    , password = ""
    , authToken = authToken
    , authError = False
    , route = route

    -- Ensure no UID conflicts from previously-stored threads
    , uid = (+) 1 <| List.foldr (max << .uid) 0 openThreads
    }



-- TODO: use a Json decoder for flags


type alias Flags =
    { authToken : Maybe String
    , openThreads : String
    }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            Routing.parseLocation location

        openThreads =
            case Json.Decode.decodeString threadStatesDecoder flags.openThreads of
                Ok openThreads ->
                    openThreads

                Err e ->
                    log e []

        model =
            initialModel flags.authToken openThreads currentRoute

        openThreadsCmds =
            openThreads
                |> List.map (fetchListForContact model.authToken)
                << List.filterMap takeKnownContacts
                << List.map .to
    in
        case model.authToken of
            Nothing ->
                { model | route = LoginRoute } ! [ newUrl LoginRoute ]

            Just _ ->
                case currentRoute of
                    DashboardRoute ->
                        model
                            ! [ Cmd.batch openThreadsCmds
                              , subscribeToTextMessages ()
                              , fetchLatestThreads model.authToken
                              ]

                    _ ->
                        model ! openThreadsCmds


takeKnownContacts : Recipient -> Maybe ContactId
takeKnownContacts recipient =
    case recipient of
        KnownContact k ->
            Just k

        _ ->
            Nothing


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.receiveTextMessages ReceiveMessages
