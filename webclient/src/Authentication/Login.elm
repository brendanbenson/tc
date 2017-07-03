module Authentication.Login exposing (..)

import Html exposing (Html, button, div, fieldset, form, h2, input, label, span, text)
import Html.Attributes exposing (attribute, class, disabled, id, placeholder, type_)
import Html.Events exposing (onInput, onSubmit)
import HtmlUtils exposing (spin)
import Messages exposing (Msg(InputPassword, InputUsername, SubmitLogin))
import Models exposing (Model)


view : Model -> Html Msg
view model =
    div [ class "login-page" ]
        [ div [ class "login-container" ]
            [ form [ class "login-form", onSubmit SubmitLogin ]
                [ h2 [] [ text "Please Log In" ]
                , fieldset []
                    [ input [ type_ "text", onInput InputUsername, placeholder "Email" ] []
                    ]
                , fieldset []
                    [ input [ type_ "password", onInput InputPassword, placeholder "Password" ] []
                    ]
                , button [ type_ "submit", disabled model.sendingAuth, spin model.sendingAuth ] [ text "Submit" ]
                , errors model
                ]
            ]
        ]


errors : Model -> Html Msg
errors model =
    case model.authError of
        True ->
            div [ class "auth-error" ]
                [ span [ class "error-label" ] [ text "Error: " ]
                , text "Username or password is incorrect"
                ]

        _ ->
            span [] []
