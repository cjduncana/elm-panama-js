module Main exposing (main)

import AllDict
import Model exposing (Flags, Model, Msg)
import Navigation exposing (Location)
import Project exposing (Project)
import Routing
import Task
import View


main : Program Flags Model Msg
main =
    Navigation.programWithFlags onLocationChange
        { init = Model.init
        , update = update
        , subscriptions = always Sub.none
        , view = View.view
        }


onLocationChange : Location -> Msg
onLocationChange location =
    case Routing.fromLocation location of
        Routing.HomeRoute ->
            Model.GoToListPage

        Routing.DetailRoute fullName ->
            Model.GoToDetailPage fullName


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Model.ProjectsRecieved projectsResult ->
            ( Result.withDefault [] projectsResult, Cmd.none )
                |> Tuple.mapFirst
                    (\projects ->
                        { model
                            | projects =
                                AllDict.fromList
                                    model.projects
                                    projects
                            , projectList = projects
                        }
                    )

        Model.UpdatedProjectRecieved updatedProject ->
            ( Result.toMaybe updatedProject, Cmd.none )
                |> Tuple.mapFirst
                    (Maybe.map
                        (\project ->
                            { model
                                | projects =
                                    AllDict.insert model.projects project
                                , page =
                                    Model.addProjectToDetailPage
                                        model.page
                                        project
                            }
                        )
                        >> Maybe.withDefault model
                    )

        Model.Navigate route ->
            ( model, Routing.modifyUrl route )

        Model.GoToListPage ->
            ( { model | page = Model.ListPage }
            , Model.getProjects model.token
            )

        Model.GoToDetailPage fullName ->
            AllDict.get model.projects fullName
                |> \maybeProject ->
                    ( { model | page = Model.DetailPage maybeProject 0 }
                    , Maybe.map (updateProjectCmd model.token) maybeProject
                        |> Maybe.withDefault Cmd.none
                    )

        Model.SetTab activeIndex ->
            ( { model | page = Model.setTabInDetailPage model.page activeIndex }
            , Cmd.none
            )


updateProjectCmd : String -> Project -> Cmd Msg
updateProjectCmd token =
    Project.updateProjectTask token
        >> Task.attempt Model.UpdatedProjectRecieved
