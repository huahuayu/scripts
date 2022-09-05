#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

BASE=/data/jaeger
mkdir -p $BASE
cd $BASE

if [ $# -ge 1 ] && [ $1 = "clean" ]; then
    sudo docker-compose down 2>/dev/null
    sudo rm -rf esdata01 esdata02 esdata03 kibanadata 2>/dev/null
    rm .env docker-compose.yml nginx_query.conf nginx_collector.conf 2>/dev/null
    exit 0
fi

mkdir -p esdata01 esdata02 esdata03 kibanadata
chown 1000:1000 -R esdata01 esdata02 esdata03 kibanadata

cat >.env <<'EOF'
# Password for the 'elastic' user (at least 6 characters)
ELASTIC_PASSWORD=passwd

# Password for the 'kibana_system' user (at least 6 characters)
KIBANA_PASSWORD=passwd

# Version of Elastic products
STACK_VERSION=7.17.5

# Set the cluster name
CLUSTER_NAME=jeager-cluster

# Set to 'basic' or 'trial' to automatically start the 30-day trial
LICENSE=basic
#LICENSE=trial

# Port to expose Elasticsearch HTTP API to the host
ES_PORT=9200

# Port to expose Kibana to the host
KIBANA_PORT=5601

# Increase or decrease based on the available host memory (in bytes)
MEM_LIMIT=4294967296

KAFKA_BROKER=b-1.c0.bajbl0.c22.kafka.us-east-1.amazonaws.com:9092,b-2.c0.bajbl0.c22.kafka.us-east-1.amazonaws.com:9092,b-3.c0.bajbl0.c22.kafka.us-east-1.amazonaws.com:9092
EOF

cat >nginx_query.conf <<'EOF'
upstream jaeger_query {
    server query01:16686;
    server query02:16686;
    server query03:16686;
}

server {
    listen          16686;
    server_name     0.0.0.0;

    location / {
      proxy_pass  http://jaeger_query;
    }
}
EOF

cat >nginx_collector.conf <<'EOF'
upstream jaeger_collector {
    server collector01:4318;
    server collector02:4318;
    server collector03:4318;
}

server {
    listen          4318;
    server_name     0.0.0.0;
    location / {
        proxy_pass      http://jaeger_collector;
    }
}
EOF

cat >docker-compose.yml <<'EOF'
version: "2.2"

services:
  es01:
    image: docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}
    volumes:
      - ./esdata01:/usr/share/elasticsearch/data
    ports:
      - 9200
    restart: always
    environment:
      - node.name=es01
      - cluster.name=${CLUSTER_NAME}
      - cluster.initial_master_nodes=es01,es02,es03
      - discovery.seed_hosts=es02,es03
      - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
      - bootstrap.memory_lock=true
      - xpack.security.enabled=false
      - xpack.license.self_generated.type=${LICENSE}
    mem_limit: ${MEM_LIMIT}
    ulimits:
      memlock:
        soft: -1
        hard: -1
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "curl -s http://localhost:9200 | grep 'You Know, for Search'",
        ]
      interval: 10s
      timeout: 10s
      retries: 120

  es02:
    depends_on:
      - es01
    image: docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}
    volumes:
      - ./esdata02:/usr/share/elasticsearch/data
    ports:
      - 9200
    restart: always
    environment:
      - node.name=es02
      - cluster.name=${CLUSTER_NAME}
      - cluster.initial_master_nodes=es01,es02,es03
      - discovery.seed_hosts=es01,es03
      - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
      - bootstrap.memory_lock=true
      - xpack.security.enabled=false
      - xpack.license.self_generated.type=${LICENSE}
    mem_limit: ${MEM_LIMIT}
    ulimits:
      memlock:
        soft: -1
        hard: -1
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "curl -s http://localhost:9200 | grep 'You Know, for Search'",
        ]
      interval: 10s
      timeout: 10s
      retries: 120

  es03:
    depends_on:
      - es02
    image: docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}
    volumes:
      - ./esdata03:/usr/share/elasticsearch/data
    ports:
      - 9200
    restart: always
    environment:
      - node.name=es03
      - cluster.name=${CLUSTER_NAME}
      - cluster.initial_master_nodes=es01,es02,es03
      - discovery.seed_hosts=es01,es02
      - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
      - bootstrap.memory_lock=true
      - xpack.security.enabled=false
      - xpack.license.self_generated.type=${LICENSE}
    mem_limit: ${MEM_LIMIT}
    ulimits:
      memlock:
        soft: -1
        hard: -1
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "curl -s http://localhost:9200 | grep 'You Know, for Search'",
        ]
      interval: 10s
      timeout: 10s
      retries: 120

  kibana:
    depends_on:
      es01:
        condition: service_healthy
      es02:
        condition: service_healthy
      es03:
        condition: service_healthy
    image: docker.elastic.co/kibana/kibana:${STACK_VERSION}
    volumes:
      - ./kibanadata:/usr/share/kibana/data
    ports:
      - ${KIBANA_PORT}:5601
    restart: always
    environment:
      - SERVERNAME=kibana
      - ELASTICSEARCH_HOSTS=["http://es01:9200","http://es02:9200","http://es03:9200"]
      - ELASTICSEARCH_USERNAME=kibana_system
      - ELASTICSEARCH_PASSWORD=${KIBANA_PASSWORD}
    mem_limit: ${MEM_LIMIT}
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "curl -s -I http://localhost:5601 | grep 'HTTP/1.1 302 Found'",
        ]
      interval: 10s
      timeout: 10s
      retries: 120

  collector01:
    depends_on:
      es01:
        condition: service_healthy
      es02:
        condition: service_healthy
      es03:
        condition: service_healthy
    image: jaegertracing/jaeger-collector:1.36
    ports:
      - 9411
      - 14250
      - 14268
      - 14269
      - 4318
      - 4317
    restart: always
    environment:
      - COLLECTOR_OTLP_ENABLED=true
      - SPAN_STORAGE_TYPE=kafka
      - KAFKA_PRODUCER_BROKERS=${KAFKA_BROKER}

  collector02:
    depends_on:
      es01:
        condition: service_healthy
      es02:
        condition: service_healthy
      es03:
        condition: service_healthy
    image: jaegertracing/jaeger-collector:1.36
    ports:
      - 9411
      - 14250
      - 14268
      - 14269
      - 4318
      - 4317
    restart: always
    environment:
      - COLLECTOR_OTLP_ENABLED=true
      - SPAN_STORAGE_TYPE=kafka
      - KAFKA_PRODUCER_BROKERS=${KAFKA_BROKER}

  collector03:
    depends_on:
      es01:
        condition: service_healthy
      es02:
        condition: service_healthy
      es03:
        condition: service_healthy
    image: jaegertracing/jaeger-collector:1.36
    ports:
      - 9411
      - 14250
      - 14268
      - 14269
      - 4318
      - 4317
    restart: always
    environment:
      - COLLECTOR_OTLP_ENABLED=true
      - SPAN_STORAGE_TYPE=kafka
      - KAFKA_PRODUCER_BROKERS=${KAFKA_BROKER}

  ingestor:
    depends_on:
      es01:
        condition: service_healthy
      es02:
        condition: service_healthy
      es03:
        condition: service_healthy
    image: jaegertracing/jaeger-ingester:1.36
    ports:
      - 14270
    restart: always
    environment:
      - SPAN_STORAGE_TYPE=elasticsearch
    command:
      - "--kafka.consumer.brokers=${KAFKA_BROKER}"
      - "--es.server-urls=http://es01:${ES_PORT},http://es02:${ES_PORT},http://es02:${ES_PORT}"

  query01:
    depends_on:
      es01:
        condition: service_healthy
      es02:
        condition: service_healthy
      es03:
        condition: service_healthy
    image: jaegertracing/jaeger-query:1.36
    ports:
      - 16685
      - 16686
      - 16687
    restart: always
    environment:
      - SPAN_STORAGE_TYPE=elasticsearch
    command:
      - "--es.server-urls=http://es01:${ES_PORT},http://es02:${ES_PORT},http://es02:${ES_PORT}"

  query02:
    depends_on:
      es01:
        condition: service_healthy
      es02:
        condition: service_healthy
      es03:
        condition: service_healthy
    image: jaegertracing/jaeger-query:1.36
    ports:
      - 16685
      - 16686
      - 16687
    restart: always
    environment:
      - SPAN_STORAGE_TYPE=elasticsearch
    command:
      - "--es.server-urls=http://es01:${ES_PORT},http://es02:${ES_PORT},http://es02:${ES_PORT}"

  query03:
    depends_on:
      es01:
        condition: service_healthy
      es02:
        condition: service_healthy
      es03:
        condition: service_healthy
    image: jaegertracing/jaeger-query:1.36
    ports:
      - 16685
      - 16686
      - 16687
    restart: always
    environment:
      - SPAN_STORAGE_TYPE=elasticsearch
    command:
      - "--es.server-urls=http://es01:${ES_PORT},http://es02:${ES_PORT},http://es02:${ES_PORT}"

  nginx:
    depends_on:
      - query01
      - query02
      - query03
      - collector01
      - collector02
      - collector03
    image: nginx
    ports:
      - 16686:16686
      - 4318:4318
    restart: always
    volumes:
      - ./nginx_query.conf:/etc/nginx/conf.d/nginx_query.conf
      - ./nginx_collector.conf:/etc/nginx/conf.d/nginx_collector.conf
EOF

sudo docker-compose up -d
