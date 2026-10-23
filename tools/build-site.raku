#!/usr/bin/env raku

# Builds the RakuPress site from the Markdown: a WordPress database in
# mysqldump's format (site/site.sql), which `rakupress import` reads into
# site/content.db, and the site's own header and footer (site/header.html,
# site/footer.html). tools/serve.sh builds, imports and serves in one go.
#
#     raku tools/build-site.raku
#
# The site is Learn Raku, learn.raku.online, in six parts (@PARTS). Its front
# page leads to all six. One part, Raku as a Foreign Language, is written in
# this repository; the other five are built in the raku.online repository
# (its learn/ folder): the tour, the drills, the examples, the cookbook and
# Raku Behind the Docs. They are copied into site/learn/ as they are, except
# for their bar, the engine and links that leave them; see assemble-learn.
# RAKU_ONLINE names that repository (default ~/raku.online).
#
# Raku as a Foreign Language is made of pages, not posts, all under
# /foreign-language/: its own front page; one page per kind of article
# (/foreign-language/readers/) with its articles under it
# (/foreign-language/readers/countdown/); Start here, Articles and Levels;
# and a page for each language a reader may come from
# (/foreign-language/from/python/). Every list on these pages is written
# here, from the articles' front matter, in the order of posts/ORDER.md
# within each level.
#
# Prose goes through pandoc. Code blocks are written here: a runnable Raku
# block becomes <pre data-raku>, which raku.js turns into an editor with a
# Run button, and its output follows it as a plain <pre>.

use lib $?FILE.IO.parent.add('lib').Str;
use Posts;

my constant @STRANDS =
    { key => 'reader', slug => 'readers', name => 'Readers', one => 'reader', glyph => '¶',
      blurb => 'Short programs to read before you run them. Guess what each one prints, run it, then read the notes.' },
    { key => 'false-friend', slug => 'false-friends', name => 'False friends', one => 'false friend', glyph => '≠',
      blurb => 'Code that looks the same in Python, Perl or JavaScript and in Raku, but means something else.' },
    { key => 'family', slug => 'word-families', name => 'Word families', one => 'word family', glyph => '&amp;',
      blurb => 'Methods and operators that are related, learned together so that you stop mixing them up.' },
    { key => 'accent', slug => 'accents', name => 'Accents', one => 'accent', glyph => 'é',
      blurb => 'One task written with a Python, a Perl and a C accent, and then the way a native writes it.' };
my constant @LEVELS = <A1 A2 B1 B2 C1 C2>;
my constant %LEVEL-NAME = A1 => 'First words', A2 => 'Everyday Raku', B1 => 'Getting around',
                          B2 => 'Independent', C1 => 'Fluent', C2 => 'Native';
my constant @FROM = <python perl js c>;
my constant %LANG = python => 'Python', perl => 'Perl', js => 'JavaScript', c => 'C';

#| Where Raku as a Foreign Language lives.
my constant $RFL = '/foreign-language';

#| The six parts of Learn Raku, in the order of the bar. All but Raku as a
#| Foreign Language were built in the raku.online repository and moved here
#| (`moved`), under their old paths. On the front page each part has a card:
#| what kind of thing it is, its numbers, and the pages it starts with
#| (`first`; `skip` names pages of a part that are not chapters of it).
my constant @PARTS =
    { slug => 'tour', name => 'Tour', title => 'A Tour of Raku', kind => 'Lessons', moved => True,
      for => 'New to Raku', open => 'Take the tour', first => <hello-world strings loops>,
      blurb => 'Eighteen short lessons, from Hello, world to grammars and junctions. Each explains one part of the language in a few paragraphs, and you can change and run every example. The whole tour takes about an hour.' },
    { slug => 'drills', name => 'Drills', title => 'Raku Drills', kind => 'Practice', moved => True,
      for => 'Want to test yourself', open => 'Start the drills',
      blurb => 'Questions at six levels, from A1 to C2: choose an answer, type the name of a routine, or fill the gap in a program. Come back after a lesson or an article and see what stayed.' },
    { slug => 'foreign-language', name => 'Foreign Language', title => 'Raku as a Foreign Language', kind => 'Articles',
      for => 'Know Python, Perl, JavaScript or C', open => 'Read the articles',
      first => <countdown string-equality comb-words-lines-split>,
      blurb => 'Raku taught the way you learn a second language: short programs to read before you run them, false friends from the language you know, word families, and the same task written with an accent and without.' },
    { slug => 'examples', name => 'Examples', title => 'Raku by example', kind => 'Programs', moved => True,
      for => 'Learn by reading code', open => 'See every program', first => <life calculator json>,
      blurb => 'Complete programs to read and run, from the Game of Life to a pocket calculator and a JSON parser. Each one is longer than a lesson and names the features it leans on.' },
    { slug => 'cookbook', name => 'Cookbook', title => 'The Raku Cookbook', kind => 'Recipes', moved => True,
      for => 'Have a job to do', open => 'See every recipe', first => <cli grammar http>,
      blurb => 'Whole tasks worked end to end: a command-line tool, a grammar for a configuration file, HTTP, databases and parallel work. Each recipe grows one program step by step, and every output shown is what Raku++ printed.' },
    { slug => 'deep', name => 'Behind the Docs', title => 'Raku Behind the Docs', kind => 'Reference', moved => True,
      for => 'Need the exact rule', open => 'Read the book', first => <containers precedence nil-any>,
      skip => <corners how-to-read colophon>,
      blurb => 'What Raku actually does, corner by corner: precedence, containers, Nil and Any, sink context. Each corner is one behaviour, shown by the smallest program that proves it.' };
my constant @MOVED = @PARTS.grep(*<moved>).map(*<slug>);

#| Raku as a Foreign Language's own sections, in the second bar on its pages.
my constant @RFL-NAV = 'start-here' => 'Start here', |@STRANDS.map({ .<slug> => .<name> }), 'levels' => 'Levels';

#| The Learn Raku app, the Complete Raku Course with Raku++ inside, in the
#| two stores; the same links as course.raku.org's footer.
my constant @STORES =
    { url => 'https://apps.apple.com/app/id6788222934', badge => 'app-store.svg',
      alt => 'Download on the App Store', width => 120 },
    { url => 'https://play.google.com/store/apps/details?id=online.deepsoft.learnraku', badge => 'google-play.svg',
      alt => 'Get it on Google Play', width => 135 };

