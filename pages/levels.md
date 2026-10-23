---
title: Levels
summary: Six levels of reading and writing Raku, from A1 to C2, described as things you can do.
---

Language teachers in Europe describe what a learner can do at six levels,
from A1 to C2. These articles use the same six levels for Raku, and so do
the [drills](/drills/). Every article is marked with one, so you can stay at
your level or step one above it.

A level says what you can **read** and what you can **write**. Reading comes
first: you will understand code at the next level long before you write it
yourself, and that is how it should be.

## A1 — First words

You can read a program of a few lines and say what it prints.

- `say`, `print`, comments
- variables with `my`: numbers and strings
- `+ - * / %`, `**`, and `~` to join strings
- `if`, `else`, `unless`
- `for` over a range like `1..10`, with `$_`
- `.uc`, `.lc`, `.chars`, `.flip`

You can write: a program that prints a table, counts to a number, or checks
one condition.

## A2 — Everyday Raku

You can read a program of a page that works with lists of things.

- arrays and hashes, `@` and `%`, `.elems`, `.keys`, `.values`, `.kv`
- `for @list -> $item { }`, pointy blocks with one or two variables
- `^10`, `.reverse`, `.sort`, `.join`, `.split`, `.words`, `.comb`
- strings with interpolation, including `{ }` inside them
- `sub` with positional parameters, `return`
- `while`, `loop`, `last`, `next`

You can write: a small program that keeps a list or a table and reports on
it.

## B1 — Getting around

You can read most programs written to solve a small task, and you can
follow method chains.

- `map`, `grep`, `first`, `sum`, `min`, `max`, `.unique`, `.classify`
- the whatever star: `* * 2`, `*.chars`
- named arguments and default values
- classes with `has` attributes and methods
- simple regexes: `m/ /`, `.match`, `.subst`, `~~`
- `Rat` arithmetic, and the difference between `say` and `put`
- `given`/`when`

You can write: a program of a hundred lines with a class or two, and read
its error messages.

## B2 — Independent

You can read code written by someone else without asking them, including
code that uses the operators that make Raku different.

- signatures with types and constraints, `multi` subs
- roles
- sequences: `1, 2, 4 ... *`, lazy lists, `gather`/`take`
- metaoperators: `[+]`, `»`, `Z`, `X`, `R`
- junctions: `any`, `all`, `none`
- `Set`, `Bag`, `Mix` and their operators
- small grammars, named captures
- `try`, `CATCH`, `die`, `fail`

You can write: a program that someone else would accept in a code review.

## C1 — Fluent

You can read a module from the ecosystem and explain how it works.

- grammars with action classes
- your own operators
- containers and binding: `=` and `:=`, `is rw`, `is copy`
- phasers: `BEGIN`, `ENTER`, `LEAVE`, `FIRST`, `LAST`
- `start`, `await`, `Promise`, `Supply`, `react`/`whenever`
- introspection: `.WHAT`, `.^name`, `.^methods`
- traits and `is export`

You can write: a module with a clear interface and tests.

## C2 — Native

You can read anything written in Raku, including dense one-liners and
golfed code, and say why it works.

- every operator and its precedence
- the metaobject protocol
- `Seq` and its caching, `Iterable` and iterators
- slangs and `EVAL`, and when not to use them

You can write: code that other Raku programmers learn from.
