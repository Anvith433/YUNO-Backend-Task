YUNO Backend Task

Backend implementation for the YUNO device-event ingestion task.

The system exposes REST APIs for device events, places Kafka between the
API and persistence layer for asynchronous processing, and stores the
events in PostgreSQL.

1. Task Implementation

This implementation focuses on the backend ingestion requirement:

Audio event ingestion

Sensor reading ingestion

Heartbeat ingestion

Request validation

Asynchronous processing using Kafka

PostgreSQL persistence

JSONB storage for event-specific payloads

Flyway database migration

Docker-based PostgreSQL and Kafka infrastructure

Concurrent load testing

The ingestion API returns HTTP 202 Accepted after publishing the event
to Kafka. Database persistence is handled asynchronously by the Kafka
consumer.

2. Architecture

Client / Device
      |
      v
REST API
      |
      v
Spring Boot
      |
      v
Kafka Producer
      |
      v
Kafka Topic
yuno-device-events
      |
      v
Kafka Consumer
      |
      v
PostgreSQL

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
DeviceEventProducer
     |
     v
Kafka
     |
     v
DeviceEventConsumer
     |
     v
DeviceEventRepository
     |
     v
PostgreSQL

Kafka acts as the asynchronous buffer between API ingestion and database
persistence.

3. Technology Stack

Technology

Purpose

Java 21

Application runtime

Spring Boot

Backend framework

Spring Web

REST APIs

Spring Kafka

Kafka integration

Apache Kafka

Asynchronous event processing

PostgreSQL

Event persistence

JPA / Hibernate

Database access

Flyway

Database migrations

Docker Compose

Local PostgreSQL and Kafka infrastructure

Maven

Build and dependency management

PowerShell

Load testing

4. API Endpoints

Base URL:

http://localhost:8080

Audio Event

POST /api/v1/ingestion/audio-event

Request:

{
  "deviceId": "device-001",
  "timestamp": "2026-09-23T09:30:00Z",
  "event": "speech_detected",
  "durationMs": 1500
}

Sensor Reading

POST /api/v1/ingestion/sensor-reading

Request:

{
  "deviceId": "device-001",
  "timestamp": "2026-09-23T09:31:00Z",
  "sensorType": "temperature",
  "value": 27.5,
  "unit": "celsius"
}

Heartbeat

POST /api/v1/ingestion/heartbeat

Request:

{
  "deviceId": "device-001",
  "timestamp": "2026-09-23T09:32:00Z",
  "batteryPercentage": 87,
  "firmwareVersion": "1.2.3"
}

Successful ingestion requests return:

HTTP 202 Accepted

5. How to Run

Prerequisites

Java 21

Docker Desktop

Git

Verify:

java -version
docker --version
git --version

Step 1: Start PostgreSQL and Kafka

From the project root:

docker compose up -d

Check the containers:

docker compose ps

The local infrastructure uses:

PostgreSQL  → localhost:5432
Kafka       → localhost:9092
Database    → yuno_db
Kafka Topic → yuno-device-events

Step 2: Start the Spring Boot Application

Windows:

mvnw.cmd spring-boot:run "-Dspring-boot.run.jvmArguments=-Duser.timezone=Asia/Kolkata"

The backend starts on:

http://localhost:8080

The application connects to the PostgreSQL and Kafka instances running
in Docker.

Step 3: Database Migration

Flyway runs automatically when the application starts.

The migration creates the device_events table and its indexes.

No manual database table creation is required.

6. Database

Events are stored in the PostgreSQL table:

device_events

Column

Purpose

id

Unique event identifier

device_id

Device that generated the event

event_type

Type of event

event_timestamp

Timestamp supplied by the device

payload

Event-specific JSON data

created_at

Database insertion timestamp

The payload column uses PostgreSQL JSONB.

This allows the same table to store different event structures while
keeping the common event metadata relational.

7. Kafka

Kafka topic:

yuno-device-events

Configuration:

Partitions: 3
Replication factor: 1
Consumer group: yuno-device-event-consumers

The device ID is used as the Kafka message key.

This keeps events for the same device associated with the same partition
while allowing multiple partitions for concurrent processing.

8. End-to-End Processing

For an audio event:

1. Client sends POST request
           |
           v
2. IngestionController validates request
           |
           v
3. IngestionService creates the device event message
           |
           v
4. Kafka Producer publishes to yuno-device-events
           |
           v
