---
title: say, put, print, note
strand: family
level: A2
tags: [output, strings]
words: [say, put, print, note]
summary: Four ways to print something, and why `say` shows an array with brackets while `put` does not.
---

All four members of this family print things. They differ in two ways:
whether they add a line break at the end, and whether they show a value the
way a person wants to read it or the way it is as a string.

## The family

### `say` — prints for a person to read

`say` prints a value and a line break. Before printing, it asks the value
for its **gist**: a short description meant for a person. For an array,
that includes the brackets.

```raku
my @birds = 'robin', 'wren', 'owl';
say @birds;
say 1/3;
```

```output
[robin wren owl]
0.333333
```

The gist of a very long list stops after 100 elements and adds `...`:

```raku
say (1..150).list;
```

```output
(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 ...)
```

An empty variable also has a gist, so `say` shows you what kind of empty
it is:

```raku
my $price;
say $price;
```

```output
(Any)
```

### `put` — prints the string

`put` also prints a line break at the end, but it prints the value as a
string, not its gist. An array becomes its elements with spaces between
them, and nothing is shortened.

```raku
my @birds = 'robin', 'wren', 'owl';
put @birds;
put 1/3;
```

```output
robin wren owl
0.333333
```

Use `put` when the output is data for another program or a file, and `say`
when it is for you to look at.

### `print` — prints the string, no line break

`print` is `put` without the line break. You add `"\n"` yourself where you
want one.

```raku
my @birds = 'robin', 'wren', 'owl';
print @birds;
print "\n";
print 'Birds seen: ', @birds.elems, "\n";
```

```output
robin wren owl
Birds seen: 3
```

### `note` — prints to the error stream

`note` works like `say`, but it writes to the standard error stream instead
of the standard output. In a terminal both appear on the screen. When you
send the output of a program to a file, the notes stay on the screen.

```raku
my $temperature = -3;
note 'Below zero!' if $temperature < 0;
say "Temperature: $temperature";
```

```output
Temperature: -3
```

The output above is only the standard output. On the error stream, the
program wrote `Below zero!`. When you press Run on this page, both streams
go to the same pane, so you see `Below zero!` there too, above the
temperature.

## Side by side

| Function | Line break | Shows | Writes to |
|---|---|---|---|
| `say` | yes | the gist: `[robin wren owl]` | standard output |
| `put` | yes | the string: `robin wren owl` | standard output |
| `print` | no | the string: `robin wren owl` | standard output |
| `note` | yes | the gist | standard error |

With an empty variable, `put` and `print` have no string to print. They
print an empty string and a warning to the error stream. `say` prints
`(Any)`:

```raku
my $price;
say $price;
put $price;
say 'end';
```

```output
(Any)

end
```

If you run it here, the warning appears in the output pane, between
`(Any)` and the empty line. It begins with
`Use of uninitialized value of type Any in string context`.

## Which one?

Which function would you use for each task?

1. While debugging, see what is in the array `@prices`, brackets and all.
2. Write the words of a list, separated by spaces, into a file that another
   program reads.
3. Print `Loading...` and stay on the same line, so the next thing printed
   continues it.
4. Tell the user that a setting is missing, without mixing the message into
   the program's real output.

<details>
<summary>Answers</summary>

1. `say @prices`, because the gist shows the brackets and so you see that
   it is an array.
2. `put`. It prints the string with no brackets, and never shortens a long
   list.
3. `print 'Loading...'`, because it adds no line break.
4. `note`. It goes to the error stream, so the real output stays clean.

</details>
