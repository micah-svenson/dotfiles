---
name: review-tests
description: Reviews Java/Quarkus tests against Bluestaq testing standards — behavior-based, Given-When-Then naming, TDFs, performance, and determinism. Auto-activates when reviewing *Test.java or *IT.java files, discussing test quality, naming, or TDF design.
tools: Read, Glob, Grep
version: 1.0.0
---

# Review Tests Skill

## Progress Tracking

Create a task for each phase at the start of the review. Mark each task
`in_progress` when you begin it and `completed` when done. This gives the
user clear visibility into where the review stands.

Tasks to create:
1. Read test files to review
2. Phase 1-2: Core principles and file placement
3. Phase 3: Naming review
4. Phase 4: TDF review (if applicable)
5. Phase 5: Integration test patterns (if applicable)
6. Phase 6-7: Tools usage and performance
7. Compile and present findings

Skip tasks for phases that don't apply (e.g., Phase 4 when no TDFs, Phase 5
when no integration tests).

When asked to review tests, apply ALL checks below in order. Report each finding with:
- **Rule**: Which rule it violates
- **Violation**: The specific bad code/pattern
- **Fix**: What it should be instead

---

## PHASE 1 — Core Principles (check every test)

### 1A. Behavior-Based (not implementation-focused)
**FAIL if test only verifies internal method calls without checking outcomes:**
```java
// ❌ VIOLATION: No outcome verified
verify(repo).save(any(CreditAccount.class));

// ✅ GOOD: Observable outcome verified
assertTrue(result.isSuccess());
assertEquals(400, result.getRemainingBalance());
```
- `verify(mock).method()` as the *primary* or *only* assertion = **flag it**
- Checking return values, state changes, exceptions = good

### 1B. Determinism (no time/random dependencies)
**FAIL if test logic depends on current time or random values:**
```java
// ❌ VIOLATIONS
LocalDate.now()          // in test data or assertions
LocalDateTime.now()
new Date()
Math.random()
UUID.randomUUID()        // only if used as a lookup key in assertions
```
**FIX**: Inject `Clock.fixed(...)` via constructor or pass explicit values.

### 1C. Single Behavior Per Test
**FAIL if method name lists AND/OR between distinct behaviors:**
```java
// ❌ registerPilot_validatesLicenseAndSendsWelcomeEmail()
// ✅ registerPilot_validatesLicense()  +  registerPilot_sendsWelcomeEmail()
```

---

## PHASE 2 — File Placement & Annotations

| File suffix | Source dir | Annotations |
|-------------|-----------|-------------|
| `*Test.java` | `src/test/java/` | Plain JUnit 5 — **NO** `@QuarkusTest` |
| `*IT.java` | `src/test-integration/java/` | `@QuarkusTest` required |
| `*TDF.java` | `src/test/java/.../testdatafactory/` | — |

**FAIL if:**
- `@QuarkusTest` appears on a `*Test.java` class (pure business logic)
- Integration test missing `@QuarkusTest`
- TDF is outside `testdatafactory/` package

---

## PHASE 3 — Naming (highest-impact review area)

### Decision tree for method name:
```
Does the scenario have context, preconditions, or business logic?
├── YES → Pattern 1: given[State]_when[Action]_then[Result]
└── NO (simple, obvious) → shortened: action_outcome()
    └── Would Pattern 1 be unwieldy (many Given/When/Then conditions)?
        └── YES → Pattern 2: Javadoc GWT + simplified method name
```

### Pattern 1 — Given-When-Then (default)
Format: `given[State]_when[Action]_then[ExpectedResult]`
```java
// ✅ givenInsufficientCredits_whenPurchasingEquipment_thenTransactionFails()
// ✅ givenExpiredCredentials_whenValidatingPilotLicense_thenReturnsFalse()
```

### Pattern 2 — Javadoc + simplified name
Use only when method name would be excessively long. Must have full GWT Javadoc:
```java
/**
 * Given: [multiple complex conditions]
 * When: [action]
 * Then: [multiple outcomes]
 */
@Test
void descriptiveButShortMethodName() { }
```

