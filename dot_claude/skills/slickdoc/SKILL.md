---
name: slickdoc
description: Use whenever the user wants to author, preview, render, or edit any slickdoc document, deck, slide, or presentation — or when the cwd contains a `.qmd` file, a `_extensions/slickdoc` symlink, or a CLAUDE.md breadcrumb that names slickdoc. Triggers on phrases like "author a document", "write a qmd", "make a presentation", "edit this slide", "update the deck", "change that callout / comparison / metric", "slickdoc", "new deck", or when editing files under /home/micah/projects/slickdoc. Uses the `slickdoc` CLI to link a standalone .qmd to the central extension so no heavy folder needs to be dragged around.
tools: Read, Edit, Write, Bash, Glob, Grep
---

# slickdoc

Themed Quarto extension at `/home/micah/projects/slickdoc/`. Provides one HTML format (auto dark/light) and two reveal.js formats (dark + light). Shared IBM Plex Sans / JetBrains Mono type, blue signal accent (`#2556A3` / `#5C86C4`), dark bg `#0f0f12`, light parchment bg `#faf6ea`, mermaid pan/zoom overlay, and a callout / metric / comparison component library.

## Authoring anywhere (primary workflow)

The user writes .qmd files next to source data in any project. The `slickdoc` CLI (`~/.local/bin/slickdoc`) creates a `_extensions/slickdoc` **symlink** pointing at the central extension — no files copied, updates reflect instantly, output lands next to the .qmd.

```bash
slickdoc new <name>                         # html (default)
slickdoc new <name> --format=reveal         # dark deck
slickdoc new <name> --format=reveal-light   # light deck
slickdoc preview <file.qmd>                 # live reload
slickdoc render  <file.qmd>                 # one-shot render
slickdoc link [dir]                         # just create the symlink
slickdoc home                               # print central project path
```

Gitignore recommendation for the containing repo: add `_extensions/slickdoc` and `*_files/` so the symlink and render artifacts don't get committed.

**Critical: reveal decks MUST use `slickdoc preview` (HTTP server) or `slickdoc render` (self-contained via `embed-resources: true`).** Edge on Windows cannot follow WSL symlinks through the `\\wsl.localhost\...` UNC mount, so opening a non-embedded rendered HTML via `file://` causes `net::ERR_FILE_NOT_FOUND` on `_extensions/slickdoc/*.css` — all theme styling, the mermaid wrapper, and the pan/zoom modal break silently. The reveal formats in `_extension.yml` already set `embed-resources: true` so `slickdoc render` output is safe to share via `file://` or email. HTML format does not set this by default; add it if sharing via file URL.

Debug protocol when reveal styling looks wrong: open devtools console first and check for `ERR_FILE_NOT_FOUND` on the extension CSS. That's almost always the real bug, not a CSS issue.

## Formats

| Front matter `format:`         | Output                       |
|--------------------------------|------------------------------|
| `slickdoc-html`                | HTML, auto dark/light toggle |
| `slickdoc-revealjs`            | Dark reveal.js deck          |
| `slickdoc-revealjs+light`      | Light reveal.js deck         |

One .qmd can render to multiple formats — write `slickdoc-html` in front matter and render with `--to slickdoc-revealjs` to get both. Put the format key in front matter as the default and pass `--to <other>` for one-offs.

## Opening output (WSL)

```bash
xdg-open 'http://localhost:<port>/doc.html'                              # preview server
cd /mnt/c && cmd.exe /c start "" "$(wslpath -w '/path/to/doc.html')"     # rendered file
```

## Component classes (use raw HTML in .qmd)

Reference card: `/home/micah/projects/slickdoc/template.qmd`. Key classes:

- **Callouts**: `<div class="notice warn|info|good">` with `.notice-header` + `.notice-body`
- **Metric grid**: `<div class="metric-grid">` with `<div class="metric-card"><div class="value [accent|good|warn]">N</div><div class="label">Label</div></div>`
- **Comparison**: `<div class="comparison">` with `<div class="comp-panel good|warn">` containing `.tag` + `<ul>`
- Also: `.accent-list`, `.kw` / `.kw-warn`, `.two-col`, `.trace-chain`, `.dimension-grid`, `.slide-goal`, `.sep`, `.insight`, `.title-section`

## Mermaid

Write plain mermaid fences. A Lua filter injects the theme; the pan/zoom JS wraps the SVG and adds a maximize button. Do not hand-write `%%{init}%%`.

**Sizing on reveal slides — when a diagram pushes other content off the slide.** The default reveal rule caps mermaid SVGs at `min(58vh, 560px)`. That's fine when the diagram is the only thing on the slide. When the slide also has a comparison block, notice block, or trailing bullets, the diagram needs to be smaller. Use this pattern:

