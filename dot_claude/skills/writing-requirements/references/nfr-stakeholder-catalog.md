# NFR Stakeholder Catalog

Every requirement has a stakeholder who cares — even non-functional ones.
This catalog gives a starting palette for picking the `<role>` when the
requirement isn't directly user-facing.

The rule of thumb: **whose problem does this solve? who notices first if
this is violated?** That stakeholder is your actor.

## The palette

### Platform architect / capacity planner

Owns scaling, capacity ceilings, mechanism choice, and "can this grow"
questions.

Use for requirements about:
- Capacity ceilings (count of users, records, markings, grants)
- Mechanism scalability (bitmask widths, table sizes, fan-out)
- Long-horizon growth assumptions
- Architectural invariants that protect future scaling

Example:
> As a **platform architect**, I need the government controls mechanism to
> scale with the distinct marking population, so that SAP-level deployments
> with low-thousands of program PIDs are supportable without re-architecting
> the access path.

### On-call engineer / SRE

Owns stability, observability, audit, and "can I diagnose this at 3am"
questions.

Use for requirements about:
- Observability of access decisions, ingestion, migration
- Audit logs and traceability
- Reconciliation and detectable inconsistencies
- Behavior under migration / dual-format windows
- Rollback safety

Example:
> As an **on-call engineer**, I need every cross-domain inconsistency to be
> detectable through structured logs, so that I can diagnose and reconcile
> without re-sending data or paging the source environment.

### Security officer / compliance auditor

Owns access-change safety, classification handling, separation-of-duties,
and "can we prove this is compliant" questions.

Use for requirements about:
- Access-control changes (silent gain/loss prevention)
- Dual-evaluate validation
- Classification marking semantic correctness
- Authority separation (write authority, grant authority, etc.)
- Audit trails for compliance

Example:
> As a **security officer**, I need every access-path change to run
> dual-evaluate validation (old vs new, per record) until parity is proven,
> so that no user silently gains or loses access during the transition and
> every change is auditable.

### Delivery lead / program manager

Owns incremental delivery, sequencing, and "can we ship in slices" questions.

Use for requirements about:
- Incremental shippability
- Backward-compatibility timelines
- Deprecation windows
- Sunset and migration calendars
- Cross-team coordination invariants

Example:
> As a **delivery lead**, I need each rollout phase to be independently
> shippable and independently valuable, so that organizational constraints
> against end-loaded value are honored and the migration cannot stall in
> a half-shipped state.

### Integration partner / future operator

Owns long-term compatibility, cross-environment behavior, and "will my
integration still work in two years" questions.

Use for requirements about:
- Cross-environment compatibility
- Preserving production integration behaviors (NiFi flows, custom routing)
- Backward-compatible response shapes
- API-shape invariants
- Federation boundaries

Example:
> As an **integration partner**, I need every behavior my existing
> production integration depends on to be either preserved unchanged or
> explicitly migrated to a documented replacement, so that no integration
> breaks silently during cutover.

### Performance engineer

Owns latency budgets, throughput, and "is this fast enough at scale"
questions.

Use for requirements about:
- Per-record decision latency budgets
- Throughput at peak load
- Memory/CPU constraints
- Cache-hit invariants

Example:
> As a **performance engineer**, I need the access-decision cost to remain
> within a documented per-record budget at the per-message rate of the
> secure-messaging surface, so that the new access model is not a regression
> against today's measured baseline.

### Data owner

Owns who-controls-what for a specific dataset or product. Different from
platform admin.

Use for requirements about:
- Grant authoring scope
- Data-owner-bound lifecycle actions (hide, publish, deprecate)
- Data ownership identity (1:1 source-to-owner, etc.)
- Coming-soon → live transitions

Example:
> As a **data owner**, I need to author grants only within the scope of
> data products I am authorized to administer, so that grant-authoring
> blast radius is bounded by my administrative scope.

### Platform administrator

Owns cross-org-wide lifecycle actions, distinct from per-DP data ownership.

Use for requirements about:
- Hide/unhide actions that override data-owner state
- Cross-environment admin actions
- Authority that supersedes individual data owners

Example:
> As a **platform administrator**, I need to hide any data product in the
> catalog regardless of its data-owner state, so that compliance takedowns
> are not blocked by data-owner availability.

## Picking when several could apply

If multiple stakeholders could reasonably own a requirement, ask:

1. **Who is harmed most by violation?** That's a strong signal.
2. **Whose verification approach makes the test most precise?** A
   security-officer-framed requirement implies an audit-level test; a
   performance-engineer-framed one implies a latency test.
3. **Which framing surfaces the strongest rationale?** Pick the actor that
   makes the `<so that>` most concrete.

If two stakeholders genuinely both care about distinct aspects, that's
usually a sign you have **two requirements**, not one.

## Subsystem-as-actor (rare)

Allowed only when the subsystem is a genuine consumer of the behavior, not
its provider. The litmus test: **does this subsystem call out, query, or
depend on the behavior in question?** If yes, it can be the actor. If the
subsystem IS the behavior, find the human downstream.

- ✅ "As the **Marketplace integration**, I need stable grant-lifecycle
  hooks from the access path..." (Marketplace consumes hooks.)
- ✅ "As the **secure-messaging subscriber path**, I need per-message
  decisions to fit within the latency budget..." (SM path consumes the
  access-decision call.)
- ❌ "As **DOCA**, I need conditional grants to evaluate correctly..."
  (DOCA IS the conditional grants.)
- ❌ "As **RLS**, I need to enforce membership..." (RLS IS the membership
  enforcement.)

## Adding to the catalog

If you find a recurring stakeholder this catalog misses, name it and
include a one-line "use for" + an example. Avoid pseudo-stakeholders like
"the system", "the architecture", or "the codebase" — those are
non-stakeholders dressed up.
