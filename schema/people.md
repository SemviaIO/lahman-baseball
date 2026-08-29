# People

::[mappedBy](https://pkg.semvia.io/semvia/folio/mapping#mappedBy) RmlMappingMap

Projects `public.people` — 24,270 rows, the register of every human the Lahman
database names — onto `bball:Person`.

`people` is the one relation in this package with a real single-column key and a
unique index behind it (`idx_people_playerid`, transcribed in
[`sql/indexes.sql`](../sql/indexes.sql)), which is why the person subject IRI is
a single-placeholder template and why `COUNT(DISTINCT ?person)` over it is sound
without further argument.

> **This is the IRI other packages join to.** The concordance bridge that resolves
> a Met baseball card to the player it depicts mints
> `https://github.com/SemviaIO/lahman-baseball/person/{lahman_playerid}` itself
> rather than minting a local IRI and relating it — `owl:sameAs` is not entailed
> anywhere in the stack, so an alias edge would be written and never followed.
> The template below is therefore a published contract, not an implementation
> detail.

> **Why a query source rather than a table source.** Every column in the Lahman
> database is `text`, including the numeric ones. A mapping that declares
> `rml:datatype xsd:integer` over a `text` column is not wrong, but the delivered
> Arrow type is `Utf8`, so the federation engine's declared-versus-delivered
> parity check correctly refuses to push any aggregate, ordering or numeric
> comparison over it down to Postgres and falls back to local evaluation. Safe,
> and slow. Casting in the SQL text is what buys the pushdown, so every relation
> this package maps that the corpus computes over arrives as an
> `rml:SQL2008Query` with its casts written into the SELECT.
>
> `birthyear` is cast; `debut` and `finalgame` are not, because the register
> already stores them as ISO-8601 text and `xsd:date` over ISO-8601 text is
> lexically sound where `xsd:integer` over `text` is not.

> **Three birth columns, one predicate.** The register splits birth into
> `birthyear`, `birthmonth` and `birthday`. Only the year is lifted. Composing a
> `xsd:date` would have to invent a value for the 978 rows missing at least one
> of the three, and a confidently wrong date is worse than an absent one.

## People

One `bball:Person` per row, subject-keyed on `playerid`.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Query](http://w3id.org/rml/SQL2008Query)
::[iterator](http://w3id.org/rml/iterator) "SELECT playerid, namefirst, namelast, bats, throws, debut, finalgame, CAST(birthyear AS integer) AS birthyear FROM public.people"
::[template](http://w3id.org/rml/template) "https://github.com/SemviaIO/lahman-baseball/person/{playerid}"
::[class](http://w3id.org/rml/class) [Person](ontology#Person)

### givenName

The name the register spells — "Babe", not "George". `namegiven` carries the
birth-certificate form and is deliberately not mapped: a query asking for a
player by name means the name they played under.

::[reference](http://w3id.org/rml/reference) "namefirst"

### familyName

::[reference](http://w3id.org/rml/reference) "namelast"

### birthYear

Cast to `integer` in the source SELECT, so a filter like `bball:birthYear 1985`
pushes into Postgres rather than being evaluated locally over strings.

::[reference](http://w3id.org/rml/reference) "birthyear"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### battingHand

L, R, or B for a switch-hitter.

::[reference](http://w3id.org/rml/reference) "bats"

### throwingHand

::[reference](http://w3id.org/rml/reference) "throws"

### debutDate

Already ISO-8601 in the source, so the `xsd:date` declaration is lexically safe
without a cast.

::[reference](http://w3id.org/rml/reference) "debut"
::[datatype](http://w3id.org/rml/datatype) [date](http://www.w3.org/2001/XMLSchema#date)

### finalGameDate

Absent for the 3,030 people the register carries who never played a game —
managers, umpires and executives.

::[reference](http://w3id.org/rml/reference) "finalgame"
::[datatype](http://w3id.org/rml/datatype) [date](http://www.w3.org/2001/XMLSchema#date)
