#!/usr/bin/env bash

#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd ${DIR}

pushd prometheus-operator
helm dependency build
popd

helm package rabbitmq-exporter-metrics

mkdir -p rabbitmq/charts
mv rabbitmq-exporter-metrics-*.tgz rabbitmq/charts/

helm package prometheus-operator
helm package rabbitmq
