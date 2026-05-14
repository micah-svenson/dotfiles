# Atomicity Rules

A requirement is atomic when it captures **one behavior, one verification,
one rationale**. This file collects the rules, the split signals, and the
techniques for getting there.

## The core test

If you cannot write a single test (or single observation procedure) that
verifies the requirement, it is not atomic. Split it.

## INVEST (originally for user stories, applied here to requirements)

| Letter | Means | Check |
|---|---|---|
| **I**ndependent | Requirement stands alone | Could this requirement be removed without affecting whether other requirements are testable? |
| **N**egotiable | The shape is open to refinement | Requirement states intent, not a fixed contract |
| **V**aluable | A stakeholder cares | `<role>` and `<so that>` both name real parties / consequences |
| **E**stimable | Implementation cost can be reasoned about | Behavior is concrete enough to scope |
| **S**mall | Focused and bounded | One behavior, one verification |
| **T**estable | Verifiable | A test or observation procedure exists |

The first letter (Independent) and last letter (Testable) are the two most
load-bearing checks for atomicity.

## IEEE 29148 characteristics (relevant subset)

ISO/IEC/IEEE 29148:2018 names nine characteristics. For atomicity, four
matter most:

- **Singular** — states a single capability, characteristic, constraint, or
  quality factor. Contains no conjunctions joining capabilities.
- **Unambiguous** — interpretable in only one way.
- **Verifiable** — the requirement's realization is verifiable.
- **Complete** — defines the necessary capability without needing external
  context to interpret.

The skill's "Quality checklist" in `SKILL.md` is a working subset of these.

## Split signals

When you see any of these in a requirement, suspect atomicity violation:

### Structural signals

- **Multiple paragraphs** in one entry. A requirements catalog is not a
  design doc; one requirement = one short paragraph (or one expanded
  bulleted form).
- **A list of behaviors** dressed as one requirement.
- **Sub-headings within a single requirement** (e.g., R-23 with separate
  paragraphs for "the principle", "the canonical example", and "the
  contract guarantee" — that's three requirements).

### Linguistic signals

- Conjunctions joining capabilities: **"and", "also", "additionally",
  "as well as", "in addition to", "plus".**
- Lists of comma-separated capabilities ("X, Y, and Z all happen").
- "Including X, Y, Z" where X/Y/Z are distinct behaviors, not examples of
  one.
- Sentences containing both a positive and a negative requirement.

### Semantic signals

- **Multiple actors implied** in the same requirement.
- **Multiple surfaces** mentioned with distinct behaviors per surface
  (vs one behavior consistent across all surfaces).
- **Multiple lifecycle phases** with different rules.
- **Multiple domains** (e.g., consumer behavior + provider behavior in
  the same entry).
- The rationale (`<so that>`) lists distinct consequences that don't share
  a common cause.

## Splitting techniques

### Split by actor

If two distinct actors care about distinct aspects, give them their own
requirements.

> Before: "Consumers can retrieve clean markings, and providers can submit
> clean markings."
>
> After:
> - **R-1a:** As a data consumer, I need to retrieve data with clean
>   classification markings, so that consumer code doesn't parse
>   distribution tokens.
> - **R-1b:** As a data provider, I need to submit data with clean
>   classification markings, so that ownership and access controls are
>   assigned correctly regardless of format used during the dual-format
>   window.

### Split by behavior / capability

If two distinct behaviors are bundled even with one actor, split.

> Before: "The classification gate evaluates first, and the gate ordering
> is consistent across every surface."
>
> After:
> - **R-17a:** As a security officer, I need the classification gate to
>   evaluate first on every record carrying a `classificationMarking`,
>   so that records without classification clearance never reach
>   UDL Access Control logic.
> - **R-17b:** As a security officer, I need the access-gate ordering
>   (classification → UDL AC → conditional grants) to be identical on
>   every enforcement surface, so that surface-specific drift cannot
>   produce different access outcomes for the same (user, record).

### Split by surface / context

If a single behavior holds across surfaces but each surface has its own
verification, the **principle** is one requirement and the **per-surface
verification** is acceptance criteria on the implementing stories, not
new requirements. But if the behavior actually differs per surface, split.

### Split by happy path vs edge case / negative

If a single entry mixes the positive ("X works") and the negative ("X must
not Y"), split. Negative requirements are valid but deserve their own
entry with their own rationale.

> Before: "Data owners can transition their DP from coming-soon to live,
> and cannot hide a DP once it is live."
>
> After:
> - **R-48:** As a data owner, I need to transition my data product from
>   coming-soon to live, so that consumers see the product is available
>   when I'm ready.
> - **R-49:** As a data owner, I need the system to NOT allow me to hide
>   a live data product, so that consumers and downstream integrations
>   are not surprised by a product disappearing from production.

### Split by lifecycle phase

If a requirement says "during migration, X; after migration, Y", split.
Those are two contracts.

## When NOT to split

- When a behavior really is one verifiable contract that mentions multiple
  surfaces, examples, or details for clarity — but those details are
  examples, not separate behaviors.
- When the behavior is short and the rationale has a single coherent
  motive expressed in bullets for readability.
- When splitting would force you to invent stakeholders or duplicate the
  rationale across multiple entries.

A useful sanity check: **could you fail the test for one of the proposed
sub-requirements while passing the others?** If yes, the split is real.
If failing one necessarily fails all of them, they are facets of one
requirement.

## Worked split — R-23 (from cerberus design-contract.md)

The original (paraphrased):
> R-23: Preserve existing production integration behaviors.
>
> The new model accounts for every behavior the existing custom production
> integrations support today. Each behavior is either preserved (the new
> model produces the same observable result) or explicitly migrated (the
> new model produces a documented, deliberate replacement). Nothing is
> dropped silently.
>
> The custom NiFi integration is the canonical example: every
> content-routing rule, source reassignment, origin preservation, tag
> output, multi-step rule precedence, and default-fallback behavior must
> have a documented home in the new model. The same principle applies to
> every other in-production integration across the surface area.
>
> Personas and scenarios serve as the behavioral contract the data model
> must fulfill. This requirement guarantees the contract is not quietly
> narrowed during the cutover. [...]

This is three behaviors bundled:

1. **The principle**: every existing behavior is preserved or explicitly
   migrated.
2. **The canonical NiFi example**: specific NiFi behaviors must each have
   a documented home.
3. **The contract guarantee**: personas/scenarios are the contract that
   cannot be silently narrowed.

Atomized:

> **R-23a — Behavior preservation or explicit migration.**
> As an integration partner, I need every behavior my existing production
> integration depends on to be either preserved unchanged or explicitly
> migrated to a documented replacement in the new model, so that no
> integration breaks silently during cutover.

> **R-23b — NiFi behavior coverage.**
> As an integration partner, I need every content-routing rule, source
> reassignment, origin preservation, tag output, multi-step precedence
> rule, and default-fallback in the custom NiFi integration to have a
> documented home in the new model, so that the canonical orbital-data
> ownership path is not the integration that breaks during cutover.

> **R-23c — Persona-scenario behavioral contract.**
> As a delivery lead, I need the persona and scenario set to be treated as
> the behavioral contract the data model fulfills, so that the cutover
> cannot quietly narrow what the model supports without explicit
> migration disclosure.

Each can be tested independently. R-23a is the principle. R-23b is the
NiFi-specific verification. R-23c is the process-level guarantee that
prevents narrowing.
