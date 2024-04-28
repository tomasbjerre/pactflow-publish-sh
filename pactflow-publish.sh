#!/bin/bash

#
# Parse arguments
#
# https://unix.stackexchange.com/questions/129391/passing-named-arguments-to-shell-scripts
#
while [ $# -gt 0 ]; do
  case "$1" in
    --username=*)
      username="${1#*=}"
      ;;
    --password=*)
      password="${1#*=}"
      ;;
    --pactflow-broker-url=*)
      pactflow_broker_url="${1#*=}"
      ;;
    --build-url=*)
      build_url="${1#*=}"
      ;;
    --pact-json-folder=*)
      pact_json_folder="${1#*=}"
      ;;
    *)
      printf "Invalid argument: $1"
      exit 1
  esac
  shift
done

if [[ -z "$username" ]]; then
    echo "Must provide --username" 1>&2
    exit 1
fi
if [[ -z "$password" ]]; then
    echo "Must provide --password" 1>&2
    exit 1
fi
if [[ -z "$pactflow_broker_url" ]]; then
    echo "Must provide --pactflow-broker-url" 1>&2
    exit 1
fi
if [[ -z "$build_url" ]]; then
    echo "Must provide --build-url" 1>&2
    exit 1
fi
if [[ -z "$pact_json_folder" ]]; then
    echo "Must provide --pact-json-folder" 1>&2
    exit 1
fi

pact_user=dXfltyFMgNOFZAxr8io9wJ37iUpY42M
pact_password=O5AIZWxelWbLvqMd8PkAVycBJh2Psyg1 # This is not a mistake, these credentials are publicly available
pactflow_broker_url=https://test.pactflow.io/contracts/publish
build_url=https://ci/builds/1234
pact_json_folder="wiremock-pact-example-springboot-app/src/test/resources/pact-json/*.json"

#
# Report to Pactflow
#
for pact_json_file in $pact_json_folder
do
  echo "Processing $pact_json_file file..."
  json=`cat $pact_json_file`
  current_version=$(npx git-changelog-command-line \
  --patch-version-pattern "^fix.*" \
  --print-current-version)
  git_hash=`git rev-parse --short HEAD`
  pacticipant_version_number="$current_version-$git_hash"
  consumer_name=`echo $json | jq -r '.consumer.name'`
  provider_name=`echo $json | jq -r '.provider.name'`
  content_base64=`echo $json | base64`
  content_base64=`echo $content_base64 | sed 's/[[:space:]]//g'`
  branch=$(git symbolic-ref --short HEAD)

  read -r -d '' publish_content << EndOfMessage
{
  "pacticipantName": "$consumer_name",
  "pacticipantVersionNumber": "$pacticipant_version_number",
  "branch": "$branch",
  "tags": [
    "$branch"
  ],
  "buildUrl": "$build_url",
  "contracts": [
    {
      "consumerName": "$consumer_name",
      "providerName": "$provider_name",
      "specification": "pact",
      "contentType": "application/json",
      "content": "$content_base64"
    }
  ]
}
EndOfMessage

  echo Publishing:
  echo
  echo $publish_content
  echo
  publish_content_file=$(mktemp)
  echo $publish_content > $publish_content_file

  curl -v -X POST \
    -u "$pact_user:$pact_password" \
    $pactflow_broker_url \
    -H "Content-Type: application/json" \
    --data-binary @$publish_content_file
done