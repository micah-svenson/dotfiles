---
name: mr-queue
description: MR review priority queue. Add MRs, check priorities, auto-prune merged MRs. Feeds MR refs to /mr-review and other skills. Data lives in ~/.mr-queue/reviews.md.
tools: Bash, Read, Write, Edit, AskUserQuestion
version: 2.0.0
---

# MR Queue -- Review Priority Manager

Manage MR review priorities via a single markdown file at `~/.mr-queue/reviews.md`. You are the intelligence layer. The file is just data. Use `glab` CLI to fetch MR state from GitLab.

## Argument Routing

Parse `$ARGUMENTS` and route:

| Input | Action |
|-------|--------|
| (empty) or `next` | Show top priority group/item (run refresh first) |
| `next N` | Show top N priority groups/items (run refresh first) |
| `sync` | Full refresh: fetch ALL open reviewer MRs, rebuild file from scratch |
| `list` | Show full queue (run refresh first) |
| `bump <ticket or repo!iid>` | Add +10 manual priority override |
| `drop <ticket or repo!iid>` | Add -10 manual priority override |
| `remove <ticket or repo!iid>` | Remove from file entirely |
| URLs or pasted MR text | Parse MR references, fetch via glab, add to file, rescore |
| Free-form with MR references | Interpret intent, extract MR refs, route accordingly |

## File Format

Data lives in `~/.mr-queue/reviews.md`. Two sections: a Priority Queue (sorted numbered list) and Grouped Details (H2 sections per ticket/group with checklist items per MR).

Create the directory and file on first use:

    mkdir -p ~/.remind-me

### Priority Queue

Numbered list at the top, sorted by score descending. Two formats:

Grouped items (MRs sharing an AFDL ticket):

    1. **AFDL-12345** - implement user auth (3 MRs, 5d, score:18)
    2. **AFDL-67890** - fix pipeline timeouts (1 MR, 12d, score:10) <!-- stale -->

Ungrouped items (no ticket, no custom group):

    3. *ungrouped* udl-ui!98 - bump dependency versions (2d, score:7)
    4. *ungrouped* afdl-core!42 - typo fix in README (35d, score:0) <!-- dormant -->

Staleness markers appear as trailing HTML comments:
- 14-30 days old: `<!-- stale -->`
- 31+ days old: `<!-- dormant -->`

### Grouped Details

H2 sections below the priority queue. Each group has a heading and a checklist of MRs.

Standard ticket group:

    ## AFDL-12345 - implement user auth <!-- priority: +5 -->

    - [ ] udl-ui!98 - Add login page | jake.smith | 5d
    - [ ] udl-ui!101 - Add auth middleware | jake.smith | 3d
    - [x] afdl-core!55 - Auth token validation | sara.jones | 5d

Custom group (for MRs without a ticket, manually grouped by user):

    ## Claude Skills <!-- custom-group --> <!-- priority: +15 -->

    - [ ] claude-tools!12 - Add mr-queue skill | micah.svenson | 1d

MR checklist format:

    - [ ] repo!iid - MR title | author | Xd

Manual priority overrides are inline HTML comments on the group heading:

    <!-- priority: +15 -->
    <!-- priority: -10 -->

These are preserved across all refreshes and rescores.

## Scoring

### Age Curve

Age is calculated from MR creation date to today. The curve peaks at 8-14 days, rewarding timely review, then drops sharply for old MRs.

| Age | Points |
|-----|--------|
| 0-3 days | +1 |
| 4-7 days | +5 |
| 8-14 days | +10 |
| 15-30 days | +2 |
| 31+ days | 0 |

### Factor Points

| Factor | Points | How to detect |
|--------|--------|---------------|
| Solo reviewer | +5 | reviewers array length 1 |
| Code owner | +8 | approval_state has code_owner rule type |
| Small MR (<100 lines) | +2 | Sum changed lines from changes endpoint |
| Draft MR | -10 | Title starts with "Draft:" or "WIP:" |
| 2+ other approvals | -5 | approval_state shows 2+ approved excluding self |
| Manual override | +/- N | From `<!-- priority: +N -->` comment on group heading |

### Group Scoring

