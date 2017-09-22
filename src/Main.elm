module Main exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onWithOptions)
import Json.Decode as Json
import Mouse
import Styles.Styles as Styles
import Time exposing (Time)
import WebAudio exposing (AudioContext(DefaultContext), OscillatorNode, OscillatorWaveType(..), connectNodes, createOscillatorNode, getDestinationNode, setValue, startOscillator, stopOscillator, tapNode)


-- MAIN


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { pickedTonic : Maybe Tonic
    , pickedRoot : Maybe Root
    , pickedChord : ChordType
    , is1Open : Bool
    , is2Open : Bool
    }


type alias Tonic =
    String


type alias Root =
    String


type alias Position =
    Float


tonicPosition : Dict Tonic Float
tonicPosition =
    Dict.fromList
        [ ( "A", 0 )
        , ( "A#/Bb", 1 )
        , ( "B", 2 )
        , ( "C", 3 )
        , ( "C#/Db", 4 )
        , ( "D", 5 )
        , ( "D#/Eb", 6 )
        , ( "E", 7 )
        , ( "F", 8 )
        , ( "F#/Gb", 9 )
        , ( "G", 10 )
        , ( "G#/Ab", 11 )
        ]


tonics : List Tonic
tonics =
    Dict.keys tonicPosition


rootPosition : Dict Tonic Float
rootPosition =
    Dict.fromList
        [ ( "I", 0 )
        , ( "II", 2 )
        , ( "III", 4 )
        , ( "IV", 5 )
        , ( "V", 7 )
        , ( "VI", 9 )
        ]


roots : List Root
roots =
    Dict.keys rootPosition


frequency : Float -> Float
frequency note =
    220 * (2 ^ (note / 12))


third : Float -> Float
third note =
    frequency (note + 4)


minorthird : Float -> Float
minorthird note =
    frequency (note + 3)


fifth : Float -> Float
fifth note =
    frequency (note + 7)


dimfifth : Float -> Float
dimfifth note =
    frequency (note + 6)


sixth : Float -> Float
sixth note =
    frequency (note + 9)


seventh : Float -> Float
seventh note =
    frequency (note + 10)


init : ( Model, Cmd Msg )
init =
    { pickedTonic = Nothing
    , pickedRoot = Nothing
    , pickedChord = Major
    , is1Open = False
    , is2Open = False
    }
        ! []



-- UPDATE


type Msg
    = TonicPicked Tonic
    | RootPicked Root
    | ChordPicked ChordType
    | DropDown1Clicked
    | DropDown2Clicked
    | Blur
    | Play
    | PlayChord


type ChordType
    = Major
    | Minor
    | DominantSeventh
    | DimSeventh


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TonicPicked tonic ->
            { model
                | pickedTonic = Just tonic
                , is1Open = False
            }
                ! []

        RootPicked root ->
            { model
                | pickedRoot = Just root
                , is2Open = False
            }
                ! []

        ChordPicked chord ->
            { model
                | pickedChord = chord
            }
                ! []

        DropDown1Clicked ->
            { model | is1Open = not model.is1Open, is2Open = False } ! []

        DropDown2Clicked ->
            { model | is2Open = not model.is2Open, is1Open = False } ! []

        Blur ->
            { model | is1Open = False } ! []

        Play ->
            let
                tonicName =
                    Maybe.withDefault "A" model.pickedTonic

                rootName =
                    Maybe.withDefault "I" model.pickedRoot

                tonic =
                    Maybe.withDefault 0 (Dict.get tonicName tonicPosition)

                root =
                    tonic + Maybe.withDefault 0 (Dict.get rootName rootPosition)

                _ =
                    playNote (frequency root)
            in
            { model | is1Open = False }
                ! []

        PlayChord ->
            case model.pickedChord of
                Major ->
                    let
                        tonicName =
                            Maybe.withDefault "A" model.pickedTonic

                        rootName =
                            Maybe.withDefault "I" model.pickedRoot

                        tonic =
                            Maybe.withDefault 0 (Dict.get tonicName tonicPosition)

                        root =
                            tonic + Maybe.withDefault 0 (Dict.get rootName rootPosition)

                        _ =
                            playNote (frequency root)

                        _ =
                            playNote (third root)

                        _ =
                            playNote (fifth root)
                    in
                    { model | is1Open = False }
                        ! []

                Minor ->
                    let
                        tonicName =
                            Maybe.withDefault "A" model.pickedTonic

                        rootName =
                            Maybe.withDefault "I" model.pickedRoot

                        tonic =
                            Maybe.withDefault 0 (Dict.get tonicName tonicPosition)

                        root =
                            tonic + Maybe.withDefault 0 (Dict.get rootName rootPosition)

                        _ =
                            playNote (frequency root)

                        _ =
                            playNote (minorthird root)

                        _ =
                            playNote (fifth root)
                    in
                    { model | is1Open = False }
                        ! []

                DominantSeventh ->
                    let
                        tonicName =
                            Maybe.withDefault "A" model.pickedTonic

                        rootName =
                            Maybe.withDefault "I" model.pickedRoot

                        tonic =
                            Maybe.withDefault 0 (Dict.get tonicName tonicPosition)

                        root =
                            tonic + Maybe.withDefault 0 (Dict.get rootName rootPosition)

                        _ =
                            playNote (frequency root)

                        _ =
                            playNote (third root)

                        _ =
                            playNote (fifth root)

                        _ =
                            playNote (seventh root)
                    in
                    { model | is1Open = False }
                        ! []

                DimSeventh ->
                    let
                        tonicName =
                            Maybe.withDefault "A" model.pickedTonic

                        rootName =
                            Maybe.withDefault "I" model.pickedRoot

                        tonic =
                            Maybe.withDefault 0 (Dict.get tonicName tonicPosition)

                        root =
                            tonic + Maybe.withDefault 0 (Dict.get rootName rootPosition)

                        _ =
                            playNote (frequency root)

                        _ =
                            playNote (minorthird root)

                        _ =
                            playNote (dimfifth root)

                        _ =
                            playNote (sixth root)
                    in
                    { model | is1Open = False }
                        ! []


