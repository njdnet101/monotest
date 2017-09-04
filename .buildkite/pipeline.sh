#!/bin/bash

create_pipeline() {
	local proj=$1

	echo "  - trigger: $proj"
	echo "    async: true"
	echo "    build:"
	echo "      branch: $BUILDKITE_BRANCH"
	echo "      commit: $BUILDKITE_COMMIT"
	echo "      message: $BUILDKITE_MESSAGE"	
}


# exit immediately on failure, or if an undefined variable is used
set -eu

BUILDKITE_BRANCH="master"
BUILDKITE_COMMIT="33304c71322ccb2b2ff656b382ab8018900ade0e"
BUILDKITE_MESSAGE="foo"
BUILDKITE_BUILD_NUMBER=40
ACCESS_TOKEN="477f1c395119a00cf113653a41f6e09d1cdda979"

# get the previous commit, so we can do a diff

previous_build="$(($BUILDKITE_BUILD_NUMBER - 1))"

response=$(curl -s "https://api.buildkite.com/v2/organizations/newvoicemedia/pipelines/monotest/builds/${previous_build}?access_token=${ACCESS_TOKEN}")

previous_commit=$(echo $response | jq '.commit')

# strip quotes
previous_commit=$(sed -e 's/^"//' -e 's/"$//' <<<"$previous_commit")

# diff to get the changed files, and filter for just the top level directories
# TODO: filter for only those directories contaning a .buildkite subdirectory

ignore='.buildkite'

#array=`git diff --name-only ${previous_commit} ${BUILDKITE_COMMIT} | sort -u | uniq`
array=$(git diff --name-only ${previous_commit} ${BUILDKITE_COMMIT} | sort -u | awk 'BEGIN {FS="/"} {print $1}' | uniq)

echo "${array}"

farray=$(echo "${ignore}" | egrep -v "${array}")

echo "steps:"
for element in $farray
do
	create_pipeline $element

#	echo "  - command: 'echo ${element}'"

done
echo "  - label: \"Done\""
echo "    command: 'echo \"Done\"'"
