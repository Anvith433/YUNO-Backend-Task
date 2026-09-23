YUNO Backend

A Spring Boot backend for ingesting device events asynchronously using Kafka and storing them in PostgreSQL.

Architecture

Client / Device
      |
      v
REST API
      |
      v
Spring Boot
      |
      v
Kafka
      |
      v
Kafka Consumer
      |
      v
PostgreSQL

Features

Audio event ingestion

Sensor reading ingestion

Heartbeat ingestion

Request validation

Asynchronous processing with Kafka

PostgreSQL persistence

JSONB event payloads

Flyway database migration

Docker-based PostgreSQL and Kafka

Concurrent load testing

Tech Stack

Java 21

Spring Boot

Spring Web

Spring Kafka

Apache Kafka

PostgreSQL

JPA / Hibernate

Flyway

Docker Compose

Maven

API Endpoints

Base URL:

http://localhost:8080

Audio Event

POST /api/v1/ingestion/audio-event

Example:

{
  "deviceId": "device-001",
  "timestamp": "2026-09-23T09:30:00Z",
  "event": "speech_detected",
  "durationMs": 1500
}

Sensor Reading

POST /api/v1/ingestion/sensor-reading

Example:

{
  "deviceId": "device-001",
  "timestamp": "2026-09-23T09:31:00Z",
  "sensorType": "temperature",
  "value": 27.5,
  "unit": "celsius"
}

Heartbeat

POST /api/v1/ingestion/heartbeat

Example:

{
  "deviceId": "device-001",
  "timestamp": "2026-09-23T09:32:00Z",
  "batteryPercentage": 87,
  "firmwareVersion": "1.2.3"
}

All successful ingestion requests return:

HTTP 202 Accepted

Request Flow

HTTP Request
     |
     v
IngestionController
     |
     v
IngestionService
     |
     v
Kafka Producer
     |
     v
yuno-device-events
     |
     v
Kafka Consumer
     |
     v
PostgreSQL

The API returns 202 Accepted because database persistence happens asynchronously after the event is published to Kafka.

Database

Events are stored in the device_events table.

Main fields:

id
device_id
event_type
event_timestamp
payload
created_at

Event-specific data is stored in PostgreSQL JSONB.

Running the Project

1. Start infrastructure

docker compose up -d

2. Start the backend

mvnw.cmd spring-boot:run "-Dspring-boot.run.jvmArguments=-Duser.timezone=Asia/Kolkata"

The application runs on:

http://localhost:8080

3. Check Docker containers

docker compose ps

Testing

Example PowerShell request:

Invoke-RestMethod -Uri "http://localhost:8080/api/v1/ingestion/audio-event" -Method POST -ContentType "application/json" -Body '{"deviceId":"device-001","timestamp":"2026-09-23T09:30:00Z","event":"speech_detected","durationMs":1500}'

Check stored events:

docker compose exec -T postgres psql -U postgres -d yuno_db -c "SELECT id, device_id, event_type, event_timestamp FROM device_events ORDER BY id DESC LIMIT 10;"

Load Test

The project includes:

load-test/load-test.ps1

Run:

.\load-test\load-test.ps1

Final tested result:

Metric

Result

Requests

50,000

HTTP 202

50,000

Failed

0

Execution time

460.71 sec

Throughput

108.53 req/sec

Records persisted

50,000

The final test verified the complete flow:

REST API → Kafka → Consumer → PostgreSQL

Project Structure

yuno-backend/
├── src/
│   ├── main/
│   │   ├── java/com/yuno/backend/
│   │   │   ├── controller/
│   │   │   ├── dto/
│   │   │   ├── entity/
│   │   │   ├── messaging/
│   │   │   ├── repository/
│   │   │   └── service/
│   │   └── resources/
│   │       └── db/migration/
├── load-test/
│   └── load-test.ps1
├── docker-compose.yml
├── pom.xml
└── README.md

Repository

https://github.com/Anvith433/YUNO-Backend-Task