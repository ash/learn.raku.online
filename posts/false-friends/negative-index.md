---
title: "@a[-1] is not the last element"
strand: false-friend
level: A2
from: [python, perl]
tags: [arrays, indexing]
summary: In Python and Perl, index -1 counts from the end. In Raku it does not even compile.
---

Python and Perl count from the end of a list with negative numbers. Raku
counts from the end too, but not with negative numbers.

## In Python

```python
cities = ["Riga", "Leiden", "Turin"]
print(cities[-1])
print(cities[-2])
```

```output
Turin
Leiden
```

## In Perl

```perl
my @cities = ("Riga", "Leiden", "Turin");
print $cities[-1], "\n";
print $cities[-2], "\n";
```

```output
Turin
Leiden
```

## In Raku

```raku error
my @cities = 'Riga', 'Leiden', 'Turin';
say @cities[-1];
```

```output
Unsupported use of a negative -1 subscript to index from the end
```

The program does not start at all. Raku sees `-1` while it compiles the
program, before the first line runs, and stops with a message that also
tells you what to write instead.

If the negative number comes from a variable, Raku cannot see it in
advance, so the program starts and stops when it gets there:

```raku error
my @cities = 'Riga', 'Leiden', 'Turin';
my $i = -1;
say @cities[$i];
```

```output
Index out of range. Is: -1, should be in 0..^Inf
```

## Why

In Python and Perl, an index that goes below zero by mistake quietly picks
an element from the other end of the list. That kind of bug is hard to
find, because nothing looks wrong.

Raku separates the two things. A number in `[ ]` always counts from the
start, so a negative number is always an error. To count from the end, you
say so with `*`, which stands for the number of elements in the array.
`*-1` means "the number of elements, minus one": the index of the last
element.

## Say it in Raku

```raku
my @cities = 'Riga', 'Leiden', 'Turin';
say @cities[*-1];
say @cities[*-2];
say @cities[*-2 .. *-1];
```

```output
Turin
Leiden
(Leiden Turin)
```

When you only want the last element, or the last few, the methods `.tail`
and `.head` say it in words:

```raku
my @cities = 'Riga', 'Leiden', 'Turin';
say @cities.tail;
say @cities.tail(2);
say @cities.head;
```

```output
Turin
(Leiden Turin)
Riga
```
