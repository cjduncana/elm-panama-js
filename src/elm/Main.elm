port module Main exposing (main)

import AllDict exposing (AllDict)
import Date
import Http exposing (Error)
import Json.Decode as Decode exposing (Value)
import Json.Encode as Encode
import Project exposing (Project, Projects)
import Task


main : Program Flags Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = always subscriptions
        }


init : Flags -> ( Model, Cmd msg )
init { token } =
    ( { token = token, projects = AllDict.empty .fullName }, Cmd.none )


type alias Flags =
    { token : String }


type alias Model =
    { token : String
    , projects : AllDict Project
    }


type Msg
    = ListProjectsSub
    | ProjectsRecieved (Result Error Projects)
    | GetProjectSub (Maybe String)
    | UpdatedProjectRecieved (Result Error Project)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ListProjectsSub ->
            ( model
            , Date.now
                |> Task.andThen (Project.listProjectsTask model.token)
                |> Task.attempt ProjectsRecieved
            )

        ProjectsRecieved projectsResult ->
            Result.withDefault [] projectsResult
                |> \projects ->
                    ( { model
                        | projects = AllDict.fromList model.projects projects
                      }
                    , List.map Project.projectEncoder projects
                        |> Encode.list
                        |> sendProjects
                    )

        GetProjectSub repoName ->
            ( model
            , Maybe.andThen (AllDict.get model.projects) repoName
                |> Maybe.map (updateProjectCmd model.token)
                |> Maybe.withDefault Cmd.none
            )

        UpdatedProjectRecieved updatedProject ->
            Result.toMaybe updatedProject
                |> Maybe.map
                    (\project ->
                        ( { model
                            | projects = AllDict.insert model.projects project
                          }
                        , Project.projectEncoder project
                            |> sendProject
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ always ListProjectsSub
            |> getProjects
        , Decode.decodeValue Decode.string
            >> Result.toMaybe
            >> GetProjectSub
            |> getProject
        ]


port getProjects : (Value -> msg) -> Sub msg


port getProject : (Value -> msg) -> Sub msg


port sendProjects : Value -> Cmd msg


port sendProject : Value -> Cmd msg


updateProjectCmd : String -> Project -> Cmd Msg
updateProjectCmd token project =
    Task.map5
        (Project.updateProject project)
        (Project.listContributorsTask project.contributorsUrl token)
        (Project.listEventsTask project.eventsUrl token)
        (Project.listIssuesTask project.url token)
        (Project.listCommitsTask project.url token)
        (Project.listLabelsTask project.url token)
        |> Task.attempt UpdatedProjectRecieved
