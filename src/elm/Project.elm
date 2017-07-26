module Project
    exposing
        ( Project
        , Projects
        , listCommitsTask
        , listContributorsTask
        , listEventsTask
        , listIssuesTask
        , listLabelsTask
        , listProjectsTask
        , projectEncoder
        , updateProject
        )

import Date exposing (Date)
import Date.Extra as Date
import Date.Extra.Config.Config_en_us exposing (config)
import Date.Extra.Duration as DateExtra
import Date.Extra.Format as DateFormat
import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Decode.Extra as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Json.Encode.Extra as Encode
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


projectEncoder : Project -> Value
projectEncoder project =
    Encode.object
        [ ( "id", Encode.int project.id )
        , ( "language", Encode.maybe Encode.string project.language )
        , ( "full_name", Encode.string project.fullName )
        , ( "owner", Encode.maybe ownerEncoder project.owner )
        , ( "name", Encode.string project.name )
        , ( "description", Encode.maybe Encode.string project.description )
        , ( "open_issues_count", Encode.int project.openIssuesCount )
        , ( "forks", Encode.int project.forks )
        , ( "watchers", Encode.int project.watchers )
        , ( "stargazers_count", Encode.int project.stargazersCount )
        , ( "default_branch", Encode.string project.defaultBranch )
        , ( "size", Encode.int project.size )
        , ( "created_at"
          , Date.toUtcIsoString project.createdAt
                |> Encode.string
          )
        , ( "updated_at"
          , Date.toUtcIsoString project.updatedAt
                |> Encode.string
          )
        , ( "pushed_at"
          , Date.toUtcIsoString project.pushedAt
                |> Encode.string
          )
        , ( "contributors"
          , List.map contributorEncoder project.contributors
                |> Encode.list
          )
        , ( "events"
          , List.map eventEncoder project.events
                |> Encode.list
          )
        , ( "issues"
          , List.map issueEncoder project.issues
                |> Encode.list
          )
        , ( "commits"
          , List.map commitEncoder project.commits
                |> Encode.list
          )
        , ( "labels"
          , List.map Encode.string project.labels
                |> Encode.list
          )
        ]


ownerDecoder : Decoder Owner
ownerDecoder =
    Decode.decode Owner
        |> Decode.required "html_url" Decode.string
        |> Decode.required "avatar_url" Decode.string
        |> Decode.required "login" Decode.string


ownerEncoder : Owner -> Value
ownerEncoder owner =
    Encode.object
        [ ( "html_url", Encode.string owner.htmlUrl )
        , ( "avatar_url", Encode.string owner.avatarUrl )
        , ( "login", Encode.string owner.login )
        ]


contributorDecoder : Decoder Contributor
contributorDecoder =
    Decode.decode Contributor
        |> Decode.required "html_url" Decode.string
        |> Decode.required "login" Decode.string
        |> Decode.required "avatar_url" Decode.string


contributorEncoder : Contributor -> Value
contributorEncoder contributor =
    Encode.object
        [ ( "html_url", Encode.string contributor.htmlUrl )
        , ( "login", Encode.string contributor.login )
        , ( "avatar_url", Encode.string contributor.avatarUrl )
        ]


eventDecoder : Decoder Event
eventDecoder =
    Decode.decode Event
        |> Decode.required "id" Decode.parseInt
        |> Decode.required "type" Decode.string
        |> Decode.requiredAt [ "actor", "login" ] Decode.string
        |> Decode.required "created_at" Decode.date


eventEncoder : Event -> Value
eventEncoder event =
    Encode.object
        [ ( "id", Encode.int event.id )
        , ( "type", Encode.string event.type_ )
        , ( "actor", Encode.string event.actor )
        , ( "created_at"
          , Date.toUtcIsoString event.createdAt
                |> Encode.string
          )
        ]


issueDecoder : Decoder Issue
issueDecoder =
    Decode.decode Issue
        |> Decode.required "id" Decode.int
        |> Decode.required "state" Decode.string
        |> Decode.required "html_url" Decode.string
        |> Decode.required "title" Decode.string
        |> Decode.required "created_at" Decode.date


issueEncoder : Issue -> Value
issueEncoder issue =
    Encode.object
        [ ( "id", Encode.int issue.id )
        , ( "state", Encode.string issue.state )
        , ( "html_url", Encode.string issue.htmlUrl )
        , ( "title", Encode.string issue.title )
        , ( "created_at"
          , Date.toUtcIsoString issue.createdAt
                |> Encode.string
          )
        ]


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


commitEncoder : Commit -> Value
commitEncoder commit =
    Encode.object
        [ ( "html_url", Encode.string commit.htmlUrl )
        , ( "sha", Encode.string commit.sha )
        , ( "author", authorEncoder commit.author )
        , ( "message", Encode.string commit.message )
        , ( "title", Encode.maybe Encode.string commit.title )
        ]


authorEncoder : Author -> Value
authorEncoder author =
    Encode.object
        [ ( "html_url", Encode.string author.htmlUrl )
        , ( "name", Encode.string author.name )
        ]
