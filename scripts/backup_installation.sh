#!/bin/sh
WIKI_BASE_PATH="/var/www/html/w"
cd $WIKI_BASE_PATH
git config --global user.email "support@hallowelt.com"
git config --global user.name "HalloWelt! GmbH"
find $WIKI_BASE_PATH -name '.git' -exec rm -R {} \;
git init
git checkout -b bluespice_free
git add -A; git commit -m 'init bluespice free'
