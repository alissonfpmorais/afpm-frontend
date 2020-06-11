module Flags.Device exposing
    ( decode
    , default
    )

import Element exposing (Device)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as P



-- TYPE


type alias Window =
    { width : Int
    , height : Int
    }



-- INFO


default : Device
default =
    Element.classifyDevice
        { width = 0
        , height = 0
        }



-- SERIALIZATION


decode : Decoder Device
decode =
    Decode.succeed Window
        |> P.required "width" Decode.int
        |> P.required "height" Decode.int
        |> Decode.map Element.classifyDevice
