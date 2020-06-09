module Page.NotFound exposing (view)

import Html exposing (text)
import Page exposing (Page)



-- VIEW


view : Page msg
view =
    { title = ""
    , content = text "Página não encontrada"
    }
