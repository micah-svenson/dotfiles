# Output Formats

The skill emits user-story-shaped requirements followed by an optional
**Notes:** section. Depending on where they land, you may need to wrap
them in a specific document format.

## Plain markdown (default)

```markdown
As a **data consumer**, I need `classificationMarking` to contain only
CAPCO and CUI tokens, so that consumer code does not parse distribution
tokens out of marking strings.

**Notes:**
- Applies on all consumer-facing surfaces: REST, Secure Messaging REST,
  AODR/Bulk Data, SCS.
- "Distribution tokens" = `PR-` / `DS-` prefixed tokens. *(pending
  glossary entry)*
- Pairs with R-3 (provider side).
```

## Cerberus design-contract.md format

The cerberus-docs project uses:

```markdown
#### R-N: Title in sentence case

*Functional.*  (or *NFR.*)

As a **<role>**, I need <behavior>, so that <rationale>.

**Notes:**
- <scope / surfaces / lifecycle>
- <term clarification — see glossary, or pending entry>
- <cross-references to related requirements>
```

**Rules:**
- Header: `####` (four hashes), sentence-case title, no trailing
  punctuation. Names the property, not the actor.
- Type marker: `*Functional.*` or `*NFR.*` on its own line.
- Contract line: short user-story sentence on a single (or wrapped)
  line.
- **Notes** section: optional. Use only when there's supporting context
  worth carrying. A requirement with no notes is fine — preferred when
  the contract line and rationale cover everything.
- Cross-references: `[R-N](#r-n-anchor-slug)`. Anchor slug is
  `r-n-title-in-kebab-case`.

**Full example:**

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
```

**Expanded-rationale example (rare):**

```markdown
#### R-16: No silent access changes

*NFR.*

As a **security officer**, I need every access-path change to run
dual-evaluate validation until parity is proven, so that:

- No user silently gains or loses access during the transition.
- Every access-control change is auditable.

**Notes:**
- Dual-evaluate is mandatory for core surfaces (RLS, Java ACM);
  per-surface technique can vary.
- Migration steps remain reversible because they were verified before
  commitment.
```

Use the expanded form only when the rationale genuinely has multiple
distinct motives flowing from one behavior. Most expanded rationales
are split signals in disguise.

**Provisional marker:** If the document supports it (R-46 in cerberus
uses one):

```markdown
*Functional. Provisional.*
```

## Cerberus constraint format (C-N)

Distinct from R-N. Constraints are facts or derived consequences, not
behaviors. **Do NOT use user-story format for constraints.**

```markdown
#### C-N: Title

Declarative paragraph stating the fact and its underlying choice.

*Underlying choice: <if Derived>.*
```

If the user asks you to write a "constraint" rather than a
"requirement", recognize the distinction. Constraints fall outside
this skill's primary output shape — but the skill should still flag
when a "requirement" is actually a constraint mis-typed (a behavioral
fact about the world, not a behavior some stakeholder needs).

## Jira story acceptance criteria

When a story implements a requirement, the AC on the story refers to
the requirement and adds story-level verification detail. The AC is
not the requirement.

```markdown
**Implements:** R-1 (Clean classification markings for consumers)

**Acceptance criteria:**
- GET /api/foo returns `classificationMarking` with only CAPCO/CUI
  tokens for a sample of records spanning U/C/S levels.
- An ingest job submitted with a clean-format marking is persisted
  with identical observable behavior to one submitted with the legacy
  composite format.

**Test instructions:** see story body.
```

The requirement is upstream. The AC is the story's verification claim
that the requirement is satisfied.

## Generic spec document

```markdown
**REQ-001 — Clean classification markings for consumers (Functional)**

As a data consumer, I need ..., so that ...

Notes:
- ...
```

Match whatever ID convention the document uses (REQ-N, FR-N, NFR-N).

## Picking the format

If the user is editing a specific document, read its existing entries
and match the shape. If the user is starting fresh, ask which document
this will land in or default to plain markdown.

When in doubt, emit the contract line + Notes block on its own and let
the user wrap.

## Notes section conventions across formats

**Bullets always.** No paragraphs inside notes.

**One thing per bullet.** If a bullet does two things, split.

**Glossary citation format:**
- Known term: `- "<term>" — see [Glossary](path#anchor).`
- Pending entry: `- "<term>" = <definition>. *(pending glossary entry)*`

**Cross-reference format:**
- Other requirement: `- Pairs with [R-N](#r-n-anchor) — <relationship>.`
- Multiple: list each on its own bullet.

**Scope clarification format:**
- `- Applies on <surfaces / lifecycle phases / contexts>.`

**Verification hint format (high-level only):**
- `- Verification: <one-line approach>.`

Detailed acceptance criteria stay on the implementing story, not in
notes.
