# ksm-sample
#
# Copyright (c) 2015-Present Pivotal Software, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import time

import influxdb
import requests

# https://www.datadoghq.com/blog/rabbitmq-monitoring/
influxdb_url = os.environ['INFLUXDB_URL']
influxdb_port = os.environ['INFLUXDB_PORT']
influxdb_username = os.environ['INFLUXDB_USERNAME']
influxdb_password = os.environ['INFLUXDB_PASSWORD']

metrics_host = os.environ['METRICS_HOST']
instance_tag = os.environ['INSTANCE_TAG']


def parse(text):
    metrics = []
    for line in text.splitlines():
        if not line.startswith("#"):
            key, value = line.split(" ")
            metric = {
                "measurement": key,
                "tags": {
                    "instance": instance_tag
                },
                "fields": {
                    "value": float(value)
                }
            }
            metrics.append(metric)
    return metrics


def emit(points):
    client = influxdb.InfluxDBClient(
        influxdb_url, influxdb_port, influxdb_username, influxdb_password, 'metrics'
    )
    print(points)
    client.write_points(points)


def query():
    response = requests.get(metrics_host + ":9419/metrics")
    if response.status_code == 200:
        parsed = parse(response.text)
        return parsed
    else:
        print("Failure", response.status_code)


# metrics_values = query()
# emit(metrics_values)

forever = True
while forever:
    time.sleep(2)
    try:
        metrics_values = query()
        emit(metrics_values)
    except Exception as e:
        print(e)