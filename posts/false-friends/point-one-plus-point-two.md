---
title: 0.1 + 0.2 is exactly 0.3
strand: false-friend
level: A2
from: [python, js]
tags: [numbers, fractions]
summary: In Python and JavaScript, `0.1 + 0.2` is not equal to `0.3`. In Raku it is, because `0.1` is stored as a fraction.
---

Most programming languages cannot add 0.1 and 0.2 exactly. Raku can, and
that surprises people who already know the other answer.

## In Python

```python
print(0.1 + 0.2 == 0.3)
print(0.1 + 0.2)
```

```output
False
0.30000000000000004
```

## In JavaScript

```js
console.log(0.1 + 0.2 === 0.3);
console.log(0.1 + 0.2);
```

```output
false
0.30000000000000004
```

## In Raku

```raku
say 0.1 + 0.2 == 0.3;
say 0.1 + 0.2;
```

```output
True
0.3
```

This is not `say` rounding the result for you. The sum really is three
tenths.

## Why

Python and JavaScript store 0.1 as a binary floating-point number. One
tenth has no exact form in binary, in the same way that one third has no
exact form in decimal: 0.3333… never ends. So the computer stores the
nearest value it can. The small errors in 0.1 and 0.2 add up, and the sum
misses 0.3 by a tiny amount.

In Raku, a number written with a decimal point, like `0.1`, is a `Rat`, a
rational number. It is stored as two integers: a numerator and a
denominator. `0.1` is 1/10, `0.2` is 2/10, and their sum is 3/10, exactly.
The method `.nude` shows the two integers; its name comes from
**nu**merator and **de**nominator.

```raku
say 0.1.WHAT;
say 0.1.nude;
say (0.1 + 0.2).nude;
```

```output
(Rat)
(1 10)
(3 10)
```

The same goes for division: `1/3` is kept as one third, not as 0.333333,
so three of them make exactly one.

```raku
say 1/3 + 1/3 + 1/3 == 1;
```

```output
True
```

## Say it in Raku

There is nothing to fix. Decimal numbers in your program add up the way
they do on paper.

When you do want a floating-point number, for speed or to get the same
result as another language, write it with an exponent: `e0` means "times
ten to the power of zero". Then Raku gives the same answer as Python.

```raku
say 0.1e0 + 0.2e0 == 0.3e0;
say 0.1e0 + 0.2e0;
say (0.1e0 + 0.2e0).WHAT;
```

```output
False
0.30000000000000004
(Num)
```
