#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

VERSION=7.1.1
ZK_BASE_DIR=/data/zookeeper
KAFKA_BASE_DIR=/data/kafka
ZK0_DATA=${ZK_BASE_DIR}/zk0/data
ZK0_LOG=${ZK_BASE_DIR}/zk0/log
KAFKA0_DATA=${KAFKA_BASE_DIR}/kafka0/data
KAFKA1_DATA=${KAFKA_BASE_DIR}/kafka1/data
KAFKA2_DATA=${KAFKA_BASE_DIR}/kafka2/data
HOST_PUBLIC_IP=192.168.2.44

if [ $# -ge 1 ]; then
  if [ $1 = clean ]; then
    sudo docker rm -f kafka0 kafka1 kafka2 zookeeper0 kafka-ui jaeger
    sudo rm -rf $ZK_BASE_DIR
    sudo rm -rf $KAFKA_BASE_DIR
    exit 0
  elif [ $1 = restart ]; then
    sudo docker rm -f kafka0 kafka1 kafka2 zookeeper0 kafka-ui jaeger
    sudo rm -rf $ZK_BASE_DIR
    sudo rm -rf $KAFKA_BASE_DIR
  fi
fi

mkdir -p $ZK_BASE_DIR
mkdir -p $KAFKA_BASE_DIR

cat >/tmp/docker-compose.yml <<EOF
---
version: "3"
services:
  zookeeper0:
    image: confluentinc/cp-zookeeper:${VERSION}
    container_name: zookeeper0
    user: root
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    volumes:
      - ${ZK0_DATA}:/var/lib/zookeeper/data
      - ${ZK0_LOG}:/var/lib/zookeeper/log
  kafka0:
    image: confluentinc/cp-kafka:${VERSION}
    container_name: kafka0
    user: root
    depends_on:
      - zookeeper0
    ports:
      - 9092:9092
    environment:
      KAFKA_BROKER_ID: 0
      KAFKA_ZOOKEEPER_CONNECT: zookeeper0:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka0:29092,PLAINTEXT_HOST://${HOST_PUBLIC_IP}:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    volumes:
      - ${KAFKA0_DATA}:/var/lib/kafka/data
  kafka1:
    image: confluentinc/cp-kafka:${VERSION}
    container_name: kafka1
    user: root
    depends_on:
      - zookeeper0
    ports:
      - 9093:9093
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper0:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka1:29093,PLAINTEXT_HOST://${HOST_PUBLIC_IP}:9093
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    volumes:
      - ${KAFKA1_DATA}:/var/lib/kafka/data
  kafka2:
    image: confluentinc/cp-kafka:${VERSION}
    container_name: kafka2
    user: root
    depends_on:
      - zookeeper0
    ports:
      - 9094:9094
    environment:
      KAFKA_BROKER_ID: 2
      KAFKA_ZOOKEEPER_CONNECT: zookeeper0:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka2:29094,PLAINTEXT_HOST://${HOST_PUBLIC_IP}:9094
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    volumes:
      - ${KAFKA2_DATA}:/var/lib/kafka/data
  kafka-ui:
    image: provectuslabs/kafka-ui:v0.4.0
    container_name: kafka-ui
    ports:
      - "8080:8080"
    depends_on:
      - kafka0,kafka1,kafka2
    environment:
      KAFKA_CLUSTERS_0_NAME: c0
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka0:29092
      KAFKA_CLUSTERS_1_NAME: c1
      KAFKA_CLUSTERS_1_BOOTSTRAPSERVERS: kafka1:29093
      KAFKA_CLUSTERS_2_NAME: c2
      KAFKA_CLUSTERS_2_BOOTSTRAPSERVERS: kafka2:29094
EOF

if [ $# -ge 1 ] && [ $1 = "dockerfile" ]; then
  echo "docker file generated: /tmp/docker-compose.yml"
  exit 0
fi

sudo docker-compose -f /tmp/docker-compose.yml up -d
rm /tmp/docker-compose.yml
