---
title: Counting words
strand: accent
level: B1
from: [python, perl, c]
tags: [hashes, sorting, bags]
summary: The three most frequent words in a sentence, written four times — with a Python, a Perl and a C accent, and as a native would write it.
---

## The task

Count how often each word appears in a sentence, and print the three most
frequent words with their counts. When two words appear equally often, the
one that comes first in the alphabet goes first.

For the sentence in the programs below, the answer is:

```output
the 4
cat 2
on 2
```

`sat` also appears twice, but `cat` and `on` come before it in the
alphabet.

## With a Python accent

```raku
my $text = 'the cat sat on the mat and the dog sat on the cat';

my @words = $text.split(' ');
my %counts;
for @words -> $word {
    if %counts{$word}:exists {
        %counts{$word} = %counts{$word} + 1;
    }
    else {
        %counts{$word} = 1;
    }
}

my @pairs = %counts.pairs.sort(-> $a, $b {
    $b.value <=> $a.value || $a.key cmp $b.key
});

for 0..2 -> $i {
    say @pairs[$i].key ~ ' ' ~ @pairs[$i].value;
}
```

What gives it away:

- The `if … :exists … else` around the counter. In Python, adding 1 to a
  missing key is an error, so you check first. In Raku, a missing value
  starts as "nothing", and `+ 1` or `++` turns nothing into 1.
- `.split(' ')` to get the words, where Raku has `.words`.
- `for 0..2 -> $i` and `@pairs[$i]`: walking over indexes to take the
  first three elements.
- Gluing the line together with `~` instead of letting `say` or
  interpolation do it.

## With a Perl accent

```raku
my $text = 'the cat sat on the mat and the dog sat on the cat';

my %count;
%count{$_}++ for split / \s+ /, $text;

for (sort { %count{$^b} <=> %count{$^a} or $^a cmp $^b }, keys %count)[0..2] -> $word {
    printf "%s %d\n", $word, %count{$word};
}
```

What gives it away:

- `split` and `keys` called as functions, with the arguments after them,
  and a regex to split on whitespace.
- A sort block that compares two keys by looking them up in the hash, the
  classic Perl idiom.
- A slice `[0..2]` of the sorted list.
- `printf` with `\n` to print a simple line.

It is close to good Raku, which is why Perl programmers feel at home so
quickly. But it counts by hand, and it looks up every value twice.

## With a C accent

```raku
my $text = 'the cat sat on the mat and the dog sat on the cat';
my @words = $text.split(' ');
my @seen;
my @counts;

loop (my $i = 0; $i < @words.elems; $i++) {
    my $found = -1;
    loop (my $j = 0; $j < @seen.elems; $j++) {
        if @seen[$j] eq @words[$i] {
            $found = $j;
            last;
        }
    }
    if $found == -1 {
        @seen.push(@words[$i]);
        @counts.push(1);
    }
    else {
        @counts[$found]++;
    }
}

loop (my $k = 0; $k < 3; $k++) {
    my $best = 0;
    loop (my $m = 1; $m < @seen.elems; $m++) {
        if @counts[$m] > @counts[$best]
           || (@counts[$m] == @counts[$best] && @seen[$m] lt @seen[$best]) {
            $best = $m;
        }
    }
    say @seen[$best], ' ', @counts[$best];
    @counts[$best] = -1;
}
```

What gives it away:

- No hash. Two parallel arrays, one for the words and one for their counts,
  and a search through the first to find the position in the second.
- `loop (…; …; …)` with an index variable everywhere.
- Selecting the top three by scanning the list three times and marking each
  winner with `-1` so it is not picked again.

It works, and it is how you would do it without a library. Raku has the
library built in.

## Native

```raku
my $text = 'the cat sat on the mat and the dog sat on the cat';

my $counts = $text.words.Bag;
for $counts.sort({ -.value, .key }).head(3) {
    say .key, ' ', .value;
}
```

## What changed

- `.words` cuts the sentence into words.
- `.Bag` does the counting. A `Bag` is a collection that remembers how many
  times each thing was put in it.
- `sort` gets a block that says **what** to sort by: the count from high to
  low (`-.value`), then the word itself (`.key`). It does not say how to
  compare two elements.
- `.head(3)` takes the first three. No indexes.
- Inside the `for` loop, `.key` and `.value` are called on the current
  element, so no variable name is needed.
