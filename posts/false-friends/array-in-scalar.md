---
title: my $n = @array is not a count
strand: false-friend
level: A2
from: [perl]
tags: [arrays, variables]
summary: In Perl, putting an array into a scalar variable gives you its length. In Raku, the scalar holds the whole array.
---

Perl programmers count an array by putting it into a scalar. Raku keeps
the array.

## In Perl

```perl
my @cities = ("Riga", "Leiden", "Turin");
my $n = @cities;
print "$n\n";
print "There are $n cities\n";
```

```output
3
There are 3 cities
```

## In Raku

```raku
my @cities = 'Riga', 'Leiden', 'Turin';
my $n = @cities;
say $n;
say "There are $n cities";
```

```output
[Riga Leiden Turin]
There are Riga Leiden Turin cities
```

There is no error. The program runs and prints a sentence you did not
want.

## Why

Perl decides what an array gives you from the place where you use it: put
it where one value is expected, and you get the count. Raku does not work
that way. A `$` variable holds one thing, and that one thing can be a whole
array.

It is the same array, not a copy. Add a city to `@cities`, and `$n` sees it:

```raku
my @cities = 'Riga', 'Leiden', 'Turin';
my $n = @cities;
@cities.push('Ghent');
say $n;
say $n.WHAT;
```

```output
[Riga Leiden Turin Ghent]
(Array)
```

## Say it in Raku

Ask for the count with `.elems`:

```raku
my @cities = 'Riga', 'Leiden', 'Turin';
my $n = @cities.elems;
say $n;
say "There are $n cities";
```

```output
3
There are 3 cities
```

Where Raku does expect a number, an array gives its count. A `+` in front
of it asks for a number, and so does a numeric comparison:

```raku
my @cities = 'Riga', 'Leiden', 'Turin';
say "There are {+@cities} cities";
say 'More than two' if @cities > 2;
```

```output
There are 3 cities
More than two
```
