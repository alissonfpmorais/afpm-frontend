module Flags exposing
    ( Flags
    , decode
    , default
    )

import Element exposing (Device)
import Flags.Device as Device
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as P



-- TYPES


type alias Flags =
    { device : Device }



-- INFO


default : Flags
default =
    { device = Device.default }



-- DECODER


decode : Decoder Flags
decode =
    Decode.succeed Flags
        |> P.required "window" Device.decode