````markdown
<style>
.shrink-mermaid .mermaid-wrapper > svg[id^="mermaid"],
.shrink-mermaid .mermaid svg,
.shrink-mermaid svg { max-height: 34vh !important; height: auto !important; }
.shrink-mermaid .mermaid-wrapper { overflow: visible !important; padding: 4px !important; margin: 0.2em 0 !important; }
.shrink-mermaid figure { margin: 0.2em 0 !important; }
</style>

::: {.shrink-mermaid}

```{mermaid}
erDiagram
    ...
```

:::
````

Tune `max-height` to fit (32–40vh is the useful range for a slide that also has a comparison block and a notice). The user can still maximize via the panzoom button, so it is fine to render the in-slide version smaller than the natural diagram size.

**Why each rule matters:**
- `svg max-height` shrinks the rendered SVG itself (not just clips). The slickdoc reveal default is `min(58vh, 560px)`; override with a smaller `vh` value.
- `mermaid-wrapper overflow: visible` prevents the wrapper from showing a scrollbar (the wrapper has `overflow: auto` in the base mermaid-panzoom.css and only switches to `visible` in reveal mode — but explicit is better when something else triggers a scrollbar).
- `mermaid-wrapper padding`/`margin` and `figure margin` claw back the ~30px of vertical real estate the wrapper reserves around the SVG. This is what makes the slide actually fit, not just the SVG.

**What does NOT work — `transform: scale()`** preserves the bounding box even though the visual shrinks, which causes a parent scrollbar (the layout still reserves the original height). Stick to `max-height` on the SVG plus padding/margin reduction.

If you find yourself doing this a lot, consider promoting `.shrink-mermaid` (or a configurable variant) into `_slickdoc-reveal-rules.scss` as a built-in utility class. Until then, inline `<style>` per slide.

## Plots

**Primary: Plotly.js via `{.slickdoc-plot}` fenced blocks.** Vendored `plotly-basic` bundle (bar, histogram, line, scatter, pie) inlined through `plotly-bootstrap.html`. A Lua filter (`plotly-inject.lua`) rewrites each `{.slickdoc-plot}` block into a themed `Plotly.newPlot` call at build time, reading slickdoc CSS tokens at runtime (dark/light auto). **Works on `file://`** — use this for anything that needs to open as a standalone shared HTML.

````markdown
```{.slickdoc-plot}
{
  "data": [
    { "type": "bar", "name": "Alpha", "x": ["Jan","Feb","Mar"], "y": [18,24,31] },
    { "type": "bar", "name": "Bravo", "x": ["Jan","Feb","Mar"], "y": [12,19,22] }
  ],
  "layout": {
    "barmode": "group",
    "xaxis": { "title": "Month" },
    "yaxis": { "title": "Velocity" }
  }
}
```
````

Spec shape: `{ "data": [<traces>], "layout": {...}, "config": {...} }`. Only `data` is required; `layout` and `config` merge onto themed defaults (`paper_bgcolor: transparent`, colorway from `window.slickdocPlotlyPalette()`, fonts/axis tokens). Covered trace types: `bar`, `scatter` (line/marker), `histogram`, `pie`. For heatmaps / maps / 3D, swap to a fuller Plotly bundle.

**Sizing via block attributes** — attach to the fenced block; they win over anything in the spec's layout:

````markdown
```{.slickdoc-plot height="400"}            ← explicit px height
```{.slickdoc-plot width="800"}             ← max pixel width (plot stays centered)
```{.slickdoc-plot height="400" width="800"}
```{.slickdoc-plot aspect="16:9"}           ← responsive aspect ratio instead of fixed height
````

The filter sets CSS on the wrapper (so layout is correct before Plotly boots) AND merges `layout.height`/`layout.width` into the Plotly call. You can still use `"height": N` inside the JSON `layout` block if you prefer — attributes override.

Runtime helpers (available to raw HTML blocks too):
- `window.slickdocPlotly(target, data, layout?, config?)` — single-call wrapper; target is a selector or element
- `window.slickdocPlotlyLayout()` — themed layout defaults
- `window.slickdocPlotlyPalette()` — ordered categorical colour array
- `window.slickdocPlotlyTokens()` — raw token map if you need individual colours

**Critical pitfall — never share axis refs.** When defining layout defaults in JS, `xaxis` and `yaxis` MUST be independent objects. Plotly mutates per-axis state during zoom/pan, and sharing a reference causes data to vanish on zoom because one axis's new range bleeds into the other. Use a `makeAxis(t)` helper (pattern already in `plotly-bootstrap.html`), not `var axis = {...}; return { xaxis: axis, yaxis: axis }`.

**Escape hatch: Python / matplotlib** — ship-bundled `.mplstyle` files. One-liner:

```python
import matplotlib.pyplot as plt
plt.style.use("_extensions/slickdoc/slickdoc.mplstyle")        # dark variant
# plt.style.use("_extensions/slickdoc/slickdoc-light.mplstyle")  # light variant
```

Matches slickdoc typography, accent-forward colour cycle, transparent canvas, minimal spines, grid tuned to `--line`. Requires a Python kernel (`jupyter: python3` in front matter).

