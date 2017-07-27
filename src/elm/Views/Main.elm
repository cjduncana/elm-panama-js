module Views.Main exposing (view)

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Model exposing (Model, Msg)
import Project exposing (Owner, Project, Projects)
import Routing


view : Projects -> Html Msg
view projects =
    divideByThree projects
        |> List.map row
        |> Html.div []


row : List (Maybe Project) -> Html Msg
row =
    List.map cell
        >> Html.div [ Attrs.class "row" ]


cell : Maybe Project -> Html Msg
cell =
    Maybe.map ibox
        >> Maybe.withDefault (Html.text "")
        >> flip (::) []
        >> Html.div [ Attrs.class "col-lg-4" ]


ibox : Project -> Html Msg
ibox project =
    Html.div [ Attrs.class "ibox" ]
        [ iboxTitle project.language project.fullName
        , iboxContent project
        ]


iboxTitle : Maybe String -> String -> Html Msg
iboxTitle language fullName =
    Html.div [ Attrs.class "ibox-title" ]
        [ Html.span
            [ Attrs.class "label"
            , Attrs.class "label-primary"
            , Attrs.class "pull-right"
            ]
            [ Maybe.withDefault "" language
                |> Html.text
            ]
        , Html.h5 []
            [ Html.a
                [ Routing.DetailRoute fullName
                    |> Model.Navigate
                    |> Events.onClick
                ]
                [ Html.text fullName ]
            ]
        ]


iboxContent : Project -> Html Msg
iboxContent project =
    Html.div [ Attrs.class "ibox-content" ]
        [ ownerView project.owner
        , Html.h4 []
            [ "Info about "
                ++ project.name
                |> Html.text
            ]
        , Html.p []
            [ Maybe.withDefault "" project.description
                |> Html.text
            ]
        , [ ( "ISSUES", project.openIssuesCount, False )
          , ( "FORKS", project.forks, False )
          , ( "WATCHERS", project.watchers, False )
          , ( "STARS", project.stargazersCount, True )
          ]
            |> List.map
                (\( title, count, right ) ->
                    Html.div
                        [ Attrs.classList
                            [ ( "col-sm-3", True )
                            , ( "text-right", right )
                            ]
                        ]
                        [ Html.div
                            [ Attrs.class "font-bold" ]
                            [ Html.text title ]
                        , toString count
                            |> Html.text
                        ]
                )
            |> Html.div
                [ Attrs.class "row"
                , Attrs.class "m-t-sm"
                ]
        ]


ownerView : Maybe Owner -> Html Msg
ownerView =
    Maybe.map
        (\owner ->
            Html.div [ Attrs.class "team-members" ]
                [ Html.a
                    [ Attrs.href owner.htmlUrl ]
                    [ Html.img
                        [ Attrs.alt "member"
                        , Attrs.class "img-circle"
                        , Attrs.src owner.avatarUrl
                        ]
                        []
                    ]
                ]
        )
        >> Maybe.withDefault (Html.text "")


divideByThree : List a -> List (List (Maybe a))
divideByThree list =
    case list of
        first_ :: second_ :: third_ :: rest_ ->
            [ Just first_, Just second_, Just third_ ] :: divideByThree rest_

        first_ :: second_ :: [] ->
            [ [ Just first_, Just second_, Nothing ] ]

        first_ :: [] ->
            [ [ Just first_, Nothing, Nothing ] ]

        [] ->
            [ [ Nothing, Nothing, Nothing ] ]
