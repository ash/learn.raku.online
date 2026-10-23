---
title: Countdown
strand: reader
level: A1
tags: [loops, conditions, strings]
words: [my, say, for, 1..10, $_, if, else, .uc]
summary: A rocket counts down from ten. Read the program and guess what it prints before you run it.
---

This is your first text. A rocket is about to start, and the program counts
down to the launch.

## Before you run it

Read the program and write down what it prints, line by line. Pay attention
to the last three numbers.

## The text

```raku
my $rocket = 'Vostok';

say "Rocket $rocket is ready.";

for 1..10 {
    my $left = 11 - $_;
    if $left > 3 {
        say $left;
    }
    else {
        say "$left!";
    }
}

say 'Lift-off!'.uc;
```

```output hidden
Rocket Vostok is ready.
10
9
8
7
6
5
4
3!
2!
1!
LIFT-OFF!
```

## Words

- `my` — creates a new variable. A variable that holds one thing has a
  name that starts with `$`.
- `say` — prints something and goes to the next line.
- `for` — repeats the block in `{ }` once for every value in a list.
- `1..10` — a range: the numbers from 1 to 10.
- `$_` — the current value inside a `for` loop: 1 the first time, 2 the
  second, and so on.
- `if`, `else` — run one block or the other, depending on a condition.
- `.uc` — gives the string in upper case.

## Reading notes

```raku norun
my $rocket = 'Vostok';
say "Rocket $rocket is ready.";
```

The first line puts the name `Vostok` in the variable `$rocket`. In double
quotes, a variable is replaced by its value, so the second line prints
`Rocket Vostok is ready.` In single quotes, it would print the name of the
variable as it is.

```raku norun
for 1..10 {
    my $left = 11 - $_;
```

The loop runs ten times, with `$_` going from 1 to 10. The program wants to
count down, not up, so it calculates `$left`: 11 − 1 = 10 the first time,
11 − 2 = 9 the second time, and 11 − 10 = 1 the last time.

```raku norun
    if $left > 3 {
        say $left;
    }
    else {
        say "$left!";
    }
```

While more than three seconds are left, the program prints the number. For
3, 2 and 1, it prints the number with an exclamation mark.

```raku norun
say 'Lift-off!'.uc;
```

The last line runs once, after the loop. `.uc` turns `Lift-off!` into
`LIFT-OFF!`. Only letters change; the hyphen and the exclamation mark stay.

## Questions

1. How many lines does the program print?
2. Which line would change if the rocket were called `Soyuz`?
3. What would the program print if the condition were `$left > 5`?

<details>
<summary>Answers</summary>

1. Twelve: one line before the loop, ten lines from the loop, and one after
   it.
2. Only the first one: `Rocket Soyuz is ready.`
3. The numbers 5, 4, 3, 2 and 1 would get an exclamation mark.

</details>

## Try this

Make the rocket count down from 20 instead of 10. You need to change two
numbers. Which ones, and why both?