### @Nested class rules
- Class name starts with `"Given"` or `"When"` + `@DisplayName`
- Test methods inside **still use full GWT syntax** (don't abbreviate because class provides context)
```java
// ❌ VIOLATION: abbreviated inside @Nested
@Nested class GivenAuthenticatedPilot {
    @Test void whenViewing_thenSucceeds() { } // missing "given" part
}
// ✅ GOOD
@Nested class GivenAuthenticatedPilot {
    @Test void givenAuthenticatedPilot_whenViewing_thenSucceeds() { }
}
```
- Max 2 levels of nesting

### @ParameterizedTest rules
- Method name describes **behavior**, not data (let `name` attribute describe data variation)
- `name` attribute is **required** — flag if missing
```java
// ✅ @ParameterizedTest(name = "Starfighter {0} with fuel {1}% can jump {2} parsecs")
//    void starfighterJumpRange_variesByTypeAndFuel(...)
//
// ❌ @ParameterizedTest(name = "Test case {index}")
//    void testSomething(...)
```
- CSV source: primitives/strings; Method source: complex objects/domain types

### Naming anti-patterns — flag ALL of these:
| Anti-pattern | Example | Severity |
|---|---|---|
| Too vague | `testStarship()`, `testPurchase()` | HIGH |
| Implementation-focused | `callsRepositorySaveMethod()` | HIGH |
| Missing outcome | `processInvalidData()` | HIGH |
| Ambiguous pronouns | `thenItFails()` — what is "it"? | MEDIUM |
| Double negative | `whenNotFailing_thenDoesNotReturnFalse()` | MEDIUM |
| Multiple behaviors | `validates_AndSendsEmail_AndUpdatesDb()` | HIGH |
| Magic numbers | `handles42ByteLimit()` vs `handlesMaxTransmissionSize()` | LOW |
| Generic exception | `throwsException()` vs `throwsNavigationException()` | MEDIUM |
| "only" keyword | `onlyCommandersCanAccess()` — ages poorly | LOW |

---

## PHASE 4 — TDF Review

**When reviewing `*TDF.java` files:**

### Structure rules
- `public static class [Entity]Builder` must be nested inside TDF class
- Factory methods **must be the only public members** of the TDF class — flag any public fields or public non-factory methods
- Factory methods **must return the nested Builder** — never a built entity directly
- `TDF.entity().build()` must work with sensible defaults (no required customization)

### Factory method naming
```java
// ✅ Domain language: xwing(), damagedFighter(), maintenanceRequired()
// ❌ Technical/vague: withShields100(), smallShip(), defaultEntity()
```

### TDF location
- `src/test/java/.../testdatafactory/` — flag if elsewhere

### Don't use TDFs when:
- Object is simple: `new Coordinate(0, 0)` is clearer
- Object used in only one test class → use a private helper method instead

---

## PHASE 5 — Integration Test Patterns

**Only applies to `*IT.java` files:**

### Required annotations
- `@QuarkusTest` on class
- `@TestProfile(IntegrationTestProfile.class)` (check if project uses profiles)

### Data cleanup
**FAIL if integration test persists data without cleanup:**
```java
// ✅ REQUIRED for DB-touching ITs
@AfterEach
@Transactional
void cleanup() {
    em.createQuery("DELETE FROM Entity").executeUpdate();
}
// Alternative: @TestTransaction on test method
```

### External service mocking
```java
// ✅ Use @InjectMock for external services
@InjectMock
ExternalMissionAPI externalMissionAPI;
```

### HTTP assertions (RestAssured)
```java
// ✅ Use given/when/then structure
given().contentType(JSON).body(request)
    .when().post("/api/resource")
    .then().statusCode(201).body("field", equalTo(value));
```

### Shared mutable state
**FAIL if tests share mutable static state or instance fields that are mutated across tests without reset.**

---

## PHASE 6 — Tools Usage

### GetSetVerifier (for model getter/setter tests)
```java
// ✅ Correct usage
GetSetVerifier.fromClass(MyModel.class)
    .withStopClass(EntityBase.class)
    .withDefaultValue(DefaultValueType.of(CustomType.class), new CustomType())
    .verify();
```
- Flag if getter/setter tests are written manually instead of using `GetSetVerifier`

### EqualsVerifier (for equals/hashCode tests)
```java
// ✅ Correct usage
EqualsVerifier.simple()
    .forClass(MyModel.class)
    .suppress(Warning.SURROGATE_KEY) // for JPA entities with generated IDs
    .verify();
```
- Flag if equals/hashCode is tested manually without `EqualsVerifier`

---

## PHASE 7 — Performance

| Type | Individual | Suite | Flag when |
|------|-----------|-------|-----------|
| Unit (`*Test.java`) | < 500ms | < 30s total | > 1s individual |
| Integration (`*IT.java`) | 1–10s | < 5min total | > 30s individual |

- Flag `Thread.sleep()` in unit tests
- Flag heavy setup (real DB, HTTP calls) in `*Test.java` files

---

## Review Output Format

Structure your review as:

```
## Test Review: [ClassName]

### ❌ Violations
1. **[Rule]** — `methodName()` (line N)
   - Problem: [what's wrong]
   - Fix: [specific correction]

### ⚠️ Suggestions
- [minor improvements, not violations]

### ✅ What's Good
- [positive callouts, don't skip this]

### Summary
[1-2 sentence overall assessment]
```

---

## Quick Reference — Common Violations Checklist

When short on time, scan for these highest-impact violations:
- [ ] Method names starting with `test` (vague)
- [ ] `verify(mock)` as sole assertion (implementation testing)
- [ ] `LocalDate.now()` / `LocalDateTime.now()` in test body
- [ ] `@QuarkusTest` on `*Test.java`
- [ ] Missing `@AfterEach` cleanup in `*IT.java` that writes to DB
- [ ] TDF factory methods returning built entity instead of builder
- [ ] `@ParameterizedTest` without `name` attribute
- [ ] `@Nested` test methods using abbreviated names (missing Given part)
- [ ] Multiple behaviors in one test (AND in method name)
