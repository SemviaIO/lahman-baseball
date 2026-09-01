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

## What it maps

Fourteen TriplesMaps over fourteen of lahman's twenty-seven relations, in six
mapping documents.

| Source relation | TriplesMap | Yields |
| --- | --- | --- |
| `public.people` | `People` | one `bball:Person` per row |
| `public.teamsfranchises` | `Franchises` | one `bball:Franchise` per row |
| `public.teams` | `TeamSeasons` | one `bball:TeamSeason` per row, edged to its franchise |
| `public.managers` | `ManagerStints` | one `bball:ManagerStint` per row |
| `public.batting` | `BattingStints` | one `bball:Stint`, carrying the batting line |
| `public.pitching` | `PitchingStints` | the same `bball:Stint`, carrying wins, losses, saves and ERA |
| `public.fielding` | `FieldingStints` | the same `bball:Stint`, carrying putouts, assists and errors — one row per position, so multi-valued |
| `public.appearances` | `PositionAppearances` | one `bball:PositionAppearance` per position played, linked back to the stint |
| `public.halloffame` | `HallOfFameBallots` | one `bball:HallOfFameBallot` per candidacy |
| `public.awardsplayers` | `AwardHonors` | one `bball:AwardHonor` per conferral |
| `public.schools` | `Schools` | one `bball:School` per row |
| `public.collegeplaying` | `CollegeAttendances` | one `bball:CollegeAttendance` per player-school-year |
| `public.parks` | `Ballparks` | one `bball:Ballpark` per row |
| `public.homegames` | `BallparkTenures` | one `bball:BallparkTenure` per club-season-park |

The thirteen relations left unmapped are `allstarfull`, `awardsmanagers`,
`awardssharemanagers`, `awardsshareplayers`, `battingpost`, `fieldingof`,
`fieldingofsplit`, `fieldingpost`, `managershalf`, `pitchingpost`, `salaries`,
`seriespost` and `teamshalf` — post-season lines, vote-share detail, split-season
oddities, and salaries. They are absent because nothing needed them yet, not
because they resist mapping; most would be a second TriplesMap onto a class that
already exists.

`sql/indexes.sql` transcribes the physical structure those relations actually
carry, and says which of the mapping's joins run against no index at all.

## The model

Twelve classes, because baseball has entities lahman's schema does not name.

| Class | Subject IRI | Read from |
| --- | --- | --- |
| `bball:Person` | `/person/{playerid}` | `people` |
| `bball:Franchise` | `/franchise/{franchid}` | `teamsfranchises` |
| `bball:TeamSeason` | `/team-season/{yearid}-{teamid}-{lgid}` | `teams` |
| `bball:Stint` | `/stint/{playerid}-{yearid}-{stint}-{teamid}` | `batting`, `pitching`, `fielding` |
| `bball:PositionAppearance` | `/position-appearance/{playerid}-{yearid}-{stint}-{teamid}-{pos}` | `appearances` |
| `bball:ManagerStint` | `/manager-stint/{playerid}-{yearid}-{teamid}-{inseason}` | `managers` |
| `bball:AwardHonor` | `/award-honor/{playerid}-{awardkey}-{yearid}-{lgid}-{citationkey}` | `awardsplayers` |
| `bball:HallOfFameBallot` | `/hall-of-fame-ballot/{playerid}-{yearid}-{votingbodykey}` | `halloffame` |
| `bball:School` | `/school/{schoolid}` | `schools` |
| `bball:CollegeAttendance` | `/college-attendance/{playerid}-{schoolid}-{attendancekey}` | `collegeplaying` |
| `bball:Ballpark` | `/park/{parkkey}` | `parks` |
| `bball:BallparkTenure` | `/ballpark-tenure/{yearkey}-{teamkey}-{parkkey}` | `homegames` |

All under this package's baseIRI, `https://github.com/SemviaIO/lahman-baseball`.

Three of those templates splice a name ending in `key` rather than a raw column.
`awardkey`, `citationkey` and `votingbodykey` are slugged copies of free text that
holds spaces, which are not IRI-safe and which this federation engine deliberately
does not percent-encode; `attendancekey` is a `COALESCE` of a nullable year,
because a NULL spliced into a template drops the whole row. Each is computed in
the mapping's own SQL, each is checked injective against the live register, and
the raw value is still delivered by a predicate. `schema/honors.md` and
`schema/colleges.md` carry the arguments.

The two calls worth arguing with are in `schema/ontology.ttl`'s class comments:
**Person is not Player** (the Hall of Fame inducts umpires and executives out of
the same identifier space), and **TeamSeason is not Franchise** (a question about
the Braves spans Boston, Milwaukee and Atlanta, and needs a resource to attach
itself to).

