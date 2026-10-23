#!/bin/sh
# Build the site from the posts, import it into site/content.db, and serve it
# with RakuPress on http://127.0.0.1:8083. Arguments go to build-site.raku,
# for example --start=2026-11-02.
#
#   RAKUPRESS    a RakuPress checkout (default ~/rakupress)
#   WEBRAKU_LIB  the lib of a Webraku checkout of main (default ~/webraku/lib)
#   PORT         default 8083
set -e
cd "$(dirname "$0")/.."
RAKUPRESS="${RAKUPRESS:-$HOME/rakupress}"
WEBRAKU_LIB="${WEBRAKU_LIB:-$HOME/webraku/lib}"
PORT="${PORT:-8083}"

rakupp tools/build-site.raku --home="http://127.0.0.1:$PORT" "$@"
rakupp -I "$WEBRAKU_LIB" "$RAKUPRESS/bin/rakupress" import site site/site.sql
exec rakupp -I "$WEBRAKU_LIB" "$RAKUPRESS/bin/rakupress" serve site --port="$PORT"
