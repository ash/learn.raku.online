---
title: + adds, even when the numbers are strings
strand: false-friend
level: A1
from: [js, python]
tags: [strings, numbers, operators]
summary: In JavaScript, `"10" + 5` is `"105"`, and in Python it is an error. In Raku it is 15, because `+` always adds.
---

In JavaScript and Python, `+` has two jobs: it adds numbers and it joins
strings. In Raku it has one.

## In JavaScript

```js
console.log("10" + 5);
console.log("10" + "5");
console.log("10" - 5);
```

```output
105
105
5
```

JavaScript sees a string, so `+` joins. `-` has only one job, so it
subtracts.

## In Python

```python
try:
    print("10" + 5)
except TypeError as e:
    print("TypeError:", e)
```

```output
TypeError: can only concatenate str (not "int") to str
```

## In Raku

```raku
say "10" + 5;
say "10" + "5";
```

```output
15
15
```

Both lines add. The strings are turned into numbers first.

If a string does not look like a number, there is nothing to add, and the
program stops:

```raku error
say "10" + "five";
```

```output
Cannot convert string to number: base-10 number must begin with valid digits or '.'
```

## Why

In Raku, the operator decides what kind of operation happens, not the
values. `+` is always addition: it turns both sides into numbers. `~` is
always joining: it turns both sides into strings.

So you can tell from the operator alone what a line will do, without
knowing where the values came from. That matters, because values that come
from a file or from the keyboard are always strings, and `+` still adds
them.

## Say it in Raku

To join, use `~`:

```raku
say "10" ~ 5;
say 10 ~ 5;
say "10" + 5;
```

```output
105
105
15
```

`~` joins even two numbers: `10 ~ 5` is the string `105`.
