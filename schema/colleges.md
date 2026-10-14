# Colleges

::[mappedBy](https://pkg.semvia.io/semvia/folio/mapping#mappedBy) RmlMappingMap

Projects `public.schools` and `public.collegeplaying` onto `bball:School` and
`bball:CollegeAttendance`.

> **The fan-out that makes this document worth reading.** `collegeplaying` is one
> row per player per school per **year** — 17,687 rows over 6,575 people. A query
> that joins a person to their college and then sums a career statistic joins a
> one-to-many edge underneath an aggregate, and every college year multiplies the
> sum. Mike Schmidt attended Ohio University for three recorded years and hit 548
> home runs; the naive join reports 1,644. Nothing in the mapping can prevent
> that — the data really is one row per year, and the model says so — but the
> class is named `CollegeAttendance` rather than `College` precisely so the
> cardinality is visible in the vocabulary rather than lurking in the table.

## Schools

One `bball:School` per row of `public.schools` — 1,287 rows, keyed on a school
identifier with no NULLs and no duplicates. A plain table source: four text
columns, all of them text in the conceptual layer too.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Table](http://w3id.org/rml/SQL2008Table)
::[iterator](http://w3id.org/rml/iterator) "public.schools"
::[template](http://w3id.org/rml/template) "https://pkg.semvia.io/semvia/lahman-baseball/school/{schoolid}"
::[class](http://w3id.org/rml/class) [School](ontology#School)

### name

::[reference](http://w3id.org/rml/reference) "name_full"

### city

::[reference](http://w3id.org/rml/reference) "city"

### state

::[reference](http://w3id.org/rml/reference) "state"

### country

::[reference](http://w3id.org/rml/reference) "country"

## CollegeAttendances

One `bball:CollegeAttendance` per row of `public.collegeplaying` — 17,687 rows,
injective on person, school and year.

`yearid` is NULL on 337 rows, and a NULL spliced into a subject template is not
merely an odd IRI: SQL `concat` swallows the NULL, so the engine's row-validity
filter drops the whole row rather than mint an identifier from a partial tuple.
`COALESCE` to the empty string keeps those 337 attendances in the graph with an
IRI that ends in a hyphen, and the cast copy carries the year as an integer for
the 17,350 rows that have one.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Query](http://w3id.org/rml/SQL2008Query)
::[iterator](http://w3id.org/rml/iterator) "SELECT playerid, schoolid, COALESCE(yearid, '') AS attendancekey, CAST(yearid AS integer) AS seasonyear FROM public.collegeplaying"
::[template](http://w3id.org/rml/template) "https://pkg.semvia.io/semvia/lahman-baseball/college-attendance/{playerid}-{schoolid}-{attendancekey}"
::[class](http://w3id.org/rml/class) [CollegeAttendance](ontology#CollegeAttendance)

### player

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [People](people#People)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "playerid"
  ::[parent](http://w3id.org/rml/parent) "playerid"

### school

Every one of the 17,687 rows resolves against `schools` — checked, not assumed.

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [Schools](#Schools)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "schoolid"
  ::[parent](http://w3id.org/rml/parent) "schoolid"

### seasonYear

::[reference](http://w3id.org/rml/reference) "seasonyear"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)
