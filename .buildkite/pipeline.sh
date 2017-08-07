#!/bin/bash


get_previous_commit() {
	previous_build="$(($BUILDKITE_BUILD_NUMBER - 1))"

	response=`curl "https://api.buildkite.com/v2/organizations/newvoicemedia/pipelines/monotest/builds/${previous_build}?access_token=477f1c395119a00cf113653a41f6e09d1cdda979"`

	previous_commit=`echo $response | jq '.commit'`

	return previous_commit
}

create_pipeline() {
	proj=$1
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

# find the directory that changed

previous_build="$(($BUILDKITE_BUILD_NUMBER - 1))"

response=`curl "https://api.buildkite.com/v2/organizations/newvoicemedia/pipelines/monotest/builds/${previous_build}?access_token=477f1c395119a00cf113653a41f6e09d1cdda979"`

#echo "$response"

previous_commit=`echo $response | jq '.commit'`

echo $previous_commit
previous_commit=`sed -e 's/^"//' -e 's/"$//' <<<"$previous_commit"`

#diffs=`git diff --name-only 6344963338f16576ea885589f7792637f1f4dde7 732054c8317b27e7b8e4e31cb23159fbaf5fdfd8 `

diffs=`git diff --name-only ${previous_commit} ${BUILDKITE_COMMIT} `
echo "$diffs"

create_pipeline "Foo"

