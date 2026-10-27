# AGENTS.md

Guidance for coding agents working in this repository.

## What this project is

**mndoc** is a Tcl Markdown-to-HTML converter and source-code documentation
extractor. It reads:

- plain Markdown files (`.md`, `.Rmd`, `.rmd`, `.Tmd`, `.tmd`, `.Pmd`, `.pmd`,
  `.man`),
- source code with Markdown embedded in `#'` comments, or in multi-line comment
  blocks (`"""#'` ... `"""`, `/**#'` ... `*/`),
- existing HTML files (to inline local images/stylesheets as base64),

and writes HTML, or extracts the Markdown for further processing.

Current version: **0.15.5**. License: **BSD-3-Clause**. Upstream:
<https://github.com/mittelmark/mndoc>.

It started as an extended fork of Tcllib's `mkdoc`; the name was changed to
`mndoc` in 0.13.0 to avoid a package-name collision.

## Repository layout

| Path | Purpose |
| --- | --- |
| `mndoc/mndoc.tcl` | **Main source of truth**: library + CLI logic + embedded manual (`#'` comments) |
| `mndoc/pkgIndex.tcl` | Package index; version used by the Makefile |
| `mndoc/mndoc.css`, `tmdoc.css`, `small.css` | Bundled stylesheets |
| `mndoc/mndoc.html` | Generated manual (tracked in git) |
| `mndoc/mndoc.pdf` | Generated manual PDF (regenerated with `make docu`, weasyprint) |
| `apps/mndoc` | Small launcher: `package require mndoc; ::mndoc::main $argv` |
| `apps/mndoc.man` | Doctools man page; documents all options and BSD-3-Clause license |
| `Makefile` | Builds the standalone bundle and runs smoke tests |
| `bin/mndoc-<version>.bin` | Prebuilt standalone executable |
| `bin/install-mndoc.sh` | Installer for `~/.local/bin` |
| `bin/tpack` | Bundler used to create single-file applications (patched for the parallel first-run race, see `patches/tpack-race.patch`) |
| `patches/markdown.patch` | Pipe/table fix for the Tcllib Markdown package (applied only if not already present) |
| `patches/tpack-race.patch` | Makes the tpack cache-extraction loader race-free |
| `tests/tables.md` | Table/pipe regression input |
| `examples/` | Sample inputs and reference outputs |
| `mndoc.vfs/` | **Generated** VFS tree with mndoc + Tcllib modules |
| `mndoc.ttcl`, `mndoc.tb64`, `mndoc.tb64.lz4`, `mndoc.tapp` | **Generated** bundling artifacts |
| `mndoc.tcl` (root) | **Generated** copy of `apps/mndoc` made by `make app` |

## Run from source

The bundled Tcllib modules live in `mndoc.vfs/lib`. Use them instead of relying
on a system-wide Tcllib:

```sh
export TCLLIBPATH="$PWD/mndoc.vfs/lib"
tclsh apps/mndoc input.md output.html
tclsh apps/mndoc mndoc/mndoc.tcl mndoc/mndoc.html --css mndoc.css
tclsh apps/mndoc --help
```

If `mndoc.vfs/` is missing, run `make app` (see caveats below).

Run the prebuilt standalone binary:

```sh
./bin/mndoc-0.15.5.bin input.md output.html
```

The root `mndoc.tcl` is **not** standalone: it only does
`package require mndoc`, so it needs `TCLLIBPATH` or an installed package.
The standalone programs are `bin/mndoc-*.bin` and `mndoc.tapp`.

## Build

```sh
make app
```

What it does:

1. Deletes and re-creates `mndoc.vfs` via `bin/tpack init`.
2. Copies `apps/mndoc` to `mndoc.tcl` and the library, package index and CSS
   into `mndoc.vfs/lib/mndoc`.
3. **Downloads** pinned Tcllib sources from commit `a0f8da869ea3f8dc0dee583d18316edc435dbc64`
   with `wget`:
   - `modules/cmdline/` (required by the bundled `yaml` package),
   - `modules/yaml/`,
   - `modules/markdown/`,
   - `modules/textutil/` (required by the bundled `markdown` package).
4. Applies `patches/markdown.patch` only if the pipe fix is not already present
   in the pinned Tcllib, plus `perl -pe` rewrites (removes one `html_escape`
   call, bumps the bundled Markdown version to 1.2.5).
