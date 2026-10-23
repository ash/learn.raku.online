---
title: "? : is ?? !! in Raku"
strand: false-friend
level: A2
from: [js, perl, c]
tags: [conditions, operators]
summary: The conditional operator a ? b : c from C, JavaScript and Perl does not compile in Raku. It is written a ?? b !! c.
---

C, JavaScript and Perl choose between two values with `? :`. Raku has the
same operator, spelled with doubled characters.

## In JavaScript

```js
const trains = 3;
console.log(trains + " " + (trains == 1 ? "train" : "trains"));
```

```output
3 trains
```

## In Perl

```perl
my $trains = 3;
print "$trains ", $trains == 1 ? "train" : "trains", "\n";
```

```output
3 trains
```

## In Raku

```raku error
my $trains = 3;
say "$trains ", $trains == 1 ? "train" : "trains";
```

```output
Unsupported use of ? and : for the ternary conditional operator
```

The program does not compile, and the message tells you what to write
instead.

## Why

In Raku, a single `?` in front of a value turns it into a Boolean, and a
single `:` starts a named argument or an adverb. Both characters were
needed elsewhere, so the conditional operator got doubled ones. The
doubles also make it easier to see in a long line: `??` asks, `!!` says
what happens otherwise.

## Say it in Raku

```raku
my $trains = 3;
say "$trains ", $trains == 1 ?? "train" !! "trains";
```

```output
3 trains
```
