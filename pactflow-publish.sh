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
    --participant-version-number=*)
      participant_version_number="${1#*=}"
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
if [[ -z "$participant_version_number" ]]; then
    echo "Must provide --participant-version-number" 1>&2
    exit 1
fi


#
# Report to Pactflow
#
pact_json_files=$(ls $pact_json_folder/*.json)
echo "Found files:"
echo $pact_json_files
echo
for pact_json_file in $pact_json_files
do
  echo "Processing $pact_json_file file..."
  json=`cat $pact_json_file`
  consumer_name=`echo $json | jq -r '.consumer.name'`
  provider_name=`echo $json | jq -r '.provider.name'`
  content_base64=`echo $json | base64`
  content_base64=`echo $content_base64 | sed 's/[[:space:]]//g'`
  branch=$(git symbolic-ref --short HEAD)

  read -r -d '' publish_content << EndOfMessage
{
  "pacticipantName": "$consumer_name",
  "pacticipantVersionNumber": "$participant_version_number",
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
    -u "$username:$password" \
    $pactflow_broker_url \
    -H "Content-Type: application/json" \
    --data-binary @$publish_content_file
done