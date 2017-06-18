module Messages exposing (..)

import Authentication.Models exposing (AuthenticationResponse)
import Http
import Models exposing (Contact, ContactId, TextMessage, ThreadState, Uid)
import Navigation exposing (Location)


type Msg
    = InputBody String
    | InputPhoneNumber String
    | Send
    | ReceiveMessages String
    | OpenThread Contact
    | CloseThread Uid
    | FetchedListForContact (Result Http.Error (List TextMessage))
    | InputThreadMessage ThreadState String
    | SendThreadMessage Contact ThreadState
    | OnLocationChange Location
    | InputUsername String
    | InputPassword String
    | SubmitLogin
    | SubmittedLogin (Result Http.Error AuthenticationResponse)
