# Reading posts: finding them, their front matter, and their code blocks.
# Shared by check.raku and build-site.raku.
unit module Posts;

#| Every post under a folder, in name order. Files whose names start with a
#| capital letter (README.md, ORDER.md) are notes, not posts.
sub markdown-files(IO::Path $dir) is export {
    gather for $dir.dir.sort -> $path {
        if $path.d {
            take $_ for markdown-files($path);
        }
        elsif $path.extension eq 'md' && $path.basename !~~ / ^ <:Lu> / {
            take $path;
        }
    }
}

#| The front matter as a hash, and the body after it. Values are strings, or
#| arrays for `[a, b]` lists. `body-line` is the file's line number of the
#| body's first line.
sub front-matter(Str $text) is export {
    my %fm = body-line => 1;
    return (%fm, $text) unless $text.starts-with("---\n");
    my $end = $text.index("\n---\n", 3);
    return (%fm, $text) unless $end.defined;

    for $text.substr(4, $end - 4).lines -> $line {
        next unless $line ~~ / ^ (<[\w-]>+) ':' \s* (.*) $ /;
        my $key = ~$0;
        my $value = (~$1).trim;
        if $value ~~ / ^ '[' (.*) ']' $ / {
            %fm{$key} = (~$0).split(',')».trim.grep(*.chars).map(&unquote).Array;
        }
        else {
            %fm{$key} = unquote($value);
        }
    }
    %fm<body-line> = $text.substr(0, $end + 5).lines.elems + 1;
    (%fm, $text.substr($end + 5))
}

sub unquote(Str $s) {
    $s ~~ / ^ (<["']>) (.*) $0 $ / ?? ~$1 !! $s
}

#| The fenced code blocks of a body, in order. Each one knows its language,
#| its flags (`error`, `norun`, `hidden`), its code, its line in the file,
#| the body lines it spans (`from` and `to`, counted from 0), and whether
#| only blank lines separate it from the block before (`adjacent`).
sub code-blocks(Str $body, Int $first-line = 1) is export {
    my @blocks;
    my $current;
    my $gap = '';
    for $body.lines.kv -> $n, $line {
        if $current {
            if $line eq '```' {
                $current<code> = $current<lines>.join("\n") ~ "\n";
                $current<to> = $n;
                @blocks.push: $current;
                $current = Nil;
                $gap = '';
            }
            else {
                $current<lines>.push: $line;
            }
        }
        elsif $line ~~ / ^ '```' (\w+) [\s+ (.+)]? $ / {
            $current = {
                lang     => ~$0,
                flags    => ($1 ?? (~$1).words !! ()).Set,
                line     => $first-line + $n,
                from     => $n,
                adjacent => !$gap.trim.chars,
                lines    => [],
            };
        }
        else {
            $gap ~= $line;
        }
    }
    @blocks
}
