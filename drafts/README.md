# Drafts

Posts that are written but can't be published yet. The checker skips this
folder unless you name it: `raku tools/check.raku drafts`.

- `false-friends/ternary.md` — `a ? b : c` does not compile in Raku.
  Rakudo rejects it with "Unsupported use of ? and : for the ternary
  conditional operator". Raku++ (5.4.1-192) runs
  `my $s = $n > 2 ? "many" : "few"` instead, with a "Useless use of
  constant string" warning, so the example doesn't do what the post says
  when it runs in the page. Move it to `posts/false-friends/` once Raku++
  gives the same compile error.
