module Flags exposing
    ( Flags
    , decode
    , default
    )

import Flags.Window as Window exposing (Window)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as P



-- TYPES


type alias Flags =
    { window : Window }



-- INFO


default : Flags
default =
    { window = Window.default }



-- DECODER


decode : Decoder Flags
decode =
    Decode.succeed Flags
        |> P.required "window" Window.decode
