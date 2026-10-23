# How posts are written

Read this before writing or editing a post. `tools/check.raku` enforces the
parts marked **checked**.

## Files

One post is one Markdown file with YAML front matter:

    posts/<strand>/<slug>.md

The slug is the file name. Use lowercase words and hyphens.

## Front matter

Keep it flat: scalars and `[a, b]` lists only, so any parser can read it.

```yaml
---
title: "@a[-1] is not the last element"
strand: false-friend
level: A2
from: [python, perl]
tags: [arrays, indexing]
summary: In Python and Perl, -1 counts from the end. In Raku it does not compile.
---
```

| Key | Needed | Values |
|---|---|---|
| `title` | always | Plain text, with no quote marks in code: WordPress curls them in titles. Quote the value if it has a colon or starts with `@`, `%`, `*` or `` ` ``. |
| `strand` | always | `reader`, `false-friend`, `family`, `accent` (**checked**) |
| `level` | always | `A1`, `A2`, `B1`, `B2`, `C1`, `C2` (**checked**) |
| `summary` | always | One or two sentences, shown under the title and in the lists of articles. Put code in backticks; quote the value if it starts with one. |
| `tags` | always | Topic words: `strings`, `arrays`, `hashes`, `regexes`, `classes`… |
| `from` | false friends, accents | `python`, `perl`, `js`, `c` (**checked**) |
| `words` | readers, families | Readers: the words this text introduces at its level. Families: the members. Each must appear in a `raku` block of the post (**checked**). |

Levels are described in `pages/levels.md`. A post's level is the lowest
level at which a learner can follow all of it.

## Code blocks

Every runnable block is a complete program, because each one runs on its
own in the page.

| Fence | Meaning |
|---|---|
| ` ```raku ` | Runs under Raku++ and Rakudo and must exit with 0 (**checked**). |
| ` ```raku error ` | Must fail under both. The following `output` block holds the error message (**checked**). |
| ` ```raku norun ` | A fragment that is shown, not run. Use sparingly. |
| ` ```python `, ` ```perl `, ` ```js ` | Run with `python3`, `perl` and `node` (**checked**). Add `norun` to skip. |
| ` ```output ` | The exact standard output of the block just above it (**checked**). |
| ` ```output hidden ` | The same, but the theme hides it until the reader presses Run or opens it. Use it for the text of a reader. |

Output comparison ignores trailing spaces on each line and trailing blank
lines. Nothing else is forgiven.

For `raku error`, put only the message in the `output` block, without the
`===SORRY!===` header, the file name and the line pointer: those differ
between Rakudo and Raku++. Every line of the block must appear in both
engines' error output, with whitespace collapsed (**checked**).

Programs must give the same output on every run:

- no input from the keyboard, files or the network;
- no clock, no random numbers;
- sort hash keys before printing them, because Rakudo iterates a hash in a
  different order on every run. The checker runs Rakudo twice to catch this.

The editor in the page shows the error stream in the same pane as the
output. When a program writes to standard error on purpose (`note`, a
warning), say in the text what the reader will see there.

## Voice

- Write to one learner, as "you". A teacher talking, not a manual.
- Short, plain sentences. No selling: never "powerful", "elegant",
  "beautiful", "simply", "just".
- Say what the code does. Don't claim things the post does not show.
- One idea per post. A post should take about five minutes to read.
- Examples are about ordinary things: cities, recipes, birds, trains,
  shopping lists. No `foo` and `bar`.
- Code is modern, idiomatic Raku (6.d), except where a block shows an accent
  or a mistake on purpose, and then the text says so.

## Shapes of the four strands

Headings are part of the format: the theme and future translations rely on
them. Keep them as written.

### Reader

    Intro: one or two sentences on what the text is about. No spoilers.
    ## Before you run it      — one question to guess the answer to
    ## The text               — the program, then ```output hidden
    ## Words                  — `word` — meaning; the front-matter words, in order of appearance
    ## Reading notes          — through the program in chunks
    ## Questions              — three questions; answers in <details>
    ## Try this               — one change to make and run

The text uses only words from its own level and below, plus the words it
lists. Twelve to forty lines.

### False friend

    Intro: one line.
    ## In Python             — (or Perl, JavaScript) the code and its output
    ## In Raku               — the same-looking code and what happens
    ## Why                   — the rule behind it, briefly
    ## Say it in Raku        — the right way, with output

A false friend can compare more than one language: use one `## In …`
section per language.

### Word family

    Intro: what the members have in common.
    ## The family            — one ### per member: one line of meaning, one example, its output
    ## Side by side          — a table
    ## Which one?            — three or four small tasks; answers in <details>

### Accent

    ## The task              — what the program does, with its output
    ## With a Python accent  — the program, then "What gives it away" bullets
    ## With a Perl accent
    ## With a C accent
    ## Native                — the program
    ## What changed          — a short list

Every version must print the same output, and the post shows it once,
under the task (**checked**: every `raku` block without its own `output`
block is compared with that one). The accents are valid Raku that works; they are not
mistakes, only foreign.
