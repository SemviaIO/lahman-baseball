# Honors

::[mappedBy](https://pkg.semvia.io/semvia/folio/mapping#mappedBy) RmlMappingMap

Projects `public.halloffame` and `public.awardsplayers` onto
`bball:HallOfFameBallot` and `bball:AwardHonor`.

> **Why both classes exist, and why neither is a property of the person.** The
> register records a Hall of Fame candidacy as one row per person per ballot per
> voting body — a player can appear on fifteen BBWAA ballots and then again
> before a Veterans committee decades later, with a different vote count each
> time. Collapsing that to `bball:inducted "Y"` on the person would throw away
> every ballot but the last and would have nothing to hang a vote count on. The
> same argument makes an award its own resource: an award is conferred by a body
> in a year, and "who won the 1963 MVP" is a question about the conferral.

> **Slugged template splices, and why.** Two of the columns these subject IRIs
> are keyed on hold free text with spaces in it — `halloffame.votedby` on 1,205
> rows, `awardsplayers.awardid` on all 12,667, and `awardsplayers.notes` on
> 3,074. A space is not an unreserved IRI character, and this federation engine
> deliberately does **not** percent-encode template splices: it mints on two
> planes, once in Rust and once as a SQL `concat` unparsed into the source's own
> dialect, and no spelling of R2RML §7.3's encoder is portable across both, so it
> verifies IRI-safety at activation time instead of transforming. A raw splice
> here would therefore mint IRIs with spaces in them.
>
> The mapping slugs those columns inside the source query — lowercase, every run
> of non-alphanumerics collapsed to a single hyphen, hyphens trimmed at the ends
> — so what reaches the template is already unreserved and the raw `concat` is
> the encoded mint on both planes. A slug is lossy in principle: two distinct
> award names could collapse onto one. Checked against the live register, they do
> not — 12,667 award rows render 12,667 distinct IRIs and 6,426 ballot rows
> render 6,426. The raw column is still carried alongside the slug and is what
> `bball:award` and `bball:votingBody` deliver, so nothing readable is lost; the
> slug is identity, the raw value is the label.

## HallOfFameBallots

One `bball:HallOfFameBallot` per row of `public.halloffame` — 6,426 rows.

Note the key: person, year, **and voting body**. Person and year alone are not
enough — 146 rows share a `(playerid, yearid)` pair, a player considered by the
writers and by a committee in the same year.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Query](http://w3id.org/rml/SQL2008Query)
::[iterator](http://w3id.org/rml/iterator) "SELECT playerid, yearid, votedby, inducted, category, trim(both '-' from regexp_replace(lower(votedby), '[^a-z0-9]+', '-', 'g')) AS votingbodykey, CAST(yearid AS integer) AS ballotyear, CAST(ballots AS integer) AS ballotscast, CAST(votes AS integer) AS votesreceived, CAST(needed AS integer) AS votesneeded FROM public.halloffame"
::[template](http://w3id.org/rml/template) "https://github.com/SemviaIO/lahman-baseball/hall-of-fame-ballot/{playerid}-{yearid}-{votingbodykey}"
::[class](http://w3id.org/rml/class) [HallOfFameBallot](ontology#HallOfFameBallot)

### player

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [People](people#People)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "playerid"
  ::[parent](http://w3id.org/rml/parent) "playerid"

### ballotYear

Not `bball:seasonYear`. A ballot year is the year of the vote, not of a season
played, and giving them one predicate would let a query join a ballot to the
team-season that happens to share its number.

::[reference](http://w3id.org/rml/reference) "ballotyear"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### votingBody

The raw label — "BBWAA", "Veterans - Golden Age Era", and twenty-four others.
The slugged form of this same column keys the subject IRI; this predicate
delivers what the register wrote.

::[reference](http://w3id.org/rml/reference) "votedby"

### ballotsCast

::[reference](http://w3id.org/rml/reference) "ballotscast"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### votesReceived

Absent on 1,983 ballots. Committee votes were frequently not published, and the
register leaves them empty rather than writing a zero that would read as
"considered and rejected unanimously".

::[reference](http://w3id.org/rml/reference) "votesreceived"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### votesNeeded

::[reference](http://w3id.org/rml/reference) "votesneeded"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### inducted

Y or N. Kept as the register's flag rather than lifted to a boolean: `xsd:boolean`
over text would need a cast whose failure mode is silent, and the two-value
domain is checked and stable.

::[reference](http://w3id.org/rml/reference) "inducted"

### inducteeCategory

Player, Manager, Umpire, Executive, Pioneer, or Pioneer/Executive.

::[reference](http://w3id.org/rml/reference) "category"

## AwardHonors

One `bball:AwardHonor` per row of `public.awardsplayers` — 12,667 rows.

The citation is part of the key, not a decoration on it: 492 groups of rows share
person, award, year and league exactly, separated only by the free-text note — a
Player of the Week won twice in one summer. A subject template that omitted it
would fuse those conferrals into one resource and lose the count.

The note is also NULL on 12,008 rows, and a NULL spliced into a template is fatal
rather than merely awkward: the engine's row-validity filter drops the whole row,
because SQL `concat` swallows a NULL and would otherwise mint an IRI from a
partial tuple. `COALESCE` to the empty string inside the slug expression is what
keeps those 12,008 conferrals in the graph; their IRIs simply end in a trailing
hyphen.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Query](http://w3id.org/rml/SQL2008Query)
::[iterator](http://w3id.org/rml/iterator) "SELECT playerid, yearid, lgid, awardid, tie, notes, trim(both '-' from regexp_replace(lower(awardid), '[^a-z0-9]+', '-', 'g')) AS awardkey, trim(both '-' from regexp_replace(lower(coalesce(notes, '')), '[^a-z0-9]+', '-', 'g')) AS citationkey, CAST(yearid AS integer) AS seasonyear FROM public.awardsplayers"
::[template](http://w3id.org/rml/template) "https://github.com/SemviaIO/lahman-baseball/award-honor/{playerid}-{awardkey}-{yearid}-{lgid}-{citationkey}"
::[class](http://w3id.org/rml/class) [AwardHonor](ontology#AwardHonor)

### player

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [People](people#People)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "playerid"
  ::[parent](http://w3id.org/rml/parent) "playerid"

### award

The award's name as the register spells it — "Most Valuable Player", "TSN
All-Star". Forty-six distinct values.

::[reference](http://w3id.org/rml/reference) "awardid"

### seasonYear

The season the award was for. Unlike a ballot year, this one does name a season,
so it shares the predicate a team-season uses.

::[reference](http://w3id.org/rml/reference) "seasonyear"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### league

::[reference](http://w3id.org/rml/reference) "lgid"

### sharedHonor

The register's tie flag, present on 659 rows and absent on the rest — an award
shared between two recipients in the same year.

::[reference](http://w3id.org/rml/reference) "tie"

### citation

The free-text note the register attaches: which position an All-Star selection
was at, which week a weekly award covered. Delivered raw, absent where the
register has nothing; the slugged copy is what keys the IRI.

::[reference](http://w3id.org/rml/reference) "notes"
