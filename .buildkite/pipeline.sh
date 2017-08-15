#!/bin/bash

create_pipeline() {
	local proj=$1

	echo "  - trigger: $proj"
	echo "    build:"
	echo "      branch: $BUILDKITE_BRANCH"
	echo "      commit: $BUILDKITE_COMMIT"
	echo "      message: $BUILDKITE_MESSAGE"	
}


# exit immediately on failure, or if an undefined variable is used
set -eu

# get the previous commit, so we can do a diff

previous_build="$(($BUILDKITE_BUILD_NUMBER - 1))"

response=$(curl -s "https://api.buildkite.com/v2/organizations/newvoicemedia/pipelines/monotest/builds/${previous_build}?access_token=${ACCESS_TOKEN}")

previous_commit=$(echo $response | jq '.commit')

# strip quotes
previous_commit=$(sed -e 's/^"//' -e 's/"$//' <<<"$previous_commit")

# diff to get the changed files, and filter for just the top level directories
# TODO: filter for only those directories contaning a .buildkite subdirectory

#array=`git diff --name-only ${previous_commit} ${BUILDKITE_COMMIT} | sort -u | uniq`
array=$(git diff --name-only ${previous_commit} ${BUILDKITE_COMMIT} | sort -u | awk 'BEGIN {FS="/"} {print $1}' | uniq)

echo "steps:"
for element in $array
do
    #echo $element
    create_pipeline $element
done
echo "  - label: \"Done\""
echo "    command: 'echo \"Done\"'"
