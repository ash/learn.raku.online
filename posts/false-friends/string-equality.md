---
title: == does not compare strings
strand: false-friend
level: A1
from: [python, js]
tags: [strings, operators, comparison]
summary: In Python and JavaScript, `==` compares strings too. In Raku, `==` compares numbers, and strings are compared with `eq`.
---

In Python and JavaScript, `==` works for anything. In Raku, `==` only
compares numbers.

## In Python

```python
print("Riga" == "Riga")
print("10" == "10.0")
```

```output
True
False
```

## In JavaScript

```js
console.log("Riga" == "Riga");
console.log("10" == "10.0");
```

```output
true
false
```

## In Raku

```raku error
say "Riga" == "Riga";
```

```output
Cannot convert string to number: base-10 number must begin with valid digits or '.'
```

`==` tries to turn both strings into numbers, and `Riga` is not a number.

When the strings do look like numbers, there is no error, and you get the
opposite answer to Python's:

```raku
say "10" == "10.0";
```

```output
True
```

Ten is ten, however you write it. This case is the more dangerous one,
because nothing tells you that the strings were never compared as strings.

## Why

In Raku, the operator decides what kind of comparison you get. There is
one set of operators for numbers and another one for strings:

| Question | Numbers | Strings |
|---|---|---|
| equal? | `==` | `eq` |
| not equal? | `!=` | `ne` |
| less than? | `<` | `lt` |
| greater than? | `>` | `gt` |

Perl works the same way, so Perl programmers already have this habit:

```perl
print "10" == "10.0" ? "equal" : "different", "\n";
print "10" eq "10.0" ? "equal" : "different", "\n";
```

```output
equal
different
```

## Say it in Raku

```raku
say "Riga" eq "Riga";
say "10" eq "10.0";
say "Riga" ne "Rome";
say "Leiden" lt "Riga";
```

```output
True
False
True
True
```

`lt` compares in alphabetical order: `Leiden` comes before `Riga`.
