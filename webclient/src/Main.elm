module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, placeholder, type_)
import Html.Events exposing (..)
import Http exposing (jsonBody)
import Json.Decode exposing (Decoder, decodeString, field, list, map2, maybe, oneOf, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import Maybe exposing (withDefault)
import Models exposing (TextMessage)
import Ports


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { body : String
    , toPhoneNumber : String
    , messages : List TextMessage
    , currentPhoneNumber : Maybe String
    , aliasing : Bool
    , alias_ : String
    }


init : ( Model, Cmd Msg )
init =
    ( { body = ""
      , toPhoneNumber = ""
      , messages = []
      , currentPhoneNumber = Nothing
      , aliasing = False
      , alias_ = ""
      }
    , Cmd.none
    )


type Msg
    = InputBody String
    | InputPhoneNumber String
    | Send
    | ReceiveMessages String
    | SetCurrentPhoneNumber String
    | StartAliasing
    | InputAlias String
    | SubmitAlias
    | SubmittedAlias (Result Http.Error Bool)


type TextMessageResponse
    = MessageList (List TextMessage)
    | IndividualMessage TextMessage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputBody newBody ->
            ( { model | body = newBody }, Cmd.none )

        InputPhoneNumber newPhoneNumber ->
            ( { model | toPhoneNumber = newPhoneNumber }, Cmd.none )

        InputAlias newAlias ->
            ( { model | alias_ = newAlias }, Cmd.none )

        Send ->
            ( model, Ports.sendTextMessage { body = model.body, toPhoneNumber = model.toPhoneNumber } )

        ReceiveMessages textMessageResponse ->
            case decodeTextMessageResponse textMessageResponse of
                MessageList messages ->
                    ( { model | messages = messages }, Cmd.none )

                IndividualMessage message ->
                    ( { model | messages = List.append model.messages [ message ] }, Cmd.none )

        SetCurrentPhoneNumber phoneNumber ->
            ( { model | currentPhoneNumber = Just phoneNumber }, Cmd.none )

        StartAliasing ->
            ( { model | aliasing = True }, Cmd.none )

        SubmitAlias ->
            ( { model | aliasing = False, alias_ = "" }, submitAlias model )

        SubmittedAlias (Ok _) ->
            ( model, Cmd.none )

        SubmittedAlias (Err _) ->
            ( model, Cmd.none )


type alias AliasRequest =
    { label : String, phoneNumber : String }


submitAlias : Model -> Cmd Msg
submitAlias model =
    let
        url =
            "http://localhost:8080/aliases"

        requestBody =
            AliasRequest model.alias_ (withDefault "" model.currentPhoneNumber)

        request =
            Http.post
                url
                (jsonBody (Json.Encode.object [ ( "label", Json.Encode.string model.alias_ ), ( "phoneNumber", Json.Encode.string (withDefault "" model.currentPhoneNumber) ) ]))
                (Json.Decode.null True)
    in
        Http.send SubmittedAlias request


decodeTextMessageResponse : String -> TextMessageResponse
decodeTextMessageResponse rawJson =
    case decodeString decodeTextMessageList rawJson of
        Ok stuff ->
            MessageList stuff

        Err _ ->
            case decodeString decodeTextMessage rawJson of
                Ok stuff ->
                    IndividualMessage stuff

                Err _ ->
                    MessageList []


decodeTextMessageList : Decoder (List TextMessage)
decodeTextMessageList =
    list decodeTextMessage


decodeTextMessage : Decoder TextMessage
decodeTextMessage =
    decode TextMessage
        |> required "body" string
        |> required "toPhoneNumber" string


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.receiveTextMessages ReceiveMessages


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "All text messages" ]
        , div [] (List.map threadSummary model.messages)
        , threadView model
        , label []
            [ text "Phone number"
            , input [ onInput InputPhoneNumber ] []
            ]
        , label []
            [ text "Message"
            , input [ onInput InputBody ] []
            ]
        , button [ onClick Send ] [ text "Send" ]
        ]


threadSummary : TextMessage -> Html Msg
threadSummary textMessage =
    div []
        [ div []
            [ a [ onClick (SetCurrentPhoneNumber textMessage.toPhoneNumber) ]
                [ text <| "From: " ++ textMessage.toPhoneNumber
                ]
            ]
        , div [] [ text textMessage.body ]
        ]


messageView : TextMessage -> Html Msg
messageView textMessage =
    div []
        [ div []
            [ a [ onClick (SetCurrentPhoneNumber textMessage.toPhoneNumber) ]
                [ text textMessage.toPhoneNumber
                ]
            ]
        , div [] [ text textMessage.body ]
        ]


threadView : Model -> Html Msg
threadView model =
    case model.currentPhoneNumber of
        Nothing ->
            h1 [] [ text "Click on a phone number" ]

        Just phoneNumber ->
            div []
                [ h1 []
                    [ span [] [ text "Text messages for " ]
                    , phoneNumberHeaderView model.aliasing phoneNumber
                    ]
                , div [] (List.map messageView (messagesForPhoneNumber phoneNumber model.messages))
                ]


phoneNumberHeaderView : Bool -> String -> Html Msg
phoneNumberHeaderView aliasing phoneNumber =
    if aliasing then
        div []
            [ input [ onInput InputAlias, type_ "text", placeholder "Edit name" ] []
            , button [ onClick SubmitAlias ] [ text "Submit" ]
            ]
    else
        span [ onClick StartAliasing ] [ text phoneNumber ]


messagesForPhoneNumber : String -> List TextMessage -> List TextMessage
messagesForPhoneNumber phoneNumber =
    List.filter (\t -> t.toPhoneNumber == phoneNumber)
