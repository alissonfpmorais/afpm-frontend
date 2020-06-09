module Flags exposing (Flags, decode, default)

import Json.Decode exposing (Decoder, succeed)



-- TYPES


type alias Flags =
    {}



-- INFO


default : Flags
default =
    {}



-- DECODER


decode : Decoder Flags
decode =
    succeed Flags
