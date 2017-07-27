module Routing exposing (Route(DetailRoute, HomeRoute), fromLocation, modifyUrl)

import Navigation exposing (Location)
import UrlParser exposing ((</>), Parser)


type Route
    = HomeRoute
    | DetailRoute String


route : Parser (Route -> a) a
route =
    UrlParser.map toDetailRoute (UrlParser.string </> UrlParser.string)


toDetailRoute : String -> String -> Route
toDetailRoute user repo =
    DetailRoute (user ++ "/" ++ repo)


routeToString : Route -> String
routeToString =
    (\route ->
        case route of
            HomeRoute ->
                []

            DetailRoute name ->
                [ name ]
    )
        >> String.join "/"
        >> String.append "#/"


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.newUrl


fromLocation : Location -> Route
fromLocation =
    UrlParser.parseHash route
        >> Maybe.withDefault HomeRoute
