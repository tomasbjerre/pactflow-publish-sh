# Pactflow Publish SH

[![NPM](https://img.shields.io/npm/v/pactflow-publish-sh.svg?style=flat-square) ](https://www.npmjs.com/package/pactflow-publish-sh)

This is a shell script that can publish Pact JSON to a [Pactflow broker](https://pactflow.io/) using `curl`.

You may want to use the shell script as is, or use it via `npx` and get it from `npm`.

## Example

You may get the version like this:

```bash
current_version=$(npx git-changelog-command-line \
  --patch-version-pattern "^fix.*" \
  --print-current-version)
git_hash=`git rev-parse --short HEAD`
participant_version_number="$current_version-$git_hash"
```

Using just the shell script:

```bash
./pactflow-publish.sh \
 --username=dXfltyFMgNOFZAxr8io9wJ37iUpY42M \
 --password=O5AIZWxelWbLvqMd8PkAVycBJh2Psyg1 \
 --pactflow-broker-url=https://test.pactflow.io/contracts/publish \
 --build-url=http://whatever/ \
 --pact-json-folder=example-pact-json \
 --participant-version-number=$participant_version_number
```

Or with `npx` via `npm`:

```bash
npx pactflow-publish-sh \
 --username=dXfltyFMgNOFZAxr8io9wJ37iUpY42M \
 --password=O5AIZWxelWbLvqMd8PkAVycBJh2Psyg1 \
 --pactflow-broker-url=https://test.pactflow.io/contracts/publish \
 --build-url=http://whatever/ \
 --pact-json-folder=example-pact-json \
 --participant-version-number=$participant_version_number
```

You can login to the broker at https://test.pactflow.io/ with username `dXfltyFMgNOFZAxr8io9wJ37iUpY42M` and password `O5AIZWxelWbLvqMd8PkAVycBJh2Psyg1`.
