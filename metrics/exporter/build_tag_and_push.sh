#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd ${DIR}

docker build . -t cfplatformeng/rabbitmq-exporter-metrics
docker push cfplatformeng/rabbitmq-exporter-metrics