- Group score = MAX of individual MR scores in that group.
- Sort by score descending. Break ties by age descending (oldest first).
- Staleness markers: 14-30d = `<!-- stale -->`, 31+d = `<!-- dormant -->`.

## glab Commands

Use `glab` CLI for all GitLab data. Never use curl or direct API calls.

### Fetch all open MRs where user is reviewer

    glab api "merge_requests?state=opened&scope=all&reviewer_username=micah.svenson&per_page=100"

### Check single MR state

    glab api "projects/PROJECT_ID/merge_requests/IID"

Where `PROJECT_ID` is the URL-encoded project path.

### Get MR size (changed lines)

    glab api "projects/PROJECT_ID/merge_requests/IID/changes"

Sum additions and deletions across files to determine size. Under 100 total = small MR.

### Get approval state

    glab api "projects/PROJECT_ID/merge_requests/IID/approval_state"

Check for code_owner rule type and count approvals excluding self (micah.svenson).

### URL Parsing

Extract repo path and short name from GitLab web URLs:

    https://gitlab.bluestaq.com/core-platform/general/udl-ui/-/merge_requests/98

- Full repo path: `core-platform/general/udl-ui`
- Short name: `udl-ui` (last path segment)
- URL-encoded for API: `core-platform%2Fgeneral%2Fudl-ui`

## Refresh Logic

Run refresh on every invocation except `remove`. Steps:

1. Read `~/.mr-queue/reviews.md` (create if missing)
2. For each MR in the file, check state via glab. Remove any that are merged or closed.
3. If an MR has 2+ other approvals and you are not code owner, deprioritize it (the -5 factor applies automatically via scoring).
4. Recalculate ages and scores for all remaining MRs.
5. Preserve all manual priority overrides (`<!-- priority: ... -->`) and custom groups (`<!-- custom-group -->`).
6. Regenerate the priority queue section (re-sort by score).
7. Rewrite the file.

## Sync (Full Rebuild)

Triggered by `sync` argument. Rebuilds the entire file from GitLab state.

1. Fetch ALL open MRs where micah.svenson is a reviewer.
2. Include Draft MRs but apply the -10 draft penalty in scoring.
3. Skip MRs authored by micah.svenson (you do not review your own MRs).
4. Extract AFDL ticket from MR title or source branch using regex `AFDL-\d+`. First match wins.
5. Group MRs by ticket. MRs with no ticket go to Ungrouped.
6. For each MR, fetch the changes endpoint (size) and approval_state endpoint (code owner, approvals).
7. Score everything using the age curve + factor points.
8. Merge with existing file data: preserve manual priority overrides and custom groups. New MRs get added, removed MRs get pruned.
9. Write the complete file.

## Adding MRs

The agent accepts multiple input forms:

- **GitLab URLs** -- extract project path + IID from each URL
- **Pasted MR text** -- extract MR references, resolve via glab search
- **"Add all my open reviews"** -- run the bulk fetch (`glab api merge_requests?...&reviewer_username=micah.svenson`), same as `sync`
- **"Add my reviews from udl-ui"** -- fetch reviewer MRs filtered to that repo

Steps for any input:

1. Extract or fetch MR data via glab.
2. Extract AFDL ticket from title or branch (`AFDL-\d+`).
3. Add to existing group if ticket matches, or create a new group. No-ticket MRs go to Ungrouped unless the user specifies a custom group.
4. Deduplicate by repo path + IID. If already present, update data but keep position and manual overrides.
5. Rescore all groups and rewrite the file.

## Grouping Logic

### Auto-grouping

Extract `AFDL-\d+` from MR title first, then source branch name. First match wins. All MRs with the same ticket number share a group.

Group description = MR title stripped of the ticket prefix (e.g., "AFDL-12345 implement auth" becomes "implement auth"). Also strip any leading repo scope prefix. Use the first MR's cleaned title as the group description.

### Manual Grouping

When the user says "group X and Y as 'name'", create a custom group:

    ## Name <!-- custom-group -->

Custom groups are preserved across all refreshes and syncs. MRs in custom groups are never auto-regrouped.

### Ungrouped