#| The front page's last section, and the footer's last column.
my constant @ELSEWHERE =
    { url => 'https://course.raku.org', name => 'The Complete Raku Course',
      blurb => 'The language from the beginning, chapter by chapter, ending with a final test.' },
    { url => 'https://raku.online/play/', name => 'Playground',
      blurb => 'An empty editor with Raku++ behind it: write any program and run it.' },
    { url => 'https://raku.online/', name => 'Raku++',
      blurb => 'The interpreter and compiler that runs every example on this site, compiled to WebAssembly.' },
    { url => 'https://raku.online/faq/', name => 'Raku FAQ',
      blurb => 'Short answers to the questions people ask while writing Raku: how do I, and why does this print twice.' },
    { url => 'https://docs.raku.org', name => 'Raku documentation',
      blurb => 'The official reference for the language, its types and its routines.' },
    { url => 'https://andrewshitov.com/raku-books/', name => 'Books',
      blurb => 'Andrew Shitov’s books: Raku one-liners, a hundred solved challenges, and a compiler written in Raku.' };

my constant $FONTS = 'https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700'
                   ~ '&family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600'
                   ~ '&family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;1,8..60,400&display=swap';

# raku.online's light and dark switch: /theme/boot.js binds it.
my constant $THEME-SWITCH = q:to/HTML/.trim;
    <span class="theme-switch"><button class="theme-btn" aria-label="Theme" aria-haspopup="true" aria-expanded="false">◐</button><ul class="theme-menu" hidden><li><button data-theme-set="system"><span class="ti">◐</span> System</button></li><li><button data-theme-set="light"><span class="ti">☀</span> Light</button></li><li><button data-theme-set="dark"><span class="ti">☾</span> Dark</button></li></ul></span>
    HTML

my constant %COLUMNS =
    wp_options            => <option_id option_name option_value autoload>,
    wp_users              => <ID user_login user_pass user_nicename user_email user_url
                              user_registered user_activation_key user_status display_name>,
    wp_posts              => <ID post_author post_date post_date_gmt post_content post_title
                              post_excerpt post_status comment_status ping_status post_password
                              post_name to_ping pinged post_modified post_modified_gmt
                              post_content_filtered post_parent guid menu_order post_type
                              post_mime_type comment_count>,
    wp_terms              => <term_id name slug term_group>,
    wp_term_taxonomy      => <term_taxonomy_id term_id taxonomy description parent count>;

my constant $GMT-OFFSET = 1;
my $root = $?FILE.IO.parent.parent;

