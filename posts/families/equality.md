---
title: "==, eq, eqv, === and ~~"
strand: family
level: B1
tags: [operators, comparison]
words: [==, eq, eqv, ===, ~~]
summary: Five ways to ask whether two things are equal, and the question each one really asks.
---

Most languages have one or two equality operators. Raku has five, because
"are these two equal?" can mean different things. Each member of this
family asks a more exact question than the one before.

## The family

### `==` — equal as numbers

`==` turns both sides into numbers and compares the numbers.

```raku
say 10 == 10.0;
say '10' == 10;
say 1/2 == 0.5;
```

```output
True
True
True
```

If a string does not look like a number, the comparison fails with an
error:

```raku error
say 'apple' == 'pear';
```

```output
Cannot convert string to number
```

For arrays and lists, the number is the count of elements. So `==` says
two lists are equal when they have the same length, whatever is in them:

```raku
my @mine = 1, 2, 3;
my @yours = 7, 8, 9;
say @mine == @yours;
```

```output
True
```

### `eq` — equal as strings

`eq` turns both sides into strings and compares the strings, character by
character.

```raku
say '10' eq '10.0';
say 10 eq '10';
say 'Riga' eq 'riga';
```

```output
False
True
False
```

`10` and `10.0` are the same number, but `'10'` and `'10.0'` are
different strings.

Careful: it is the value that becomes a string, not the way you typed it.
The number `10.0` becomes the string `'10'`:

```raku
say 10 eq 10.0;
say 10.0;
```

```output
True
10
```

### `eqv` — the same type and the same contents

`eqv` does not turn anything into anything. Both sides must be of the same
type, and everything inside them must be the same too. This is the one to
use for lists and arrays.

```raku
my @mine = 1, 2, 3;
my @yours = 1, 2, 3;
say @mine eqv @yours;
say @mine eqv [1, 2, 4];
say 3 eqv 3.0;
```

```output
True
False
False
```

`3` is an integer and `3.0` is a fraction (`Rat`), so they are not the
same type.

### `===` — the same thing

`===` asks whether the two sides are the same object. Two arrays with the
same contents are still two arrays.

```raku
my @mine = 1, 2, 3;
my @yours = 1, 2, 3;
say @mine === @yours;
say @mine === @mine;
say 'Riga' === 'Riga';
```

```output
False
True
True
```

Strings and numbers count as the same thing whenever their value and type
are the same, so `'Riga' === 'Riga'` is `True`.

### `~~` — does it fit?

`~~` is the smartmatch. It does not ask "are they equal?" but "does the
left side fit what the right side describes?" What that means depends on
the right side: a type, a range, a regex or a plain value.

```raku
say 'Riga' ~~ Str;
say 5 ~~ 1..10;
say 'Riga' ~~ /R/;
say 10 ~~ 10.0;
```

```output
True
True
｢R｣
True
```

A regex on the right gives you the match itself, which counts as true. A
number on the right compares as numbers, like `==`.

## Side by side

| Operator | Question | `10` and `10.0` | `[1, 2]` and `[3, 4]` |
|---|---|---|---|
| `==` | same number? | `True` | `True` (both have 2 elements) |
| `eq` | same string? | `True` (both become `'10'`) | `False` |
| `eqv` | same type and contents? | `False` | `False` |
| `===` | the same object? | `False` | `False` |
| `~~` | does the left fit the right? | `True` | `False` |

## Which one?

Which operator would you use for each task?

1. Check whether the user typed exactly `yes`.
2. Check whether two arrays hold the same elements in the same order.
3. Check whether a value is a whole number of type `Int`.
4. Check whether the price `'4.50'` read from a file equals `4.5`.

<details>
<summary>Answers</summary>

1. `eq`: `$answer eq 'yes'`.
2. `eqv`: `@a eqv @b`. With `==`, you would compare only their lengths.
3. `~~`: `$value ~~ Int`.
4. `==`: `'4.50' == 4.5` is `True`, while `'4.50' eq 4.5` is `False`,
   because `4.5` becomes the string `'4.5'`.

</details>
