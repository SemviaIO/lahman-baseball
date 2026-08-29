-- Physical structure for the relations this package's mappings project.
--
-- This file is a TRANSCRIPT, not a proposal. Every index below already exists
-- on the `lahman` database in the semvia-test-data Neon instance, verified
-- against `pg_indexes` on 2026-08-29. It is committed here because a semantic
-- package that describes a relation's MEANING and says nothing about its
-- PHYSICAL LAYOUT ships half a description: the federation engine's pushdown
-- planner assumes a relational source prunes on an indexed key
-- (`PushdownProfile`, crates/vkg-federation/src/federation/capability.rs), and
-- it has no way to learn which columns those are. Recording them makes the
-- assumption auditable and makes the drift visible when it happens.
--
-- Every statement is IF NOT EXISTS, so applying this to the live database is a
-- no-op today. It is not a migration; it is the answer to "what does this
-- package need to be true of its source for the demo queries to hold their
-- latency budget."
--
-- See SemviaIO/SemviaIO#5152 for the open design question this file stands in
-- for: physical structure belongs in the modelling→ingest pipeline as declared
-- metadata, not as hand-applied DDL that a package transcribes after the fact.
--
-- ---------------------------------------------------------------------------
-- What is NOT here, and why that matters more than what is
-- ---------------------------------------------------------------------------
--
-- Nine of the fourteen relations this package maps carry no index at all:
-- `teamsfranchises`, `parks`, `schools`, `homegames`, `halloffame`,
-- `awardsplayers`, `collegeplaying`, `managers`, and `teams` beyond the two
-- columns noted below. Each of those is the parent side of at least one
-- `rml:RefObjectMap` join, so every one of those joins is a sequential scan of
-- the parent. The relations are small — 203 to 17,687 rows — so this is a
-- deliberate non-problem rather than an oversight, but a query that reports a
-- surprising latency should look here before it looks at the planner.
--
-- The engine also reads uniqueness for a second purpose beyond selectivity:
-- `subject_key_columns` (crates/vkg-federation/src/bridge.rs) will fuse a
-- subject-mint to a source key only when a UNIQUE index's columns are exactly
-- the columns the subject template splices. Two of the three unique indexes
-- below meet that bar; the third does not, and the note there says why.

-- ---------------------------------------------------------------------------
-- public.people — 24,270 rows, the person register
-- ---------------------------------------------------------------------------

-- The subject key, and the one place in this package where template, index and
-- entity all agree exactly. `People` mints `/person/{playerid}` from this single
-- column, so the UNIQUE index's column set IS the template's placeholder set and
-- the mint fuses. Every other class in the package joins back to this column to
-- resolve a name, which makes it the busiest key in the schema.
CREATE UNIQUE INDEX IF NOT EXISTS idx_people_playerid
  ON public.people USING btree (playerid);

-- Name lookup, split across the two name columns because the corpus asks about
-- them separately: a query filters on `bball:familyName "Jeter"` and then on
-- `bball:givenName "Derek"`, and a composite index on (namelast, namefirst)
-- would serve the first and not the second.
--
-- `lower(...)` with `text_pattern_ops` answers anchored prefix search
-- case-insensitively — the shape a type-ahead produces. An index on the raw
-- column cannot serve a lowered predicate, and the default `text_ops` opclass
-- cannot serve `LIKE 'x%'` on a non-C collation.
CREATE INDEX IF NOT EXISTS idx_people_namelast
  ON public.people USING btree (lower(namelast) text_pattern_ops);

CREATE INDEX IF NOT EXISTS idx_people_namefirst
  ON public.people USING btree (lower(namefirst) text_pattern_ops);

-- ---------------------------------------------------------------------------
-- public.teams — 3,614 rows, one club per season
-- ---------------------------------------------------------------------------

