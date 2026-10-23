---
title: Splitting on nothing does not give you the letters
strand: false-friend
level: A2
from: [js, perl, python]
tags: [strings, lists]
summary: In JavaScript and Perl, splitting on an empty string gives the characters. In Raku you also get an empty string at each end. Use `.comb`.
---

To get the letters of a word, JavaScript and Perl programmers split it on
nothing. In Raku that gives you two extra pieces.

## In JavaScript

```js
console.log("Riga".split(""));
```

```output
[ 'R', 'i', 'g', 'a' ]
```

## In Perl

```perl
my @letters = split //, "Riga";
print join(" ", @letters), "\n";
print scalar(@letters), "\n";
```

```output
R i g a
4
```

## In Python

Python refuses an empty separator and has `list` instead:

```python
try:
    print("Riga".split(""))
except ValueError as e:
    print("ValueError:", e)
print(list("Riga"))
```

```output
ValueError: empty separator
['R', 'i', 'g', 'a']
```

## In Raku

```raku
say "Riga".split("");
say "Riga".split("").elems;
```

```output
( R i g a )
6
```

Look at the spaces inside the parentheses. Before `R` and after `a` there
is an empty string, so the list has six elements, not four.

## Why

`.split` cuts the string at every place where the separator is found, and
keeps everything between the cuts, even when it is empty. An empty
separator is found everywhere: between the letters, but also before the
first letter and after the last one. That makes five cuts in a four-letter
word, and six pieces.

JavaScript and Perl treat the empty separator as a special case and drop
the empty pieces at the ends. Raku does not make a special case.

## Say it in Raku

`.comb` without an argument gives you the characters:

```raku
say "Riga".comb;
say "Riga".comb.elems;
```

```output
(R i g a)
4
```

When you do split and want no empty pieces, say so with `:skip-empty`:

```raku
say "Riga".split("", :skip-empty);
```

```output
(R i g a)
```
