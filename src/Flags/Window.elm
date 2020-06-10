module Flags.Window exposing
    ( Window
    , decode
    , default
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as P



-- TYPE


type alias Window =
    { width : Int
    , height : Int
    }



-- INFO


default : Window
default =
    { width = 0
    , height = 0
    }



-- SERIALIZATION


decode : Decoder Window
decode =
    Decode.succeed Window
        |> P.required "width" Decode.int
        |> P.required "height" Decode.int
