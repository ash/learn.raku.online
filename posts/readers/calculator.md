---
title: A pocket calculator
strand: reader
level: C1
tags: [grammars, actions, parsing]
words: [grammar, rule, "+ %", token, "$/", make, .made, .parse, "actions => Evaluate"]
summary: A grammar and an action class that read an arithmetic expression like `2 + 3 * (4 - 1)` and work out its value.
---

This program is a calculator for expressions with `+`, `-`, `*`, `/` and
parentheses. A grammar reads the expression, and an action class works out
the value while the grammar reads.

## Before you run it

Nowhere does the program say that `*` goes before `+`. Will the first
expression give 11 or 15? And the last one, `7 - 2 - 1`: 4 or 6?

## The text

```raku
grammar Calculator {
    rule TOP        { <expression> }
    rule expression { <term>+ % <add-op> }
    rule term       { <factor>+ % <mul-op> }
    rule factor     { <number> | '(' <expression> ')' }
    token add-op    { '+' | '-' }
    token mul-op    { '*' | '/' }
    token number    { \d+ }
}

class Evaluate {
    method TOP($/)        { make $<expression>.made }
    method expression($/) { make combine($<term>».made, $<add-op>».Str) }
    method term($/)       { make combine($<factor>».made, $<mul-op>».Str) }
    method factor($/)     { make $<number> ?? +$<number> !! $<expression>.made }
}

sub combine(@values, @ops) {
    my $result = @values[0];
    for @ops Z @values[1..*] -> ($op, $value) {
        given $op {
            when '+' { $result += $value }
            when '-' { $result -= $value }
            when '*' { $result *= $value }
            when '/' { $result /= $value }
        }
    }
    return $result;
}

for '2 + 3 * (4 - 1)', '10 / 4', '(1 + 2) * (3 + 4)', '7 - 2 - 1' -> $expression {
    my $match = Calculator.parse($expression, actions => Evaluate);
    say "$expression = {$match.made}";
}
```

```output hidden
2 + 3 * (4 - 1) = 11
10 / 4 = 2.5
(1 + 2) * (3 + 4) = 21
7 - 2 - 1 = 4
```

## Words

- `grammar` — a group of named patterns that together describe a small
  language. It looks like a class, and it is one.
- `rule` — a named pattern in which the spaces in the pattern allow spaces
  in the input. `2 + 3` and `2+3` both match.
- `+ %` — `<term>+ % <add-op>` means one or more terms, separated by
  add-ops: `term`, or `term + term`, or `term - term + term`.
- `token` — a named pattern in which spaces are only for the reader of the
  program. It matches exactly what it says.
- `$/` — the match object. In an action method, it is the match of the
  rule with the same name, and `$<term>` is short for `$/<term>`.
- `make` — attaches a value to the current match.
- `.made` — gives back the value that `make` attached.
- `.parse` — matches the whole string against the grammar, starting with
  `TOP`.
- `actions => Evaluate` — tells `.parse` to call the methods of `Evaluate`
  as the rules match.

## Reading notes

```raku norun
    rule TOP        { <expression> }
    rule expression { <term>+ % <add-op> }
    rule term       { <factor>+ % <mul-op> }
    rule factor     { <number> | '(' <expression> ')' }
```

Read the four rules from top to bottom, and you have the whole language. An
expression is terms joined by `+` or `-`. A term is factors joined by `*`
or `/`. A factor is a number, or a whole expression in parentheses.

This is where the precedence comes from. In `2 + 3 * (4 - 1)`, the
expression has two terms: `2` and `3 * (4 - 1)`. The second term is
finished, multiplication and all, before the expression adds anything. The
grammar has no table of priorities; the nesting of the rules is the
priority.

The parentheses lead back to `expression`, so `factor` can contain a whole
expression, which can contain factors with parentheses, and so on.

```raku norun
    token add-op    { '+' | '-' }
    token mul-op    { '*' | '/' }
    token number    { \d+ }
```

The smallest pieces are tokens: they match characters, with no spaces
allowed inside. A number is one or more digits.

```raku norun
class Evaluate {
    method TOP($/)        { make $<expression>.made }
    method expression($/) { make combine($<term>».made, $<add-op>».Str) }
    method term($/)       { make combine($<factor>».made, $<mul-op>».Str) }
    method factor($/)     { make $<number> ?? +$<number> !! $<expression>.made }
}
```

Each method has the name of a rule, and `.parse` calls it as soon as that
rule has matched. The rules inside have matched before the rule around
them, so when `term` runs, every factor in it already carries its value.
The methods work from the inside out.

`factor` makes a number from the digits with `+`, or takes the value of the
expression in parentheses. `term` and `expression` collect the values of
their parts with `».made`, the operators with `».Str`, and give both lists
to `combine`. `TOP` passes the final value up. The tokens have no methods,
because nothing needs to be calculated for them.

```raku norun
sub combine(@values, @ops) {
    my $result = @values[0];
    for @ops Z @values[1..*] -> ($op, $value) {
```

`combine` starts with the first value and then takes each operator together
with the value after it: `Z` zips the operators with the values from the
second one on. It works from left to right, so `7 - 2 - 1` is
`(7 - 2) - 1`, which is 4.

`10 / 4` gives `2.5` and not 2, because `/` in Raku gives an exact fraction.

## Questions

1. Which methods of `Evaluate` run for `10 / 4`, and in what order?
2. What does the program print for `7 - (2 - 1)`?
3. In `(1 + 2) * (3 + 4)`, how many times does the method `expression`
   run?

<details>
<summary>Answers</summary>

1. `factor` for 10, `factor` for 4, then `term`, `expression` and `TOP`.
2. `7 - (2 - 1) = 6`. The parentheses make `2 - 1` a factor of its own,
   which is finished before the subtraction from 7.
3. Three times: once for `1 + 2`, once for `3 + 4`, and once for the whole
   string.

</details>

## Try this

Add `%`, the remainder of a division. You need to change one token and add
one line to `combine`. Then try `17 % 5 * 2`: is it 4 or 7?