5. Ensures `bin/tpack` is the tpack v0.7.1 release with
   `patches/tpack-race.patch` applied, then runs `tpack wrap mndoc.tapp --lz4`
   and copies the result to `bin/mndoc-$(VERSION).bin`.

Consequences:

- The build needs **network access, `wget`, `patch`, `perl` and `tclsh`**.
  The Tcllib download is pinned to a commit, so a given commit is
  reproducible, but bumping the pin may require refreshing the patches.
- `make app` overwrites `mndoc.tcl`, `mndoc.vfs/`, `mndoc.ttcl`,
  `mndoc.tb64*`, `mndoc.tapp` and the binary. Do not hand-edit these.
- Never run `make app` just to run tests; it is destructive and slow.
- `TCL9` in the Makefile is defined but unused; `TCL=tclsh` is used for
  bundling. The code itself supports Tcl 8.6+ and Tcl 9; `make test` should
  be run under both when possible.

### Generated bundle anatomy

`tpack` produces a shell/Tcl polyglot:

- `mndoc.ttcl` — loader/boot code (base64 + lz4 decoders, archive extraction)
  followed by the app launcher.
- `mndoc.tb64` — uncompressed base64 archive of the VFS (legacy/non-lz4).
- `mndoc.tb64.lz4` — lz4-compressed archive.
- `mndoc.tapp` — `mndoc.ttcl` + `^Z` (`\u001A`) + `mndoc.tb64.lz4`;
  this is the actual single-file executable.

At runtime the loader extracts the archive to
`$TMPDIR/$USER/<basename>-<mtime>.<pid>/`, caches it there, adds the extracted
tree to `auto_path`, and sources `main.tcl`. Because the tpack race patch makes
each process unpack into its own per-PID cache directory, concurrent first runs
do not share or delete one another's in-progress trees. If a `mndoc.vfs/`
directory exists next to the script, the loader uses that directory instead of
the embedded archive. This is why running `./mndoc.tapp` from the repository
root can silently use a stale or modified `mndoc.vfs/` instead of the embedded
libraries.

## Tests

`make test` is the supported test entry point. It requires the bundled
libraries, so run `make app` first if `mndoc.vfs/` is missing:

```sh
make test
```

The target uses `$(CURDIR)/mndoc.vfs/lib`, writes all output to a temporary
directory, and covers:

- highlight.js and auto-refresh output,
- base64 inlining for HTML and Markdown input, including `--base64 false`,
- YAML title/author/date output,
- non-ISO and integer date fallback,
- table/pipe handling from `tests/tables.md`,
- nested CSS paths,
- `--bodyonly`.

The suite should pass under both Tcl 8.6 and Tcl 9. The tracked
`examples/*.html` files are reference outputs and must not be overwritten by
tests.

`tests/date.md` is a manual German-format date fixture; the automated date
coverage lives inline in `make test`.

## Version bumps

The version appears in several independent places. Update all of them and
regenerate the manual:

1. `mndoc/pkgIndex.tcl` — both `package ifneeded` lines (the Makefile reads
   `VERSION` from here).
2. `mndoc/mndoc.tcl`:
   - history header at the top,
   - YAML title in the embedded manual (`#' title: ...`),
   - both `package provide` lines,
   - `CHANGES` section near the end.
3. `mndoc/mndoc.html` — regenerate (see below).
4. `README.md` — ChangeLog.
5. `apps/mndoc.man` — `[vset VERSION ...]`.
6. `mndoc/mndoc.pdf` — regenerate via `make docu` (needs `weasyprint`).

Regenerate the manual:

```sh
TCLLIBPATH="$PWD/mndoc.vfs/lib" \
  tclsh apps/mndoc mndoc/mndoc.tcl mndoc/mndoc.html \
  --css mndoc.css --mathjax true --javascript highlightjs
```

`make docu` does the same but then also runs `weasyprint` to build
`mndoc/mndoc.pdf`; the PDF step may fail if `weasyprint` is not installed, after
the HTML has already been written.

## Code conventions

- Tcl 8.6-compatible code; `package require Tcl 8.6-`. Keep Tcl 9 working.
- 4-space indentation, opening brace on the same line.
- Public entry point is `::mndoc::mndoc infile outfile ?--option value ...?`;
  command-line handling is `::mndoc::main argv`.
- Options are `--long-option value` pairs, not flags with a separate parser.
  Keep the option list in `main` (`valid_args`), the `array set arg` defaults,
  and the `USAGE`/`HELP` text in sync.
