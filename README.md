# Learn Raku, and Raku as a Foreign Language

This repository builds **Learn Raku**, learn.raku.online, a RakuPress site
in six parts: the tour, the drills, Raku as a Foreign Language, the
examples, the cookbook and Raku Behind the Docs. Five of them are written
in the raku.online repository and copied in by the build; one is written
here.

That one, **Raku as a Foreign Language**, teaches Raku with the methods of
language learning: graded readers, false friends, word families and
accents. See [PLAN.md](PLAN.md) for the idea and [STYLE.md](STYLE.md) for
how posts are written.

    pages/      Start here, Levels
    posts/      readers/, false-friends/, families/, accents/
    drafts/     posts waiting for something (see drafts/README.md)
    site/       the RakuPress site: site.json, static/site.css; what the build writes
    tools/      check.raku, build-site.raku, serve.sh, lib/Posts.rakumod

## Checking the posts

Every example in every post is run, and its output is compared with the
output printed in the post. Raku examples run under both Raku++ and
Rakudo; Python, Perl and JavaScript examples run under `python3`, `perl`
and `node`.

    raku tools/check.raku                  # all posts
    raku tools/check.raku posts/readers    # one strand
    RAKUDO=/path/to/rakudo raku tools/check.raku

It exits with 1 if anything fails, so it can run in CI once the repository
is set up.

## The site

This is **learn.raku.online**. It runs on RakuPress, and it is a website
rather than a blog: every page is a WordPress page, with no dates,
categories or comments. The Markdown files are the source;
`tools/build-site.raku` turns them into a WordPress database in
mysqldump's format (`site/site.sql`), which `rakupress import` reads into
`site/content.db`, and writes the site's header and footer.

    tools/serve.sh                         # build, import, serve on :8083

| Address | What it is |
|---|---|
| `/` | Learn Raku, the front page (a static page): where to start, a card for each of the six parts with its numbers and first pages, the levels the articles and the drills share, one example to run, and what else to read |
| `/tour/`, `/drills/`, `/examples/`, `/cookbook/`, `/deep/` | The five parts that moved here from raku.online (see below) |
| `/foreign-language/` | Raku as a Foreign Language: its own front page, with everything below under it |
| `…/start-here/`, `…/levels/` | From `pages/`; Levels also lists the articles at each level |
| `…/articles/` | Every article, by kind |
| `…/readers/`, `…/false-friends/`, `…/word-families/`, `…/accents/` | One page per kind, its articles grouped by level |
| `…/readers/countdown/`, … | The articles, as pages under their kind, with Previous and Next at the end |
| `…/from/`, `…/from/python/`, … | The false friends and accents for each language a reader comes from |

The bar at the top of every page has Learn Raku's six parts and, in the
corner, the Raku course, the playground and Raku++. The pages of Raku as a
Foreign Language have a second bar with its sections and the search, which
finds its articles.

Until 23 October 2026 the articles were at the root (`/readers/countdown/`).
`site.json` keeps a 301 from each of those 36 addresses (`redirects`); the
list is fixed, since no new article ever had an old address.

- The six parts, their order and what the front page says about each are
  `@PARTS` in `tools/build-site.raku`. The numbers on the cards are counted
  at build time from the pages themselves, and the build stops if a page a
  card starts with has gone.
- The flashcard at the top of Raku as a Foreign Language's front page is
  one of `@FLASHCARDS` in `tools/build-site.raku`: false friends, word
  families and accents, a line or two of code from each. The first visit
  shows the first card, and every reload the next (the browser remembers
  which in `localStorage`). The build stops if a card's code is not in its
  article, or prints something the article's output does not show.
- Within a kind, articles are ordered by level, then by `posts/ORDER.md`.
- The summary in the front matter is shown under the title and in every
  list. Code in it goes in backticks.
- A runnable Raku block becomes `<pre data-raku>`, and RakuPress loads
  raku.js from raku.online on any page that has one: each block becomes an
  editor with a Run button. Its output follows as `<pre class="rfl-output">`,
  and a reader's output is folded in a `<details>`.
- The design is in `site/static/`: `bar.css` (the colours, among them one
  for each part, the fonts and the bar at the top, on every page) and
  `site.css` (the rest).
- The mark is RA over KU, as on the Learn Raku app, in the site's ink and
  paper: inline in the bar and the footer (`brand` in the build), and
  `icon.svg`, the favicon, which follows the system's light or dark.
  `icon-180.png`, the home-screen icon, was drawn from the same markup in
  headless Chrome with Inter 800; draw it again if the mark changes, and
  `root/favicon.ico` (16, 32 and 48 pixels) with it. `root/` is served at
  `/`, for files that must be at the root of the site.
- The front page and the footer have the App Store and Google Play buttons
  for the Learn Raku app (`@STORES`, the links in course.raku.org's footer);
  the badges and the app's icon are in `site/static/`. Light or dark is
  raku.online's switch: `/theme/boot.js` sets `html[data-theme-active]`, and
  the raku.js editors follow the same attribute. Fonts come from Google
  Fonts: Fraunces, Source Serif 4, Inter and JetBrains Mono.
- `site/site.json` turns on what RakuPress needs for this: the static front
  page, `header-file`, `footer-file`, `no-branding`, `no-theme-fonts`, the
  `static` folders and `extra-head`. The build stamps every link to the
  site's own files with the file's time, so browsers fetch new ones.

### The parts from raku.online

The tour, the drills, Raku by example, the cookbook and Raku Behind the Docs
are written and built in the raku.online repository, into its `learn/`
folder, as before. The build copies them, with raku.online's `theme/`, into
`site/learn/` (`RAKU_ONLINE` names the checkout, `~/raku.online` by
default), and changes three things on the way:

- `theme/shell.js`, raku.online's bar, becomes this site's: `bar.css` and
  the generated `bar.js`, which also moves the page's light and dark switch
  into the bar and keeps the room their layout leaves at the top
  (`--shell-h`) at the bar's height;
- the engine is loaded from https://raku.online (`raku.js`, and the drills'
  own worker), where its frozen addresses are;
- a link that leaves the moved sections goes back to raku.online.

raku.online keeps a redirect page at every one of their old addresses.
