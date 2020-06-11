module Page exposing (Page, view)

import Browser exposing (Document)
import Element exposing (Device)
import Html exposing (Html, footer, header, main_, text)



-- TYPES


type alias Page msg =
    { title : String
    , content : Html msg
    , device : Device
    }



-- VIEW


view : Page msg -> Document msg
view { title, content } =
    { title = title ++ " - AFPM"
    , body =
        [ viewHeader
        , viewMain content
        , viewFooter
        ]
    }


viewHeader : Html msg
viewHeader =
    header [] [ text "" ]


viewMain : Html msg -> Html msg
viewMain content =
    main_ [] [ content ]


viewFooter : Html msg
viewFooter =
    footer [] [ text "" ]
