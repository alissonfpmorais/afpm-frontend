module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Flags
import Flags.Window exposing (Window)
import Html
import Json.Decode as Decode
import Page exposing (Page)
import Page.Home as Home exposing (Model, Msg)
import Page.NotFound as NotFound
import Page.Redirect as Redirect
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)



-- MODEL


type alias Model =
    { window : Window
    , pageModel : PageModel
    }


type PageModel
    = Redirect Session
    | NotFound Session
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

        session =
            Session.guest navKey flags

        model =
            { window = flags.window
            , pageModel = Redirect session
            }
    in
    changeRouteTo (Route.fromUrl url) model



-- UPDATE


type Msg
    = NoOp
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotHomeMsg Home.Msg


toSession : PageModel -> Session
toSession pageModel =
    case pageModel of
        Redirect session ->
            session

        NotFound session ->
            session

        Home subModel ->
            Home.toSession subModel


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model.pageModel
    in
    case maybeRoute of
        Nothing ->
            ( { model | pageModel = NotFound session }
            , Cmd.none
            )

        Just Route.NotFound ->
            ( { model | pageModel = NotFound session }
            , Cmd.none
            )

        Just Route.Home ->
            Home.init session
                |> updateWith Home GotHomeMsg model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.pageModel ) of
        ( NoOp, _ ) ->
            ( model, Cmd.none )

        ( ClickedLink (Browser.Internal url), _ ) ->
            let
                navKey =
                    model.pageModel
                        |> toSession
                        |> Session.navKey
            in
            ( model
            , Nav.pushUrl navKey (Url.toString url)
            )

        ( ClickedLink (Browser.External href), _ ) ->
            ( model
            , Nav.load href
            )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( GotHomeMsg subMsg, Home subModel ) ->
            Home.update subMsg subModel
                |> updateWith Home GotHomeMsg model

        ( GotHomeMsg _, _ ) ->
            ( model, Cmd.none )


updateWith : (subModel -> PageModel) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toPageModel toMsg model ( subModel, subCmd ) =
    ( { model | pageModel = toPageModel subModel }
    , Cmd.map toMsg subCmd
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.pageModel of
        Redirect _ ->
            Sub.none

        NotFound _ ->
            Sub.none

        Home subModel ->
            Home.subscriptions subModel
                |> Sub.map GotHomeMsg



-- VIEW


view : Model -> Document Msg
view { pageModel } =
    case pageModel of
        Redirect _ ->
            viewPage (\_ -> NoOp) Redirect.view

        NotFound _ ->
            viewPage (\_ -> NoOp) NotFound.view

        Home homeModel ->
            viewPage GotHomeMsg (Home.view homeModel)


viewPage : (msg -> Msg) -> Page msg -> Document Msg
viewPage toMsg { title, content } =
    Page.view
        { title = title
        , content = Html.map toMsg content
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
