---
title: map, grep, first, classify
strand: family
level: B1
tags: [lists, functional]
words: [map, grep, first, classify]
summary: Four methods that walk through a list and do something with each element, and how to tell which one you need.
---

All four members of this family go through a list one element at a time
and run a piece of code for each element. They differ in what they do with
the answer that code gives.

## The family

### `map` — changes every element

`map` gives you a new list with one result for each element. The code
inside tells it how to turn an element into its result.

```raku
my @prices = 3.50, 12, 0.99, 7.25, 20;
say @prices.map(* * 2);
say @prices.map({ $_ * 2 });
```

```output
(7 24 1.98 14.5 40)
(7 24 1.98 14.5 40)
```

The two lines do the same. `* * 2` is a short way to write a block with
one argument: the first `*` stands for the element, the second one is the
multiplication.

The original array does not change. `map` makes a new list.

### `grep` — keeps some elements

`grep` asks a yes-or-no question about each element and keeps the elements
for which the answer is yes. The elements themselves do not change.

```raku
my @prices = 3.50, 12, 0.99, 7.25, 20;
say @prices.grep(* > 5);
```

```output
(12 7.25 20)
```

Instead of a block, you can give `grep` a regex or a value. It keeps every
element that matches it.

```raku
my @cities = 'Riga', 'Rome', 'Oslo', 'Rotterdam', 'Bern', 'Ottawa';
say @cities.grep(/o/);
say @cities.grep('Oslo');
```

```output
(Rome Oslo Rotterdam)
(Oslo)
```

### `first` — finds one element

`first` asks the same kind of question as `grep`, but it stops at the
first element that answers yes and gives you that element, not a list.

```raku
my @prices = 3.50, 12, 0.99, 7.25, 20;
say @prices.first(* > 5);
say @prices.first(* > 5, :k);
say @prices.first(* > 100);
```

```output
12
1
Nil
```

With `:k`, you get the position of the element instead of the element.
When nothing matches, `first` gives you `Nil`.

### `classify` — sorts elements into groups

`classify` runs the code for each element and uses the answer as the name
of a group. The result is a hash: one key per group, and an array of the
elements in that group.

```raku
my @cities = 'Riga', 'Rome', 'Oslo', 'Rotterdam', 'Bern', 'Ottawa';
my %by-letter = @cities.classify(*.substr(0, 1));
for %by-letter.keys.sort -> $letter {
    say "$letter: %by-letter{$letter}";
}
```

```output
B: Bern
O: Oslo Ottawa
R: Riga Rome Rotterdam
```

The keys are sorted before printing, because a hash does not keep its keys
in any particular order.

## Side by side

| Method | The code answers | You get |
|---|---|---|
| `map` | what to put instead of the element | a list of the same length |
| `grep` | yes or no | a shorter list of the original elements |
| `first` | yes or no | one element, or `Nil` |
| `classify` | the name of a group | a hash of groups |

A quick test: if the code returns a new value, you want `map`. If it
returns `True` or `False`, you want `grep` or `first`, depending on
whether you need all the matches or one. If it returns a label, you want
`classify`.

## Which one?

Which method would you use for each task?

1. Get the length of every city name in a list.
2. Find the first city in a list whose name is longer than five letters.
3. Split a list of words into groups by their number of letters.
4. Keep only the prices under 10.

<details>
<summary>Answers</summary>

1. `map`: `@cities.map(*.chars)` gives `(4 4 4 9 4 6)` for the cities
   above.
2. `first`: `@cities.first(*.chars > 5)` gives `Rotterdam`.
3. `classify`: `@words.classify(*.chars)`.
4. `grep`: `@prices.grep(* < 10)`.

</details>
