module Page.Home exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import Html exposing (text)
import Page exposing (Page)
import Session exposing (Session)



-- MODEL


type Model
    = Model Session Internals


type alias Internals =
    {}


init : Session -> ( Model, Cmd Msg )
init session =
    ( Model session {}
    , Cmd.none
    )



-- UPDATE


type Msg
    = NoOp


toSession : Model -> Session
toSession model =
    case model of
        Model session _ ->
            session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Page Msg
view _ =
    { title = "Home"
    , content = text ""
    }
