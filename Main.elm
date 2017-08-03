module Main exposing (..)

import Html exposing (..)
import Random
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time, every, millisecond)


fieldWidth : Float
fieldWidth =
    500


fieldHeight : Float
fieldHeight =
    500


minDistance : Float
minDistance =
    10


maxDistance : Float
maxDistance =
    25


numBirds : Int
numBirds =
    50


type alias Bird =
    { x : Float
    , y : Float
    , dx : Float
    , dy : Float
    , speed : Float
    }


type alias Model =
    List Bird


type Msg
    = InitBirds (List Bird)
    | Move Time
    | NoOp


generateBirds : Random.Generator (List Bird)
generateBirds =
    Random.list numBirds <|
        Random.map5
            floatsToBird
            (Random.float 10 (fieldWidth - 10))
            (Random.float 10 (fieldHeight - 10))
            (Random.float -1 1)
            (Random.float -1 1)
            (Random.float 0.5 3)


normalize : Float -> Float -> ( Float, Float )
normalize dx dy =
    let
        magnitude =
            sqrt <| dx ^ 2 + dy ^ 2
    in
        if magnitude == 0 then
            ( 0, 0 )
        else
            ( dx / magnitude, dy / magnitude )


floatsToBird : Float -> Float -> Float -> Float -> Float -> Bird
floatsToBird x y dx dy speed =
    let
        ( newDx, newDy ) =
            normalize dx dy
    in
        { x = x
        , y = y
        , dx = newDx
        , dy = newDy
        , speed = speed
        }


init : ( Model, Cmd Msg )
init =
    ( [], Random.generate InitBirds generateBirds )


subscriptions : Model -> Sub Msg
subscriptions model =
    every millisecond Move


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitBirds birds ->
            ( birds, Cmd.none )

        Move _ ->
            ( List.map (moveBird model) model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


moveBird : List Bird -> Bird -> Bird
moveBird birds bird =
    let
        ( closestBird, closestDistance ) =
            List.map (distance bird) birds
                |> List.sortBy Tuple.second
                |> List.drop 1
                |> List.head
                |> Maybe.withDefault ( bird, 0 )
    in
        if closestDistance < minDistance then
            moveAway bird closestBird |> continue
        else if closestDistance > maxDistance then
            moveTowards bird closestBird |> continue
        else if bird.x <= 10 || bird.x >= fieldWidth - 10 then
            bounceX bird |> continue
        else if bird.y <= 10 || bird.y >= fieldHeight - 10 then
            bounceY bird |> continue
        else
            moveAlong bird closestBird |> continue


continue : Bird -> Bird
continue bird =
    let
        newX =
            bird.x + (bird.dx * bird.speed)

        newY =
            bird.y + (bird.dy * bird.speed)
    in
        { bird
            | x = clamp 10 (fieldWidth - 10) newX
            , y = clamp 10 (fieldHeight - 10) newY
        }


bounceX : Bird -> Bird
bounceX bird =
    { bird | dx = bird.dx * -1 }


bounceY : Bird -> Bird
bounceY bird =
    { bird | dy = bird.dy * -1 }


distance : Bird -> Bird -> ( Bird, Float )
distance bird1 bird2 =
    let
        distance =
            sqrt <| (bird1.x - bird2.x) ^ 2 + (bird1.y - bird2.y) ^ 2
    in
        ( bird2, distance )


moveAway : Bird -> Bird -> Bird
moveAway bird1 bird2 =
    let
        ( newDx, newDy ) =
            normalize (bird1.x - bird2.x) (bird1.y - bird2.y)
    in
        { bird1 | dx = newDx, dy = newDy }


moveTowards : Bird -> Bird -> Bird
moveTowards bird1 bird2 =
    let
        ( newDx, newDy ) =
            normalize (bird2.x - bird1.x) (bird2.y - bird1.y)
    in
        { bird1 | dx = newDx, dy = newDy }


moveAlong : Bird -> Bird -> Bird
moveAlong bird1 bird2 =
    { bird1 | dx = bird2.dx, dy = bird2.dy, speed = bird2.speed }


view model =
    svg [ width <| toString fieldWidth, height <| toString fieldHeight ]
        (List.map renderBird model)


renderBird : Bird -> Svg Msg
renderBird bird =
    circle [ cx <| toString bird.x, cy <| toString bird.y, r "5" ] []


main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
