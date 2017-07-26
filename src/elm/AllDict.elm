module AllDict exposing (AllDict, empty, insert, get, fromList)

import Dict exposing (Dict)


type AllDict a
    = AllDict (a -> String) (Dict String a)


empty : (a -> String) -> AllDict a
empty keygen =
    AllDict keygen Dict.empty


insert : AllDict a -> a -> AllDict a
insert (AllDict keygen dict) value =
    Dict.insert (keygen value) value dict
        |> AllDict keygen


get : AllDict a -> String -> Maybe a
get (AllDict _ dict) key =
    Dict.get key dict


fromList : AllDict a -> List a -> AllDict a
fromList (AllDict keygen _) =
    List.map (\value -> ( keygen value, value ))
        >> Dict.fromList
        >> AllDict keygen