**Legacy: Observable Plot via `{ojs}` blocks** — still wired in (`slickdoc-plot.css`, `plot-bootstrap.html` helpers), **but Quarto's OJS runtime refuses to start on `file://` URLs**. Only works via `slickdoc preview` (HTTP) or when served over HTTP. Prefer `{.slickdoc-plot}` for everything shareable as a single file.

Reference: `docs/plots.qmd` in the central project.

## Extension source map (`_extensions/slickdoc/`)

| File                             | Purpose                                              |
|----------------------------------|------------------------------------------------------|
| `_extension.yml`                 | Format definitions (html + revealjs + revealjs+light)|
| `slickdoc-light.scss`            | HTML light theme (Bootstrap defaults + scss rules)   |
| `slickdoc-dark.scss`             | HTML dark theme                                      |
| `_slickdoc-rules.scss`           | Shared HTML scss:rules (imported by both)            |
| `slickdoc-reveal-dark.scss`      | Reveal dark theme                                    |
| `slickdoc-reveal-light.scss`     | Reveal light theme                                   |
| `_slickdoc-reveal-rules.scss`    | Shared reveal scss:rules (imported by both)          |
| `slickdoc.css`                   | Component classes (callouts, grids, comparison, etc.)|
| `mermaid-panzoom.css`            | Modal/toolbar/wrapper styles                         |
| `mermaid-panzoom.js`             | Pan/zoom logic (delegated body click handler)        |
| `svg-pan-zoom.min.js`            | Vendored svg-pan-zoom 3.6.1                          |
| `panzoom-bootstrap.html`         | Inlines both JS files (via `include-after-body`)     |
| `mermaid-inject.lua`             | Lua filter: injects theme init into mermaid blocks   |
| `slickdoc-plot.css`              | Observable Plot / OJS theming (axes, grid, tooltip)  |
| `plot-bootstrap.html`            | Inlines `window.slickdocPlot*` helpers (OJS-era)     |
| `slickdoc-plotly.css`            | Plotly wrapper, modebar, reveal fit                  |
| `plotly-basic.min.js`            | Vendored Plotly.js basic bundle (~1.1 MB)            |
| `plotly-bootstrap.html`          | Inlines Plotly + `window.slickdocPlotly*` helpers    |
| `plotly-inject.lua`              | Lua filter: `{.slickdoc-plot}` → Plotly.newPlot call |
| `slickdoc.mplstyle`              | matplotlib theme (dark variant)                      |
| `slickdoc-light.mplstyle`        | matplotlib theme (light variant)                     |

## Editing the extension

- **HTML accent color**: update `--accent`, `--accent-bright`, `--accent-dim`, and `--mermaid-*` tokens in `_slickdoc-rules.scss`. The two color themes share this file.
- **Reveal backgrounds**: `$backgroundColor` and `:root { --bg-root / --bg-surface / --bg-raised }` at the top of `slickdoc-reveal-{dark,light}.scss`.
- **Adding a component**: add CSS to `slickdoc.css` using `var(--accent)` etc., add an example to `template.qmd`, and document it in this skill.
- **After editing `mermaid-panzoom.js` or `svg-pan-zoom.min.js`**: rebuild `panzoom-bootstrap.html`:

  ```bash
  cd /home/micah/projects/slickdoc/_extensions/slickdoc
  { echo '<script>'; cat svg-pan-zoom.min.js; echo; echo '</script>'; echo '<script>'; cat mermaid-panzoom.js; echo; echo '</script>'; } > panzoom-bootstrap.html
  ```

- **Test against the central project**:

  ```bash
  cd /home/micah/projects/slickdoc
  quarto preview docs/index.qmd          # html
  quarto preview docs/slides.qmd         # dark deck
  quarto preview docs/slides-light.qmd   # light deck
  ```

## Architecture gotchas

- Extension resolution walks from the .qmd dir upward looking for `_extensions/{name}/` — the symlink approach leans on this. If a .qmd is nested, the walker still finds the link as long as it's at or above the .qmd's dir.
- `_quarto.yml` `project.render` list: if a .qmd lives in a subdirectory of a multi-file Quarto project (e.g., `docs/`), it must be listed under `project.render` or Quarto will not apply the project's extension resolution when rendering from that subdir. This does **not** affect the authoring-anywhere workflow (which uses a standalone .qmd with no `_quarto.yml`).
- `include-after-body` inserts raw HTML but does NOT copy referenced JS files — that's why `panzoom-bootstrap.html` inlines both scripts.
- Format-modifier keys (`revealjs+light`) are siblings of the base format in `_extension.yml`; Quarto resolves `slickdoc-revealjs+light` by matching the modifier key first and falling back to the base.
- Delegated click handler on `document.body` (in `mermaid-panzoom.js`) is deliberate — Quarto re-renders DOM nodes so per-element listeners break.
