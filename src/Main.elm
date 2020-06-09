module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Flags
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


type Model
    = Redirect Session
    | NotFound Session
    | Home Home.Model


init : Decode.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        session =
            case Decode.decodeValue Flags.decode flags of
                Ok response ->
                    Session.guest navKey response

                Err _ ->
                    Session.guest navKey Flags.default
    in
    changeRouteTo (Route.fromUrl url) (Redirect session)



-- UPDATE


type Msg
    = NoOp
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotHomeMsg Home.Msg


toSession : Model -> Session
toSession model =
    case model of
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
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.NotFound ->
            ( NotFound session, Cmd.none )

        Just Route.Home ->
            Home.init session
                |> updateWith Home GotHomeMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( NoOp, _ ) ->
            ( model, Cmd.none )

        ( ClickedLink (Browser.Internal url), _ ) ->
            ( model
            , Nav.pushUrl (Session.navKey (toSession model)) (Url.toString url)
            )

        ( ClickedLink (Browser.External href), _ ) ->
            ( model
            , Nav.load href
            )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

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
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    case model of
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
