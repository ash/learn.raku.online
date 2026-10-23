---
title: Weather in four cities
strand: reader
level: A2
tags: [subs, arrays, hashes, numbers]
words: [sub, "$celsius", return, "@cities", "-> $city", "{fahrenheit($c)}"]
summary: Today's temperature in Riga, Amsterdam, Turin and Belgrade, in Celsius and Fahrenheit, with a word for how it feels.
---

A weather report for four European cities. The temperatures are in
Celsius, and the program also gives them in Fahrenheit, for a friend who
lives in the United States.

## Before you run it

In which order do the cities come out? And how does `59` look in the
output: `59`, `59.0` or `59.00`?

## The text

```raku
sub fahrenheit($celsius) {
    return $celsius * 9 / 5 + 32;
}

sub feels($celsius) {
    if $celsius < 5 {
        return 'cold';
    }
    if $celsius < 12 {
        return 'cool';
    }
    return 'mild';
}

my @cities = 'Riga', 'Amsterdam', 'Turin', 'Belgrade';
my %today = Riga => 4, Amsterdam => 11, Turin => 15, Belgrade => 9;

for @cities -> $city {
    my $c = %today{$city};
    say "$city: $c °C, {fahrenheit($c)} °F, {feels($c)}";
}
```

```output hidden
Riga: 4 °C, 39.2 °F, cold
Amsterdam: 11 °C, 51.8 °F, cool
Turin: 15 °C, 59 °F, mild
Belgrade: 9 °C, 48.2 °F, cool
```

## Words

- `sub` — defines a function: a piece of code with a name that you can
  call again and again.
- `$celsius` — a parameter. When you call `fahrenheit(4)`, the value 4
  arrives in the sub as `$celsius`.
- `return` — ends the sub and gives a value back to the code that called
  it.
- `@cities` — an array: a list of values in a variable. Array names start
  with `@`.
- `-> $city` — gives a name to the current element of the loop.
- `{fahrenheit($c)}` — inside double quotes, `{ }` runs the code, here a
  call of the sub, and puts the result into the string.

## Reading notes

```raku norun
sub fahrenheit($celsius) {
    return $celsius * 9 / 5 + 32;
}
```

The first sub converts a temperature: multiply by 9, divide by 5, add 32.
Defining a sub does not run it. It waits until something calls it.

```raku norun
sub feels($celsius) {
    if $celsius < 5 {
        return 'cold';
    }
    if $celsius < 12 {
        return 'cool';
    }
    return 'mild';
}
```

The second sub gives a word for the temperature. As soon as one `return`
runs, the sub is over, so the checks below it are skipped. This is why the
second `if` does not need to check that the temperature is 5 or more: if it
were below 5, the sub would have returned already.

Both subs call their parameter `$celsius`. These are two different
variables: each sub has its own.

```raku norun
my @cities = 'Riga', 'Amsterdam', 'Turin', 'Belgrade';
my %today = Riga => 4, Amsterdam => 11, Turin => 15, Belgrade => 9;
```

The cities are in an array, and today's temperatures are in a hash, with
the city as the key.

```raku norun
for @cities -> $city {
    my $c = %today{$city};
    say "$city: $c °C, {fahrenheit($c)} °F, {feels($c)}";
}
```

The loop goes over the array, so the cities come out in the order of the
array, not in alphabetical order. For each city, it looks up the
temperature and prints one line with the results of both subs.

`4 * 9 / 5 + 32` is `39.2`. `15 * 9 / 5 + 32` is exactly `59`, and Raku
prints it as `59`, without a decimal point.

## Questions

1. Which sub is called first when the loop prints the line for Riga?
2. What would `feels(12)` return?
3. If the second `if` in `feels` checked `$celsius < 10`, which city's line
   would change?

<details>
<summary>Answers</summary>

1. `fahrenheit`. The code in the string runs from left to right.
2. `mild`. 12 is not less than 5 and not less than 12.
3. Amsterdam's. 11 is not less than 10, so it would be `mild`. Belgrade,
   with 9, would still be `cool`.

</details>

## Try this

Add Tallinn with 2 °C. You need to change two lines. Then add a third word
to `feels`: `freezing` for temperatures below 0.
