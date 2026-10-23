# Raku as a Foreign Language

A site for people learning Raku, built on Rakupress. It teaches Raku with
the methods used to learn a human language: graded readers, false friends,
word families and accent work.

It does not repeat the other Raku sites:

- the course (course.raku.org) is ordered by language feature and explains
  each one;
- raku.online has the tour, drills, examples, cookbook, FAQ and Behind the Docs;
- raku-books has the books.

This site is ordered by the learner instead: what they already know (Python,
Perl, JavaScript, C) and how far along they are (A1 to C2). The main activity
is reading and comparing, not studying a topic.

## The four strands

Every post belongs to one strand. Rakupress lists them as categories.

| Strand | What a post is | Built from |
|---|---|---|
| **Readers** | A short complete program read as a text at one level. Guess the output, run it, read the notes, answer the questions. | `posts/readers/` |
| **False friends** | Code that is valid in Python, Perl or JavaScript and also in Raku, or looks like it is, but means something else. | `posts/false-friends/` |
| **Word families** | One root and its relatives: `comb`, `words`, `lines`, `split`; or `x`, `xx`, `X`. What they share and where they differ. | `posts/families/` |
| **Accents** | One task written the way a Python, Perl or C programmer writes Raku, then the way a native writes it. | `posts/accents/` |

Fixed pages live in `pages/`: the welcome page, the levels, and how to use
the site.

## Levels

`pages/levels.md` describes six levels, A1 to C2, as can-do statements in
the style of the CEFR. Every reader and false friend carries a level, so a
learner can follow one level, and every post can be filtered by the
language the reader comes from (`from:`).

## Running code

Every `raku` block on the site runs in the page through raku.js, loaded from
raku.online, the same way raku-books does it. The engine in the page is
Raku++, so the outputs shown must be what Raku++ prints, and they must also
be what Rakudo prints. `tools/check.raku` runs every example under both, and
runs the Python, Perl and JavaScript examples under their own interpreters,
so a false friend's claim about Python is checked too.

## Content

All text and code are written for this site. Nothing is taken from other
sites or books.

The pilot set is in `posts/`: 8 readers (A1 to C1), 8 false friends,
5 word families and 3 accents. `posts/ORDER.md` schedules them over five
weeks, one post per weekday, starting at A1 and moving up. The welcome
page and the levels page go up on launch day.

`drafts/` holds posts that wait on something; see `drafts/README.md`.

## Open questions for later

- Domain and server: a subdomain of raku.online or a new name, and a
  RakuPress instance on the new server next to the two blogs.
- Languages: English first. The course has 11 languages; translations can
  follow once the format settles.
- A fifth strand, **Phrasebook**: systematic correspondences between
  languages (`len(x)` → `x.elems`, `", ".join(xs)` → `xs.join(", ")`), like
  the sound-change rules in the Bridges app.
