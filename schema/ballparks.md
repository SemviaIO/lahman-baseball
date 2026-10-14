# Ballparks

::[mappedBy](https://pkg.semvia.io/semvia/folio/mapping#mappedBy) RmlMappingMap

Projects `public.parks` and `public.homegames` onto `bball:Ballpark` and
`bball:BallparkTenure`.

> **A tenure, not an attribute.** A club's home ground is not a property of the
> club or of the park; it is a relation that holds for a season and then stops.
> `homegames` already knows this — it is one row per year, team and park — and
> the mapping names the row rather than flattening it onto either end. The Yankees
> hosting at Shea Stadium in 1974 and 1975 is then two resources with their own
> attendance figures, not an exception to a `bball:homeGround` property.

## Ballparks

One `bball:Ballpark` per row of `public.parks` — 345 rows, keyed on `parkkey`,
which is distinct and non-NULL throughout. The relation also carries `id` and
`parkalias`; neither is mapped. `id` is a surrogate with no meaning outside the
dump, and `parkalias` is a semicolon-joined list of former names that would need
splitting before it could be more than a string.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Table](http://w3id.org/rml/SQL2008Table)
::[iterator](http://w3id.org/rml/iterator) "public.parks"
::[template](http://w3id.org/rml/template) "https://pkg.semvia.io/semvia/lahman-baseball/park/{parkkey}"
::[class](http://w3id.org/rml/class) [Ballpark](ontology#Ballpark)

### name

::[reference](http://w3id.org/rml/reference) "parkname"

### city

::[reference](http://w3id.org/rml/reference) "city"

### state

::[reference](http://w3id.org/rml/reference) "state"

### country

::[reference](http://w3id.org/rml/reference) "country"

## BallparkTenures

One `bball:BallparkTenure` per row of `public.homegames` — 3,303 rows, injective
on year, team and park.

The register spells this relation's key columns `yearkey`, `teamkey` and
`leaguekey` where every other relation spells them `yearid`, `teamid` and `lgid`.
The mapping does not rename them — a reference must name the column the source
delivers — but the join conditions below are where that inconsistency stops being
the consumer's problem, because `bball:teamSeason` reconciles the two spellings
once and every query afterwards sees one edge.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Query](http://w3id.org/rml/SQL2008Query)
::[iterator](http://w3id.org/rml/iterator) "SELECT yearkey, teamkey, leaguekey, parkkey, spanfirst, spanlast, CAST(yearkey AS integer) AS seasonyear, CAST(games AS integer) AS gameshosted, CAST(attendance AS integer) AS seasonattendance FROM public.homegames"
::[template](http://w3id.org/rml/template) "https://pkg.semvia.io/semvia/lahman-baseball/ballpark-tenure/{yearkey}-{teamkey}-{parkkey}"
::[class](http://w3id.org/rml/class) [BallparkTenure](ontology#BallparkTenure)

### ballpark

All 3,303 rows resolve against `parks` — checked.

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [Ballparks](#Ballparks)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "parkkey"
  ::[parent](http://w3id.org/rml/parent) "parkkey"

### teamSeason

The three-column join across the spelling change. All 3,303 rows resolve.

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [TeamSeasons](franchises-and-seasons#TeamSeasons)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "teamkey"
  ::[parent](http://w3id.org/rml/parent) "teamid"
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "yearkey"
  ::[parent](http://w3id.org/rml/parent) "yearid"
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "leaguekey"
  ::[parent](http://w3id.org/rml/parent) "lgid"

### seasonYear

::[reference](http://w3id.org/rml/reference) "seasonyear"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### gamesHosted

::[reference](http://w3id.org/rml/reference) "gameshosted"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### seasonAttendance

::[reference](http://w3id.org/rml/reference) "seasonattendance"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### firstHomeGameDate

Already ISO-8601 in the register, so `xsd:date` needs no cast.

::[reference](http://w3id.org/rml/reference) "spanfirst"
::[datatype](http://w3id.org/rml/datatype) [date](http://www.w3.org/2001/XMLSchema#date)

### lastHomeGameDate

::[reference](http://w3id.org/rml/reference) "spanlast"
::[datatype](http://w3id.org/rml/datatype) [date](http://www.w3.org/2001/XMLSchema#date)
