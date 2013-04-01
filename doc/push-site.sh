#! /bin/sh

set -eu

if [ "x$(git status --porcelain)" != "x" ]; then
  echo "error:  git repo has uncommited changes." >&2
  exit 1
fi

if [ ! -e .gh-pages ]; then
  git clone -b gh-pages https://github.com/kentonv/capnproto.git .gh-pages
  cd .gh-pages
else
  cd .gh-pages
  git pull
fi

if [ "x$(git status --porcelain)" != "x" ]; then
  echo "error:  .gh-pages is not clean." >&2
  exit 1
fi

cd ..

exit 0

rm -rf _site .gh-pages/*

jekyll --pygments --no-lsi --safe
cp -r _site/* .gh-pages

REV="$(git rev-parse HEAD)"

cd .gh-pages
git add *
git commit -m "site generated @$REV"

if [ "x$(git status --porcelain)" != "x" ]; then
  echo "error:  .gh-pages is not clean after commit." >&2
  exit 1
fi

echo -n "Push now? (y/N)"
read -n 1 YESNO
echo

if [ "$YESNO" == "y" ]; then
  git push
  cd ..
  rm -rf .gh-pages
else
  echo "Did not push.  You may want to delete .gh-pages."
fi
