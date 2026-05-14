# Worked Examples

Real before/after pairs grounded in the cerberus design-contract.md. Use
these to calibrate when:
- A requirement is bundled and needs atomization.
- A requirement is technically atomic but its contract line is stuffed
  with scope, surfaces, examples, or term clarifications — push the
  detail into **Notes:**.
- A requirement is missing rationale and needs `<so that>` surfaced.
- A "requirement" is actually a constraint, design choice, or AC mis-typed.

## The slim line + Notes pattern

Every requirement aims for:

```markdown
#### R-N: Short title naming the property

*Functional.*  (or *NFR.*)

As a <role>, I need <one-clause behavior>, so that <one-clause rationale>.

**Notes:**
- <scope / surfaces>
- <term clarification, see glossary or pending>
- <cross-reference to related requirement>
```

The contract line is durable. The notes are mutable — prune as terms
move to glossary and cross-refs get wired.

## Example 1 — Format conversion with slim+notes

A clean shall-style requirement that needs the user-story wrap **and**
detail routed to notes.

**Before:**
> **R-7: Distribution controls capacity has no fixed ceiling.** *NFR.*
>
> The distribution access control mechanism does not impose a fixed
> capacity ceiling. The mechanism scales with the user's accessible-set
> size and the distinct grant population, not with a fixed bitmask width.

The original is short, but it bundles the property (no fixed ceiling)
with one implementation note (not a fixed bitmask width).

**After:**

```markdown
#### R-7: Distribution controls capacity has no fixed ceiling

*NFR.*

As a **platform architect**, I need the distribution access control
mechanism to scale with the accessible-set size and distinct grant
population, so that SAP-level deployments are supportable without
architectural rework.

**Notes:**
- "No fixed ceiling" means no fixed bitmask width, fixed enum, or
  hardcoded mechanism cap. The mechanism scales as the input population
  scales.
- Baseline today: ~25 markings, single-digit grant counts per user.
- Target: low thousands as a working figure, tens of thousands as a
  stress ceiling.
```

The contract line is short. The notes hold scope and clarification.
The "no bitmask width" detail is now a clarification of "no fixed
ceiling", not part of the contract.

## Example 2 — Splitting two actors

**Before:**
> Consumers can retrieve data with `classificationMarking` containing
> only CAPCO and CUI tokens. Providers can submit data with clean
> format and ownership is correctly determined regardless of whether
> they used old or new format during the dual-format window.

Two actors → two requirements.

**After:**

```markdown
#### R-1: Clean classification markings for consumers

*Functional.*

As a **data consumer**, I need `classificationMarking` to contain only
CAPCO and CUI tokens, so that consumer code does not parse distribution
tokens out of marking strings.

**Notes:**
- Applies on all consumer-facing surfaces: REST, Secure Messaging REST,
  AODR/Bulk Data, SCS.
- "Distribution tokens" = `PR-` / `DS-` prefixed tokens. *(pending
  glossary entry)*
- Pairs with [R-3](#r-3-clean-classification-markings-for-providers).

#### R-3: Clean classification markings for providers

*Functional.*

As a **data provider**, I need to submit data with clean
`classificationMarking` and have UDL correctly determine ownership
regardless of format used, so that I can migrate to clean ingest at my
own pace.

**Notes:**
- Applies during the dual-format window (both old composite and new
  clean formats accepted).
- Ownership-resolution applies regardless of format.
- Pairs with [R-1](#r-1-clean-classification-markings-for-consumers).
```

## Example 3 — Atomization with notes carrying clarifications

**Before (R-17):**
> On any record carrying a `classificationMarking`, the Government
> Access Control gate evaluates first. UDL Access Control runs only on
> records that pass the classification gate. Conditional grants run on
> top of UDL Access Control. The ordering is consistent across every
> surface that performs an access decision (REST, RLS, Java ACM, Kafka
> SM, AODR / Bulk, SCS, NiFi).

Two behaviors: (a) the ordering and (b) cross-surface consistency.

**After:**

```markdown
#### R-17a: Classification gate evaluates first

*Functional.*

As a **security officer**, I need the access-control pipeline to
evaluate classification → UDL Access Control → conditional grants in
that order on every record carrying a `classificationMarking`, so that
records failing classification never reach downstream evaluators.

**Notes:**
- Conditional grants cannot grant access to a record the user has no
  classification right to see.
- Pairs with [R-17b](#r-17b-access-gate-ordering-is-consistent-across-surfaces)
  for cross-surface consistency.
- Distinct from [R-18](#r-18-...) (decision parity) — this is ordering
  parity, not decision parity.

#### R-17b: Access-gate ordering is consistent across surfaces

*Functional.*

As a **security officer**, I need the access-gate ordering from
[R-17a](#r-17a-classification-gate-evaluates-first) to apply identically
on every enforcement surface, so that surface-specific drift cannot
produce different access decisions for the same (user, record) pair.

**Notes:**
- Surfaces: REST, RLS, Java ACM, Kafka SM, AODR/Bulk, SCS, NiFi.
- Per-surface implementation may vary; ordering must not.
- Distinct from [R-18](#r-18-...) (decision parity).
```

