---
title: x, xx and X
strand: family
level: B1
tags: [operators, strings, lists]
words: [x, xx, X]
summary: Three operators that look alike — one repeats a string, one repeats a list element, and one combines two lists.
---

The three members of this family all multiply something, and all three
are spelled with the letter x. Each one gives you something bigger than
the one before: a string, a list, a list of combinations.

## The family

### `x` — repeats a string

`x` takes a string on the left and a number on the right, and gives you
one string with the left side repeated that many times.

```raku
say 'ha' x 3;
say '-' x 20;
say ('=' x 5) ~ ' end';
```

```output
hahaha
--------------------
===== end
```

The result is always a string, even when the left side is a number:
`3 x 2` is the string `33`.

```raku
say 3 x 2;
say (3 x 2).WHAT;
```

```output
33
(Str)
```

### `xx` — repeats an element in a list

`xx` gives you a list instead of a string. Each repetition is a separate
element.

```raku
say 'ha' xx 3;
say ('ha' xx 3).join(', ');
my @row = 0 xx 4;
say @row;
```

```output
(ha ha ha)
ha, ha, ha
[0 0 0 0]
```

`xx` does something that `x` does not: it runs the left side again for
every element. If the left side changes something, you see the change.

```raku
my $n = 0;
say $n++ xx 3;
```

```output
(0 1 2)
```

That is why `[0 xx 3] xx 2` gives you two separate rows, not the same row
twice. Changing one row does not change the other.

```raku
my @grid = [0 xx 3] xx 2;
@grid[0][1] = 5;
say @grid;
```

```output
[[0 5 0] [0 0 0]]
```

### `X` — combines two lists

`X` is the cross product. It takes two lists and gives you every pair you
can make with one element from the left and one from the right.

```raku
say <S M L> X <red blue>;
say (<S M L> X <red blue>).elems;
```

```output
((S red) (S blue) (M red) (M blue) (L red) (L blue))
6
```

Three sizes and two colours make six pairs. You can put another operator
right after the `X`, and it is applied to each pair instead of making a
list of two. With `~`, the pairs are joined into strings:

```raku
say <S M L> X~ <-red -blue>;
say (1, 2) X* (10, 100);
```

```output
(S-red S-blue M-red M-blue L-red L-blue)
(10 100 20 200)
```

## Side by side

| Operator | Left side | You get | Example |
|---|---|---|---|
| `x` | a string | one longer string | `'ab' x 2` → `abab` |
| `xx` | anything | a list of copies | `'ab' xx 2` → `(ab ab)` |
| `X` | a list | a list of all combinations | `<a b> X <1 2>` → `((a 1) (a 2) (b 1) (b 2))` |

## Which one?

Which operator would you use for each task?

1. Print a line of 30 stars under a heading.
2. Start a list of seven zeros, one for each day of the week.
3. Make the names of all chess squares from `a1` to `h8`.
4. Indent a line by four spaces.

<details>
<summary>Answers</summary>

1. `x`: `say '*' x 30`.
2. `xx`: `my @days = 0 xx 7`.
3. `X~`: `('a'..'h') X~ (1..8)` gives `a1 a2 … a8 b1 … h8`.
4. `x`: `' ' x 4 ~ $line`.

</details>