-- The near-miss. `TeamSeasons` mints `/team-season/{yearid}-{teamid}-{lgid}`
-- from THREE columns; this UNIQUE index covers two of them. It is genuinely
-- unique — no club plays in two leagues in one season — but the engine's fusion
-- test is column-set equality, not implication, so a two-column key under a
-- three-column template does not fuse. That is the conservative answer and the
-- right one: proving the third column redundant needs a functional dependency
-- the index does not declare.
--
-- The index still earns its place. Every `bball:teamSeason` RefObjectMap in the
-- package joins on (teamid, yearid, lgid), and this index serves the leading two
-- columns of that predicate, which is what turns 128,598 batting-stint joins
-- into index lookups rather than a hash build over the whole relation.
CREATE UNIQUE INDEX IF NOT EXISTS idx_teams_team_year
  ON public.teams USING btree (teamid, yearid);

CREATE INDEX IF NOT EXISTS idx_teams_name
  ON public.teams USING btree (lower(name) text_pattern_ops);

-- ---------------------------------------------------------------------------
-- public.batting, public.pitching, public.fielding — the three stint relations
-- ---------------------------------------------------------------------------

-- (playerid, yearid) on each, not the full four-column stint key. The queries
-- that matter here start from a person and gather a career — "every stint for
-- this player" — so the leading column is what prunes, and `yearid` orders the
-- result the way the query wants to read it. Adding `stint` and `teamid` would
-- make the index cover the subject template exactly, but no query in the corpus
-- looks a stint up by its full key, and none of the three relations has a UNIQUE
-- constraint to fuse against regardless.
--
-- Note the asymmetry with `fielding`: it holds 174,332 rows over 127,079
-- distinct stints, because it records one row per position played. The index
-- does not distinguish them and neither does the mapping — see `schema/stints.md`
-- for why that fan-out is carried forward rather than collapsed.
CREATE INDEX IF NOT EXISTS idx_batting_player
  ON public.batting USING btree (playerid, yearid);

CREATE INDEX IF NOT EXISTS idx_pitching_player
  ON public.pitching USING btree (playerid, yearid);

CREATE INDEX IF NOT EXISTS idx_fielding_player
  ON public.fielding USING btree (playerid, yearid);

-- ---------------------------------------------------------------------------
-- public.appearances — 128,512 rows, the flattened position table
-- ---------------------------------------------------------------------------

-- Two indexes for the two directions the pivot is read from. The player index
-- answers "what positions did this person play", which is the corpus's shape;
-- the team-year index answers "who played for this club that season", which is
-- what the `bball:teamSeason` join needs from the child side.
--
-- Both matter more here than on the other stint relations, because the mapping
-- reads this table through a thirteen-branch `UNION ALL` — the planner sees
-- thirteen scans of `appearances`, and a predicate that prunes is worth thirteen
-- times what it is worth elsewhere.
CREATE INDEX IF NOT EXISTS idx_appearances_player
  ON public.appearances USING btree (playerid, yearid, teamid);

CREATE INDEX IF NOT EXISTS idx_appearances_team_year
  ON public.appearances USING btree (teamid, yearid);

-- ---------------------------------------------------------------------------
-- Name lookup on the remaining labelled relations
-- ---------------------------------------------------------------------------

-- Same opclass argument as `people`. These three are the label side of the joins
-- the corpus uses to turn an IRI into something a reader recognizes — a
-- franchise name, a school name, a ballpark name — and every one of those joins
-- runs against a relation with no key index at all, so the name index is the
-- only physical structure those queries can use.
CREATE INDEX IF NOT EXISTS idx_franchises_name
  ON public.teamsfranchises USING btree (lower(franchname) text_pattern_ops);

CREATE INDEX IF NOT EXISTS idx_schools_name
  ON public.schools USING btree (lower(name_full) text_pattern_ops);

CREATE INDEX IF NOT EXISTS idx_parks_name
  ON public.parks USING btree (lower(parkname) text_pattern_ops);