5. API returns HTTP 202
           |
           v
6. Kafka Consumer receives the event
           |
           v
7. Consumer converts message into DeviceEvent
           |
           v
8. DeviceEventRepository persists it
           |
           v
9. PostgreSQL stores the event

The database operation is decoupled from the HTTP request path.

9. Testing the APIs

Audio Event

Invoke-RestMethod -Uri "http://localhost:8080/api/v1/ingestion/audio-event" -Method POST -ContentType "application/json" -Body '{"deviceId":"device-001","timestamp":"2026-09-23T09:30:00Z","event":"speech_detected","durationMs":1500}'

Sensor Reading

Invoke-RestMethod -Uri "http://localhost:8080/api/v1/ingestion/sensor-reading" -Method POST -ContentType "application/json" -Body '{"deviceId":"device-001","timestamp":"2026-09-23T09:31:00Z","sensorType":"temperature","value":27.5,"unit":"celsius"}'

Heartbeat

Invoke-RestMethod -Uri "http://localhost:8080/api/v1/ingestion/heartbeat" -Method POST -ContentType "application/json" -Body '{"deviceId":"device-001","timestamp":"2026-09-23T09:32:00Z","batteryPercentage":87,"firmwareVersion":"1.2.3"}'

10. Verify Data in PostgreSQL

docker compose exec -T postgres psql -U postgres -d yuno_db -c "SELECT id, device_id, event_type, event_timestamp, created_at FROM device_events ORDER BY id DESC LIMIT 10;"

Complete flow:

REST API
   ↓
Kafka
   ↓
Consumer
   ↓
PostgreSQL

11. Load Testing

The concurrent PowerShell load-test script is:

load-test/load-test.ps1

Run:

.\load-test\load-test.ps1

Final clean test:

50,000 concurrent requests

Final Result

Metric

Result

Total Requests

50,000

HTTP 202

50,000

Failed

0

Execution Time

460.71 sec

Throughput

108.53 req/sec

Persisted Records

50,000

The persistence count was independently verified in PostgreSQL.

The final test observed:

50,000 requests
        ↓
50,000 HTTP 202 responses
        ↓
Kafka
        ↓
Kafka Consumer
        ↓
50,000 persisted PostgreSQL records

Note: this demonstrates the tested result under the local test
conditions. It is not a guarantee of zero data loss under every
infrastructure or failure scenario.

12. Load Test Evidence

Additional execution and persistence screenshots are available in:

load-test/screenshots/

13. Project Structure

yuno-backend/
├── src/
│   ├── main/
│   │   ├── java/com/yuno/backend/
│   │   │   ├── config/
│   │   │   ├── controller/
│   │   │   ├── dto/
│   │   │   ├── entity/
│   │   │   ├── messaging/
│   │   │   ├── repository/
│   │   │   └── service/
│   │   └── resources/
│   │       ├── db/migration/
│   │       └── application.properties
│   └── test/
├── load-test/
│   ├── screenshots/
│   └── load-test.ps1
├── docker-compose.yml
├── pom.xml
├── mvnw
├── mvnw.cmd
└── README.md

14. Key Design Decisions

Why Kafka?

The API should not wait for database persistence before responding.

Kafka provides an asynchronous buffer between ingestion and storage,
allowing bursts of incoming device events to be handled separately from
database writes.

Why PostgreSQL?

PostgreSQL provides:

Relational persistence

JSONB support for flexible event payloads

Indexing for commonly queried fields

Straightforward local development through Docker

Why JSONB?

Different event types have different fields.

Common event metadata is stored relationally, while event-specific
information is stored in payload.

15. Validation and Error Handling

Incoming requests use Jakarta Bean Validation.

Examples:

Required device ID

Required timestamp

Valid heartbeat battery range

Non-negative audio duration

Required sensor type and unit

Serialization errors are handled before publishing the event.

The Kafka consumer handles message deserialization and persistence
failures by propagating processing failures rather than silently
accepting invalid data.

16. Current Scope and Production Improvements

This implementation focuses on the requested ingestion and persistence
workflow.

Potential production-scale enhancements include:

Kafka retry and backoff policies

Dead-letter topic handling

Global REST exception handling

Authentication and authorization

Metrics and tracing

Horizontal scaling

Kafka replication and high availability

Environment-based secret management

These are outside the current minimal implementation scope.

17. Repository

https://github.com/Anvith433/YUNO-Backend-Task
