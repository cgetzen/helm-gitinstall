#!/bin/bash

# helm gitinstall https://github.com/helm/charts/stable/aerospike -b featureBranch

# helm git install https://github.com/helm/charts/stable/aerospike -b=master -n test
# helm git upgrade test https://github.com/helm/charts/stable/aerospike -b=master --set=id=a


DEBUG=false
ACTION=$1; shift
PASS_PARAMS=""

case $ACTION in
    upgrade)
    PRE_PASS_PARAMS=$1; shift
    CHART_URL=$1; shift
    ;;
    install)
    CHART_URL=$1; shift
    ;;
    *)
    echo "command not available"
    exit 1
    ;;
esac

for i in "$@"
do
case $i in
    -b=*|--branch=*)
    BRANCH="${i#*=}"
    shift # past argument=value
    ;;
    *)
    PASS_PARAMS="$PASS_PARAMS $i"
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

eval "$(which helm) $ACTION $PRE_PASS_PARAMS $TMP/tmp $PASS_PARAMS"

rm -rf $TMP
