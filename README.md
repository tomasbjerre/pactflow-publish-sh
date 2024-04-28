# Wiremock NPM

[![NPM](https://img.shields.io/npm/v/pactflow-publish-sh.svg?style=flat-square) ](https://www.npmjs.com/package/pactflow-publish-sh)

This is a shell script that can publish Pact JSON to a [Pactflow broker](https://test.pactflow.io/).

You may want to use the shell script as is, or use it via `npx` and get it from `npm`.

## Example

```bash
./pactflow-publish-sh \
 --username dXfltyFMgNOFZAxr8io9wJ37iUpY42M \
 --password O5AIZWxelWbLvqMd8PkAVycBJh2Psyg1 \
 --pactflow-broker-url https://test.pactflow.io/contracts/publish \
 --build-url build_url http://whatever/
 --pact-json-folder example-pact-json/*.json
```

## Example with NPX

```bash
npx pactflow-publish-sh \
 --username dXfltyFMgNOFZAxr8io9wJ37iUpY42M \
 --password O5AIZWxelWbLvqMd8PkAVycBJh2Psyg1 \
 --pactflow-broker-url https://test.pactflow.io/contracts/publish \
 --build-url build_url http://whatever/
 --pact-json-folder example-pact-json/*.json
```
