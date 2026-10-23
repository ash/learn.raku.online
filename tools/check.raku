#!/usr/bin/env raku

# Checks every post: the front matter, the headings of its strand, and every
# code example. Raku blocks run under Raku++ and Rakudo; Python, Perl and
# JavaScript blocks run under python3, perl and node. The output of each run
# is compared with the `output` block that follows it in the post.
#
#     raku tools/check.raku                 # every post
#     raku tools/check.raku posts/readers   # one strand
#     raku tools/check.raku posts/accents/word-count.md
#
# The rules are described in STYLE.md.

use lib $?FILE.IO.parent.add('lib').Str;
use Posts;

my constant %STRAND-DIR = readers => 'reader', false-friends => 'false-friend',
                          families => 'family', accents => 'accent';
my constant @LEVELS = <A1 A2 B1 B2 C1 C2>;
my constant @FROM   = <python perl js c>;

my constant %HEADINGS =
    reader         => ('Before you run it', 'The text', 'Words', 'Reading notes', 'Questions', 'Try this'),
    'false-friend' => ('In Raku', 'Why', 'Say it in Raku'),
    family         => ('The family', 'Side by side', 'Which one?'),
    accent         => ('The task', 'With a Python accent', 'With a Perl accent',
                       'With a C accent', 'Native', 'What changed');

my constant %ENGINES =
    raku   => <rakupp rakudo>,
    python => <python3>,
    perl   => <perl>,
    js     => <node>;

# RAKUPP=... and RAKUDO=... choose other builds of the two engines.
my %COMMAND = rakupp => %*ENV<RAKUPP> // 'rakupp', rakudo => %*ENV<RAKUDO> // 'rakudo';

my %EXT = raku => 'raku', python => 'py', perl => 'pl', js => 'js';

my $TIMEOUT = 20;
my $tmp = $*TMPDIR.add("rfl-check-$*PID");

sub MAIN(*@paths, Int :$repeat = 2) {
    @paths = 'posts' unless @paths;
    my @files = @paths.map({ .IO.d ?? markdown-files(.IO) !! .IO }).flat;

    mkdir $tmp;
    my $failed = 0;
    my $blocks = 0;
    for @files -> $file {
        my ($n, @problems) = check-post($file, $repeat);
        $blocks += $n;
        if @problems {
            $failed++;
            say "FAIL $file";
            say "  $_" for @problems;
        }
        else {
            say "ok   $file ($n runs)";
        }
    }
    $tmp.dir».unlink;
    $tmp.rmdir;

    say '';
    say "{+@files} posts, $blocks runs, $failed failed";
    exit($failed ?? 1 !! 0);
}