The surface enumeration is in R-17b's notes, not stuffed into the
contract line.

## Example 4 — Three-bundle atomization with notes

**Before (R-23, three paragraphs):**
The general preservation principle, NiFi-specific behaviors, and the
persona/scenario contract guarantee — all in one entry.

**After:**

```markdown
#### R-23a: Behavior preservation or explicit migration

*Functional.*

As an **integration partner**, I need every existing integration
behavior to be either preserved or explicitly migrated in the new
model, so that no production integration breaks silently during cutover.

**Notes:**
- "Preserved" = new model produces the same observable result.
- "Explicitly migrated" = new model produces a documented, deliberate
  replacement.
- No third disposition (silent drop) is allowed.

#### R-23b: NiFi behavior coverage

*Functional.*

As an **integration partner**, I need every behavior in the custom NiFi
integration to have a documented home in the new model, so that the
canonical orbital-data integration is not the one that breaks during
cutover.

**Notes:**
- Covered behaviors: content-routing rules, source reassignment,
  origin preservation, tag output, multi-step precedence, default-fallback.
- Concrete checklist verification: each NiFi behavior maps to one
  R-23a disposition.
- Pairs with [R-23a](#r-23a-behavior-preservation-or-explicit-migration)
  (the principle this verifies).

#### R-23c: Persona-scenario behavioral contract

*Functional.*

As a **delivery lead**, I need the persona and scenario set to be
treated as the behavioral contract the data model fulfills, so that
the cutover cannot quietly narrow what the model supports.

**Notes:**
- Every scenario-surfaced behavior earns a preservation or migration
  answer before cutover.
- Process discipline level (not per-integration verification — that's
  R-23a/b territory).
```

## Example 5 — Negative requirement

**Before:** (bundled list)
> Data owners cannot hide a live data product.

**After:**

```markdown
#### R-49: Data owner cannot hide a live DP

*Functional.*

As a **data owner**, I need the system to NOT allow me to hide a data
product once it is in the live state, so that consumers and downstream
integrations are not surprised by a product disappearing from production.

**Notes:**
- "Live state" = the DP has transitioned out of coming-soon and is
  advertised to consumers. *(pending glossary entry)*
- Platform admin retains hide capability for compliance takedowns (see
  [R-47](#r-47-platform-admin-hide-unhide)).
```

The "NOT" is explicit and stays in the contract line. The clarification
of "live state" goes in notes.

## Example 6 — Rationale push-back

A draft comes in with a rationale that just restates the behavior.

**Draft:**
> As a data consumer, I need `classificationMarking` to be clean,
> so that the marking is clean.

The `so that` adds nothing.

**Push-back:** "What breaks if the marking isn't clean? Why does the
consumer care?"

**Revised:**

```markdown
#### R-N: Clean classification markings for consumers

*Functional.*

As a **data consumer**, I need `classificationMarking` to contain only
CAPCO/CUI tokens, so that my parser can rely on a single grammar
without detecting-and-stripping distribution prefixes.

**Notes:**
- Distribution prefixes (`PR-`, `DS-`) may collide with future CUI
  dissemination tokens; clean separation prevents future parser
  ambiguity.
```

The "real consequence" (parser ambiguity, collision risk) is now in the
rationale or notes.

## Example 7 — Mis-typed entry

> Hibernate is the ORM, so injecting WHERE clauses into arbitrary
> Hibernate-generated SQL would require a SQL parsing engine. We use
> RLS.

This is a **constraint** (derived from a prior technology choice), not
a behavioral requirement. Flag it.

**Resolution:** lives as a `C-N` constraint, declarative format:

```markdown
#### C-1: RLS stays for Postgres

A unified ACM without RLS was explored and rejected. Hibernate ORM
generates complex query shapes (CTEs, subqueries, joins). Injecting
WHERE clauses into arbitrary Hibernate SQL would require a SQL parsing
engine. RLS remains for Postgres enforcement.

*Underlying choice: Hibernate as the ORM.*
```

Constraints do not use user-story format. They are facts/consequences,
not behaviors a stakeholder requests.

## Example 8 — Authoring from rough intent

**User input:** "I want a requirement that the access control mechanism
can scale beyond 25 markings without hitting a fixed bitmask ceiling."

**Output:**

```markdown
#### R-N: Government controls capacity has no fixed ceiling

*NFR.*

As a **platform architect**, I need the government controls mechanism
to scale with the distinct marking population, so that SAP-level
deployments are supportable without a mechanism rewrite.

**Notes:**
- "Government controls" = classification level, security controls,
  dissemination controls, releasability. *(pending glossary entry)*
- "No fixed ceiling" excludes fixed bitmask widths, fixed enums,
  hardcoded marking lists.
- Baseline today: ~25 markings. SAP scope: markings-per-program with
  users holding hundreds of program PIDs across SCI compartments.
- Future CUI/dissemination additions should not force a mechanism
  rewrite.
```

User's mention of "bitmask ceiling" landed as a clarification in notes,
not the contract line — the contract is about the scaling property,
not the alternative chosen.
