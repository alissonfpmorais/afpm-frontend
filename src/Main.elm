module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Flags
import Global
import Html
import Json.Decode as Decode
import Page exposing (Page)
import Page.Home as Home exposing (Model, Msg)
import Page.NotFound as NotFound
import Page.Redirect as Redirect
import Route exposing (Route)
import Session
import Url exposing (Url)



-- MODEL


type Model
    = Redirect Redirect.Model
    | NotFound NotFound.Model
    | Home Home.Model


init : Decode.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init encodedFlags url navKey =
    let
        flags =
            case Decode.decodeValue Flags.decode encodedFlags of
                Ok response ->
                    response

                Err _ ->
                    Flags.default

        global =
            { session = Session.guest navKey flags
            , device = flags.device
            }
    in
    global
        |> Redirect.init
        |> Redirect
        |> changeRouteTo (Route.fromUrl url)



-- UPDATE


type Msg
    = NoOp
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotNotFoundMsg NotFound.Msg
    | GotHomeMsg Home.Msg


toGlobal : Model -> Global.Model
toGlobal model =
    case model of
        Redirect subModel ->
            Redirect.toGlobal subModel

        NotFound subModel ->
            NotFound.toGlobal subModel

        Home subModel ->
            Home.toGlobal subModel


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        global =
            toGlobal model
    in
    case maybeRoute of
        Nothing ->
            NotFound.init global
                |> updateWith NotFound GotNotFoundMsg

        Just Route.NotFound ->
            NotFound.init global
                |> updateWith NotFound GotNotFoundMsg

        Just Route.Home ->
            Home.init global
                |> updateWith Home GotHomeMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( NoOp, _ ) ->
            ( model, Cmd.none )

        ( ClickedLink (Browser.Internal url), _ ) ->
            let
                global =
                    toGlobal model
            in
            ( model
            , Nav.pushUrl (Session.navKey global.session) (Url.toString url)
            )

        ( ClickedLink (Browser.External href), _ ) ->
            ( model
            , Nav.load href
            )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( GotNotFoundMsg subMsg, NotFound subModel ) ->
            NotFound.update subMsg subModel
                |> updateWith NotFound GotNotFoundMsg

        ( GotNotFoundMsg _, _ ) ->
            ( model, Cmd.none )

        ( GotHomeMsg subMsg, Home subModel ) ->
            Home.update subMsg subModel
                |> updateWith Home GotHomeMsg

        ( GotHomeMsg _, _ ) ->
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Redirect _ ->
            Sub.none

        NotFound _ ->
            Sub.none

        Home subModel ->
            Home.subscriptions subModel
                |> Sub.map GotHomeMsg



-- VIEW


view : Model -> Document Msg
view model =
    case model of
        Redirect subModel ->
            viewPage (\_ -> NoOp) (Redirect.view subModel)

        NotFound subModel ->
            viewPage (\_ -> NoOp) (NotFound.view subModel)

        Home homeModel ->
            viewPage GotHomeMsg (Home.view homeModel)


viewPage : (msg -> Msg) -> Page msg -> Document Msg
viewPage toMsg { title, content, device } =
    Page.view
        { title = title
        , content = Html.map toMsg content
        , device = device
        }



-- PROGRAM


main : Program Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }
