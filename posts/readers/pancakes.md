---
title: Pancakes for six
strand: reader
level: B1
tags: [numbers, fractions, subs, named-arguments]
words: ["1/3", ":$from = 4", "to => 6", "%pancakes<sugar>", .nude]
summary: A recipe for four people, scaled for six and for five. A third of a cup of sugar shows how Raku keeps fractions exact.
---

The recipe is for four people. Six are coming, or maybe only five. The
program works out how much of everything you need.

## Before you run it

The recipe needs a third of a cup of sugar. How will the program print the
amount of sugar for five people? And what does the very last line print?

## The text

```raku
# Pancakes for four people. Six are coming, or maybe five.
my %pancakes =
    flour => 250,    # grams
    milk  => 500,    # millilitres
    eggs  => 3,
    sugar => 1/3;    # cups

sub scale($amount, :$from = 4, :$to = 4) {
    return $amount * $to / $from;
}

for %pancakes.keys.sort -> $item {
    my $six  = scale(%pancakes{$item}, to => 6);
    my $five = scale(%pancakes{$item}, to => 5);
    say "$item: $six for six, $five for five";
}

my $sugar = scale(%pancakes<sugar>, to => 5);
say "Sugar for five: {$sugar.nude.join('/')} cup";

my $back = scale($sugar, from => 5);
say "Back to four: {$back.nude.join('/')} cup";
say $back == %pancakes<sugar>;
```

```output hidden
eggs: 4.5 for six, 3.75 for five
flour: 375 for six, 312.5 for five
milk: 750 for six, 625 for five
sugar: 0.5 for six, 0.416667 for five
Sugar for five: 5/12 cup
Back to four: 1/3 cup
True
```

## Words

- `1/3` — a fraction. Raku keeps it as one third, a `Rat`, not as
  0.3333… with a limited number of digits.
- `:$from = 4` — a named parameter with a default value. If the caller
  does not say `from => …`, `$from` is 4.
- `to => 6` — passes a named argument. Named arguments can come in any
  order, and you can leave out the ones that have defaults.
- `%pancakes<sugar>` — the value for the key `sugar`. `< >` is a short way
  to write `%pancakes{'sugar'}` when the key is a plain word.
- `.nude` — gives the numerator and the denominator of a fraction, as a
  list of two numbers: `(5 12)` for 5/12.

## Reading notes

```raku norun
my %pancakes =
    flour => 250,    # grams
    milk  => 500,    # millilitres
    eggs  => 3,
    sugar => 1/3;    # cups
```

The recipe is a hash. The comments give the units, so the numbers stay
plain numbers that the program can calculate with.

```raku norun
sub scale($amount, :$from = 4, :$to = 4) {
    return $amount * $to / $from;
}
```

`scale` has one positional parameter, the amount, and two named ones. Both
named parameters are 4 by default, because the recipe is for four. A call
only has to say what is different: `to => 6` for six people,
`from => 5` to go back from five.

```raku norun
for %pancakes.keys.sort -> $item {
    my $six  = scale(%pancakes{$item}, to => 6);
    my $five = scale(%pancakes{$item}, to => 5);
    say "$item: $six for six, $five for five";
}
```

When you divide whole numbers with `/` in Raku, the result is a fraction,
not a rounded number. `250 * 6 / 4` is exactly 375, and `3 * 6 / 4` is
exactly 4.5. Raku prints whole results without a decimal point.

The sugar for five is 1/3 × 5/4 = 5/12. When Raku prints a fraction like
this as a decimal number, it rounds it to six digits after the point, so
you see `0.416667`. That is only how it is printed. The value in `$five`
is still exactly five twelfths.

```raku norun
my $sugar = scale(%pancakes<sugar>, to => 5);
say "Sugar for five: {$sugar.nude.join('/')} cup";
```

Cooks measure in fractions of a cup, so the program prints the fraction:
`.nude` gives `(5 12)`, and `.join('/')` makes `5/12` of it.

```raku norun
my $back = scale($sugar, from => 5);
say "Back to four: {$back.nude.join('/')} cup";
say $back == %pancakes<sugar>;
```

Scaling 5/12 from five people back to four gives 1/3 again. Nothing was
lost on the way, so the comparison with the original amount is `True`.

## Questions

1. Why are the items printed in the order eggs, flour, milk, sugar?
2. What does `scale(500, to => 2)` return?
3. What does `scale(3, from => 2, to => 3)` return, and what does it mean
   in the kitchen?

<details>
<summary>Answers</summary>

1. Because the loop goes over `%pancakes.keys.sort`, which is alphabetical.
2. `250`: half of the milk, for two people.
3. `4.5`. If a recipe for two people needs 3 eggs, a recipe for three
   needs four and a half.

</details>

## Try this

Print the sugar for six as a fraction too. What does `.nude` give for a
whole number, like the flour for six?