sub check-post(IO::Path $file, Int $repeat) {
    my @problems;
    my ($fm, $body) = front-matter($file.slurp);
    @problems.append: check-front-matter($fm, $file);
    @problems.append: check-headings($fm<strand> // '', $body);

    my @blocks = code-blocks($body, $fm<body-line>);
    my $default-output;
    $default-output = @blocks.first(*<lang> eq 'output')<code>
        if ($fm<strand> // '') eq 'accent';

    if ($fm<strand> // '') eq 'reader' && !@blocks.first({ .<lang> eq 'output' && 'hidden' (elem) .<flags> }) {
        @problems.push: 'a reader needs an `output hidden` block for its text';
    }

    my @raku-code = @blocks.grep(*<lang> eq 'raku')».<code>;
    for @($fm<words> // []) -> $word {
        @problems.push: "word `$word` is not in any raku block"
            unless @raku-code.first(*.contains($word));
    }

    my $runs = 0;
    for @blocks.kv -> $i, %block {
        next if %block<lang> eq 'output';
        next if 'norun' (elem) %block<flags>;
        unless %ENGINES{%block<lang>}:exists {
            @problems.push: "line %block<line>: unknown language `%block<lang>`";
            next;
        }

        my $next = @blocks[$i + 1];
        my $expected = $next && $next<lang> eq 'output' && $next<adjacent> ?? $next<code> !! Str;
        $expected //= $default-output if %block<lang> eq 'raku';
        my $wants-error = 'error' (elem) %block<flags>;
        if $wants-error && !$expected.defined {
            @problems.push: "line %block<line>: a `raku error` block needs an output block with the message";
            next;
        }

        my %seen;
        for @(%ENGINES{%block<lang>}) -> $engine {
            my $times = $engine eq 'rakudo' ?? $repeat !! 1;
            for ^$times {
                my %r = execute($engine, %block<lang>, %block<code>);
                $runs++;
                @problems.append: compare(%block, $engine, %r, $expected, $wants-error);
                %seen{$engine}.push: normalize(%r<out>);
            }
        }
        if %seen<rakudo> && %seen<rakudo>.unique > 1 {
            @problems.push: "line %block<line>: Rakudo prints different output on different runs (hash order?)";
        }
        if %seen<rakupp> && %seen<rakudo> && !$wants-error && %seen<rakupp>[0] ne %seen<rakudo>[0] {
            @problems.push: "line %block<line>: Raku++ and Rakudo print different output";
        }
    }

    ($runs, |@problems.unique)
}

sub check-front-matter(%fm, IO::Path $file) {
    my @problems;
    for <title strand level summary tags> -> $key {
        @problems.push: "front matter: `$key` is missing" unless %fm{$key};
    }
    my $strand = %fm<strand> // '';
    my $dir-strand = %STRAND-DIR{$file.parent.basename};
    @problems.push: "front matter: strand `$strand` does not match the folder"
        if $dir-strand && $strand ne $dir-strand;
    @problems.push: "front matter: unknown level `%fm<level>`"
        if %fm<level> && %fm<level> !(elem) @LEVELS;
    if $strand eq 'false-friend' | 'accent' {
        @problems.push: 'front matter: `from` is missing' unless %fm<from>;
    }
    for @(%fm<from> // []) -> $from {
        @problems.push: "front matter: unknown `from` value `$from`" if $from !(elem) @FROM;
    }
    if $strand eq 'reader' | 'family' {
        @problems.push: 'front matter: `words` is missing' unless %fm<words>;
    }
    @problems
}

sub check-headings(Str $strand, Str $body) {
    my @wanted = @(%HEADINGS{$strand} // ());
    my @found = $body.lines.grep(*.starts-with('## ')).map(*.substr(3).trim);
    my @problems;

    my $pos = 0;
    for @wanted -> $heading {
        my $at = @found.first($heading, :k);
        if !$at.defined {
            @problems.push: "heading `## $heading` is missing";
        }
        elsif $at < $pos {
            @problems.push: "heading `## $heading` is out of order";
        }
        else {
            $pos = $at;
        }
    }
    if $strand eq 'false-friend' && !@found.first({ / ^ 'In ' / && $_ ne 'In Raku' }) {
        @problems.push: 'a false friend needs an `## In <language>` section before `## In Raku`';
    }
    @problems
}

sub execute(Str $engine, Str $lang, Str $code) {
    state $count = 0;
    my $file = $tmp.add("block-{++$count}.%EXT{$lang}");
    $file.spurt($code);
    my $proc = run 'perl', '-e', 'alarm shift; exec @ARGV or die', $TIMEOUT,
                   %COMMAND{$engine} // $engine, ~$file, :out, :err;
    my $out = $proc.out.slurp(:close);
    my $err = $proc.err.slurp(:close);
    my %r = :$out, :$err, code => $proc.exitcode;
    $file.unlink;
    %r
}

sub compare(%block, Str $engine, %r, $expected, Bool $wants-error) {
    my $where = "line %block<line> ($engine)";
    if $wants-error {
        return "$where: expected an error, but the program ran" if %r<code> == 0;
        my $err = collapse(%r<err>);
        return $expected.lines.grep(*.trim.chars).map(&collapse)
            .grep({ !$err.contains($_) })
            .map({ "$where: the error does not contain `$_`\n    got: " ~ $err.substr(0, 300) });
    }

    if %r<code> != 0 {
        return "$where: exit code %r<code>\n    " ~ (%r<err>.trim || '(no error output)').lines.head(6).join("\n    ");
    }
    return () unless $expected.defined;
    my $got = normalize(%r<out>);
    my $want = normalize($expected);
    return () if $got eq $want;
    "$where: output differs\n" ~ show-diff($want, $got)
}

sub normalize(Str $s) {
    my @lines = $s.lines.map(*.trim-trailing);
    @lines.pop while @lines && !@lines.tail.chars;
    @lines.join("\n")
}

sub collapse(Str $s) {
    $s.subst(/\s+/, ' ', :g).trim
}

sub show-diff(Str $want, Str $got) {
    my @w = $want.lines;
    my @g = $got.lines;
    my @out;
    for ^max(@w.elems, @g.elems) -> $i {
        my $a = @w[$i] // '(none)';
        my $b = @g[$i] // '(none)';
        next if $a eq $b;
        @out.push: "    want: $a\n    got:  $b";
        last if @out == 5;
    }
    @out.join("\n")
}
