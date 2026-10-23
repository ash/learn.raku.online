---
title: There is no length
strand: false-friend
level: A2
from: [python, js, perl]
tags: [strings, arrays]
summary: "`len`, `.length` and `length` do not exist in Raku. A string has `.chars`, and a list has `.elems`."
---

Every language has a way to ask "how long is it?", and each one spells it
differently. Raku spells it in two ways, because it is two questions.

## In Python

```python
print(len("Riga"))
print(len(["Riga", "Leiden", "Turin"]))
```

```output
4
3
```

## In JavaScript

```js
console.log("Riga".length);
console.log(["Riga", "Leiden", "Turin"].length);
```

```output
4
3
```

## In Perl

```perl
my @cities = ("Riga", "Leiden", "Turin");
print length("Riga"), "\n";
print scalar(@cities), "\n";
```

```output
4
3
```

## In Raku

```raku error
say "Riga".length;
```

```output
No such method 'length'
```

```raku error
my @cities = 'Riga', 'Leiden', 'Turin';
say @cities.length;
```

```output
No such method 'length' for invocant of type 'Array'
```

There is no function called `len` or `length` either. Raku stops and tells
you that it does not know that routine.

## Why

"How long" can mean different things. For a string, it can mean the
number of characters or the number of bytes, and those are not the same
once a word has letters outside English:

```raku
say "Rīga".chars;
say "Rīga".encode.bytes;
```

```output
4
5
```

The letter `ī` takes two bytes. Raku does not guess which length you mean:
`.chars` counts characters, and `.elems` counts the elements of a list.

## Say it in Raku

```raku
my @cities = 'Riga', 'Leiden', 'Turin';
say "Riga".chars;
say @cities.elems;
```

```output
4
3
```

Be careful not to swap them. Each one works on the other kind of value
too, and gives an answer you did not ask for:

```raku
my @cities = 'Riga', 'Leiden', 'Turin';
say @cities.chars;
say "Riga".elems;
```

```output
17
1
```

`.chars` on an array first turns it into the string
`Riga Leiden Turin`, which has 17 characters. `.elems` on a string treats
it as a list with one element: the string itself.
