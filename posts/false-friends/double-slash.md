---
title: // is not integer division
strand: false-friend
level: A2
from: [python]
tags: [numbers, operators]
summary: In Python, `7 // 2` is 3. In Raku, `//` means "or else, if there is no value", so `7 // 2` is 7.
---

In Python, `//` divides and drops the fraction. In Raku, `//` does not
divide at all.

## In Python

```python
print(7 // 2)
print(7 % 2)
print(-7 // 2)
```

```output
3
1
-4
```

## In Raku

```raku
say 7 // 2;
```

```output
7
```

No error and no warning, only a wrong answer. That makes this the more
dangerous kind of false friend.

## Why

In Raku, `//` is the defined-or operator. It gives you the left side if
the left side has a value, and the right side if it does not. `7` has a
value, so the answer is `7`, and the `2` is never looked at.

Its job is giving defaults:

```raku
my $nickname;
say $nickname // 'no nickname';

my $city = 'Turin';
say $city // 'unknown';
```

```output
no nickname
Turin
```

`$nickname` was declared but never given a value, so `//` uses the text on
the right. `$city` has a value, so `//` keeps it.

If you come from Perl, this is nothing new: Perl's `//` means the same.

```perl
my $nickname;
print $nickname // "no nickname", "\n";
```

```output
no nickname
```

## Say it in Raku

Integer division is `div`, and the remainder is `%`:

```raku
say 7 div 2;
say 7 % 2;
say 7 / 2;
```

```output
3
1
3.5
```

`/` is ordinary division and keeps the fraction: `3.5`.

With negative numbers, `div` rounds down, the same way Python's `//` does:

```raku
say -7 div 2;
say -7 % 2;
```

```output
-4
1
```
