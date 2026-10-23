#!/bin/sh
# Publish learn.raku.online: check every example, build the site for its real
# address, copy it to the RakuPress server, and start the site on its new
# database. The site stops for the few seconds the swap takes: SQLite keeps
# write-ahead files beside a database, and a running instance's would not
# belong to the new one. The blogs on the same server are not touched.
#
#   SERVER=<user>@<server> tools/publish.sh
#
# The site lives whole in /srv/rakupress/data/sites/learn.raku.online on the
# server, outside the code RakuPress's own tools/deploy.sh replaces; its
# services, nginx file and certificate come from that repository (deploy/).
#
#   RAKU_ONLINE  the raku.online checkout with the learning sections in learn/
#   RAKUPRESS    a RakuPress checkout (default ~/rakupress)
#   WEBRAKU_LIB  the lib of a Webraku checkout of main (default ~/webraku/lib)
set -eu
: "${SERVER:?set SERVER=<user>@<the RakuPress server>}"
cd "$(dirname "$0")/.."
RAKUPRESS="${RAKUPRESS:-$HOME/rakupress}"
WEBRAKU_LIB="${WEBRAKU_LIB:-$HOME/webraku/lib}"
HOME_URL=https://learn.raku.online
DIR=/srv/rakupress/data/sites/learn.raku.online
SSH="ssh -o BatchMode=yes"

rakupp tools/check.raku
rakupp tools/build-site.raku --home="$HOME_URL"
rakupp -I "$WEBRAKU_LIB" "$RAKUPRESS/bin/rakupress" import site site/site.sql

# The import leaves part of the database in its write-ahead file, so what is
# copied is a backup: one self-contained file.
rm -f site/publish.db
sqlite3 site/content.db ".backup site/publish.db"

# Everything but the database, which is swapped below; uploads are the
# server's own.
$SSH "$SERVER" "mkdir -p $DIR"
rsync -a --delete -e "$SSH" \
    --exclude=/site.sql --exclude='/content.db*' --exclude=/publish.db --exclude=/uploads/ \
    site/ "$SERVER:$DIR/"
rsync -a -e "$SSH" site/publish.db "$SERVER:$DIR/content.db.new"
rm -f site/publish.db

$SSH "$SERVER" sh -s <<EOF
set -eu
systemctl stop rakupress@learn.raku.online.service rakupress@learn.raku.online-standby.service
cd $DIR
rm -f content.db-wal content.db-shm
mv content.db.new content.db
chown -R rakupress:rakupress $DIR
for unit in learn.raku.online-standby learn.raku.online; do
    systemctl enable "rakupress@\$unit.service" >/dev/null 2>&1
    systemctl start "rakupress@\$unit.service"
    port=\$(sed -n 's/^PORT=//p' "/etc/rakupress/\$unit.env")
    i=0
    until curl -sf -o /dev/null -H 'Host: learn.raku.online' -H 'X-Forwarded-Proto: https' "http://127.0.0.1:\$port/"; do
        i=\$((i + 1))
        [ \$i -lt 120 ] || { echo "rakupress@\$unit did not answer on :\$port within a minute" >&2; exit 1; }
        sleep 0.5
    done
    echo "rakupress@\$unit answers on :\$port"
done
EOF
echo "published $HOME_URL"
echo "(the local site now has the real address in it: run tools/serve.sh to build it for this machine again)"
