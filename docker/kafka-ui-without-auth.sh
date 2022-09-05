#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

KAFAKA0= localhost:9092
KAFAKA1= localhost:9092
KAFAKA2= localhost:9092

docker run -p 8080:8080 \
-e KAFKA_CLUSTERS_0_NAME=c0 \
-e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=$KAFAKA0 \
-e KAFKA_CLUSTERS_1_NAME=c1 \
-e KAFKA_CLUSTERS_1_BOOTSTRAPSERVERS=$KAFAKA1 \
-e KAFKA_CLUSTERS_2_NAME=c2 \
-e KAFKA_CLUSTERS_2_BOOTSTRAPSERVERS=$KAFAKA2 \
-d provectuslabs/kafka-ui:latest
