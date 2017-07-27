module Views.Detail exposing (view)

import Date exposing (Date)
import Date.Extra.Config.Config_en_us exposing (config)
import Date.Extra.Format as DateFormat
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Model exposing (Msg)
import Project exposing (Commit, Contributor, Event, Issue, Project)


view : Maybe Project -> Int -> Html Msg
view maybeProject activeIndex =
    Maybe.map (detailView activeIndex) maybeProject
        |> Maybe.withDefault (Html.text "")


detailView : Int -> Project -> Html Msg
detailView activeIndex project =
    Html.div [ Attrs.class "row" ]
        [ Html.div [ Attrs.class "col-lg-9" ]
            [ Html.div
                [ Attrs.class "wrapper"
                , Attrs.class "wrapper-content"
                ]
                [ Html.div [ Attrs.class "ibox" ]
                    [ Html.div [ Attrs.class "ibox-content" ]
                        [ Html.div [ Attrs.class "row" ]
                            [ Html.div [ Attrs.class "col-lg-12" ]
                                [ Html.div [ Attrs.class "m-b-md" ]
                                    [ Html.h2 []
                                        [ Html.text project.fullName ]
                                    ]
                                , Html.dl [ Attrs.class "dl-horizontal" ]
                                    [ Html.dt [] [ Html.text "Language:" ]
                                    , Html.dd []
                                        [ Html.span
                                            [ Attrs.class "label"
                                            , Attrs.class "label-primary"
                                            ]
                                            [ project.language
                                                |> Maybe.withDefault ""
                                                |> Html.text
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        , Html.div [ Attrs.class "row" ]
                            [ Html.div [ Attrs.class "col-lg-5" ]
                                [ Html.dl [ Attrs.class "dl-horizontal" ]
                                    [ Html.dt [] [ Html.text "ID:" ]
                                    , Html.dd []
                                        [ project.id
                                            |> toString
                                            |> Html.text
                                        ]
                                    , Html.dt [] [ Html.text "Created by:" ]
                                    , Html.dd []
                                        [ project.owner
                                            |> Maybe.map .login
                                            |> Maybe.withDefault ""
                                            |> Html.text
                                        ]
                                    , Html.dt [] [ Html.text "Default Branch:" ]
                                    , Html.dd []
                                        [ Html.text project.defaultBranch ]
                                    , Html.dt [] [ Html.text "Size:" ]
                                    , Html.dd []
                                        [ project.size
                                            |> toString
                                            |> Html.text
                                        ]
                                    ]
                                ]
                            , Html.div
                                [ Attrs.class "col-lg-7"
                                , Attrs.id "cluster_info"
                                ]
                                [ Html.dl [ Attrs.class "dl-horizontal" ]
                                    [ Html.dt [] [ Html.text "Created:" ]
                                    , Html.dd []
                                        [ project.createdAt
                                            |> formatDate
                                            |> Html.text
                                        ]
                                    , Html.dt [] [ Html.text "Last Updated:" ]
                                    , Html.dd []
                                        [ project.updatedAt
                                            |> formatDate
                                            |> Html.text
                                        ]
                                    , Html.dt [] [ Html.text "Last Pushed:" ]
                                    , Html.dd []
                                        [ project.pushedAt
                                            |> formatDate
                                            |> Html.text
                                        ]
                                    , Html.dt [] [ Html.text "Contributors:" ]
                                    , project.contributors
                                        |> List.map contributorView
                                        |> Html.dd
                                            [ Attrs.class "project-people" ]
                                    ]
                                ]
                            ]
                        , Html.div
                            [ Attrs.class "row"
                            , Attrs.class "m-t-sm"
                            ]
                            [ Html.div [ Attrs.class "col-lg-12" ]
                                [ panel activeIndex project ]
                            ]
                        ]
                    ]
                ]
            ]
        , Html.div [ Attrs.class "col-lg-3" ]
            [ Html.div
                [ Attrs.class "wrapper"
                , Attrs.class "wrapper-content"
                , Attrs.class "project-manager"
                ]
                [ Html.h4 [] [ Html.text "Project description" ]
                , Html.p [ Attrs.class "small" ]
                    [ Maybe.withDefault "" project.description
                        |> Html.text
                    ]
                , Html.p
                    [ Attrs.class "small"
                    , Attrs.class "font-bold"
                    ]
                    []
                , Html.h5 [] [ Html.text "Project Labels" ]
                , List.map labelView project.labels
                    |> Html.ul
                        [ Attrs.class "tag-list"
                        , Attrs.style [ ( "padding", "0" ) ]
                        ]
                ]
            ]
        ]


contributorView : Contributor -> Html msg
contributorView contributor =
    Html.a
        [ Attrs.href contributor.htmlUrl
        , Attrs.target "_blank"
        ]
        [ Html.img
            [ Attrs.title contributor.login
            , Attrs.class "img-circle"
            , Attrs.src contributor.avatarUrl
            ]
            []
        ]


labelView : String -> Html msg
labelView label =
    Html.li []
        [ Html.button
            [ Attrs.class "btn"
            , Attrs.class "btn-sm"
            , Attrs.class "btn-default"
            ]
            [ Html.i
                [ Attrs.class "fa"
                , Attrs.class "fa-tag"
                ]
                []
            , Html.text (" " ++ label)
            ]
        ]


panel : Int -> Project -> Html Msg
panel activeIndex project =
    Html.div
        [ Attrs.class "panel"
        , Attrs.class "blank-panel"
        ]
        [ Html.div [ Attrs.class "panel-heading" ]
            [ Html.div [ Attrs.class "panel-options" ]
                [ [ "Events", "Issues", "Commits" ]
                    |> List.indexedMap (navTab activeIndex)
                    |> Html.ul
                        [ Attrs.class "nav"
                        , Attrs.class "nav-tabs"
                        ]
                ]
            ]
        , Html.div [ Attrs.class "panel-body" ]
            [ [ [ Html.thead []
                    [ tableHeader [ "ID", "TYPE", "ACTOR", "DATE" ] ]
                , project.events
                    |> List.map eventView
                    |> Html.tbody []
                ]
              , [ Html.thead []
                    [ tableHeader [ "ID", "STATE", "TITLE", "CREATED" ] ]
                , project.issues
                    |> List.map issueView
                    |> Html.tbody []
                ]
              , [ Html.thead []
                    [ tableHeader [ "SHA", "AUTHOR", "MESSAGE" ] ]
                , project.commits
                    |> List.map commitView
                    |> Html.tbody []
                ]
              ]
                |> List.indexedMap (tabPane activeIndex)
                |> Html.div [ Attrs.class "tab-content" ]
            ]
        ]


navTab : Int -> Int -> String -> Html Msg
navTab activeIndex thisIndex tabText =
    Html.li
        [ Attrs.classList [ ( "active", activeIndex == thisIndex ) ] ]
        [ Html.a
            [ Model.SetTab thisIndex
                |> Events.onClick
            ]
            [ Html.text tabText ]
        ]


tabPane : Int -> Int -> List (Html msg) -> Html msg
tabPane activeIndex thisIndex tableContent =
    Html.div
        [ Attrs.class "tab-pane"
        , Attrs.classList [ ( "active", activeIndex == thisIndex ) ]
        ]
        [ Html.table
            [ Attrs.class "table"
            , Attrs.class "table-striped"
            ]
            tableContent
        ]


tableHeader : List String -> Html msg
tableHeader =
    List.map (\title -> Html.th [] [ Html.text title ])
        >> Html.tr []


eventView : Event -> Html msg
eventView event =
    Html.tr []
        [ Html.td []
            [ toString event.id
                |> Html.text
            ]
        , Html.td [] [ Html.text event.type_ ]
        , Html.td [] [ Html.text event.actor ]
        , Html.td []
            [ formatDate event.createdAt
                |> Html.text
            ]
        ]


issueView : Issue -> Html msg
issueView issue =
    Html.tr []
        [ Html.td []
            [ toString issue.id
                |> Html.text
            ]
        , Html.td [] [ Html.text issue.state ]
        , Html.td []
            [ Html.a
                [ Attrs.href issue.htmlUrl
                , Attrs.target "_blank"
                ]
                [ Html.text issue.title ]
            ]
        , Html.td []
            [ formatDate issue.createdAt
                |> Html.text
            ]
        ]


commitView : Commit -> Html msg
commitView commit =
    Html.tr []
        [ Html.td []
            [ Html.a
                [ Attrs.href commit.htmlUrl
                , Attrs.target "_blank"
                ]
                [ String.left 10 commit.sha
                    |> Html.text
                ]
            ]
        , Html.td []
            [ Html.a
                [ Attrs.href commit.author.htmlUrl
                , Attrs.target "_blank"
                ]
                [ Html.text commit.author.name ]
            ]
        , Html.td []
            [ Html.text commit.message
            , Html.a
                [ Attrs.href commit.htmlUrl
                , Attrs.target "_blank"
                ]
                [ Maybe.withDefault "" commit.title
                    |> Html.text
                ]
            ]
        ]


formatDate : Date -> String
formatDate =
    DateFormat.format config "%b %d, %Y %I:%M:%S %p"
