---
title: The departure board
strand: reader
level: B1
tags: [classes, sorting, lists]
words: [class, has, "$.number", method, Train.new, "*.departs", .grep, .first, gt]
summary: Five trains, one small class, and three questions to the timetable — all trains in order, the trains to Rotterdam, and the first one after nine.
---

A station has five trains this morning. The program describes a train as a
class, puts five trains in a list, and asks that list three questions.

## Before you run it

The trains are written in the program in no particular order. Which train
does the last line name? Read the condition on that line carefully.

## The text

```raku
class Train {
    has $.number;
    has $.to;
    has $.departs;
    has $.platform;

    method board {
        "$.departs  $.to (train $.number), platform $.platform";
    }
}

my @trains =
    Train.new(number => 3014, to => 'Utrecht',   departs => '09:12', platform => 5),
    Train.new(number => 1745, to => 'Rotterdam', departs => '08:47', platform => 2),
    Train.new(number => 3020, to => 'Utrecht',   departs => '09:42', platform => 5),
    Train.new(number => 2241, to => 'Haarlem',   departs => '09:05', platform => 8),
    Train.new(number => 1749, to => 'Rotterdam', departs => '09:17', platform => 2);

say 'All departures:';
for @trains.sort(*.departs) -> $train {
    say $train.board;
}

say '';
say 'To Rotterdam:';
for @trains.grep(*.to eq 'Rotterdam') -> $train {
    say $train.board;
}

say '';
my $next = @trains.sort(*.departs).first(*.departs gt '09:00');
say "First train after nine: {$next.number} to {$next.to}";
```

```output hidden
All departures:
08:47  Rotterdam (train 1745), platform 2
09:05  Haarlem (train 2241), platform 8
09:12  Utrecht (train 3014), platform 5
09:17  Rotterdam (train 1749), platform 2
09:42  Utrecht (train 3020), platform 5

To Rotterdam:
08:47  Rotterdam (train 1745), platform 2
09:17  Rotterdam (train 1749), platform 2

First train after nine: 2241 to Haarlem
```

## Words

- `class` — describes a kind of object: what it knows and what it can do.
- `has` — declares an attribute, a piece of data that every object of the
  class carries.
- `$.number` — an attribute with a dot: Raku also makes a method with the
  same name, so other code can ask a train for its number.
- `method` — a sub that belongs to a class and works on one object.
- `Train.new` — makes a new object. You give the attributes as named
  arguments: `number => 3014`.
- `*.departs` — the whatever star. `*.departs` is a short way to write a
  small piece of code: "take a thing and give me its `.departs`".
- `.grep` — keeps the elements of a list for which a condition is true.
- `.first` — gives the first element for which a condition is true.
- `gt` — "greater than" for strings: compares them in alphabetical order.

## Reading notes

```raku norun
class Train {
    has $.number;
    has $.to;
    has $.departs;
    has $.platform;
```

Every train knows four things: its number, where it goes, when it leaves,
and from which platform. The times are strings, like `'09:12'`.

```raku norun
    method board {
        "$.departs  $.to (train $.number), platform $.platform";
    }
}
```

The method makes the line that the departure board shows. Inside double
quotes, `$.departs` and the other attributes are replaced by their values.
There is no `return`: a method gives back the value of its last statement.

```raku norun
my @trains =
    Train.new(number => 3014, to => 'Utrecht',   departs => '09:12', platform => 5),
    ...
```

Five calls of `Train.new`, separated by commas, make a list of five trains.

```raku norun
for @trains.sort(*.departs) -> $train {
    say $train.board;
}
```

`.sort(*.departs)` sorts the trains by their departure time. The array
itself does not change: `.sort` gives you a new, sorted list. Times written
as `'08:47'` and `'09:12'` sort correctly as strings, because they always
have two digits for the hour and two for the minutes.

```raku norun
for @trains.grep(*.to eq 'Rotterdam') -> $train {
    say $train.board;
}
```

`.grep` keeps the trains whose destination is Rotterdam. It does not sort:
the two trains come out in the order of the array, which happens to be the
order of their times.

```raku norun
my $next = @trains.sort(*.departs).first(*.departs gt '09:00');
say "First train after nine: {$next.number} to {$next.to}";
```

The last question chains two methods: sort the trains by time, then take
the first one that leaves after `'09:00'`. That is train 2241 to Haarlem,
at 09:05. Without the `.sort`, `.first` would find train 3014, because it
is first in the array and leaves at 09:12.

## Questions

1. What does `$next.platform` give?
2. What would the program print under "To Rotterdam:" if the condition were
   `*.platform == 5`?
3. Why does the method `board` not need `return`?

<details>
<summary>Answers</summary>

1. `8`, the platform of train 2241.
2. The two trains to Utrecht, 3014 and then 3020, both from platform 5.
3. A method or sub gives back the value of the last statement it runs. The
   string is the last, and only, statement in `board`.

</details>

## Try this

Ask the timetable a fourth question: print the numbers of all trains that
leave from platform 2, sorted by time. One line of code is enough, for
example with `.grep`, `.sort` and `.map(*.number)`.
