---
title: Totals per city
strand: accent
level: B1
from: [python, perl, c]
tags: [hashes, strings, numbers]
summary: Adding up sales per city from a small table, written with a Python, a Perl and a C accent, and as a native would write it.
---

## The task

A shop has a small table of sales: one sale per line, with the city and
the amount. Add up the amounts for each city and print the totals, with
the cities in alphabetical order and two digits after the decimal point.

Every program below starts with the same table:

```raku norun
my $sales = q:to/END/;
Riga 12.50
Leiden 4.75
Turin 10.00
Riga 7.25
Leiden 3.10
Turin 2.35
Riga 0.40
END
```

`q:to/END/` is a heredoc: everything up to the line `END` becomes one
string, with a line break after each line. The answer is:

```output
Leiden 7.85
Riga 20.15
Turin 12.35
```

## With a Python accent

```raku
my $sales = q:to/END/;
Riga 12.50
Leiden 4.75
Turin 10.00
Riga 7.25
Leiden 3.10
Turin 2.35
Riga 0.40
END

my %totals;
for $sales.split("\n") -> $line {
    if $line.trim eq '' {
        next;
    }
    my @parts = $line.split(' ');
    my $city = @parts[0];
    my $amount = @parts[1].Num;
    %totals{$city} = (%totals{$city} // 0) + $amount;
}

for %totals.keys.sort -> $city {
    say("$city {sprintf('%.2f', %totals{$city})}");
}
```

What gives it away:

- `.split("\n")` and then skipping the empty line. In Python,
  `text.split("\n")` leaves an empty string after the last line break, so
  you learn to check for it. Raku's `.lines` does not give you that empty
  line.
- `.Num`, which is Python's `float()`. It works, but it turns the exact
  amount `12.50` into an approximate floating-point number.
- `(%totals{$city} // 0) + $amount`, which is Python's
  `totals.get(city, 0) + amount`. Raku starts a missing value from zero by
  itself when you use `+=`.
- `sprintf` inside a string to format the number, the way an f-string
  does it, and parentheses around the argument of `say`.

## With a Perl accent

```raku
my $sales = q:to/END/;
Riga 12.50
Leiden 4.75
Turin 10.00
Riga 7.25
Leiden 3.10
Turin 2.35
Riga 0.40
END

my %total;
for split /\n/, $sales {
    next unless /\S/;
    my ($city, $amount) = split /\s+/, $_;
    %total{$city} += $amount;
}

for sort keys %total {
    printf "%s %.2f\n", $_, %total{$_};
}
```

What gives it away:

- `split` with a regex, called as a function, both for the lines and for
  the fields.
- `next unless /\S/`: a regex that silently matches against `$_` to skip
  empty lines.
- `sort keys %total` read from right to left, as a chain of functions.
- `printf` with `\n` at the end.

This is short and correct Raku. A Perl programmer reads it without
effort. What is foreign is the shape: every step is a function wrapped
around the next one, instead of methods following each other.

## With a C accent

```raku
my $sales = q:to/END/;
Riga 12.50
Leiden 4.75
Turin 10.00
Riga 7.25
Leiden 3.10
Turin 2.35
Riga 0.40
END

my @lines = $sales.lines;
my @cities;
my @sums;

loop (my $i = 0; $i < @lines.elems; $i++) {
    my $space = @lines[$i].index(' ');
    my $city = @lines[$i].substr(0, $space);
    my $amount = @lines[$i].substr($space + 1).Numeric;

    my $j = 0;
    while $j < @cities.elems && @cities[$j] ne $city {
        $j++;
    }
    if $j == @cities.elems {
        @cities.push($city);
        @sums.push(0);
    }
    @sums[$j] += $amount;
}

loop (my $x = 0; $x < @cities.elems - 1; $x++) {
    loop (my $y = 0; $y < @cities.elems - 1 - $x; $y++) {
        if @cities[$y] gt @cities[$y + 1] {
            my $city = @cities[$y];
            @cities[$y] = @cities[$y + 1];
            @cities[$y + 1] = $city;
            my $sum = @sums[$y];
            @sums[$y] = @sums[$y + 1];
            @sums[$y + 1] = $sum;
        }
    }
}

loop (my $k = 0; $k < @cities.elems; $k++) {
    printf("%s %.2f\n", @cities[$k], @sums[$k]);
}
```

What gives it away:

- Finding the space with `.index` and cutting the line with `.substr`, the
  way you would with `strchr` and pointer arithmetic.
- Two arrays side by side instead of a hash, and a `while` loop to search
  for the city.
- A bubble sort written by hand, which has to swap both arrays in step.
- `loop` with a counter for every pass through a list.

## Native

```raku
my $sales = q:to/END/;
Riga 12.50
Leiden 4.75
Turin 10.00
Riga 7.25
Leiden 3.10
Turin 2.35
Riga 0.40
END

my %totals;
for $sales.lines.map(*.words) -> ($city, $amount) {
    %totals{$city} += $amount;
}

for %totals.sort {
    say .key, ' ', .value.fmt('%.2f');
}
```

## What changed

- `.lines` gives the lines without the empty one at the end, and `.words`
  cuts each line into its two fields.
- `-> ($city, $amount)` unpacks the two fields straight into two
  variables.
- `+=` on a missing key starts from zero, and turns the string `'12.50'`
  into a number on the way.
- The amounts stay exact. `12.50` becomes the fraction 25/2 (a `Rat`), not a
  floating-point number, so adding money gives exactly the right total.
- `%totals.sort` sorts the pairs of the hash by key. `.key` and `.value`
  are called on each pair, and `.fmt` formats the number.