## Caveats worth knowing before you query

**Three relations mint the same stint subject, and only one of them may say
"home runs".** Batting, pitching and fielding all key on
`(playerid, yearid, stint, teamid)`, so all three project onto one `bball:Stint`.
That is the point of the model — a two-way player's batting line and his ERA are
predicates on one resource. But four of the column names collide with opposite
senses across batting and pitching: home runs, walks, strikeouts and games are
hit, drawn, suffered and played on one side and allowed, issued, recorded and
pitched on the other. Sharing those predicates would seat two contradictory
values on one node and let a career `SUM` add home runs allowed to home runs hit.
So `bball:homeRuns`, `bball:walks`, `bball:strikeouts` and `bball:games` come
from the batting relation alone, and the pitching map contributes only the four
predicates no batting line can carry. Pitching counts that need their own sense —
hits allowed, innings pitched — are not mapped rather than mapped ambiguously.

**A position appearance is its own resource, not a stint.** `appearances` is one
row per player-season-team with thirteen position columns side by side; the
mapping pivots them into one row per position, so its grain is finer than a
stint's. Each row mints a `bball:PositionAppearance` whose subject splices the
position code, carrying exactly one `bball:position` and one
`bball:gamesAtPosition`. Ask for the pair off the appearance, not off the stint:
before `v0.2.0` these rows minted the shared stint subject, which put every
position of a stint on one resource with nothing pairing a position to its own
count, and a question about a player's primary position by season answered a
cross product.

**The appearance's stint link attaches to stint 1.** `appearances` has no stint
column, so the pivot pins `'1' AS stint` as a visible constant. For the 9,725
player-seasons with more than one stint, covering 20,324 appearances rows, that
ordinal may not be the one batting would give, and 10,634 of the pivot's rows
name a stint no batting row mints — those carry no `bball:stint` at all and are
reachable through `bball:player` and `bball:teamSeason` instead. The team and the
season are always right; the ordinal is not always right.

**`bball:putouts`, `bball:assists` and `bball:errors` are multi-valued.**
`fielding` records one row per position played — 174,332 rows over 127,079
distinct stints — and the subject template does not splice the position. A stint
spent at two positions carries two of each. Use `SUM`, not a lookup.

**A career total is a `SUM`, never a property.** The register stores no career
line for anyone, so neither does this package. `SUM(?hr)` over
`?stint bball:player ?p ; bball:homeRuns ?hr` is the shape, and a `DISTINCT` over
the stint variable — not over the value — is what keeps it honest when another
one-to-many relation joins in.

**`bball:CollegeAttendance` is one row per year.** Joining a person to their
college underneath an aggregate multiplies the aggregate by the number of years
attended: Mike Schmidt's three Ohio University rows turn 548 career home runs
into 1,644. The class is named for the row, not for the school, so the
cardinality is in the vocabulary rather than lurking in the table.

**Three subject templates splice a computed key, not a column.** `awardkey`,
`citationkey` and `votingbodykey` are slugged copies of free text with spaces in
it; `attendancekey` is a `COALESCE` of a nullable year. Spaces are not IRI-safe
and this engine does not percent-encode template splices, and a NULL splice drops
the whole row rather than minting a partial IRI. Each computed key is checked
injective against the live register; each raw value is still delivered by a
predicate.

**Every column in lahman is `text`, and the mapping casts in SQL.** Declaring
`rml:datatype xsd:integer` over a `text` column is legal, delivers Arrow `Utf8`,
and makes the federation engine correctly refuse to push an aggregate or an
ordering down to Postgres — safe, and slow. Every numeric predicate here is
sourced from an `rml:SQL2008Query` with `CAST(... AS integer)` in the SQL text.
`debut`, `finalgame`, `spanfirst` and `spanlast` are the exceptions: the register
already stores them as ISO-8601, so `xsd:date` needs no cast.

**No `sh:minCount` on any mapped property.** These shapes describe a virtual
graph over a source we do not control, and that source has nulls — 978 people
with no birth year, 3,030 with no debut, 1,983 ballots with no published vote
count, 855 team-seasons with no World Series outcome. A shape is documentation
here, not a gate the source could satisfy.

**`bball:earnedRunAverage` is unexercised.** It is the one datatype declaration
in the package no query has measured — `xsd:decimal` over a Postgres `numeric`.
Treat a pushdown decline there as unmeasured rather than as known-good.

## Licence and attribution

Everything Semvia authored here is CC0 1.0 Universal — see `LICENSE`.

The data is the Lahman database's and is not redistributed by this package. See
`NOTICE` for the source, its terms of use, and what this package does and does
not claim.
