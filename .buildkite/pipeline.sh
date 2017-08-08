#!/bin/bash

create_pipeline() {
	local proj=$1
	# begin the pipeline.yml file
	echo "steps:"
	echo "  - trigger: $proj"
	echo "    build:"
	echo "      branch: $BUILDKITE_BRANCH"
	echo "      commit: $BUILDKITE_COMMIT"
	echo "      message: $BUILDKITE_MESSAGE"	
}


BUILDKITE_BRANCH="branch"
BUILDKITE_COMMIT="732054c8317b27e7b8e4e31cb23159fbaf5fdfd8"
BUILDKITE_MESSAGE="message"
BUILDKITE_BUILD_NUMBER="10"


# exit immediately on failure, or if an undefined variable is used
set -eu

# get the previous commit, so we can do a diff

previous_build="$(($BUILDKITE_BUILD_NUMBER - 1))"

response=`curl "https://api.buildkite.com/v2/organizations/newvoicemedia/pipelines/monotest/builds/${previous_build}?access_token=477f1c395119a00cf113653a41f6e09d1cdda979"`

previous_commit=`echo $response | jq '.commit'`

# strip quotes
previous_commit=`sed -e 's/^"//' -e 's/"$//' <<<"$previous_commit"`

# diff to get the changed files
#diffs=`git diff --name-only ${previous_commit} ${BUILDKITE_COMMIT} `
#echo "$diffs"

array=`git diff --name-only ${previous_commit} ${BUILDKITE_COMMIT} | sort -u | awk 'BEGIN {FS="/"} {print $1}' | uniq`
#printf -- "%s\n" "${array[@]}"
#printf "\n"
for element in $array
do
    echo $element
done
create_pipeline "Foo"

