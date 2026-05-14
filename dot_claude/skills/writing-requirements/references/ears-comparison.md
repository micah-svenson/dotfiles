# EARS Comparison

This skill uses the user-story format for every requirement. EARS (Easy
Approach to Requirements Syntax) is the most common alternative, and it
has real strengths. This file explains the trade-off so you can speak to
it if the user asks.

## What EARS is

EARS, introduced by Alistair Mavin and the Rolls-Royce team in 2009, is
a structured natural-language syntax for requirements built on five
patterns:

| Pattern | Template | Use when |
|---|---|---|
| Ubiquitous | The `<system>` shall `<response>`. | Always active, no trigger. |
| State-driven | While `<precondition>`, the `<system>` shall `<response>`. | Active during a state. |
| Event-driven | When `<trigger>`, the `<system>` shall `<response>`. | Initiated by an event. |
| Optional | Where `<feature is included>`, the `<system>` shall `<response>`. | Conditional on a feature. |
| Unwanted | If `<trigger>`, then the `<system>` shall `<response>`. | Required response to error/failure. |

EARS' strengths:
- Strong constraint on syntax → less ambiguity at the sentence level.
- Forces explicit triggers and states.
- Verifiable: each pattern maps cleanly to a test shape.

## What this skill uses instead

> As a `<role>`, I need `<behavior>`, so that `<rationale>`.

## Why user-story format here

Three reasons:

### 1. Rationale is first-class

EARS produces the behavior crisply but does not carry rationale. "When
the money is received, the app shall send a notification" is precise
syntax but silent on **why**. The team adopting EARS typically captures
rationale in a separate Notes field or upstream document.

In a design contract — where the catalog is read by people making design
decisions weeks or months later — the rationale is the most important
part. The "so that" clause forces the author to surface why the
requirement exists, not just what it demands. When a design question
arises ("can we relax this constraint?"), the answer lives in the
rationale.

### 2. Stakeholder is first-class

EARS uses "the system" as the universal subject. That makes ownership
diffuse: there's no role on the hook for a violation, no party whose
expectations the requirement protects. The `<role>` slot in user-story
format forces stakeholder discovery, which:
- Reveals when a requirement has no real stakeholder (a sign it's
  arbitrary purity).
- Anchors the requirement to a verification audience (what does this
  stakeholder need to see to trust the requirement is met?).
- Naturally distinguishes requirements by impact ("the platform
  architect cares" vs "the security officer cares" implies different
  test surfaces).

### 3. Natural readability

EARS sentences read like specification prose. User stories read like
intent. For a design contract, intent travels better — readers
internalize the goal faster, and the language survives translation into
design conversations, ACs, and engineer briefings without rewording.

## When EARS might be considered

- **Safety-critical or contractual systems** where the rigidity of
  shall-language is itself a regulatory requirement. (Aerospace, medical
  devices, defense systems with contractual EARS compliance.)
- **Pure environmental constraints** with no behavioral content. "The
  software shall be written in Java" doesn't have a stakeholder beyond
  "the team", and the user-story shape adds nothing.
- **Trigger-heavy requirements** where the When/While/If clause is the
  most important part. EARS surfaces triggers structurally; user stories
  embed them in the behavior clause.

For most software requirements, especially in design contracts, the
user-story format is the better tool. EARS is the right tool when
regulatory shape is required or when the requirement is so axiomatic
that no stakeholder narrative adds value.

## Translation between formats

If you need to translate a user-story requirement into EARS for a
downstream audience that requires it, the mapping is roughly:

| User-story slot | EARS slot |
|---|---|
| `<behavior>` | `<response>` (most behaviors) |
| `<behavior>` triggered by event | `When <trigger>, the system shall <response>` |
| `<behavior>` during a state | `While <state>, the system shall <response>` |
| Negative behavior ("NOT do Y") | `If <trigger>, the system shall NOT <response>` |
| `<role>` | Lost in translation. Note as a comment. |
| `<so that>` | Lost in translation. Note as a comment or upstream doc. |

The information loss in the role and rationale is the cost. That's why
the skill defaults to user-story: those slots are too valuable to drop.

## If the user prefers EARS

If the user genuinely wants EARS output (e.g., they're publishing into a
spec that requires it), produce both:

1. The user-story form (durable contract, rationale captured).
2. The EARS form (publish-ready, syntax-compliant).

The user-story stays in the design contract; the EARS form goes
downstream. Don't lose the rationale just because EARS doesn't carry it.
