# lahman-baseball

A Semvia semantic package over the Sean Lahman Baseball Database — the
season-level record of Major League Baseball from 1871 forward.

It ships no data. What it ships is a description: an ontology of the game, a
Postgres connection descriptor carrying no credential, and RML mapping documents
that tell the Semvia federation engine how to read lahman's tables as RDF.
Install it and the register becomes queryable over SPARQL, answered by the
database at query time. Nothing is copied and nothing is materialized.

## Install

```json
{
  "requires": {
    "https://github.com/SemviaIO/lahman-baseball": "SemviaIO/lahman-baseball#v0.1.0"
  }
}
```

Any git ref works in place of the tag — a branch or a commit SHA, in the
`owner/repo#ref` form.

The connection descriptor names the database but carries **no password**. The
installer binds it out of band: `svdb:password` is a secret-marked field, and the
binding is keyed to the descriptor's own subject IRI,
`https://github.com/SemviaIO/lahman-baseball/schema/connection#semvia-test-data`,
so the credential is released only for the destination you consented to. No
credential appears anywhere in this repository, and none ever will.

## The model

Eleven classes, because baseball has entities lahman's schema does not name.

| Class | Subject IRI | Read from |
| --- | --- | --- |
| `bball:Person` | `/person/{playerid}` | `people` |
| `bball:Franchise` | `/franchise/{franchid}` | `teamsfranchises` |
| `bball:TeamSeason` | `/team-season/{yearid}-{teamid}-{lgid}` | `teams` |
| `bball:Stint` | `/stint/{playerid}-{yearid}-{stint}-{teamid}` | `batting`, `pitching`, `fielding`, `appearances` |
| `bball:ManagerStint` | `/manager-stint/{playerid}-{yearid}-{teamid}-{inseason}` | `managers` |
| `bball:AwardHonor` | `/award-honor/{playerid}-{awardid}-{yearid}-{lgid}-{citation}` | `awardsplayers` |
| `bball:HallOfFameBallot` | `/hall-of-fame-ballot/{playerid}-{yearid}-{votedby}` | `halloffame` |
| `bball:School` | `/school/{schoolid}` | `schools` |
| `bball:CollegeAttendance` | `/college-attendance/{playerid}-{schoolid}-{yearid}` | `collegeplaying` |
| `bball:Ballpark` | `/park/{parkkey}` | `parks` |
| `bball:BallparkTenure` | `/ballpark-tenure/{yearkey}-{teamkey}-{parkkey}` | `homegames` |

All under this package's baseIRI, `https://github.com/SemviaIO/lahman-baseball`.

The two calls worth arguing with are in `schema/ontology.ttl`'s class comments:
**Person is not Player** (the Hall of Fame inducts umpires and executives out of
the same identifier space), and **TeamSeason is not Franchise** (a question about
the Braves spans Boston, Milwaukee and Atlanta, and needs a resource to attach
itself to).

## Licence and attribution

Everything Semvia authored here is CC0 1.0 Universal — see `LICENSE`.

The data is the Lahman database's and is not redistributed by this package. See
`NOTICE` for the source, its terms of use, and what this package does and does
not claim.
