---
title: Is it a palindrome?
strand: reader
level: A1
tags: [strings, loops, conditions]
words: ["#", "<Anna Level Riga Kayak Tallinn Rotor>", .lc, eq, .flip, "~"]
summary: Six words, read forwards and backwards. Guess which of them are palindromes before you run the program.
---

A palindrome is a word that reads the same from both ends, like *level*.
This program takes six words and checks each of them.

## Before you run it

Which of the six words are palindromes? Be careful with the first one: it
starts with a capital letter.

## The text

```raku
# Some words read the same from both ends.
my $count = 0;

for <Anna Level Riga Kayak Tallinn Rotor> {
    my $word = $_.lc;
    if $word eq $word.flip {
        say "$_ is a palindrome.";
        $count = $count + 1;
    }
    else {
        say "$_ is not. Backwards, it is " ~ $word.flip ~ '.';
    }
}

say "Palindromes found: $count";
```

```output hidden
Anna is a palindrome.
Level is a palindrome.
Riga is not. Backwards, it is agir.
Kayak is a palindrome.
Tallinn is not. Backwards, it is nnillat.
Rotor is a palindrome.
Palindromes found: 4
```

## Words

- `#` — starts a comment. Raku ignores everything from `#` to the end of
  the line. Comments are for people.
- `<Anna Level Riga Kayak Tallinn Rotor>` — a list of words. Inside `< >`,
  every word separated by spaces becomes a string, so you don't need quotes
  and commas.
- `.lc` — gives the string in lower case. It is the opposite of `.uc`.
- `eq` — compares two strings. It is true when they are exactly the same.
- `.flip` — gives the string backwards.
- `~` — joins two strings into one.

## Reading notes

```raku norun
# Some words read the same from both ends.
my $count = 0;
```

The first line is a comment: it tells you what the program is about, and
Raku skips it. The second line creates a counter that starts at zero.

```raku norun
for <Anna Level Riga Kayak Tallinn Rotor> {
    my $word = $_.lc;
```

The loop runs six times, once for each word in the list, and `$_` holds the
current word. The program makes a lower-case copy of it in `$word`. The
word in `$_` itself does not change.

Why lower case? Because `'Anna'.flip` is `annA`, and `Anna` and `annA` are
not the same string. After `.lc`, the program compares `anna` with `anna`.

```raku norun
    if $word eq $word.flip {
        say "$_ is a palindrome.";
        $count = $count + 1;
    }
```

If the word is the same forwards and backwards, the program says so and
adds one to the counter. It prints `$_`, not `$word`, so you see the word
with its capital letter.

```raku norun
    else {
        say "$_ is not. Backwards, it is " ~ $word.flip ~ '.';
    }
```

Otherwise, it prints the word backwards. Three strings are joined with `~`:
the text in double quotes, the flipped word, and a full stop.

Why not put `$word.flip` inside the double quotes? In a string, Raku
replaces `$word` with its value, but it does not call `.flip`. You would
see `riga.flip` instead of `agir`.

```raku norun
say "Palindromes found: $count";
```

After the loop, the program prints the counter.

## Questions

1. How many lines does the program print?
2. What would the program say about `Anna` if the line were
   `my $word = $_;` without `.lc`?
3. What does `say 'Riga'.flip;` print?

<details>
<summary>Answers</summary>

1. Seven: one for each of the six words, and one with the count.
2. `Anna is not. Backwards, it is annA.` Without `.lc`, the capital `A`
   ends up at the end.
3. `agiR`. `.flip` keeps the capital letter; it only moves it.

</details>

## Try this

Add the words `Madam` and `Mississippi` to the list. Before you run the
program, decide what the last line will say.
