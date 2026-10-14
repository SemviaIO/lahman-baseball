# Stints

::[mappedBy](https://pkg.semvia.io/semvia/folio/mapping#mappedBy) RmlMappingMap

Projects `public.batting`, `public.pitching`, `public.fielding` and
`public.appearances` onto one class, `bball:Stint`.

> **Four relations, one subject.** The register already agrees that a player's
> batting line, pitching line, fielding line and appearance line for a stretch
> with one club in one season are facts about the same thing: all four tables key
> on `(playerid, yearid, stint, teamid)`. It just has no name for that thing, so
> a question that spans two of them is a join the asker has to write. The four
> TriplesMaps below mint the **same** subject template, so the join is already
> made and a two-way player's home runs and his earned run average are predicates
> on one resource.
>
> Every one of the 57,630 pitching rows and every one of the 127,079 distinct
> fielding stints has a batting row on the same four-column key — checked, not
> assumed — so the batting map is a superset of both. The appearances pivot is
> the exception, and the note under it says why.

> **Why all four maps repeat the identity edges.** `bball:player`, the
> `bball:teamSeason` edge and the `a bball:Stint` class triple are emitted by
> every map here, not by one designated map. Two reasons. A mapping document
> should be readable and correct on its own, without a reader having to know that
> deleting a sibling document would strand these subjects. And the repetition
> costs nothing: RDF is a set, the federation engine's unfolding closes with a
> dedup barrier over the full solution tuple before any `GROUP BY` folds it, so
> four identical `?stint bball:player ?p` rows collapse to one long before a
> `SUM` sees them. That barrier is the same one #4788's fix seats the aggregate
> above; the corpus entries that sum over stints are its live witnesses.

> **The predicate carve-out, restated where it bites.** Batting and pitching mint
> the same subject and their column names collide with opposite senses — home
> runs hit versus allowed, walks drawn versus issued, strikeouts suffered versus
> recorded, games played versus pitched. Only the batting map emits those four.
> The pitching map emits the four a batting line cannot carry: wins, losses,
> saves and earned run average. The ontology's property block carries the full
> argument; the consequence here is that `bball:homeRuns` on a stint always means
> *hit*, with no per-query disambiguation needed and none possible.

## BattingStints

One `bball:Stint` per row of `public.batting` — 128,598 rows, injective on the
four-column subject template.

`stint` is spliced raw into the subject and cast to `ordinal` for querying; the
template needs the text and a comparison needs the integer, and one column cannot
be both. `c_2b` and `c_3b` are the register's spelling of doubles and triples,
prefixed because a CSV header cannot start an identifier with a digit — the
conceptual names drop the survivor prefix along with the abbreviation.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Query](http://w3id.org/rml/SQL2008Query)
::[iterator](http://w3id.org/rml/iterator) "SELECT playerid, yearid, stint, teamid, lgid, CAST(stint AS integer) AS ordinal, CAST(g AS integer) AS games, CAST(ab AS integer) AS atbats, CAST(h AS integer) AS hits, CAST(c_2b AS integer) AS doubles, CAST(c_3b AS integer) AS triples, CAST(hr AS integer) AS homeruns, CAST(rbi AS integer) AS runsbattedin, CAST(sb AS integer) AS stolenbases, CAST(bb AS integer) AS walks, CAST(so AS integer) AS strikeouts FROM public.batting"
::[template](http://w3id.org/rml/template) "https://pkg.semvia.io/semvia/lahman-baseball/stint/{playerid}-{yearid}-{stint}-{teamid}"
::[class](http://w3id.org/rml/class) [Stint](ontology#Stint)

### player

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [People](people#People)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "playerid"
  ::[parent](http://w3id.org/rml/parent) "playerid"

### teamSeason

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [TeamSeasons](franchises-and-seasons#TeamSeasons)
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

Games played. The pitching relation counts games pitched in a column of the same
name, and does not share this predicate.

::[reference](http://w3id.org/rml/reference) "games"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### atBats

::[reference](http://w3id.org/rml/reference) "atbats"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### hits

::[reference](http://w3id.org/rml/reference) "hits"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### doubles

::[reference](http://w3id.org/rml/reference) "doubles"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### triples

::[reference](http://w3id.org/rml/reference) "triples"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### homeRuns

Home runs hit. A career total is a `SUM` over this predicate across a person's
stints, not a column on the person — the register stores no career line, and
inventing one in the conceptual layer would be asserting a fact no source holds.

::[reference](http://w3id.org/rml/reference) "homeruns"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### runsBattedIn

::[reference](http://w3id.org/rml/reference) "runsbattedin"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### stolenBases

Absent on 2,546 rows — the register did not record stolen bases league-wide until
1886, and the mapping leaves those stints without the predicate rather than
reading a blank as a zero.

::[reference](http://w3id.org/rml/reference) "stolenbases"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### walks

::[reference](http://w3id.org/rml/reference) "walks"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### strikeouts

::[reference](http://w3id.org/rml/reference) "strikeouts"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

## PitchingStints

One `bball:Stint` per row of `public.pitching` — 57,630 rows, minting the same
subject as the batting stint it always shares a key with.

Four predicates only, all of them unambiguous on a stint: no batting line carries
wins, losses, saves or an earned run average. Hits allowed, innings pitched and
the rest of the pitching line need predicates of their own before they can be
mapped, and they do not have them yet.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Query](http://w3id.org/rml/SQL2008Query)
::[iterator](http://w3id.org/rml/iterator) "SELECT playerid, yearid, stint, teamid, lgid, CAST(w AS integer) AS wins, CAST(l AS integer) AS losses, CAST(sv AS integer) AS saves, CAST(era AS numeric) AS earnedrunaverage FROM public.pitching"
::[template](http://w3id.org/rml/template) "https://pkg.semvia.io/semvia/lahman-baseball/stint/{playerid}-{yearid}-{stint}-{teamid}"
::[class](http://w3id.org/rml/class) [Stint](ontology#Stint)

### player

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [People](people#People)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "playerid"
  ::[parent](http://w3id.org/rml/parent) "playerid"

### teamSeason

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [TeamSeasons](franchises-and-seasons#TeamSeasons)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "teamid"
  ::[parent](http://w3id.org/rml/parent) "teamid"
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "yearid"
  ::[parent](http://w3id.org/rml/parent) "yearid"
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "lgid"
  ::[parent](http://w3id.org/rml/parent) "lgid"

### wins

::[reference](http://w3id.org/rml/reference) "wins"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### losses

::[reference](http://w3id.org/rml/reference) "losses"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### saves

::[reference](http://w3id.org/rml/reference) "saves"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### earnedRunAverage

Cast to `numeric`, not to `integer` — the source stores it as decimal text.
`xsd:decimal` over a Postgres `numeric` is the one datatype declaration in this
package whose pushdown is not exercised by any corpus entry, so treat a decline
here as unmeasured rather than as known-good.

::[reference](http://w3id.org/rml/reference) "earnedrunaverage"
::[datatype](http://w3id.org/rml/datatype) [decimal](http://www.w3.org/2001/XMLSchema#decimal)

## FieldingStints

One `bball:Stint` per row of `public.fielding` — but 174,332 rows over 127,079
distinct stints, because the register records a **separate row per position
played**. The subject template does not splice `pos`, so a stint spent at two
positions carries two putout counts, two assist counts and two error counts on
one resource.

That is the honest projection of a source whose grain is finer than the entity's,
and the `bball:Stint` shape declines to cap those paths at 1 for exactly that
reason: a cap would report the register as invalid when what is actually true is
that the model is one level coarser than the table. A query that wants per-
position fielding numbers needs a resource per position, which this package does
not mint; a query that wants a stint's total needs `SUM`, not a lookup.

This map does **not** emit `bball:position`. The appearances pivot below does,
at a grain the two would otherwise fight over — see the note there.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Query](http://w3id.org/rml/SQL2008Query)
::[iterator](http://w3id.org/rml/iterator) "SELECT playerid, yearid, stint, teamid, lgid, CAST(po AS integer) AS putouts, CAST(a AS integer) AS assists, CAST(e AS integer) AS errors FROM public.fielding"
::[template](http://w3id.org/rml/template) "https://pkg.semvia.io/semvia/lahman-baseball/stint/{playerid}-{yearid}-{stint}-{teamid}"
::[class](http://w3id.org/rml/class) [Stint](ontology#Stint)

### player

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [People](people#People)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "playerid"
  ::[parent](http://w3id.org/rml/parent) "playerid"

### teamSeason

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [TeamSeasons](franchises-and-seasons#TeamSeasons)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "teamid"
  ::[parent](http://w3id.org/rml/parent) "teamid"
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "yearid"
  ::[parent](http://w3id.org/rml/parent) "yearid"
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "lgid"
  ::[parent](http://w3id.org/rml/parent) "lgid"

### putouts

::[reference](http://w3id.org/rml/reference) "putouts"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### assists

::[reference](http://w3id.org/rml/reference) "assists"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

### errors

::[reference](http://w3id.org/rml/reference) "errors"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)

## PositionAppearances

The unflatten. `public.appearances` is one row per player-season-team with
**thirteen position columns side by side** — `g_p`, `g_c`, `g_1b`, `g_2b`,
`g_3b`, `g_ss`, `g_lf`, `g_cf`, `g_rf`, `g_of`, `g_dh`, `g_ph`, `g_pr` — a
spreadsheet shape, not a relational one. RDF has no column position, so the
predicate would have to be `bball:gamesAtShortstop`, `bball:gamesAtCatcher` and
eleven more: thirteen predicates encoding one dimension, and a query asking "what
position did they play" unable to be written without naming all thirteen.

The `rml:SQL2008Query` source below turns the columns into rows — thirteen
`UNION ALL` branches, one per position, each lifting the position code into a
`pos` value and the count into `gamesatposition`. One predicate pair comes out:
`bball:position` and `bball:gamesAtPosition`, paired one-to-one per row.

> **Why this is the escape hatch and not a workaround.** RML's own answer to a
> source whose shape does not match the model is RML-LV's `rml:logicalView`, and
> the collection-and-container extension's `rml:gather`. The federation engine
> admits neither. `rml:SQL2008Query` is the admitted seam: the walker treats the
> SQL text as opaque and hands it to the source, so the reshaping happens where
> the source can optimize it. The engine sees a relation with a `pos` column and
> a `gamesatposition` column and never learns it was a pivot.

> **The `CAST` is load-bearing.** Every column in the Lahman database is `text`.
> Declaring `rml:datatype xsd:integer` over `text` is legal and would deliver
> Arrow `Utf8`, so the engine's declared-versus-delivered parity check would
> correctly refuse to push an `ORDER BY ?games` or a `SUM` into Postgres — safe,
> and slow. The cast lives in the SQL text, so the delivered type is `Int32` and
> the parity check holds.

> **The four totals columns are deliberately dropped.** `g_all`, `gs`,
> `g_batting` and `g_defense` are not positions; they are sums over the row.
> Pivoting them would put `bball:position "g_all"` next to `bball:position "SS"`
> and every aggregate over the predicate would double-count. A consumer wanting a
> season total sums `bball:gamesAtPosition`, which is what the totals columns
> already are — except for `g_of`, which is itself the sum of `g_lf`, `g_cf` and
> `g_rf` and is kept because the register uses it alone for seasons predating the
> split. A sum over all thirteen therefore over-counts an outfielder's games, and
> a consumer that wants a clean total should exclude either `OF` or the three
> corner codes. This is a wart of the source, carried forward rather than papered
> over.

> **The stint-ordinal edge case, stated plainly.** `appearances` has no `stint`
> column. It is one row per player-season-**team**, where batting, pitching and
> fielding are one row per player-season-stint-team. The pivot therefore pins
> `'1' AS stint` — a constant, visible in the SQL text above any reader's
> objection. For the 9,725 player-seasons with more than one stint, covering
> 20,324 appearances rows, that constant is wrong whenever the appearance belongs
> to stint 2 or later, and 10,634 of the pivot's subjects have no batting row at
> stint 1 at all. Those position facts attach to a stint-1 subject for the right
> team and the right season, and to a stint ordinal that may not be the one the
> other three relations would give. Recovering the true ordinal means joining
> back to `batting` on the team, which is a fifth relation inside a source query
> whose whole purpose was to reshape a fourth — the cost is not worth it for a
> package whose job is to exercise a federation engine, and a reader who needs
> per-stint position numbers should know they are not here.
>
> The `> 0` filter in the outer `WHERE` drops the position-seasons a player never
> appeared in. Without it every row would carry thirteen position facts, nearly
> all of them zero, and the mapping would assert that Derek Jeter caught in zero
> games — a triple that is true and useless. 324,812 rows survive the filter.

::[source](http://w3id.org/rml/source) [semvia-test-data](connection#semvia-test-data)
::[referenceFormulation](http://w3id.org/rml/referenceFormulation) [SQL2008Query](http://w3id.org/rml/SQL2008Query)
::[iterator](http://w3id.org/rml/iterator) "SELECT playerid, yearid, stint, teamid, lgid, pos, gamesatposition FROM (SELECT playerid, yearid, '1' AS stint, teamid, lgid, 'P' AS pos, CAST(g_p AS integer) AS gamesatposition FROM public.appearances UNION ALL SELECT playerid, yearid, '1', teamid, lgid, 'C', CAST(g_c AS integer) FROM public.appearances UNION ALL SELECT playerid, yearid, '1', teamid, lgid, '1B', CAST(g_1b AS integer) FROM public.appearances UNION ALL SELECT playerid, yearid, '1', teamid, lgid, '2B', CAST(g_2b AS integer) FROM public.appearances UNION ALL SELECT playerid, yearid, '1', teamid, lgid, '3B', CAST(g_3b AS integer) FROM public.appearances UNION ALL SELECT playerid, yearid, '1', teamid, lgid, 'SS', CAST(g_ss AS integer) FROM public.appearances UNION ALL SELECT playerid, yearid, '1', teamid, lgid, 'LF', CAST(g_lf AS integer) FROM public.appearances UNION ALL SELECT playerid, yearid, '1', teamid, lgid, 'CF', CAST(g_cf AS integer) FROM public.appearances UNION ALL SELECT playerid, yearid, '1', teamid, lgid, 'RF', CAST(g_rf AS integer) FROM public.appearances UNION ALL SELECT playerid, yearid, '1', teamid, lgid, 'OF', CAST(g_of AS integer) FROM public.appearances UNION ALL SELECT playerid, yearid, '1', teamid, lgid, 'DH', CAST(g_dh AS integer) FROM public.appearances UNION ALL SELECT playerid, yearid, '1', teamid, lgid, 'PH', CAST(g_ph AS integer) FROM public.appearances UNION ALL SELECT playerid, yearid, '1', teamid, lgid, 'PR', CAST(g_pr AS integer) FROM public.appearances) pivot WHERE gamesatposition > 0"
::[template](http://w3id.org/rml/template) "https://pkg.semvia.io/semvia/lahman-baseball/stint/{playerid}-{yearid}-{stint}-{teamid}"
::[class](http://w3id.org/rml/class) [Stint](ontology#Stint)

### player

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [People](people#People)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "playerid"
  ::[parent](http://w3id.org/rml/parent) "playerid"

### teamSeason

::[parentTriplesMap](http://w3id.org/rml/parentTriplesMap) [TeamSeasons](franchises-and-seasons#TeamSeasons)
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "teamid"
  ::[parent](http://w3id.org/rml/parent) "teamid"
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "yearid"
  ::[parent](http://w3id.org/rml/parent) "yearid"
::[joinCondition](http://w3id.org/rml/joinCondition)
  ::[child](http://w3id.org/rml/child) "lgid"
  ::[parent](http://w3id.org/rml/parent) "lgid"

### position

One of P, C, 1B, 2B, 3B, SS, LF, CF, RF, OF, DH, PH, PR — the branch's own
constant, not a source column. Multi-valued on a stint by design.

::[reference](http://w3id.org/rml/reference) "pos"

### gamesAtPosition

::[reference](http://w3id.org/rml/reference) "gamesatposition"
::[datatype](http://w3id.org/rml/datatype) [integer](http://www.w3.org/2001/XMLSchema#integer)