playNote : Float -> ()
playNote frequency =
    createOscillatorNode DefaultContext Sine
        |> tapNode .frequency (\freq -> setValue frequency freq)
        |> connectNodes (getDestinationNode DefaultContext) 0 0
        |> startOscillator 0.0
        |> stopOscillator 3.0



-- VIEW


view : Model -> Html Msg
view model =
    let
        selectedText1 =
            model.pickedTonic
                |> Maybe.withDefault "-- pick a key --"

        selectedText2 =
            model.pickedRoot
                |> Maybe.withDefault "-- pick a root --"

        displayStyle1 =
            if model.is1Open then
                ( "display", "block" )
            else
                ( "display", "none" )

        displayStyle2 =
            if model.is2Open then
                ( "display", "block" )
            else
                ( "display", "none" )
    in
    div []
        [ div [ style Styles.text ] [ text "// REFRESH TO PLAY NEW CHORD //" ]
        , div [ style Styles.text ] [ text "Pick a key and a chord in the key. For example, you can pick the key 'A' and the third chord 'III' in the key, which is an 'E' chord." ]
        , div
            [ style Styles.dropdownContainer ]
            [ p
                [ style Styles.dropdownInput
                , onClick DropDown1Clicked
                ]
                [ span [ style Styles.dropdownText ] [ text <| selectedText1 ]
                , span [] [ text " ▾" ]
                ]
            , ul
                [ style <| displayStyle1 :: Styles.dropdownList ]
                (List.map viewTonic tonics)
            ]
        , div
            [ style Styles.dropdownContainer ]
            [ p
                [ style Styles.dropdownInput
                , onClick DropDown2Clicked
                ]
                [ span [ style Styles.dropdownText ] [ text <| selectedText2 ]
                , span [] [ text " ▾" ]
                ]
            , ul
                [ style <| displayStyle2 :: Styles.dropdownList ]
                (List.map viewRoot roots)
            ]
        , div []
            [ button [ style Styles.button, onClick Play ] [ text "Play the root" ]
            ]
        , div [ style Styles.text ] [ text "Use these buttons to change the kind of chord you're playing. Do you hear a difference?" ]
        , div [ style Styles.text ]
            [ fieldset [ style Styles.fieldset ]
                [ label [ style Styles.text ]
                    [ input [ type_ "radio", name "chord", onClick <| ChordPicked Major ] []
                    , text "Major"
                    ]
                , label [ style Styles.text ]
                    [ input [ type_ "radio", name "chord", onClick <| ChordPicked Minor ] []
                    , text "Minor"
                    ]
                , label [ style Styles.text ]
                    [ input [ type_ "radio", name "chord", onClick <| ChordPicked DominantSeventh ] []
                    , text "Dominant Seventh"
                    ]
                , label [ style Styles.text ]
                    [ input [ type_ "radio", name "chord", onClick <| ChordPicked DimSeventh ] []
                    , text "Diminished Seventh"
                    ]
                ]
            ]
        , div []
            [ button [ style Styles.button, onClick PlayChord ] [ text "Play the chord" ]
            ]
        ]


viewTonic : Tonic -> Html Msg
viewTonic tonic =
    li
        [ style Styles.dropdownListItem
        , onClick <| TonicPicked tonic
        ]
        [ text tonic ]


viewRoot : Root -> Html Msg
viewRoot root =
    li
        [ style Styles.dropdownListItem
        , onClick <| RootPicked root
        ]
        [ text root ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.is1Open then
        Mouse.clicks (always Blur)
    else if model.is2Open then
        Mouse.clicks (always Blur)
    else
        Sub.none



-- helper to cancel click anywhere


onClick : msg -> Attribute msg
onClick message =
    onWithOptions
        "click"
        { stopPropagation = True
        , preventDefault = False
        }
        (Json.succeed message)