sub MAIN(Str :$home = 'http://127.0.0.1:8083', Str :$date = ~Date.today) {
    my @articles = articles();

    # The parts from raku.online first: the front page counts their pages.
    my $raku-online = (%*ENV<RAKU_ONLINE> // $*HOME.add('raku.online')).IO;
    die "No learn/ in $raku-online: set RAKU_ONLINE to a raku.online checkout that has the learning sections"
        unless $raku-online.add('learn/tour/index.html').e;
    # bar.js before them, as they carry its time.
    spurt-if-changed($root.add('site/static/bar.js'), bar-js());
    assemble-learn($raku-online);

    # Page ids: the site's own pages first, then the articles.
    my %page-id;
    my $id = 0;
    %page-id{$_} = ++$id for 'home', 'start-here', 'levels', |@STRANDS.map(*<slug>),
                             'from', |@FROM.map({ "from/$_" }), 'articles', 'foreign-language';
    .<id> = ++$id for @articles;

    my @rows;
    sub page(Str $key, Str $title, Str $slug, Str $content, Str $excerpt = '', Int :$parent = 0, Int :$order = 0) {
        @rows.push: page-row(%page-id{$key} // $key.Int, $home, $title, $slug, $content, $excerpt, $date,
                             :$parent, :$order);
    }

    page 'home', 'Learn Raku', 'home', hub-html(@articles),
         'Six ways into Raku: lessons, drills, articles, programs, recipes and the rules behind them.';

    # Raku as a Foreign Language: every page of it under its own.
    my $rfl = %page-id<foreign-language>;
    page 'foreign-language', 'Raku as a Foreign Language', 'foreign-language', rfl-html(@articles),
         'Raku taught the way you learn a second language: readers, false friends, word families and accents.';

    for <start-here levels> -> $key {
        my ($fm, $body) = front-matter($root.add("pages/$key.md").slurp);
        my $html = $key eq 'levels' ?? levels-html($body, @articles) !! body-html($body);
        page $key, $fm<title>, $key, wrap($html), plain($fm<summary> // ''), parent => $rfl, order => 1;
    }

    for @STRANDS.kv -> $n, %s {
        my @mine = @articles.grep(*<strand><key> eq %s<key>);
        page %s<slug>, %s<name>, %s<slug>, strand-html(%s, @mine), %s<blurb>, parent => $rfl, order => 2 + $n;
        for @mine.kv -> $i, %a {
            my $prev = $i > 0 ?? @mine[$i - 1] !! Nil;
            page ~%a<id>, %a<fm><title>, %a<slug>, article-html(%a, $prev, @mine[$i + 1]),
                 plain(%a<fm><summary>), parent => %page-id{%s<slug>}, order => $i;
        }
    }

    page 'articles', 'Articles', 'articles', articles-html(@articles),
         'Every reader, false friend, word family and accent.', parent => $rfl, order => 1;

    page 'from', 'Coming from another language', 'from', from-index-html(@articles), parent => $rfl, order => 10;
    for @FROM -> $lang {
        page "from/$lang", "Coming from %LANG{$lang}", $lang, from-html($lang, @articles),
             parent => %page-id<from>;
    }

    my @options = options($home, %page-id<home>);
    my %rows =
        wp_options       => @options.kv.map(-> $n, $o { [$n + 1, $o.key, $o.value, 'yes'] }).Array,
        wp_users         => [[1, 'andrew', '', 'andrew', '', '', "$date 00:00:00", '', 0, 'Andrew Shitov'],],
        wp_posts         => @rows,
        wp_terms         => [[1, 'Uncategorized', 'uncategorized', 0],],
        wp_term_taxonomy => [[1, 1, 'category', '', 0, 0],];

    my $sql = $root.add('site/site.sql');
    $sql.spurt: %COLUMNS.keys.sort.map({ table-sql($_, %rows{$_}) }).join;
    $root.add('site/header.html').spurt: header-html(%page-id);
    $root.add('site/footer.html').spurt: footer-html();

    # Browsers keep the site's own files for a day, so every link to one
    # carries the file's time: in site.json, and in the pages from raku.online.
    my $json = $root.add('site/site.json');
    $json.spurt: stamped($json.slurp);
    say "$sql: {@articles.elems} articles, {@rows.elems - @articles.elems} other pages";
    say "site/learn: {@MOVED.join(', ')} and theme, from $raku-online";
}

#| Links to /rfl/… and /theme/… files with ?v= set to each file's time.
sub stamped(Str $s --> Str) {
    $s.subst(/ '/rfl/' (<[\w.-]>+) '?v=' \w+ /, -> $m { "/rfl/$m[0]?v={$root.add("site/static/$m[0]").modified.Int}" }, :g)
      .subst(/ '/theme/' (<[\w.-]>+) '?v=' \w+ /, -> $m { "/theme/$m[0]?v={$root.add("site/learn/theme/$m[0]").modified.Int}" }, :g)
}

sub spurt-if-changed(IO::Path $file, Str $content) {
    $file.spurt($content) unless $file.e && $file.slurp eq $content;
}

# ---------- the articles ----------

#| Every article, with its front matter, strand, address and place: in the
#| order of posts/ORDER.md within each strand and level.
sub articles() {
    my @a = post-order().kv.map(-> $n, $file {
        my ($fm, $body) = front-matter($file.slurp);
        my %s = @STRANDS.first(*<key> eq $fm<strand>);
        my $slug = $file.basename.subst(/'.md' $/, '');
        %( :$fm, :$body, strand => %s, order => $n, :$slug, url => "$RFL/%s<slug>/$slug/" )
    });
    @a.sort(-> %a {
        my $strand = %a<strand><key>;
        @STRANDS.first({ .<key> eq $strand }, :k), level-index(%a<fm><level>), %a<order>
    }).Array
}

#| The posts in the order of posts/ORDER.md; any post it does not list
#| comes after those, in name order.
sub post-order() {
    my $posts = $root.add('posts');
    my @listed = $posts.add('ORDER.md').lines
        .map({ / '](' (<-[)]>+ '.md') ')' / ?? $posts.add(~$0).resolve !! Empty })
        .grep({ .e && .Str.starts-with($posts.resolve.Str) });
    my %seen = @listed.map(*.Str => True);
    (|@listed, |markdown-files($posts).map(*.resolve).grep({ !%seen{.Str} }))
}

sub level-index(Str $level --> Int) { @LEVELS.first($level, :k) // @LEVELS.elems }

sub article-html(%a, $prev, $next --> Str) {
    my %s = %a<strand>;
    my $meta = qq[<div class="rfl-meta"><a class="rfl-kicker rfl-s-{%s<key>}" href="$RFL/{%s<slug>}/">{%s<one>.tc}</a>]
             ~ level-badge(%a<fm><level>) ~ from-links(%a<fm><from> // []) ~ '</div>';
    my $pager = '';
    if $prev || $next {
        $pager = qq[<nav class="rfl-pager" aria-label="More {%s<name>.lc}">]
            ~ ($prev ?? qq[<a class="rfl-prev" href="{$prev<url>}"><span>Previous {%s<one>}</span>{esc($prev<fm><title>)}</a>] !! '<span></span>')
            ~ ($next ?? qq[<a class="rfl-next" href="{$next<url>}"><span>Next {%s<one>}</span>{esc($next<fm><title>)}</a>] !! '')
            ~ '</nav>';
    }
    wrap(join "\n", $meta, qq[<p class="rfl-lead">{inline(%a<fm><summary>)}</p>], body-html(%a<body>), $pager)
}

sub level-badge(Str $level --> Str) {
    qq[<a class="rfl-level rfl-level-{$level.substr(0, 1).lc}" href="$RFL/levels/#{$level.lc}" title="{%LEVEL-NAME{$level}}">$level\</a>]
}

sub from-links(@from --> Str) {
    return '' unless @from;
    '<span class="rfl-from">from ' ~ @from.map({ qq[<a href="$RFL/from/$_/">%LANG{$_}\</a>] }).join(', ') ~ '</span>'
}

sub article-list(@items, Bool :$strand, Bool :$level --> Str) {
    '<ul class="rfl-list">' ~ @items.map(-> %a {
        '<li>'
        ~ qq[<a class="rfl-list-link" href="{%a<url>}"><span class="rfl-list-title">{esc(%a<fm><title>)}</span>]
        ~ qq[<span class="rfl-list-summary">{inline(%a<fm><summary>)}</span></a>]
        ~ '<span class="rfl-list-tags">'
        ~ ($strand ?? qq[<a class="rfl-kicker rfl-s-{%a<strand><key>}" href="$RFL/{%a<strand><slug>}/">{%a<strand><one>.tc}</a>] !! '')
        ~ ($level ?? level-badge(%a<fm><level>) !! '')
        ~ '</span></li>'
    }).join ~ '</ul>'
}

sub count(Int $n, Str $one, Str $many = $one ~ 's' --> Str) { $n == 1 ?? "1 $one" !! "$n $many" }

# ---------- the front page: Learn Raku ----------

#| The front page: the six parts of Learn Raku, where to start, the levels
#| the articles and the drills share, and what else there is to read.
sub hub-html(@articles --> Str) {
    my %drills = drill-levels();
    my $where = @PARTS.map({
        qq[<li class="lr-p-{.<slug>}"><a href="/{.<slug>}/"><span class="lr-where-who">{.<for>}</span>]
        ~ qq[<span class="lr-where-go">{.<title>}</span></a></li>]
    }).join
    ~ '<li class="lr-where-course"><a href="https://course.raku.org"><span class="lr-where-who">Want a whole course, chapter by chapter</span>'
    ~ '<span class="lr-where-go">The Complete Raku Course</span></a></li>';
    my $away = @ELSEWHERE.map({
        qq[<a class="lr-away" href="{.<url>}"><span class="lr-away-name">{.<name>}</span>]
        ~ qq[<span class="lr-away-blurb">{.<blurb>}</span></a>]
    }).join;

    wrap(qq:to/HTML/);
        <section class="rfl-hero lr-hero">
        <div class="rfl-hero-text">
        <p class="rfl-eyebrow">Free, and nothing to install</p>
        <h2 class="rfl-hero-title">Six ways into <mark>Raku</mark>.</h2>
        <p class="rfl-hero-lead">Lessons for your first hour, questions to test yourself, articles for people who already know another programming language, complete programs, whole tasks worked end to end, and the exact rules behind it all. Almost every example runs right in the page, on Raku++.</p>
        <p class="rfl-actions"><a class="rfl-button" href="/tour/">Take the tour</a><a class="rfl-button rfl-button-quiet" href="$RFL/">Raku as a Foreign Language</a></p>
        </div>
        <nav class="lr-where" aria-label="Where to start">
        <h3>Where to start</h3>
        <ul>$where\</ul>
        </nav>
        </section>
        <section class="rfl-section">
        <header class="rfl-section-head"><h2>Six parts</h2><p>Each part teaches in its own way and stands on its own. Together they take you from the first lesson to the exact rules.</p></header>
        <div class="lr-parts">
        {@PARTS.map({ part-card($_, @articles, %drills) }).join("\n")}
        </div>
        </section>
        <section class="rfl-section">
        <header class="rfl-section-head"><h2>Six levels</h2><p>The articles and the drills share the levels of a language course, from A1 to C2. Work at your level, and then one above it.</p></header>
        {level-tiles(@articles, %drills)}
        </section>
        <section class="rfl-section lr-app">
        <img class="lr-app-icon" src="/rfl/learn-raku-app.png" alt="" width="96" height="96">
        <div class="lr-app-text">
        <h2>Learn Raku on your phone</h2>
        <p>The Learn Raku app carries the whole <a href="https://course.raku.org">Complete Raku Course</a>: 399 lessons, over a thousand examples, 217 quizzes, 396 exercises and the Final Test. Raku++ is inside, so the examples run on the phone itself, with no connection. For iPhone, iPad and Android.</p>
        {store-badges()}
        </div>
        </section>
        <section class="rfl-section rfl-try">
        <div class="rfl-try-text">
        <h2>The examples run</h2>
        <p>The lessons, the articles, the programs and Behind the Docs run their examples in your browser, on <a href="https://raku.online">Raku++</a> compiled to WebAssembly. Nothing is sent to a server. The cookbook works with files, networks and databases, so its recipes show what Raku++ printed on a real machine. Change this program and press Run.</p>
        </div>
        <div class="rfl-try-code">
        <pre data-raku>say (1..10).map(* ** 2).grep(* %% 2);
        say 'Learn Raku'.flip;
        say 1/3 + 1/6;
        say &lt;Riga Leiden Turin&gt;.sort(*.chars);</pre>
        </div>
        </section>
        <section class="rfl-section">
        <header class="rfl-section-head"><h2>Elsewhere</h2><p>A whole course, an empty editor, the engine behind every Run button, and more to read.</p></header>
        <div class="lr-aways">$away\</div>
        </section>
        HTML
}

#| The App Store and Google Play buttons for the Learn Raku app.
sub store-badges(--> Str) {
    '<p class="lr-stores">' ~ @STORES.map({
        qq[<a href="{.<url>}"><img src="/rfl/{.<badge>}" alt="{.<alt>}" width="{.<width>}" height="40"></a>]
    }).join ~ '</p>'
}

#| One part's card on the front page: what it is, its numbers, and the pages
#| it starts with (for the drills, how many questions each level has).
sub part-card(%p, @articles, %drills --> Str) {
    my @stats;
    my $inside;
    given %p<slug> {
        when 'foreign-language' {
            my @first = %p<first>.map(-> $slug { @articles.first(*<slug> eq $slug) // die "No article $slug" });
            @stats = @articles.elems => 'articles', @STRANDS.elems => 'kinds';
            $inside = begin-with(@first.map({ (.<url>, esc(.<fm><title>), level-badge(.<fm><level>)) }));
        }
        when 'drills' {
            my $most = %drills.values.max;
            @stats = %drills.values.sum => 'questions', @LEVELS.elems => 'levels';
            $inside = '<div class="lr-begin"><h4>Questions per level</h4>'
                    ~ qq[<ol class="lr-bars" style="--most: $most">]
                    ~ @LEVELS.map({ qq[<li class="rfl-level-{.substr(0, 1).lc}" style="--n: {%drills{$_} // 0}"><b>{%drills{$_} // 0}</b><span class="lr-bar"></span>$_\</li>] }).join
                    ~ '</ol></div>';
        }
        default {
            my @pages = part-pages(%p);
            my $dir = $root.add("site/learn/%p<slug>");
            @stats = @pages.elems => %(tour => 'lessons', examples => 'programs', cookbook => 'recipes',
                                       deep => 'chapters'){%p<slug>};
            @stats.push: count-in(%p, @pages, '<pre data-raku') => 'live examples' if %p<slug> eq 'tour';
            @stats.push: count-in(%p, @pages, 'class="corner"') => 'corners' if %p<slug> eq 'deep';
            $inside = begin-with(%p<first>.map(-> $page {
                die "No page /%p<slug>/$page/ among the chapters of %p<title>" unless $page (elem) @pages;
                ("/%p<slug>/$page/", page-title($dir.add("$page/index.html")))
            }));
        }
    }
    qq[<article class="lr-part lr-p-{%p<slug>}">]
    ~ qq[<p class="lr-part-kind">{%p<kind>}</p>]
    ~ qq[<h3><a href="/{%p<slug>}/">{%p<title>}</a></h3>]
    ~ qq[<p class="lr-part-blurb">{%p<blurb>}</p>]
    ~ '<dl class="lr-stats">' ~ @stats.map({ qq[<div><dt>{.value}</dt><dd>{thousands(.key)}</dd></div>] }).join ~ '</dl>'
    ~ $inside
    ~ qq[<a class="lr-open" href="/{%p<slug>}/">{%p<open>}</a>]
    ~ '</article>'
}

#| The first pages of a part: (address, title, and what follows the link).
sub begin-with(@pages --> Str) {
    '<div class="lr-begin"><h4>Begin with</h4><ol>'
    ~ @pages.map(-> ($url, $title, $after = '') { qq[<li><a href="$url">$title\</a>$after\</li>] }).join
    ~ '</ol></div>'
}

#| The chapters of a part from raku.online: the pages its own front page
#| links to, in that order, without redirects and without its `skip` pages.
sub part-pages(%p --> List) {
    my $slug = %p<slug>;
    my $dir = $root.add("site/learn/$slug");
    my %skip = (%p<skip> // ()).Set;
    $dir.add('index.html').slurp.comb(/ 'href="/' $slug '/' <( <[a..z0..9-]>+ )> '/' <[#"]> /).unique
        .grep({ !%skip{$_} })
        .grep({ my $f = $dir.add("$_/index.html"); $f.e && !$f.slurp.contains('http-equiv="refresh"') })
        .List
}

#| How many times a piece of markup appears in a part's chapters.
sub count-in(%p, @pages, Str $what --> Int) {
    @pages.map({ $root.add("site/learn/%p<slug>/$_/index.html").slurp.comb($what).elems }).sum
}

#| A page's heading, from its <h1> (keeping <code>), or else its <title>.
sub page-title(IO::Path $file --> Str) {
    my $html = $file.slurp;
    my $h1 = $html ~~ / '<h1' <-[>]>* '>' (.*?) '</h1>' / ?? ~$0 !! '';
    $h1 = $h1.subst(/ '<' <!before '/'? 'code' <[\s>]>> <-[>]>* '>' /, '', :g).trim;
    $h1 || ($html ~~ / '<title>' (<-[<]>*?) [' — ' | '</title>'] / ?? ~$0 !! $file.parent.basename)
}

#| How many questions the drills have at each level, from their question bank.
sub drill-levels(--> Hash) {
    $root.add('site/learn/drills/data/drills.js').slurp
        .comb(/ 'level:' \s* "'" <( <[ABC]> <[12]> )> "'" /).Bag.Hash
}

sub thousands(Int $n --> Str) { $n.flip.comb(3).join(',').flip }

# ---------- Raku as a Foreign Language ----------

#| Its own front page.
sub rfl-html(@articles --> Str) {
    my %ff = @articles.first(*<slug> eq 'point-one-plus-point-two') // {};
    my $flash = %ff ?? qq:to/HTML/ !! '';
        <figure class="rfl-flash">
        <figcaption><span class="rfl-flash-kind">False friend</span>{level-badge(%ff<fm><level>)}</figcaption>
        <div class="rfl-flash-row"><span class="rfl-flash-lang">Python</span><code>0.1 + 0.2 == 0.3</code><span class="rfl-flash-out rfl-no">False</span></div>
        <div class="rfl-flash-row"><span class="rfl-flash-lang">Raku</span><code>0.1 + 0.2 == 0.3</code><span class="rfl-flash-out rfl-yes">True</span></div>
        <a class="rfl-flash-more" href="{%ff<url>}">Why the answers differ</a>
        </figure>
        HTML

    my $strands = @STRANDS.map(-> %s {
        my @mine = @articles.grep(*<strand><key> eq %s<key>);
        qq[<article class="rfl-strand rfl-s-{%s<key>}">]
        ~ qq[<h3><a href="$RFL/{%s<slug>}/"><span class="rfl-glyph" aria-hidden="true">{%s<glyph>}</span>{%s<name>}</a></h3>]
        ~ qq[<p>{%s<blurb>}</p>]
        ~ '<ul class="rfl-strand-list">'
        ~ @mine.head(3).map({ qq[<li><a href="{.<url>}">{esc(.<fm><title>)}</a>{level-badge(.<fm><level>)}</li>] }).join
        ~ '</ul>'
        ~ qq[<a class="rfl-more" href="$RFL/{%s<slug>}/">All {count(@mine.elems, %s<one>, %s<name>.lc)}</a>]
        ~ '</article>'
    }).join("\n");

    wrap(qq:to/HTML/);
        <section class="rfl-hero">
        <div class="rfl-hero-text">
        <p class="rfl-eyebrow">For people who already know another programming language</p>
        <h2 class="rfl-hero-title">Learn Raku the way you learned your <mark>second language</mark>.</h2>
        <p class="rfl-hero-lead">Nobody learns a second language from zero. You read, you compare it with the one you know, you notice the words that fool you, and slowly you lose your accent. These articles teach Raku the same way, and every example runs in your browser.</p>
        <p class="rfl-actions"><a class="rfl-button" href="$RFL/start-here/">Start here</a><a class="rfl-button rfl-button-quiet" href="$RFL/levels/">Find your level</a></p>
        </div>
        $flash
        </section>
        <section class="rfl-section">
        <header class="rfl-section-head"><h2>Four kinds of articles</h2><p>Each one practises a different skill, the way a language course mixes reading, vocabulary and pronunciation.</p></header>
        <div class="rfl-strands">
        $strands
        </div>
        </section>
        <section class="rfl-section">
        <header class="rfl-section-head"><h2>Find your level</h2><p>Six levels, as in a language course. Read at your level, and then one above it.</p></header>
        {level-tiles(@articles)}
        </section>
        <section class="rfl-section">
        <header class="rfl-section-head"><h2>Coming from another language?</h2><p>False friends and accents start from what you already know.</p></header>
        {language-tiles(@articles)}
        </section>
        <section class="rfl-section rfl-try">
        <div class="rfl-try-text">
        <h2>Every example runs</h2>
        <p>The programs in these articles run in your browser, on <a href="https://raku.online">Raku++</a> compiled to WebAssembly. Nothing is sent to a server. Change this one and press Run.</p>
        </div>
        <div class="rfl-try-code">
        <pre data-raku>my \@cities = 'Riga', 'Leiden', 'Turin';
        say \@cities[*-1];
        say 'Riga'.comb;
        say 0.1 + 0.2 == 0.3;</pre>
        </div>
        </section>
        <section class="rfl-section rfl-also">
        <p>Raku as a Foreign Language is one part of <a href="/">Learn Raku</a>. The others: {
            @PARTS.grep(*<moved>).map({ qq[<a href="/{.<slug>}/">{.<title>}</a>] }).join(', ')
        }.</p>
        </section>
        HTML
}

sub articles-html(@articles --> Str) {
    my $out = qq[<p class="rfl-lead">Four kinds of articles, each practising a different skill. ]
            ~ qq[Every one is marked with its <a href="$RFL/levels/">level</a>, from A1 to C2.</p>];
    for @STRANDS -> %s {
        my @mine = @articles.grep(*<strand><key> eq %s<key>);
        $out ~= qq[<section class="rfl-group rfl-s-{%s<key>}">]
              ~ qq[<h2 id="{%s<slug>}"><span class="rfl-glyph" aria-hidden="true">{%s<glyph>}</span><a href="$RFL/{%s<slug>}/">{%s<name>}</a></h2>]
              ~ qq[<p>{%s<blurb>}</p>] ~ article-list(@mine, :level) ~ '</section>';
    }
    wrap($out)
}

#| The six levels, with the articles at each; on the front page, with the
#| drills' questions too.
sub level-tiles(@articles, %drills? --> Str) {
    '<div class="rfl-levels">' ~ @LEVELS.map(-> $l {
        my $n = @articles.grep(*<fm><level> eq $l).elems;
        my @what = $n ?? count($n, 'article') !! ();
        @what.push: count($_, 'question') with %drills{$l};
        qq[<a class="rfl-level-tile rfl-level-{$l.substr(0, 1).lc}" href="$RFL/levels/#{$l.lc}">]
        ~ qq[<span class="rfl-level-code">$l\</span><span class="rfl-level-name">%LEVEL-NAME{$l}\</span>]
        ~ qq[<span class="rfl-level-count">{@what ?? @what.join(' · ') !! 'coming later'}</span></a>]
    }).join ~ '</div>'
}

sub language-tiles(@articles --> Str) {
    '<div class="rfl-langs">' ~ @FROM.map(-> $lang {
        my $n = @articles.grep({ $lang (elem) (.<fm><from> // []) }).elems;
        qq[<a class="rfl-lang-tile" href="$RFL/from/$lang/"><span class="rfl-lang-name">%LANG{$lang}\</span>]
        ~ qq[<span class="rfl-lang-count">{count($n, 'article')}</span></a>]
    }).join ~ '</div>'
}

sub strand-html(%s, @mine --> Str) {
    my $out = qq[<div class="rfl-intro rfl-s-{%s<key>}"><span class="rfl-glyph" aria-hidden="true">{%s<glyph>}</span>]
            ~ qq[<p class="rfl-lead">{%s<blurb>}</p></div>];
    for @LEVELS -> $l {
        my @at = @mine.grep(*<fm><level> eq $l) or next;
        $out ~= qq[<section class="rfl-group"><h2 id="{$l.lc}">{level-badge($l)} %LEVEL-NAME{$l}\</h2>]
              ~ article-list(@at) ~ '</section>';
    }
    wrap($out)
}

sub from-index-html(@articles --> Str) {
    wrap(qq[<p class="rfl-lead">You already know a programming language, and it shapes what you expect from Raku. ]
       ~ qq[False friends and accents start from that: pick the language you know best.</p>]
       ~ language-tiles(@articles))
}

sub from-html(Str $lang, @articles --> Str) {
    my $name = %LANG{$lang};
    my $out = qq[<p class="rfl-lead">$name programmers bring habits with them. Some of them help in Raku, and some get in the way. ]
            ~ qq[These articles start from what $name does.</p>];
    for @STRANDS -> %s {
        my @mine = @articles.grep({ .<strand><key> eq %s<key> && $lang (elem) (.<fm><from> // []) }) or next;
        $out ~= qq[<section class="rfl-group"><h2>{%s<name>}</h2>] ~ article-list(@mine, :level) ~ '</section>';
    }
    wrap($out)
}

#| The Levels page: its Markdown, with the articles of each level listed
#| after that level's description.
sub levels-html(Str $body, @articles --> Str) {
    my @lines;
    my %lists;
    my $current;
    my sub close-level() {
        return unless $current;
        my @at = @articles.grep(*<fm><level> eq $current);
        %lists{"RFLLEVEL$current"} = @at
            ?? qq[<div class="rfl-at-level"><h3>Articles at $current\</h3>] ~ article-list(@at, :strand) ~ '</div>'
            !! qq[<p class="rfl-none">Nothing at $current yet.</p>];
        @lines.append: '', "RFLLEVEL$current", '';
    }
    for $body.lines -> $line {
        if $line ~~ / ^ '## ' (<[ABC]><[12]>) » / {
            close-level();
            $current = ~$0;
            @lines.push: "$line \{#{$current.lc}\}";
        }
        else {
            @lines.push: $line;
        }
    }
    close-level();
    body-html(@lines.join("\n"), %lists)
}

# ---------- header and footer ----------

#| The bar at the top of every page: Learn Raku, its six parts, and in the
#| corner the Raku course, and the playground and Raku++ on raku.online. On the RakuPress pages it
#| carries the light and dark switch itself; on the pages from raku.online,
#| bar.js moves the page's own switch into it.
sub bar-html(Bool :$switch --> Str) {
    '<header class="rfl-top"><div class="rfl-top-inner">' ~ brand()
    ~ '<nav class="rfl-nav" aria-label="Learn Raku">'
    ~ @PARTS.map({ qq[<a class="rfl-nav-{.<slug>}" href="/{.<slug>}/">{.<name>}</a>] }).join
    ~ '</nav><div class="rfl-tools">'
    ~ '<a class="rfl-corner" href="https://course.raku.org">Course</a>'
    ~ '<a class="rfl-corner" href="https://raku.online/play/">Play<span class="rfl-corner-long">ground</span></a>'
    ~ '<a class="rfl-corner" href="https://raku.online/">Raku++</a>'
    ~ ($switch ?? $THEME-SWITCH !! '')
    ~ '</div></div></header>'
}

#| The second bar, on the pages of Raku as a Foreign Language: its sections
#| and its search. site.css hides it on the front page.
sub rfl-bar-html(--> Str) {
    my %strand = @STRANDS.map({ .<slug> => .<key> });
    '<nav class="rfl-sub" aria-label="Raku as a Foreign Language"><div class="rfl-sub-inner">'
    ~ qq[<a class="rfl-sub-title" href="$RFL/">Raku <i>as a</i> Foreign Language</a>]
    ~ '<div class="rfl-sub-links">'
    ~ @RFL-NAV.map({
        my $s = %strand{.key} ?? " rfl-s-%strand{.key}" !! '';
        qq[<a class="rfl-sub-{.key}$s" href="$RFL/{.key}/">{.value}</a>]
    }).join
    ~ '</div>'
    ~ '<form class="rfl-find" role="search" method="get" action="/"><label class="screen-reader-text" for="rfl-find">Search the articles</label>'
    ~ '<input id="rfl-find" type="search" name="s" placeholder="Search"></form>'
    ~ '</div></nav>'
}

#| The header file RakuPress puts at the top of its pages. Every page but the
#| front one is part of Raku as a Foreign Language, so it is underlined in the
#| bar; in the second bar, the section being shown is: RakuPress marks the
#| page and its parent on <body>.
sub header-html(%page-id --> Str) {
    my $active = @RFL-NAV.map(*.key).map(-> $k {
        ".page-id-%page-id{$k} .rfl-sub-$k, .parent-pageid-%page-id{$k} .rfl-sub-$k"
    }).join(",\n");
    qq:to/HTML/;
    {bar-html(:switch)}
    {rfl-bar-html()}
    <style>
    body:not(.home) .rfl-nav-foreign-language,
    $active \{ border-radius: 6px 6px 0 0; color: var(--rfl-ink); box-shadow: inset 0 -2px 0 var(--rfl-ink); \}
    </style>
    HTML
}

#| bar.js: on the pages from raku.online, learn.raku.online's bar in place of
#| raku.online's (their pages load it where they loaded theme/shell.js).
sub bar-js(--> Str) {
    my $bar = bar-html().subst('\\', '\\\\', :g).subst("'", "\\'", :g);
    qq:to/JS/;
    /* bar.js — written by tools/build-site.raku; do not edit. On the pages built
       in the raku.online repository it puts learn.raku.online's bar where
       raku.online's shell.js would have put raku.online's, moves the page's
       light and dark switch into it, and keeps --shell-h, which their layout
       leaves free at the top, at the bar's height. */
    (function () \{
      'use strict';
      var BAR = '$bar';
      function build() \{
        if (document.querySelector('.rfl-top')) return;
        var t = document.createElement('template');
        t.innerHTML = BAR;
        var bar = t.content.firstElementChild;
        var path = location.pathname;
        bar.querySelectorAll('.rfl-nav a').forEach(function (a) \{
          if (path.indexOf(a.getAttribute('href')) === 0) a.setAttribute('aria-current', 'page');
        \});
        var sw = document.querySelector('.theme-switch');
        if (sw) bar.querySelector('.rfl-tools').appendChild(sw);
        document.body.insertBefore(bar, document.body.firstChild);
        document.documentElement.classList.add('rfl-shell');
        // Until bar.css is in, the bar is unstyled and as tall as the window;
        // measured then, it would push the page out of sight. So fit() waits
        // for the fixed bar, and runs again whenever the bar changes height.
        function fit() \{
          if (getComputedStyle(bar).position !== 'fixed') return;
          document.documentElement.style.setProperty('--shell-h', bar.offsetHeight + 'px');
        \}
        fit();
        if (window.ResizeObserver) new ResizeObserver(fit).observe(bar);
        else \{ window.addEventListener('resize', fit); window.addEventListener('load', fit); \}
      \}
      if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', build);
      else build();
    \})();
    JS
}

sub footer-html(--> Str) {
    qq:to/HTML/;
    <div class="rfl-foot">
    <div class="rfl-foot-inner">
    <div class="rfl-foot-about">{brand()}<p>Six ways into Raku, from the first lesson to the exact rules. Almost every example runs in your browser, on Raku++.</p><p>The Complete Raku Course, as an app:</p>{store-badges()}</div>
    <nav class="rfl-foot-col" aria-label="Learn Raku"><h2>Learn Raku</h2><ul>{@PARTS.map({ qq[<li><a href="/{.<slug>}/">{.<title>}</a></li>] }).join}</ul></nav>
    <nav class="rfl-foot-col" aria-label="Raku as a Foreign Language"><h2>Foreign Language</h2><ul><li><a href="$RFL/start-here/">Start here</a></li>{@STRANDS.map({ qq[<li><a href="$RFL/{.<slug>}/">{.<name>}</a></li>] }).join}<li><a href="$RFL/levels/">Levels</a></li></ul></nav>
    <nav class="rfl-foot-col" aria-label="Coming from"><h2>Coming from</h2><ul>{@FROM.map({ qq[<li><a href="$RFL/from/$_/">%LANG{$_}\</a></li>] }).join}</ul></nav>
    <nav class="rfl-foot-col" aria-label="Elsewhere"><h2>Elsewhere</h2><ul>{@ELSEWHERE.map({ qq[<li><a href="{.<url>}">{.<name>}</a></li>] }).join}</ul></nav>
    </div>
    <p class="rfl-foot-small">By Andrew Shitov. Runs on RakuPress and Raku++.</p>
    </div>
    HTML
}

# ---------- the sections from raku.online ----------

#| Copies the learning sections built in the raku.online repository, and its
#| theme, into site/learn/, which RakuPress serves under /tour/, /theme/ and
#| the rest. Three things change on the way:
#| - their bar is this site's (bar.css and bar.js, in place of shell.js);
#| - they load the engine from raku.online, where it lives;
#| - a link that leaves the moved sections goes back to raku.online.
sub assemble-learn(IO::Path $from) {
    my $to = $root.add('site/learn');
    run 'rm', '-rf', ~$to;
    copy-tree($from.add('www/theme'), $to.add('theme'), -> $text, $ { $text });

    my $tags = stamped(qq[<link rel="icon" href="/rfl/icon.svg?v=0" type="image/svg+xml">\n]
                     ~ qq[<link rel="apple-touch-icon" href="/rfl/icon-180.png?v=0">\n]
                     ~ qq[<link rel="stylesheet" href="$FONTS">\n]
                     ~ qq[<link rel="stylesheet" href="/rfl/bar.css?v=0">\n]
                     ~ qq[<script src="/rfl/bar.js?v=0" defer></script>]);
    my %local = (|@MOVED, 'theme', 'rfl').Set;
    copy-tree($from.add("learn/$_"), $to.add($_), -> $text, $ext {
        $ext eq 'js' ?? learn-js($text) !! learn-html($text, $tags, %local)
    }) for @MOVED;
}

sub learn-html(Str $html, Str $tags, %local --> Str) {
    $html
    .subst(/ '<script src="/theme/shell.js' <-["]>* '" defer></script>' /, $tags)
    .subst(/ '<html' (<-[>]>*) '>' /, -> $m {
        my $attrs = ~$m[0];
        $attrs.contains('class="') ?? '<html' ~ $attrs.subst('class="', 'class="rfl-shell ') ~ '>'
                                    !! "<html$attrs class=\"rfl-shell\">"
    })
    .subst(/ (<|w> ['href' | 'src' | 'action'] '="') '/' (<-["]>*) '"' /, -> $m {
        my $path = ~$m[1];
        my $first = $path.split(/<[/?#]>/)[0];
        !$path.chars || $first (elem) %local ?? ~$m !! "{$m[0]}https://raku.online/$path\""
    }, :g)
    .subst(/ '="https://raku.online/' (<[\w-]>+) <?before <[/"?#]>> /, -> $m {
        ~$m[0] (elem) %local ?? "=\"/$m[0]" !! ~$m
    }, :g)
}

#| The drills run the engine in a worker of their own, which loads it from
#| the root of the site it is on.
sub learn-js(Str $js --> Str) {
    $js.subst("importScripts('/rakujs.js'", "importScripts('https://raku.online/rakujs.js'")
       .subst("locateFile: p => '/' + p + V", "locateFile: p => 'https://raku.online/' + p + V")
}

sub copy-tree(IO::Path $src, IO::Path $dst, &edit) {
    mkdir $dst;
    for $src.dir -> $p {
        my $target = $dst.add($p.basename);
        if $p.d { copy-tree($p, $target, &edit) }
        elsif $p.extension eq 'html' | 'js' { $target.spurt: edit($p.slurp, $p.extension) }
        else { $p.copy($target) }
    }
}

#| Learn Raku's name, after its mark: RA over KU, as on the Learn Raku app.
sub brand(--> Str) {
    '<a class="rfl-brand" href="/"><span class="rfl-mark" aria-hidden="true">'
    ~ '<svg viewBox="0 0 100 100"><text x="50" y="46">RA</text><text x="50" y="85">KU</text></svg></span>'
    ~ '<span class="rfl-brand-name">Learn Raku</span></a>'
}

# ---------- Markdown to HTML ----------

#| A page's content, in one Custom HTML block, so that RakuPress does not
#| run wpautop over it.
sub wrap(Str $html --> Str) { "<!-- wp:html -->\n{$html.trim}\n<!-- /wp:html -->" }

#| Markdown to HTML. Code blocks, and any paragraph that is one of the keys
#| of %extra, are replaced by HTML written here.
sub body-html(Str $body, %extra? --> Str) {
    my @lines = $body.lines;
    my @blocks = code-blocks($body);
    my @chunks;     # { from, to, html }, in order
    my $i = 0;
    while $i < @blocks {
        my %b = @blocks[$i];
        my $next = @blocks[$i + 1];
        if %b<lang> ne 'output' && $next && $next<lang> eq 'output' && $next<adjacent> {
            @chunks.push: { from => %b<from>, to => $next<to>,
                            html => code-html(%b) ~ "\n" ~ output-html($next, error => 'error' (elem) %b<flags>) };
            $i += 2;
        }
        else {
            @chunks.push: { from => %b<from>, to => %b<to>,
                            html => %b<lang> eq 'output' ?? output-html(%b) !! code-html(%b) };
            $i++;
        }
    }

    my @md;
    my $line = 0;
    for @chunks.kv -> $n, %c {
        @md.append: @lines[$line ..^ %c<from>];
        @md.append: '', "RFLBLOCK$n", '';
        $line = %c<to> + 1;
    }
    @md.append: @lines[$line ..^ @lines];

    my %html = |%extra, |@chunks.kv.map(-> $n, %c { "RFLBLOCK$n" => %c<html> });
    my $html = pandoc(@md.join("\n"));
    $html = $html.subst("<p>{.key}\</p>", .value) for %html;
    $html.trim
}

sub code-html(%b --> Str) {
    my $code = esc(%b<code>.chomp);
    given %b<lang> {
        when 'raku' {
            'norun' (elem) %b<flags>
                ?? qq[<pre class="rfl-code"><code>$code\</code></pre>]
                !! qq[<pre data-raku>$code\</pre>]
        }
        default {
            qq[<pre class="rfl-code" data-lang="{%LANG{$_} // $_}"><code>$code\</code></pre>]
        }
    }
}

sub output-html(%o, Bool :$error --> Str) {
    my $pre = qq[<pre class="rfl-output{$error ?? ' rfl-error' !! ''}">{esc(%o<code>.chomp)}</pre>];
    'hidden' (elem) %o<flags>
        ?? qq[<details class="rfl-reveal"><summary>Show the output</summary>$pre\</details>]
        !! $pre
}

sub pandoc(Str $markdown --> Str) {
    state $n = 0;
    my $file = $*TMPDIR.add("rfl-build-$*PID-{++$n}.md");
    $file.spurt($markdown);
    my $proc = run 'pandoc', '--from=markdown-smart-tex_math_dollars-subscript-superscript-strikeout-implicit_figures-raw_tex',
                   '--to=html', '--wrap=none', ~$file, :out, :err;
    my $html = $proc.out.slurp(:close);
    my $err = $proc.err.slurp(:close);
    $file.unlink;
    die "pandoc failed: $err" if $proc.exitcode;
    $html
}

#| A front-matter string as HTML: `code` in backticks becomes <code>.
sub inline(Str $s --> Str) {
    $s.split('`').kv.map(-> $i, $part { $i %% 2 ?? esc($part) !! "<code>{esc($part)}</code>" }).join
}

#| The same string as plain text, for excerpts.
sub plain(Str $s --> Str) { $s.subst('`', '', :g) }

sub esc(Str $s --> Str) {
    $s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g).subst('"', '&quot;', :g)
}

# ---------- the database ----------

sub page-row(Int $id, Str $home, Str $title, Str $slug, Str $content, Str $excerpt, Str $date,
             Int :$parent = 0, Int :$order = 0) {
    my $local = "$date 08:00:00";
    my $gmt = sprintf('%s %02d:00:00', $date, 8 - $GMT-OFFSET);
    [$id, 1, $local, $gmt, $content, $title, $excerpt, 'publish', 'closed', 'closed', '',
     $slug, '', '', $local, $gmt, '', $parent, "$home/?page_id=$id", $order, 'page', '', 0]
}

#| The site's options: what WordPress would hold after setting it up by hand,
#| with Settings → Reading showing a static front page.
sub options(Str $home, Int $front --> List) {
    (
        siteurl              => $home,
        home                 => $home,
        blogname             => 'Learn Raku',
        blogdescription      => 'Six ways into Raku: lessons, drills, articles, programs, recipes and the rules',
        date_format          => 'F j, Y',
        time_format          => 'g:i a',
        gmt_offset           => ~$GMT-OFFSET,
        permalink_structure  => '/%year%/%monthnum%/%day%/%postname%/',
        show_on_front        => 'page',
        page_on_front        => ~$front,
        default_category     => '1',
        default_comment_status => 'closed',
        template             => 'twentysixteen',
        stylesheet           => 'twentysixteen',
        sticky_posts         => php-serialize([]),
        sidebars_widgets     => php-serialize({ 'sidebar-1' => [], 'sidebar-2' => [], 'sidebar-3' => [],
                                                array_version => 3 }),
    )
}

sub table-sql(Str $table, @rows --> Str) {
    my @cols = @(%COLUMNS{$table});
    "CREATE TABLE `$table` (\n" ~ @cols.map({ "  `$_` x,\n" }).join ~ ") ENGINE=InnoDB;\n"
        ~ @rows.map({ "INSERT INTO `$table` VALUES (" ~ .map(&sql-value).join(',') ~ ");\n" }).join
        ~ "\n"
}

sub sql-value($v --> Str) {
    return ~$v if $v ~~ Int;
    "'" ~ $v.Str.subst('\\', '\\\\', :g).subst("'", "\\'", :g).subst('"', '\\"', :g)
            .subst("\n", '\n', :g).subst("\r", '\r', :g) ~ "'"
}

# PHP's serialize(), for the options WordPress keeps serialized.
multi sub php-serialize(Int:D $i --> Str) { "i:$i;" }
multi sub php-serialize(Str:D $s --> Str) { 's:' ~ $s.encode.bytes ~ ':"' ~ $s ~ '";' }
multi sub php-serialize(Positional:D $a --> Str) {
    'a:' ~ $a.elems ~ ':{' ~ $a.kv.map(-> $k, $v { php-serialize($k) ~ php-serialize($v) }).join ~ '}'
}
multi sub php-serialize(Associative:D $h --> Str) {
    'a:' ~ $h.elems ~ ':{' ~ $h.sort(*.key).map({
        (.key ~~ / ^ \d+ $ / ?? php-serialize(.key.Int) !! php-serialize(.key)) ~ php-serialize(.value)
    }).join ~ '}'
}
