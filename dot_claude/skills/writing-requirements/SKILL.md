---
name: writing-requirements
description: >
  Write slim, atomic, independently-verifiable software requirements in
  user-story format ("As a <role>, I need <behavior>, so that <rationale>")
  with an optional **Notes:** section for supporting context (scope,
  cross-references, pending glossary entries). Use this skill whenever the
  user is authoring, refining, or rewriting any requirement, design-contract
  item, spec entry, or NFR — especially when an existing requirement is
  multi-paragraph, bundles multiple behaviors, lacks a clear rationale, or
  reads like a wall of prose because scope and clarifications are stuffed
  into the contract line. Also use when the user wants to audit a
  requirements document for notes that should be promoted to a glossary or
  split into separate requirements. Triggers on phrases like "write a
  requirement", "capture this as a requirement", "add to the design
  contract", "these requirements are too big", "split this requirement",
  "atomize this", "trim this requirement", "add an NFR", "rewrite this
  requirement", "the rationale is missing", "audit my requirements notes",
  "promote to glossary", or any work on requirement-like artifacts that
  need a clear actor, single behavior, a so-that motive, and clean
  separation between the durable contract and the mutable supporting notes.
---

# Writing Requirements

You help the user author and rewrite software requirements that are
**atomic, slim, independently verifiable, and carry their rationale**.

Every requirement comes out in user-story shape, optionally followed by a
**Notes:** section:

> **As a `<role>`, I need `<behavior>`, so that `<rationale>`.**
>
> **Notes:**
> - Scope, surface, lifecycle clarifications.
> - Term clarifications (with glossary pointers).
> - Cross-references to related requirements.

The user-story line is the **durable contract**. The notes are **mutable
supporting context** — they exist so the contract line stays slim. Notes
are pruned over time as terms move into the glossary or facts get
promoted into their own requirements.

## When to use this skill

- The user is writing a new requirement, spec line, or design-contract entry.
- The user wants to rewrite an existing requirement that reads as a
  paragraph, bundles multiple behaviors, or is vague about who cares and why.
- The user wants to atomize a bundled requirement into independently
  verifiable pieces.
- The user wants to trim down requirements that pass atomicity formally
  but still feel dense because scope and clarifications are stuffed into
  the contract line.
- The user wants to audit the notes across a requirements document and
  promote them to a glossary or new requirements.

Do **not** use this skill for: acceptance criteria on a story (those live
on the story and use a different shape), implementation notes, design
decisions, or pure documentation prose.

## Three modes

### Mode 1 — Author from intent

The user describes a goal, behavior, or constraint. You produce one or
more atomic requirements with slim contract lines and supporting notes.

1. Identify the actor.
   - If user-facing: pick the role directly (data consumer, marketplace
     buyer, etc.).
   - If non-user-facing (NFR, system property, constraint): run
     **stakeholder discovery** — "whose problem does this solve? who
     notices first if this is violated?" See
     `references/nfr-stakeholder-catalog.md`.
2. Draft the **contract line** (`As a ..., I need ..., so that ...`).
   Keep it short. Behavior clause states the single contract; rationale
   clause states the single primary consequence. Aim for one short
   sentence end-to-end.
3. Identify everything that **didn't fit** in the contract line and route
   it:
   - Scope/applicability/surfaces → **Notes:**.
   - Term clarifications → **Notes:** (and check glossary, see below).
   - Cross-references to related requirements → **Notes:**.
   - Additional behaviors → **a separate requirement** (split, don't
     stuff).
   - Implementation details → drop. Not part of the requirement.
4. Run **glossary scan** (below) for any terms-of-art you used. Cite
   existing glossary entries; flag pending entries inline in notes.
5. Run the **quality checklist** below.
6. If the input describes more than one behavior, switch to Mode 2.

### Mode 2 — Atomize an existing requirement

The user provides an existing requirement (often multi-paragraph or
multi-behavior). You split it into N atomic requirements with slim
contract lines and notes.

