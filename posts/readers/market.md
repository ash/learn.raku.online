---
title: At the market
strand: reader
level: A2
tags: [hashes, loops, strings]
words: ["%prices", "=>", .keys, .sort, "-> $item", "%prices{$item}", "{%prices.elems}"]
summary: Five things from the market and what they cost. In what order does the program list them?
---

We came back from the market with five things. The program lists what we
bought, adds up the prices, and checks the budget.

## Before you run it

The program lists the five items with their prices. In what order? Is it
the order in which they are written in the program?

## The text

```raku
# What we bought at the market, with prices in euro.
my %prices =
    bread  => 2.15,
    cheese => 4.75,
    apples => 3.25,
    milk   => 1.15,
    coffee => 6.45;

my $total = 0;
for %prices.keys.sort -> $item {
    say "$item: %prices{$item}";
    $total = $total + %prices{$item};
}

say "Items: {%prices.elems}";
say "Total: $total";
say "Average: {$total / %prices.elems}";

unless $total > 20 {
    say 'We stayed within our budget of 20 euro.';
}
```

```output hidden
apples: 3.25
bread: 2.15
cheese: 4.75
coffee: 6.45
milk: 1.15
Items: 5
Total: 17.75
Average: 3.55
We stayed within our budget of 20 euro.
```

## Words

- `%prices` — a hash: a table that connects keys to values. Hash names
  start with `%`.
- `=>` — makes a pair of a key and a value: `bread => 2.15`. The key on
  the left does not need quotes.
- `.keys` — gives the keys of a hash: here, the names of the items.
- `.sort` — gives the elements of a list in order: numbers from small to
  large, strings in alphabetical order.
- `-> $item` — gives a name to the current element of a `for` loop, instead
  of `$_`.
- `%prices{$item}` — the value for the key `$item`. Inside double quotes,
  Raku replaces it with the value.
- `{%prices.elems}` — inside double quotes, the code in `{ }` runs and its
  result goes into the string. `.elems` counts the elements.

## Reading notes

```raku norun
my %prices =
    bread  => 2.15,
    cheese => 4.75,
    apples => 3.25,
    milk   => 1.15,
    coffee => 6.45;
```

The hash is filled with five pairs. The statement takes six lines, but it
is one statement: it ends with the semicolon after `6.45`. The spaces that
line up the arrows are only there for the eye.

```raku norun
my $total = 0;
for %prices.keys.sort -> $item {
    say "$item: %prices{$item}";
    $total = $total + %prices{$item};
}
```

A hash does not remember the order in which you put things in. If you want
an order, you ask for one: `%prices.keys` gives the five names, and `.sort`
puts them in alphabetical order. That is why `apples` comes first, although
it is third in the program.

For each name, the loop prints the name and the price and adds the price to
`$total`.

```raku norun
say "Items: {%prices.elems}";
say "Total: $total";
say "Average: {$total / %prices.elems}";
```

`$total` can go straight into the string. `%prices.elems` cannot: inside
double quotes, a hash name is only replaced when it is followed by `{ }`
with a key. So the program puts the code in `{ }`, and Raku runs it. The
same goes for the division on the last line.

The average is exactly `3.55`. Raku keeps numbers like `2.15` exact, as
fractions, so sums and averages of prices have no rounding errors in them.

```raku norun
unless $total > 20 {
    say 'We stayed within our budget of 20 euro.';
}
```

`unless` is the opposite of `if`: the block runs when the condition is
false. The total is 17.75, which is not more than 20, so the line is
printed.

## Questions

1. Which item is printed last, and why?
2. What would `say "Items: %prices.elems";` print, without the `{ }`?
3. What would change in the output if cheese cost 7.25?

<details>
<summary>Answers</summary>

1. `milk`, because it is last in alphabetical order.
2. `Items: %prices.elems`. Without a key in `{ }` after it, `%prices` is
   not replaced inside a string.
3. The cheese line, the total (20.25) and the average (4.05) would change,
   and the last line would not be printed, because 20.25 is more than 20.

</details>

## Try this

Print the items from the most expensive to the cheapest. Hint: `.sort` can
take a block that says what to sort by, for example
`.sort({ %prices{$_} })`, and `.reverse` turns a list around.
