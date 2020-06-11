module Global exposing (Model)

import Element exposing (Device)
import Session exposing (Session)



-- MODEL


type alias Model =
    { session : Session
    , device : Device
    }