- Functions are namespaced and kebab-cased (`img-replace`, `inline-assets`).
- The manual is embedded in `mndoc/mndoc.tcl` as `#'` comments; user-facing
  behaviour changes should be documented there and in `README.md`.
- HTML is assembled with `string map`/`subst`/regexes. Keep changes small and
  test against the examples; there is no HTML templating library.
- Do not add new Tcllib dependencies unless necessary. The runtime code only
  requires `yaml` and `Markdown` (`cmdline` and `textutil` are bundled solely
  because those packages need them at load time).
- Only local images and CSS are base64-inlined. JavaScript inlining is still a
  TODO, and `--base64 false` disables this for both Markdown and HTML input.

## Date handling

YAML `date` values are normalized by `::mndoc::normalize-date`:

- integer values with 9–13 digits are treated as Unix timestamps in seconds or
  milliseconds; shorter integers such as `2026` are treated as text,
- ISO dates and date-times are parsed and rendered as `YYYY-MM-DD` (time and
  timezone components are dropped),
- all other values are kept exactly as written, including German
  `dd.mm.yyyy`, slash/dash formats and free text such as `Spring 2026`;
  conversion never fails because of a date format.

The normalizer deliberately does not try non-ISO formats: preserving the
author's spelling is preferred over guessing day/month order. When adding ISO
variants, add them to the `formats` list in `mndoc/mndoc.tcl` and test a
recognised ISO date, a timestamp, a short integer, and a non-ISO fallback such
as `28.10.2026`.

## Known issues and pitfalls

- The YAML front matter is only recognised if the opening `---` occurs within
  the first four lines.
- `subst -nobackslashes -nocommands` is applied to the HTML header/footer
  template, so `$...` variable references in user-supplied templates are still
  substituted. Treat header/footer files as trusted input.
- Generated artifacts are covered by `.gitignore`; editor/backup files
  (`Makefile~`, `tests/date.md.~*`) are ignored via the `*~` pattern.
- The build downloads pinned Tcllib sources; a future commit bump may require
  refreshing `patches/markdown.patch` (the Markdown pipe fix may already be in
  upstream) or the tpack loader. If the build breaks, check the Tcllib
  `markdown`/`yaml` sources first.
- The `.tapp` parallel first-run race is fixed by `patches/tpack-race.patch`
  (per-PID cache directories). Keep that patch applied to `bin/tpack` before
  running `make app`.
- Do not confuse `mndoc/mndoc.tcl` (source) with root `mndoc.tcl` (generated
  launcher). Do not confuse the tracked `mndoc/mndoc.html` (manual) with
  generated test output.

## Useful one-liners

```sh
# show version / help from source
TCLLIBPATH="$PWD/mndoc.vfs/lib" tclsh apps/mndoc --version
TCLLIBPATH="$PWD/mndoc.vfs/lib" tclsh apps/mndoc --help

# convert a C++ file with embedded '#' documentation
TCLLIBPATH="$PWD/mndoc.vfs/lib" tclsh apps/mndoc examples/cpp.cpp /tmp/cpp.html

# extract Markdown only (no HTML)
TCLLIBPATH="$PWD/mndoc.vfs/lib" tclsh apps/mndoc examples/cpp.cpp /tmp/cpp.md

# inline images/stylesheets in an existing HTML file
TCLLIBPATH="$PWD/mndoc.vfs/lib" tclsh apps/mndoc examples/extern.html /tmp/intern.html

# inspect the bundle
head -n 20 mndoc.tapp
python3 -c "d=open('mndoc.tapp','rb').read(); print(len(d), d.find(b'\x1a'))"

# run the test suite under both Tcl versions
TCLLIBPATH="$PWD/mndoc.vfs/lib" tclsh apps/mndoc examples/hilight.md /tmp/hilight.html --javascript highlightjs
TCLLIBPATH="$PWD/mndoc.vfs/lib" tclsh8.6 apps/mndoc examples/hilight.md /tmp/hilight86.html --javascript highlightjs
```

## Release checklist (0.15.x)

Before tagging a release, make sure:

- [ ] `make app` and `make test` pass, and `bin/mndoc-<version>.bin` is current.
- [ ] `mndoc/mndoc.html` and `mndoc/mndoc.pdf` are regenerated (version/date updated).
- [ ] `bin/install-mndoc.sh` works on a fresh account (`~/.local/bin` is created).
- [ ] The GitHub release attaches `mndoc-<version>.bin`, `install-mndoc.sh`, and `mndoc.pdf`.
