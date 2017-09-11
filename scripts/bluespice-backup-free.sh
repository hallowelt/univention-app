#!/bin/sh

git config --global user.email "support@hallowelt.com"
git config --global user.name "HalloWelt! GmbH"
#find $BLUESPICE_WEBROOT -name '.git' -exec rm -R {} \;
cd $BLUESPICE_WEBROOT
if [ ! -f .git ]; then
  git init
  git checkout -B bluespice_free && git add -A && git commit -m 'save bluespice free'
fi
