#!/bin/bash

DEBUG=false
CHART_URL=$1
PASS_PARAMS=""

for i in "$@"
do
case $i in
    -b=*|--branch=*)
    BRANCH="${i#*=}"
    shift # past argument=value
    ;;
    *)
    if [ "$i" != "$CHART_URL" ]; then
      PASS_PARAMS="$PASS_PARAMS $i"
    fi
    ;;
esac
done

if [ -z "$BRANCH" ]; then
  BRANCH="master"
fi

REPO=$(echo $CHART_URL | sed -E 's (https://[^/]*/[^/]*/[^/]*).* \1 ')
REPO_PATH=$(echo $CHART_URL | sed -E 's https://[^/]*/[^/]*/[^/]*/  ')
SVN=$REPO.git/branches/$BRANCH/$REPO_PATH
TMP=$(mktemp -d)
svn export $SVN $TMP/tmp > /dev/null

if [ $DEBUG = true ]; then
  echo chart url: $CHART_URL
  echo repo: $REPO
  echo repo path: $REPO_PATH
  echo branch: $BRANCH
  echo SVN_url: $SVN
  echo params: $PASS_PARAMS
  echo TMP: $TMP
fi

RUN="$(which helm) install $TMP/tmp $PASS_PARAMS"
eval "$RUN"

rm -rf $TMP
