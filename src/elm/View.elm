module View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Model exposing (Model, Msg, Page)
import Project exposing (Projects)
import Routing
import Views.Detail as DetailView
import Views.Main as MainView


view : Model -> Html Msg
view model =
    Html.div [ Attrs.id "wrapper" ]
        [ navbar
        , wrapper model.page model.projectList
        ]


navbar : Html Msg
navbar =
    Html.nav
        [ Attrs.attribute "role" "navigation"
        , Attrs.class "navbar-default"
        , Attrs.class "navbar-static-side"
        ]
        [ Html.div [ Attrs.class "sidebar-collapse" ] [ sidemenu ] ]


sidemenu : Html Msg
sidemenu =
    Html.ul
        [ Attrs.class "nav"
        , Attrs.class "metismenu"
        , Attrs.id "side-menu"
        ]
        [ Html.li [ Attrs.class "nav-header" ]
            [ Html.div
                [ Attrs.class "dropdown"
                , Attrs.class "profile-element"
                ]
                [ Html.a
                    [ Attrs.attribute "data-toggle" "dropdown"
                    , Attrs.class "dropdown-toggle"
                    , Model.Navigate Routing.HomeRoute
                        |> Events.onClick
                    ]
                    [ Html.span [ Attrs.class "clear" ]
                        [ Html.span
                            [ Attrs.class "block"
                            , Attrs.class "m-t-xs"
                            ]
                            [ Html.strong
                                [ Attrs.class "font-bold" ]
                                [ Html.text "GitHub Trends" ]
                            ]
                        , Html.span
                            [ Attrs.class "text-muted"
                            , Attrs.class "text-xs"
                            , Attrs.class "block"
                            ]
                            [ Html.text "Most Popular by Week" ]
                        ]
                    ]
                , Html.ul
                    [ Attrs.class "dropdown-menu"
                    , Attrs.class "m-t-xs"
                    ]
                    [ Html.li []
                        [ Html.a
                            [ Model.Navigate Routing.HomeRoute
                                |> Events.onClick
                            ]
                            [ Html.text "Logout" ]
                        ]
                    ]
                ]
            , Html.div [ Attrs.class "logo-element" ] [ Html.text "IN+" ]
            ]
        , Html.li [ Attrs.class "active" ]
            [ Html.a
                [ Model.Navigate Routing.HomeRoute
                    |> Events.onClick
                ]
                [ Html.i [ Attrs.class "fa", Attrs.class "fa-th-large" ] []
                , Html.text " "
                , Html.span [ Attrs.class "nav-label" ]
                    [ Html.text "GitHub Trend" ]
                ]
            ]
        ]


wrapper : Page -> Projects -> Html Msg
wrapper page projects =
    Html.div
        [ Attrs.id "page-wrapper"
        , Attrs.class "gray-bg"
        ]
        [ Html.div
            [ Attrs.class "row"
            , Attrs.class "border-bottom"
            ]
            [ Html.nav
                [ Attrs.attribute "role" "navigation"
                , Attrs.class "navbar"
                , Attrs.class "navbar-static-top"
                , Attrs.class "white-bg"
                , Attrs.style [ ( "margin-bottom", "0" ) ]
                ]
                [ Html.div [ Attrs.class "navbar-header" ] [] ]
            ]
        , Html.div
            [ Attrs.class "wrapper"
            , Attrs.class "wrapper-content"
            ]
            [ mainContent page projects ]
        ]


mainContent : Page -> Projects -> Html Msg
mainContent page projects =
    case page of
        Model.ListPage ->
            MainView.view projects

        Model.DetailPage maybeProject activeIndex ->
            DetailView.view maybeProject activeIndex
