#!/bin/bash -xe
SERVER=http://graylog-es.psamvp.hcs.harman.com:9200
LIST=$SERVER/_cat/indices?format=json
CURL="curl -k -s"
XARGS="xargs -t"

function patchMapping {
	set -x
	xargs -I INDEX $CURL -X PUT "http://graylog-es.psamvp.hcs.harman.com:9200/INDEX" -H "Content-Type: application/json" -d '{"settings": { "index.mapping.ignore_malformed": true }}'
#	$CURL -X PUT "http://graylog-es.psamvp.hcs.harman.com:9200/zeebe23x-record_job_0.23.1_2020-06-02?include_type_name=false" -H "Content-Type: application/json" -d @x
#	xargs -I INDEX $CURL -X PUT "http://graylog-es.psamvp.hcs.harman.com:9200/INDEX?include_type_name=false" -H "Content-Type: application/json" -d @x
}

function indices {
	$CURL "$LIST" | jq -r ".[].index" | grep "${1:-.}"
}

function cluster {
	$CURL "$SERVER/_cluster/settings" | jq .
}

function ingest {
	$CURL "$SERVER/_nodes" | jq ".nodes | to_entries[] | .value.ingest" 
}

function nodes {
	$CURL "$SERVER/_nodes" | jq .
}

function pipeline {
	$CURL "$SERVER/_ingest/pipeline" | jq .
}

function cluster-state {
	$XARGS -I INDEX $CURL "$SERVER/_cluster/state/INDEX" | jq .
}

function settings {
	xargs -I INDEX $CURL "$SERVER/INDEX/_settings" | jq .
}

function mapping {
	xargs -I INDEX $CURL "$SERVER/INDEX/_mapping" | jq .
}

function delete {
	$XARGS -I INDEX $CURL -X POST "$SERVER/INDEX/_delete_by_query" -H 'Content-Type: application/json' -d '{"query":{"query_string":{ "query": "'${1:-*}'"}}}' | jq . 
}

function query {
	$XARGS -I INDEX $CURL -X POST "$SERVER/INDEX/_search" -H 'Content-Type: application/json' -d '{"query":{"query_string":{ "query": "'${1:-*}'"}}}' | jq . 
}

#function delete {
#	set -x
#	tr '\n' ' ' | sed -e "s/ /,/g" | sed -e "s#^#$SERVER/#" | xargs $CURL -X DELETE
#}

eval $1
