---
title: comb, words, lines, split
strand: family
level: A2
tags: [strings, lists]
words: [.comb, .words, .lines, .split]
summary: Four methods that cut a string into a list of pieces, and how to pick the right one.
---

All four members of this family take one string and give you back a list
of smaller strings. They differ in where they cut, and in what they do with
the parts between the cuts.

## The family

### `.comb` — keeps what you want

Without an argument, `.comb` gives you every character on its own.

```raku
say 'Riga'.comb;
```

```output
(R i g a)
```

With a pattern, it keeps only the pieces that match the pattern and throws
the rest away. Here the pattern `\d+` means "one or more digits".

```raku
say '2026-10-22'.comb(/\d+/);
say 'Platform 9, train 3014 to Utrecht'.comb(/\d+/);
```

```output
(2026 10 22)
(9 3014)
```

### `.words` — cuts at spaces

`.words` cuts wherever there is whitespace: spaces, tabs or line breaks. It
does not matter how many there are in a row.

```raku
say 'bread   butter  cheese'.words;
say '  one more time  '.words;
```

```output
(bread butter cheese)
(one more time)
```

### `.lines` — cuts at line breaks

`.lines` gives you one string per line, without the line break at the end
of each.

```raku
my $list = "milk\nbread\neggs\n";
say $list.lines;
say $list.lines.elems;
```

```output
(milk bread eggs)
3
```

The line break after `eggs` does not make a fourth, empty line.

### `.split` — cuts where you say

`.split` cuts at the separator you give it, and keeps everything between
the separators, even when there is nothing there.

```raku
say 'Amsterdam,Rotterdam,,Utrecht'.split(',');
say 'Amsterdam,Rotterdam,,Utrecht'.split(',').elems;
```

```output
(Amsterdam Rotterdam  Utrecht)
4
```

Between the two commas there is an empty string. It shows up as the double
space in the output, and it counts as an element.

## Side by side

| Method | Cuts at | Gives you | Empty pieces |
|---|---|---|---|
| `.comb` | — | the characters, or the matches of a pattern | never |
| `.words` | any whitespace | the words | never |
| `.lines` | line breaks | the lines | only empty lines in the middle |
| `.split` | the separator you give | everything between separators | kept |

A way to remember them: `.comb` describes what you **keep**, `.split`
describes what you **throw away**, and `.words` and `.lines` already know
both.

## Which one?

Which method would you use for each task?

1. Get the four digits of the year `2026` one by one.
2. Read the fields of the line `Anna;;Leiden;31`, where the second field is
   empty on purpose.
3. Get the words of a sentence that someone typed with two spaces after
   each full stop.
4. Get all the numbers from `3 apples and 12 pears`.

<details>
<summary>Answers</summary>

1. `.comb`: `'2026'.comb` gives `(2 0 2 6)`.
2. `.split(';')`, because it keeps the empty field, so the city is always
   the third element.
3. `.words`. `.split(' ')` would give you empty strings for the double
   spaces.
4. `.comb(/\d+/)` gives `(3 12)`.

</details>
