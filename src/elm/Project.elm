module Project
    exposing
        ( Commit
        , Contributor
        , Event
        , Issue
        , Owner
        , Project
        , Projects
        , getProject
        , listProjectsTask
        , updateProjectTask
        )

import Date exposing (Date)
import Date.Extra.Config.Config_en_us exposing (config)
import Date.Extra.Duration as DateExtra
import Date.Extra.Format as DateFormat
import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Decode.Extra as Decode
import Json.Decode.Pipeline as Decode
import Task exposing (Task)


updateProject :
    Project
    -> Contributors
    -> Events
    -> Issues
    -> Commits
    -> Labels
    -> Project
updateProject project contributors events issues commits labels =
    { project
        | contributors = contributors
        , events = events
        , issues = issues
        , commits = commits
        , labels = labels
    }


listProjectsTask : String -> Date -> Task Error Projects
listProjectsTask token date =
    Decode.field "items" (Decode.list projectDecoder)
        |> Http.get
            ([ ( "q", "created:>" ++ sevenDaysAgo date )
             , ( "sort", "stars" )
             , ( "order", "desc" )
             , ( "access_token", token )
             ]
                |> List.map (\( key, value ) -> key ++ "=" ++ value)
                |> String.join "&"
                |> (++) "https://api.github.com/search/repositories?"
            )
        |> Http.toTask


getProject : String -> String -> Task Error Project
getProject fullName token =
    projectDecoder
        |> Http.get
            ("https://api.github.com/repos/"
                ++ fullName
                ++ "?access_token="
                ++ token
            )
        |> Http.toTask


listContributorsTask : String -> String -> Task Error Contributors
listContributorsTask contributorsUrl token =
    Decode.list contributorDecoder
        |> Http.get (contributorsUrl ++ "?access_token=" ++ token)
        |> Http.toTask


listEventsTask : String -> String -> Task Error Events
listEventsTask eventsUrl token =
    Decode.list eventDecoder
        |> Http.get (eventsUrl ++ "?access_token=" ++ token)
        |> Http.toTask


listIssuesTask : String -> String -> Task Error Issues
listIssuesTask url token =
    Decode.list issueDecoder
        |> Http.get (url ++ "/issues?access_token=" ++ token)
        |> Http.toTask


listCommitsTask : String -> String -> Task Error Commits
listCommitsTask url token =
    Decode.list commitDecoder
        |> Http.get (url ++ "/commits?access_token=" ++ token)
        |> Http.toTask


listLabelsTask : String -> String -> Task Error Labels
listLabelsTask url token =
    Decode.list (Decode.field "name" Decode.string)
        |> Http.get (url ++ "/labels?access_token=" ++ token)
        |> Http.toTask


updateProjectTask : String -> Project -> Task Error Project
updateProjectTask token project =
    Task.map5
        (updateProject project)
        (listContributorsTask project.contributorsUrl token)
        (listEventsTask project.eventsUrl token)
        (listIssuesTask project.url token)
        (listCommitsTask project.url token)
        (listLabelsTask project.url token)


sevenDaysAgo : Date -> String
sevenDaysAgo =
    DateExtra.add DateExtra.Day -7
        >> DateFormat.format config "%Y-%m-%d"


type alias Project =
    { id : Int
    , language : Maybe String
    , fullName : String
    , owner : Maybe Owner
    , name : String
    , description : Maybe String
    , openIssuesCount : Int
    , forks : Int
    , watchers : Int
    , stargazersCount : Int
    , defaultBranch : String
    , size : Int
    , createdAt : Date
    , updatedAt : Date
    , pushedAt : Date
    , url : String
    , contributorsUrl : String
    , contributors : Contributors
    , eventsUrl : String
    , events : Events
    , issues : Issues
    , commits : Commits
    , labels : Labels
    }


type alias Projects =
    List Project


type alias Owner =
    { htmlUrl : String
    , avatarUrl : String
    , login : String
    }


type alias Contributor =
    { htmlUrl : String
    , login : String
    , avatarUrl : String
    }


type alias Contributors =
    List Contributor


type alias Event =
    { id : Int
    , type_ : String
    , actor : String
    , createdAt : Date
    }


type alias Events =
    List Event


type alias Issue =
    { id : Int
    , state : String
    , htmlUrl : String
    , title : String
    , createdAt : Date
    }


type alias Issues =
    List Issue


type alias Commit =
    { htmlUrl : String
    , sha : String
    , author : Author
    , message : String
    , title : Maybe String
    }


type alias Commits =
    List Commit


type alias Author =
    { htmlUrl : String
    , name : String
    }


type alias Labels =
    List String



-- Helper Functions


projectDecoder : Decoder Project
projectDecoder =
    Decode.decode Project
        |> Decode.required "id" Decode.int
        |> Decode.optional "language" (Decode.nullable Decode.string) Nothing
        |> Decode.required "full_name" Decode.string
        |> Decode.optional "owner" (Decode.nullable ownerDecoder) Nothing
        |> Decode.required "name" Decode.string
        |> Decode.optional "description" (Decode.nullable Decode.string) Nothing
        |> Decode.required "open_issues_count" Decode.int
        |> Decode.required "forks" Decode.int
        |> Decode.required "watchers" Decode.int
        |> Decode.required "stargazers_count" Decode.int
        |> Decode.required "default_branch" Decode.string
        |> Decode.required "size" Decode.int
        |> Decode.required "created_at" Decode.date
        |> Decode.required "updated_at" Decode.date
        |> Decode.required "pushed_at" Decode.date
        |> Decode.required "url" Decode.string
        |> Decode.required "contributors_url" Decode.string
        |> Decode.hardcoded []
        |> Decode.required "events_url" Decode.string
        |> Decode.hardcoded []
        |> Decode.hardcoded []
        |> Decode.hardcoded []
        |> Decode.hardcoded []


ownerDecoder : Decoder Owner
ownerDecoder =
    Decode.decode Owner
        |> Decode.required "html_url" Decode.string
        |> Decode.required "avatar_url" Decode.string
        |> Decode.required "login" Decode.string


contributorDecoder : Decoder Contributor
contributorDecoder =
    Decode.decode Contributor
        |> Decode.required "html_url" Decode.string
        |> Decode.required "login" Decode.string
        |> Decode.required "avatar_url" Decode.string


eventDecoder : Decoder Event
eventDecoder =
    Decode.decode Event
        |> Decode.required "id" Decode.parseInt
        |> Decode.required "type" Decode.string
        |> Decode.requiredAt [ "actor", "login" ] Decode.string
        |> Decode.required "created_at" Decode.date


issueDecoder : Decoder Issue
issueDecoder =
    Decode.decode Issue
        |> Decode.required "id" Decode.int
        |> Decode.required "state" Decode.string
        |> Decode.required "html_url" Decode.string
        |> Decode.required "title" Decode.string
        |> Decode.required "created_at" Decode.date


commitDecoder : Decoder Commit
commitDecoder =
    let
        decoder htmlUrl sha message title authorHtmlUrl authorName =
            Commit
                htmlUrl
                sha
                (Author authorHtmlUrl authorName)
                message
                title
                |> Decode.succeed
    in
        Decode.decode decoder
            |> Decode.required "html_url" Decode.string
            |> Decode.required "sha" Decode.string
            |> Decode.requiredAt [ "commit", "message" ] Decode.string
            |> Decode.optional "title" (Decode.nullable Decode.string) Nothing
            |> Decode.requiredAt [ "author", "html_url" ] Decode.string
            |> Decode.requiredAt [ "commit", "author", "name" ] Decode.string
            |> Decode.resolve
