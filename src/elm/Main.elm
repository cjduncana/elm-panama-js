port module Main exposing (..)

import Date exposing (Date)
import Date.Extra.Config.Config_en_us exposing (config)
import Date.Extra.Duration as DateExtra exposing (Duration(Day))
import Date.Extra.Format as DateFormat
import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Task exposing (Task)


main : Program Flags Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd msg )
init { token } =
    ( token, Cmd.none )


type alias Flags =
    { token : String }


type alias Model =
    String


type alias Project =
    { language : Maybe String
    , fullName : String
    , owner : Maybe Owner
    , name : String
    , description : Maybe String
    , openIssuesCount : Int
    , forks : Int
    , watchers : Int
    , stargazersCount : Int
    }


type alias Projects =
    List Project


type alias Owner =
    { htmlUrl : String
    , avatarUrl : String
    }


type Msg
    = ListProjectsSub
    | ProjectsRecieved (Result Error Projects)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg token =
    case msg of
        ListProjectsSub ->
            ( token
            , Date.now
                |> Task.andThen (listProjectsTask token)
                |> Task.attempt ProjectsRecieved
            )

        ProjectsRecieved projects ->
            ( token
            , Result.withDefault [] projects
                |> List.map projectEncoder
                |> Encode.list
                |> sendProjects
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    getProjects (\_ -> ListProjectsSub)


port getProjects : (Value -> msg) -> Sub msg


port sendProjects : Value -> Cmd msg



-- Helper Functions


listProjectsTask : String -> Date -> Task Error Projects
listProjectsTask token date =
    let
        url =
            [ ( "q", "created:>" ++ sevenDaysAgo date )
            , ( "sort", "stars" )
            , ( "order", "desc" )
            , ( "access_token", token )
            ]
                |> List.map (\( key, value ) -> key ++ "=" ++ value)
                |> String.join "&"
                |> (++) "https://api.github.com/search/repositories?"
    in
        Decode.field "items" (Decode.list projectDecoder)
            |> Http.get url
            |> Http.toTask


sevenDaysAgo : Date -> String
sevenDaysAgo =
    DateExtra.add Day -7
        >> DateFormat.format config "%Y-%m-%d"


projectDecoder : Decoder Project
projectDecoder =
    Decode.decode Project
        |> Decode.optional "language" (Decode.nullable Decode.string) Nothing
        |> Decode.required "full_name" Decode.string
        |> Decode.optional "owner" (Decode.nullable ownerDecoder) Nothing
        |> Decode.required "name" Decode.string
        |> Decode.optional "description" (Decode.nullable Decode.string) Nothing
        |> Decode.required "open_issues_count" Decode.int
        |> Decode.required "forks" Decode.int
        |> Decode.required "watchers" Decode.int
        |> Decode.required "stargazers_count" Decode.int


projectEncoder : Project -> Value
projectEncoder project =
    Encode.object
        [ ( "language"
          , Maybe.map Encode.string project.language
                |> Maybe.withDefault Encode.null
          )
        , ( "full_name", Encode.string project.fullName )
        , ( "owner"
          , Maybe.map ownerEncoder project.owner
                |> Maybe.withDefault Encode.null
          )
        , ( "name", Encode.string project.name )
        , ( "description"
          , Maybe.map Encode.string project.description
                |> Maybe.withDefault Encode.null
          )
        , ( "open_issues_count", Encode.int project.openIssuesCount )
        , ( "forks", Encode.int project.forks )
        , ( "watchers", Encode.int project.watchers )
        , ( "stargazers_count", Encode.int project.stargazersCount )
        ]


ownerDecoder : Decoder Owner
ownerDecoder =
    Decode.decode Owner
        |> Decode.required "html_url" Decode.string
        |> Decode.required "avatar_url" Decode.string


ownerEncoder : Owner -> Value
ownerEncoder owner =
    Encode.object
        [ ( "html_url", Encode.string owner.htmlUrl )
        , ( "avatar_url", Encode.string owner.avatarUrl )
        ]
