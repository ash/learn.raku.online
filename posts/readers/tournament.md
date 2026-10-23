---
title: The school tournament
strand: reader
level: B2
tags: [lists, metaoperators, junctions, signatures]
words: [.combinations, "X=>", Z, "<=>", More, .fmt, "[+]", "»", all]
summary: Four school teams play each other once. Six results become a league table in twenty lines, with `X`, `Z`, `[+]`, `»` and a junction.
---

Four teams from a school play a small football tournament: every team plays
every other team once. A win gives three points, a draw one. The program
takes the six results and prints the table.

## Before you run it

Two teams finish with the same number of points. In which order does the
program print them? And how many goals were scored in the whole
tournament?

## The text

```raku
my @teams = <Eagles Herons Owls Swans>;
my @games = @teams.combinations(2);    # every pair plays once
my @goals = (2, 1), (0, 0), (3, 1), (1, 2), (2, 2), (0, 1);

my %points = @teams X=> 0;

for @games Z @goals -> (($home, $away), ($home-goals, $away-goals)) {
    given $home-goals <=> $away-goals {
        when More { %points{$home} += 3 }
        when Less { %points{$away} += 3 }
        default   { %points{$home} += 1; %points{$away} += 1 }
    }
}

for %points.sort({ -.value, .key }) {
    say .fmt('%-8s %d');
}

say "Goals: {[+] @goals».sum}";
say 'Every team has a point.' if all(%points.values) > 0;
```

```output hidden
Eagles   7
Owls     4
Swans    4
Herons   1
Goals: 15
Every team has a point.
```

## Words

- `.combinations` — all the ways to choose elements from a list.
  `.combinations(2)` gives every pair, each pair once.
- `X=>` — the cross operator `X` combined with `=>`: it makes a pair of
  every element on the left with every element on the right.
- `Z` — the zip operator: takes the first element of each list, then the
  second of each, and so on.
- `<=>` — compares two numbers and gives `Less`, `Same` or `More`.
- `More` — one of the three values of the type `Order`, together with
  `Less` and `Same`.
- `.fmt` — formats a value with a pattern, like `sprintf`. On a pair, the
  pattern gets the key and the value.
- `[+]` — the reduction operator: puts `+` between all elements of a list.
- `»` — the hyper operator: calls the method that follows on every element
  of the list.
- `all` — makes a junction: a value that stands for all the elements at
  once. A comparison with it is true only if it is true for each of them.

## Reading notes

```raku norun
my @teams = <Eagles Herons Owls Swans>;
my @games = @teams.combinations(2);    # every pair plays once
my @goals = (2, 1), (0, 0), (3, 1), (1, 2), (2, 2), (0, 1);
```

`@games` gets six pairs, in this order: Eagles–Herons, Eagles–Owls,
Eagles–Swans, Herons–Owls, Herons–Swans, Owls–Swans. `@goals` holds the
results in the same order: the Eagles beat the Herons 2:1, and so on. The
first team of each pair is the home team.

```raku norun
my %points = @teams X=> 0;
```

`X=>` pairs every team with every element on the right. There is only one
element there, `0`, so you get `Eagles => 0, Herons => 0, Owls => 0,
Swans => 0`, and every team starts in the table with zero points, even if
it never wins.

```raku norun
for @games Z @goals -> (($home, $away), ($home-goals, $away-goals)) {
```

`Z` walks along both lists together. Each step gives a list of two
elements, a game and its result: `((Eagles Herons) (2 1))` the first time.
The signature of the block takes that list apart in one go. The outer
parentheses take the two elements, and the inner ones take each element
apart again, into four variables.

```raku norun
    given $home-goals <=> $away-goals {
        when More { %points{$home} += 3 }
        when Less { %points{$away} += 3 }
        default   { %points{$home} += 1; %points{$away} += 1 }
    }
```

`<=>` turns the score into one of three answers. `More` means the home team
scored more and wins three points; `Less` means the away team wins. The
only other answer is `Same`, a draw, and `default` gives both teams a point.

```raku norun
for %points.sort({ -.value, .key }) {
    say .fmt('%-8s %d');
}
```

The table is sorted by two things. The block returns a list for each team:
minus the points, so that more points come first, and then the name. When
the points are equal, as for the Owls and the Swans, the names decide.
`%-8s` writes the name in eight characters, so the points line up.

```raku norun
say "Goals: {[+] @goals».sum}";
say 'Every team has a point.' if all(%points.values) > 0;
```

`@goals».sum` adds up each result on its own and gives `(3 0 4 3 4 1)`.
`[+]` adds those six numbers. The last line asks whether all the points
are greater than zero. They are, because even the Herons drew once.

## Questions

1. How many points do the Swans get, and from which games?
2. What would `say @teams.combinations(2).elems;` print for six teams?
3. What would the table look like if the last result were `(1, 0)`
   instead of `(0, 1)`?

<details>
<summary>Answers</summary>

1. Four: a 2:2 draw with the Herons, and a 1:0 win as the away team against
   the Owls.
2. `15`. Each of the six teams meets the five others, and each game is
   counted once: 6 × 5 / 2.
3. Eagles 7, Owls 7, Herons 1, Swans 1. The Owls win that game instead of
   the Swans. The Eagles stay above the Owls, and the Herons above the
   Swans, because of the alphabet.

</details>

## Try this

Give three points for a win and nothing for a draw. Which line of the
output disappears then?
