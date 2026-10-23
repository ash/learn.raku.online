---
title: Fibonacci numbers below 1000
strand: accent
level: B2
from: [python, perl, c]
tags: [sequences, loops]
summary: The Fibonacci numbers below 1000, written with a Python, a Perl and a C accent, and with a native Raku sequence.
---

## The task

Print the Fibonacci numbers that are smaller than 1000, on one line. The
sequence starts with 1 and 1, and every next number is the sum of the two
before it.

```output
1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987
```

## With a Python accent

```raku
my ($a, $b) = 1, 1;
my @result = [];
while $a < 1000 {
    @result.append($a);
    ($a, $b) = ($b, $a + $b);
}
say(@result.join(' '));
```

What gives it away:

- `($a, $b) = ($b, $a + $b)`, the famous Python line `a, b = b, a + b`.
  It works in Raku too: the right side is calculated before anything is
  assigned.
- `my @result = []` to start an empty list, and `.append` to add to it.
- Building the list first, then joining it into one string with
  `.join(' ')`.
- Parentheses around the argument of `say`, as with Python's `print()`.

## With a Perl accent

```raku
my @fib = (1, 1);
while (1) {
    my $next = @fib[@fib - 1] + @fib[@fib - 2];
    last if $next >= 1000;
    push @fib, $next;
}
print join(' ', @fib), "\n";
```

What gives it away:

- `while (1)` with a `last` inside: an endless loop that you break out of.
- `@fib - 1` to get the last index, because an array in a numeric context
  is its length. In Perl you would write `$#fib`.
- `push`, `join` and `print` as functions, and `"\n"` added by hand.
- Parentheses around the list in `my @fib = (1, 1)`. Raku does not need
  them here.

## With a C accent

```raku
my @fib;
@fib[0] = 1;
@fib[1] = 1;
my $count = 2;
loop {
    my $next = @fib[$count - 1] + @fib[$count - 2];
    if $next >= 1000 {
        last;
    }
    @fib[$count] = $next;
    $count++;
}

loop (my $i = 0; $i < $count; $i++) {
    print @fib[$i];
    if $i < $count - 1 {
        print ' ';
    }
}
print "\n";
```

What gives it away:

- A separate `$count` variable that keeps track of how many elements the
  array has, when the array already knows.
- Filling the array one index at a time, starting with `@fib[0]` and
  `@fib[1]`.
- Printing the numbers one by one, with an `if` to avoid a space after the
  last one.

## Native

```raku
my @fib = 1, 1, * + * ...^ * >= 1000;
put @fib;
```

## What changed

- The `...` operator builds a sequence. On its left are the first values
  and the rule for the next one; on its right is the condition to stop.
- `* + *` is the rule: a piece of code with two arguments. The sequence
  calls it with the two last numbers it has, and the result is the next
  number.
- `* >= 1000` is the stop condition. The `^` in `...^` means "stop before
  the number that meets the condition", so 1597 is not in the list.
- There is no loop and no counter. You describe the sequence, and Raku
  builds it.
- `put` prints the elements of the array with spaces between them, so
  there is nothing to join.
