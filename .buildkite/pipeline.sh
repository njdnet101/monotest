#!/bin/bash

detect_changed_files_and_folders() {
  echo "Detecting Changes For This Build"

  #SHIPPABLE_COMMIT_RANGE is an Environment Variable which
  #gives the range between the last successful Commit ID and
  #the  current Commit ID as <COMMIT_ID_1>...<COMMIT_ID_2>

  array=`git diff --name-only $SHIPPABLE_COMMIT_RANGE | sort -u | awk 'BEGIN {FS="/"} {print $1}' | uniq`
  printf -- "%s\n" "${array[@]}"
  printf "\n"
  for element in $array
  do
    build_and_push_changed_folder $element
  done
}


BUILDKITE_BRANCH="branch"
BUILDKITE_COMMIT="732054c8317b27e7b8e4e31cb23159fbaf5fdfd8"
BUILDKITE_MESSAGE="message"
BUILDKITE_BUILD_NUMBER="10"


# exit immediately on failure, or if an undefined variable is used
set -eu

# find the directory that changed

# begin the pipeline.yml file
echo "steps:"
echo "  - trigger: " #${projdir}
echo "    build:"
echo "      branch: $BUILDKITE_BRANCH"
echo "      commit: $BUILDKITE_COMMIT"
echo "      message: $BUILDKITE_MESSAGE"


echo "$BUILDKITE_BUILD_NUMBER"
LAST_BUILD="$(($BUILDKITE_BUILD_NUMBER - 1))"
echo "$LAST_BUILD"


response=`curl "https://api.buildkite.com/v2/organizations/newvoicemedia/pipelines/monotest/builds/${LAST_BUILD}?access_token=477f1c395119a00cf113653a41f6e09d1cdda979"`

#echo "$response"

previous_commit=`echo $response | jq '.commit'`

echo $previous_commit
previous_commit=`sed -e 's/^"//' -e 's/"$//' <<<"$previous_commit"`

#diffs=`git diff --name-only 6344963338f16576ea885589f7792637f1f4dde7 732054c8317b27e7b8e4e31cb23159fbaf5fdfd8 `
#echo "$diffs"

diffs=`git diff --name-only ${previous_commit} ${BUILDKITE_COMMIT} `
echo "$diffs"



