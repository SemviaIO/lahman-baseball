# Franchises and Seasons

::[mappedBy](https://pkg.semvia.io/semvia/folio/mapping#mappedBy) RmlMappingMap

Projects `public.teamsfranchises`, `public.teams` and `public.managers` onto
`bball:Franchise`, `bball:TeamSeason` and `bball:ManagerStint`.

> **The split this document exists to make.** The register's `teams` relation is
> one row per club per season, and it carries `franchid` on every one of those
> rows — so the fact that the 1966 Atlanta Braves and the 1952 Boston Braves are
> the same organization is present in the dump only as a repeated string. The
> mapping lifts it into an edge: `teams` becomes a `bball:TeamSeason` and the
> franchise it belongs to becomes a separate `bball:Franchise` resource that
> `bball:franchise` points at. A question about a franchise's history now has a
> resource to attach itself to, and the answer is a graph walk rather than a
> `GROUP BY` over a string.

> **Two join shapes, deliberately both present.** `bball:franchise` is the
> single-column case — `franchid` in the child, `franchid` in the parent. The
> `bball:teamSeason` edges into `TeamSeasons` are the three-column case, because
> the team-season subject IRI splices year, team and league and a
> `rml:RefObjectMap` must reproduce every column the parent's template splices or
> it would join to a row whose IRI it cannot reconstruct. The federation engine
> compiles a multi-condition `rml:RefObjectMap` into an equijoin on the
> conjunction; nothing about the three-column form is a special case.

## Franchises

One `bball:Franchise` per row of `public.teamsfranchises` — 203 rows, one per
continuing organization. This is the one relation in the package that needs no
cast, no coalesce and no query source: three text columns, all of them text-typed
in the conceptual layer too, so a plain table source is honest.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Table](http://w3id.org/rml/SQL2008Table)
::[iterator](http://w3id.org/rml/iterator) "public.teamsfranchises"
::[template](http://w3id.org/rml/template) "https://pkg.semvia.io/semvia/lahman-baseball/franchise/{franchid}"
::[class](http://w3id.org/rml/class) [Franchise](ontology#Franchise)

### name

::[reference](http://w3id.org/rml/reference) "franchname"

### active

::[reference](http://w3id.org/rml/reference) "active"

## TeamSeasons

One `bball:TeamSeason` per row of `public.teams` — 3,614 rows, injective on the
three-column subject template.

The SELECT keeps `yearid`, `teamid`, `lgid` and `franchid` in their raw text form
because they are template splices and join columns, and adds cast copies under
conceptual names for the columns the corpus computes over. `seasonyear` is the
cast twin of `yearid`: the template needs the text, a `?ts bball:seasonYear 1998`
filter needs the integer, and one column cannot be both.

`rank` reads as a bare column in the SELECT. It is also the name of a Postgres
window function, but a bare `rank` in a value expression is a column reference —
only `rank()` with the parentheses is the function — so no quoting is needed and
none is used.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Query](http://w3id.org/rml/SQL2008Query)
::[iterator](http://w3id.org/rml/iterator) "SELECT yearid, teamid, lgid, franchid, name, wswin, CAST(yearid AS integer) AS seasonyear, CAST(w AS integer) AS wins, CAST(l AS integer) AS losses, CAST(rank AS integer) AS standingsrank FROM public.teams"
::[template](http://w3id.org/rml/template) "https://pkg.semvia.io/semvia/lahman-baseball/team-season/{yearid}-{teamid}-{lgid}"
::[class](http://w3id.org/rml/class) [TeamSeason](ontology#TeamSeason)

### seasonYear

::[reference](http://w3id.org/rml/reference) "seasonyear"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### name

The club's name that season — "Boston Beaneaters", not "Braves".

::[reference](http://w3id.org/rml/reference) "name"

### league

::[reference](http://w3id.org/rml/reference) "lgid"

### wins

::[reference](http://w3id.org/rml/reference) "wins"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### losses

::[reference](http://w3id.org/rml/reference) "losses"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### standingsRank

::[reference](http://w3id.org/rml/reference) "standingsrank"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### wonWorldSeries

Y, N, or absent — 855 of the 3,614 seasons have no value, and the register is
right to leave them empty rather than answer N for a season with no World Series
to lose. Nothing in this package asserts a `sh:minCount` that would call those
rows invalid.

::[reference](http://w3id.org/rml/reference) "wswin"

### franchise

The single-column join. `teams.franchid` has no NULLs across all 3,614 rows and
every value resolves in `teamsfranchises`, so this edge is total in practice —
but the mapping does not depend on that, and a season whose franchise code went
missing would simply carry no `bball:franchise` triple rather than mint a subject
from a partial row.

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [Franchises](#Franchises)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "franchid"
  ::[parent](http://w3id.org/rml/parent) "franchid"

## ManagerStints

One `bball:ManagerStint` per row of `public.managers` — 4,410 rows, injective on
`(playerid, yearid, teamid, inseason)`.

`inseason` appears twice for the same reason `yearid` does in TeamSeasons: as raw
text it splices the subject IRI, as `ordinal` it is the integer a query compares.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Query](http://w3id.org/rml/SQL2008Query)
::[iterator](http://w3id.org/rml/iterator) "SELECT playerid, yearid, teamid, lgid, inseason, CAST(inseason AS integer) AS ordinal, CAST(g AS integer) AS games, CAST(w AS integer) AS wins, CAST(l AS integer) AS losses, CAST(rank AS integer) AS standingsrank FROM public.managers"
::[template](http://w3id.org/rml/template) "https://pkg.semvia.io/semvia/lahman-baseball/manager-stint/{playerid}-{yearid}-{teamid}-{inseason}"
::[class](http://w3id.org/rml/class) [ManagerStint](ontology#ManagerStint)

### player

Managers live in the same `people` register as players and share its identifier
space, which is why `bball:player` is the edge here too — the predicate is named
for the commonest case, not for a subtype.

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [People](people#People)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "playerid"
  ::[parent](http://w3id.org/rml/parent) "playerid"

### teamSeason

The three-column join, reproducing every splice of the team-season template.

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [TeamSeasons](#TeamSeasons)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "teamid"
  ::[parent](http://w3id.org/rml/parent) "teamid"
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "yearid"
  ::[parent](http://w3id.org/rml/parent) "yearid"
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "lgid"
  ::[parent](http://w3id.org/rml/parent) "lgid"

### stintOrdinal

::[reference](http://w3id.org/rml/reference) "ordinal"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### games

::[reference](http://w3id.org/rml/reference) "games"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### wins

::[reference](http://w3id.org/rml/reference) "wins"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### losses

::[reference](http://w3id.org/rml/reference) "losses"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### standingsRank

::[reference](http://w3id.org/rml/reference) "standingsrank"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)
