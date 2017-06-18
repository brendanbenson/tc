module Authentication.Login exposing (..)

import Html exposing (Html, button, div, form, input, label, span, text)
import Html.Attributes exposing (type_)
import Html.Events exposing (onInput, onSubmit)
import Messages exposing (Msg(InputPassword, InputUsername, SubmitLogin))
import Models exposing (Model)


view : Model -> Html Msg
view model =
    div []
        [ form [ onSubmit SubmitLogin ]
            [ label []
                [ text "Email"
                , input [ type_ "text", onInput InputUsername ] []
                ]
            , label []
                [ text "Password"
                , input [ type_ "password", onInput InputPassword ] []
                ]
            , button [ type_ "submit" ] [ text "Submit" ]
            ]
        , errors model
        ]


errors : Model -> Html Msg
errors model =
    case model.authError of
        True ->
            span [] [ text "Username or password is incorrect" ]

        _ ->
            span [] []
