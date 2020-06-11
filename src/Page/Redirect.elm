module Page.Redirect exposing (Model, init, toGlobal, view)

import Global
import Html exposing (text)
import Page exposing (Page)



-- MODEL


type Model
    = Model Global.Model


init : Global.Model -> Model
init global =
    Model global



-- INFO


toGlobal : Model -> Global.Model
toGlobal (Model global) =
    global



-- VIEW


view : Model -> Page msg
view (Model global) =
    { title = ""
    , content = text "Carregando..."
    , device = global.device
    }