MRs with no AFDL ticket and no custom group assignment. Each appears as an independent entry in the priority queue with the `*ungrouped*` prefix.

## Output Formatting

### `next` or `next 1`

Show the single highest priority item with full detail:

    **AFDL-12345** - implement user auth (score: 18)
    3 MRs, oldest 5d
    - udl-ui!98 - Add login page | jake.smith | 5d
      https://gitlab.bluestaq.com/core-platform/general/udl-ui/-/merge_requests/98
    - udl-ui!101 - Add auth middleware | jake.smith | 3d
      https://gitlab.bluestaq.com/core-platform/general/udl-ui/-/merge_requests/101

### `next N`

Top N items, numbered, with full URLs for each MR.

### `list`

Full priority queue from the file, plus a summary line:

    12 MRs across 8 groups. 3 stale, 1 dormant.

### After adding MRs

Confirm what was added and show the current top 3 from the queue.

## Preferences: `~/.mr-queue/preferences.md`

A learning file the agent reads during scoring and updates over time. Two sections: explicit rules from the user and patterns the agent has observed.

Create on first use if it doesn't exist.

### File Format

    # Review Preferences

    ## Rules
    User-stated preferences. Each rule has a weight adjustment applied during scoring.

    - **Author: chris.harper** +5 -- "prioritize chris's reviews, he's blocked on OAuth"
    - **Repo: udl-ui** +3 -- "I'm focused on the UI repo this sprint"
    - **Author: jacob.hoffer** -3 -- "Jake's ADRs can wait"

    ## Patterns
    Agent-observed tendencies. Each has a confidence level and date last confirmed.

    - **Small MRs first** +2 -- user consistently reviews <100 line MRs before large ones (confirmed 2026-04-06, high confidence)
    - **Defers developer-hub** -2 -- user regularly skips developer-hub reviews in favor of core repos (confirmed 2026-04-01, medium confidence)

### Accepting Explicit Rules

When the user says things like:
- "prioritize reviews from chris" -> add `Author: chris.harper +5`
- "boost udl-ui reviews" -> add `Repo: udl-ui +3`
- "deprioritize developer-hub" -> add `Repo: developer-hub -3`
- "stop prioritizing chris" -> remove that rule

Default weight for explicit rules: +5 for prioritize, -3 for deprioritize. User can specify a number ("boost chris by 10").

Confirm with the user before saving: "Adding preference: prioritize chris.harper (+5). Sound right?"

### Learning Patterns

After the user interacts with the queue (bumps, drops, reviews in a certain order, or explicitly reorders), note what happened. Over time, if a pattern repeats 3+ times, record it.

Pattern types to watch for:
- **Author preference** -- user consistently reviews certain authors first/last
- **Repo preference** -- user consistently prioritizes certain repos
- **Size preference** -- user reviews small or large MRs first
- **Ticket type preference** -- user prioritizes fixes over features, or vice versa

When recording a pattern:
- Start with low confidence and a small weight (+/- 1-2)
- Increase confidence and weight as the pattern repeats
- Include the date last confirmed
- Never exceed +/- 5 for learned patterns (explicit rules can go higher)

If a learned pattern conflicts with an explicit rule, the explicit rule wins.

### Applying Preferences During Scoring

Read `preferences.md` during every scoring pass. For each MR:

1. Check if any author rules match the MR author -> apply weight
2. Check if any repo rules match the MR repo -> apply weight
3. Check if any patterns apply (size, type, etc.) -> apply weight
4. Add the total preference adjustment to the MR's score

These adjustments stack with the base scoring (age + factors + manual overrides).

## Rules

1. Always use `glab` CLI for GitLab data. Never curl, never direct HTTP.
2. Be concise. No filler, no emdashes.
3. Preserve manual overrides and custom groups across every refresh and sync.
4. Deduplicate by repo path + IID. Never create duplicate entries.
5. Create `~/.mr-queue/` directory and `reviews.md` file on first use (`mkdir -p ~/.remind-me`).
6. Always include full GitLab URLs in output so the user can click through.
7. Use short repo names (last path segment) in the file for readability.
8. Read `preferences.md` on every scoring pass. Update it when the user gives preference instructions or when patterns are observed.
