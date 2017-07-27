module Model
    exposing
        ( Flags
        , Model
        , Msg
            ( GoToDetailPage
            , GoToListPage
            , Navigate
            , ProjectsRecieved
            , SetTab
            , UpdatedProjectRecieved
            )
        , Page(ListPage, DetailPage)
        , addProjectToDetailPage
        , init
        , getProjects
        , setTabInDetailPage
        )

import AllDict exposing (AllDict)
import Date
import Http exposing (Error)
import Navigation exposing (Location)
import Project exposing (Project, Projects)
import Routing exposing (Route)
import Task exposing (Task)


init : Flags -> Location -> ( Model, Cmd Msg )
init { token } location =
    case Routing.fromLocation location of
        Routing.HomeRoute ->
            ( { token = token
              , projects = AllDict.empty .fullName
              , projectList = []
              , page = ListPage
              }
            , getProjects token
            )

        Routing.DetailRoute fullName ->
            ( { token = token
              , projects = AllDict.empty .fullName
              , projectList = []
              , page = DetailPage Nothing 0
              }
            , getProject fullName token
            )


type alias Flags =
    { token : String }


type alias Model =
    { token : String
    , projects : AllDict Project
    , projectList : Projects
    , page : Page
    }


type Msg
    = ProjectsRecieved (Result Error Projects)
    | UpdatedProjectRecieved (Result Error Project)
    | Navigate Route
    | GoToListPage
    | GoToDetailPage String
    | SetTab Int


type Page
    = ListPage
    | DetailPage (Maybe Project) Int


getProjects : String -> Cmd Msg
getProjects token =
    Date.now
        |> Task.andThen (Project.listProjectsTask token)
        |> Task.attempt ProjectsRecieved


getProject : String -> String -> Cmd Msg
getProject fullName token =
    Project.getProject fullName token
        |> Task.andThen (Project.updateProjectTask token)
        |> Task.attempt UpdatedProjectRecieved


addProjectToDetailPage : Page -> Project -> Page
addProjectToDetailPage page project =
    case page of
        ListPage ->
            ListPage

        DetailPage _ activeIndex ->
            DetailPage (Just project) activeIndex


setTabInDetailPage : Page -> Int -> Page
setTabInDetailPage page activeIndex =
    case page of
        ListPage ->
            ListPage

        DetailPage project _ ->
            DetailPage project activeIndex