1. Scan for **split signals**:
   - Multiple paragraphs in one entry.
   - Conjunctions joining distinct capabilities ("and", "also").
   - Multiple actors implied.
   - Multiple surfaces, lifecycle phases, or domains bundled.
   - A list of behaviors masquerading as one requirement.
2. Identify the underlying behaviors. Group only what shares **one actor,
   one verification approach, and one rationale**.
3. Propose N atomic requirements. Map the split (e.g., "R-23 splits into
   R-23a, R-23b, R-23c"). Final IDs are renumbered by the document owner.
4. For each new requirement:
   - Draft a slim contract line.
   - **Check for negative / exclusion framing in the original** ("does
     not impose a ceiling", "not with a fixed bitmask width"). If
     present, ask what the requirement is *positively* requiring and
     write the contract line in the positive form. The exclusion goes
     to **Notes:** if useful, or gets dropped. See "Anti-patterns" for
     the full rationale.
   - Route scope, clarifications, and cross-refs to **Notes:**.
   - Run the glossary scan.
5. Run the quality checklist on each.
6. Flag any behavior in the original that you could not assign to a new
   requirement — it may be a constraint, design note, or AC mis-typed
   as a requirement.

### Mode 3 — Audit notes across a requirements doc

The user wants to clean up accumulated notes across a requirements
document. You scan all `**Notes:**` sections and propose actions.

1. Read the requirements document and (if present) the glossary.
2. Build an inventory of every notes bullet across every requirement.
3. Classify each bullet:
   - **Promote to glossary**: a term-of-art used in multiple
     requirements that should be defined once globally.
   - **Promote to new requirement**: a fact that describes an
     independently verifiable behavior, not just supporting context.
   - **Promote cross-ref**: a relationship that should be wired in as a
     proper link (and the note removed once the link exists).
   - **Prune**: the note is now redundant because the term has been
     glossarized or the cross-ref exists or the fact has been split into
     its own requirement.
   - **Keep**: the note is still earning its place as ephemeral
     clarification.
4. Propose one action at a time. For glossary promotions, draft the
   glossary entry. For new-requirement promotions, draft the requirement
   in Mode 1 style. For prunes, show what to remove.
5. After each action lands, re-scan the affected requirement's notes —
   some prunes cascade.

## The format

### Slim contract line (the durable part)

> As a `<role>`, I need `<behavior>`, so that `<rationale>`.

**Style:**
- One short sentence end-to-end. If you can't say it in one short
  sentence, ask whether you're stuffing scope or examples into the
  behavior clause (route them to notes) or whether you actually have two
  requirements (split).
- Behavior clause states the contract, not its conditions, scope, or
  examples.
- Rationale clause states the consequence, not its elaboration.

**Examples (slim):**

> As a **data consumer**, I need `classificationMarking` to contain only
> CAPCO and CUI tokens, so that consumer code does not parse distribution
> tokens out of marking strings.

> As a **platform architect**, I need the government controls mechanism
> to scale with the distinct marking population (no fixed capacity
> ceiling), so that SAP-level deployments are supportable without
> re-architecting the access path.

### Notes section (the mutable part)

> **Notes:**
> - Scope, applicability, surfaces.
> - Term clarifications (with glossary pointers or "pending glossary
>   entry" markers).
> - Cross-references to related requirements.
> - Verification hints (high-level — full ACs belong on stories).
> - Open questions or pending decisions.

**Style:**
- Bullet list, short bullets. Each bullet does one thing.
- Do NOT use notes to expand the behavior or rationale. If a fact is
  part of the contract, it belongs in the contract line. Notes are
  context, not contract.
- Notes are mutable. Pruning notes does not weaken the requirement.

**Example (full):**

```markdown
#### R-1: Clean classification markings for consumers

*Functional.*

As a **data consumer**, I need `classificationMarking` to contain only
CAPCO and CUI tokens, so that consumer code does not parse distribution
tokens out of marking strings.

**Notes:**
- Applies on all consumer-facing surfaces: REST, Secure Messaging REST,
  AODR/Bulk Data, SCS.
- "Distribution tokens" = `PR-` and `DS-` prefixed tokens. *(pending
  glossary entry)*
- Pairs with [R-3](#r-3-clean-classification-markings-for-providers).
```

### What goes where: the routing rules

| Fact | Belongs in |
|---|---|
| The single contract (one behavior, one rationale) | User-story line |
| Scope across surfaces / contexts | Notes |
| Term clarifications | Notes (cite glossary) or Glossary |
| Cross-references to related requirements | Notes |
| Examples that illustrate but aren't the contract | Notes |
| Verification approach (high-level) | Notes |
| Detailed acceptance criteria | NOT here — story-level ACs |
| Implementation specifics | NOT here — design docs |
| Additional behaviors | A separate requirement (split, don't stuff) |

### Expanded contract line (rare)

When the rationale genuinely has multiple distinct motives that all flow
from the same behavior, you may expand the `<so that>` into bullets:

> As a **security officer**, I need every access-path change to run
> dual-evaluate validation until parity is proven, so that:
> - No user silently gains or loses access during the transition.
> - Every access-control change is auditable.

Use this sparingly. Most expanded rationales are actually a signal that
you have **two requirements**.

The `<behavior>` clause may also expand to bullets when the behavior has
multiple verifiable facets sharing one actor and one rationale — but this
is almost always a split signal. Default to splitting.

## Glossary scanning

Before finishing any requirement, scan for a glossary in the project. If
the requirements document is at `docs/define/design-contract.md`, look
for:

- `docs/**/glossary.md` (most common)
- `glossary.md` at the project root
- A `## Glossary` or `# Glossary` section in any sibling doc
- A `_glossary.md` partial

Use a Glob / Grep approach. If multiple candidates exist, ask the user
which is canonical or default to the most-recently-modified one.

**Citation conventions in notes:**

- **Term exists in glossary**: `- "<term>" — see [Glossary](path#anchor).`
- **Term does not exist yet**:
  `- "<term>" = <one-line definition>. *(pending glossary entry)*`
- **Term is ambiguous and not in glossary**:
  `- "<term>" — clarify in context: <usage in this requirement>.
  *(pending glossary entry)*`

If no glossary file exists at all, mark every term-of-art as
*(pending glossary entry)* and propose to the user that a glossary be
created. Do not create the file yourself unless asked.

## Actor rules

### Preferred actor types

- **User-facing roles**: data consumer, data provider, marketplace buyer,
  allied-nation user, platform administrator, integration partner.
- **NFR / system-property stakeholders**: see
  `references/nfr-stakeholder-catalog.md`. Common ones: platform
  architect, on-call engineer, security officer, compliance auditor,
  delivery lead, performance engineer, future operator.

### Forbidden: "As the system, I..."

The system is not a stakeholder. If you find yourself writing this, run
stakeholder discovery. Whose problem does this solve?

### Conditional: subsystem-as-actor

"As the Marketplace integration, I need..." is allowed **only when the
subsystem is a genuine consumer** of the behavior, not its provider.

- ✅ "As the **Marketplace integration**, I need stable grant-lifecycle
  hooks from the access path, so that order state can drive grant state
  without custom polling." *(Marketplace consumes hooks.)*
- ❌ "As **DOCA**, I need conditional grants to evaluate correctly..."
  *(DOCA IS conditional grants. Find the consumer.)*

## Atomicity rules

A single requirement must:

- Express **one** behavior, property, or constraint.
- Have **one** verification approach.
- Use **no** conjunctions joining distinct capabilities in the behavior
  clause.
- Be independently verifiable.

See `references/atomicity-rules.md` for the full split-signal catalog
and worked examples.

## Quality checklist

Run on every requirement after writing. If any item fails, revise.

- [ ] **Single behavior** — one capability, one verification point.
- [ ] **Slim contract line** — one short sentence end-to-end. If
  longer, ask whether scope/examples should move to notes.
- [ ] **Real stakeholder** — a named role, not "the system".
- [ ] **Rationale present** — `<so that>` names a real consequence, not
  a restatement.
- [ ] **Independently verifiable** — could test this without first
  satisfying other requirements in the same document.
- [ ] **Solution-neutral** — states what, not how.
- [ ] **Unambiguous** — one interpretation. Terms-of-art either
  glossary-cited or noted as pending.
- [ ] **Notes earn their place** — each bullet is scope, term clarification,
  cross-ref, or pending-glossary marker. No bullet duplicates the
  behavior or rationale. If a bullet describes a separately verifiable
  behavior, split it into its own requirement instead.
- [ ] **Negative requirements explicit** — "I need the system to NOT do
  Y, so that Z" when applicable.

## Anti-patterns to call out

When you spot these in a draft (yours or the user's), name them and revise:

- **Stuffed contract line** — scope, surfaces, edge cases, examples
  packed into the behavior or rationale clause. Move them to notes.
- **"As the system, I..."** — push to find the real stakeholder.
- **Subsystem-as-provider-as-actor** ("As DOCA, I need DOCA to work...") —
  find the consumer instead.
- **"shall" smuggled into the behavior clause** — the user-story shape
  does not need "shall".
- **Implementation in the behavior clause** ("I need a Redis cache..." vs
  "I need cached lookups under N ms").
- **Negative / exclusion framing as the contract** — phrases like "does
  not impose a fixed ceiling", "not with a fixed bitmask width", "no
  Redis cache", "doesn't use enums" usually encode an *implementation
  exclusion*, not the actual contract. Ask: "what does the requirement
  positively require?" The positive form is almost always the real
  contract; the negative is coupling to an alternative being rejected.
  Move the exclusion to **Notes:** if it's still useful, or drop it if
  it's just the absence of a particular implementation. Example:
  *"the mechanism does not impose a fixed capacity ceiling"* → *"the
  mechanism supports the projected population for the planning horizon"*.
  A fixed-width mechanism sized appropriately satisfies the latter;
  only the former excludes it.
  Exception: genuine negative requirements ("I need the system to NOT
  do Y") are different — they prohibit a behavior a stakeholder
  actively wants prohibited, not an implementation pattern.
- **Rationale that restates the behavior** ("...so that the marking is
  clean") — push for the real downstream consequence.
- **Notes used as a dumping ground** — if a notes bullet describes an
  independently verifiable behavior, it's a requirement, not a note.
- **Bundled INVEST violations** — multiple behaviors + multiple actors +
  multiple surfaces → split.
- **Multi-paragraph entries** in a requirements catalog. One requirement,
  one slim contract line + optional notes.

## Output rendering

Default: emit the user-story line + optional `**Notes:**` block as plain
markdown.

For documents with a specific shape (cerberus-docs design-contract.md
with `#### R-N: Title`, *Type.*, body, notes), wrap accordingly. See
`references/output-formats.md`.

## Reference files

- `references/nfr-stakeholder-catalog.md` — actor palette for NFRs.
- `references/atomicity-rules.md` — INVEST, IEEE 29148, splitting
  techniques, full split-signal catalog.
- `references/worked-examples.md` — before/after pairs with the slim-line
  + notes pattern applied.
- `references/output-formats.md` — cerberus design-contract, Jira ACs,
  generic markdown, with notes-section conventions.
- `references/ears-comparison.md` — why this skill uses user-story format
  instead of EARS.

## Working style

- One requirement at a time. Do not paste a wall of seven new
  requirements on the user. Draft, share, get a reaction, refine.
- For atomization runs, propose the split count up front, then walk the
  user through each.
- For audit runs (Mode 3), propose one action at a time. Glossary
  promotions especially — let the user review the proposed glossary entry
  before it lands.
- Surface rationale honestly. If the user provides a behavior with no
  motive, push back: "what breaks if this isn't true?" Do not invent.
- When the user resists a split, ask them to name a single test covering
  all bundled behaviors. If they can't, the split is correct.
- Notes are mutable. Don't write notes you wouldn't be willing to prune
  later when they're no longer needed.
