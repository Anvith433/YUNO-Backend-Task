YUNO Backend Task
Overview
This repository contains the implementation of all four tasks from the YUNO Backend assignment.
The project is built with Spring Boot and PostgreSQL. Kafka is used for asynchronous device-event processing, and PGVector is used for the RAG prototype.
Tasks
Task	What was implemented
Task 1	Device event ingestion using REST API, Kafka and PostgreSQL
Task 2	User sessions, conversations, emotional tags and commitments
Task 3	Small RAG pipeline using local embeddings and PGVector
Task 4	Security write-up for the YUNO backend
---
Task 1 – Device Event Ingestion
What was built
The backend accepts three types of device events:
Audio events
Sensor readings
Heartbeats
The main idea is to avoid writing directly to PostgreSQL during the API request.
```text
Device
  ↓
REST API
  ↓
Kafka
  ↓
Kafka Consumer
  ↓
PostgreSQL
```
When an event arrives:
The API receives and validates it.
The event is sent to Kafka.
The API returns `202 Accepted`.
The Kafka consumer receives the event.
The event is saved in PostgreSQL.
This separates event ingestion from database persistence and helps handle bursts of incoming requests.
APIs
Event	Endpoint
Audio	`POST /api/v1/ingestion/audio-event`
Sensor	`POST /api/v1/ingestion/sensor-reading`
Heartbeat	`POST /api/v1/ingestion/heartbeat`
Example:
```json
{
  "deviceId": "device-001",
  "timestamp": "2026-09-23T09:30:00Z",
  "event": "speech_detected",
  "durationMs": 1500
}
```
A successfully accepted request returns:
```text
HTTP 202 Accepted
```
Kafka
Topic:
```text
yuno-device-events
```
Configuration:
```text
Partitions: 3
Consumer Group: yuno-device-event-consumers
```
The device ID is used as the Kafka message key so that events from the same device stay on the same partition.
PostgreSQL
Events are stored in:
```text
device_events
```
Main fields:
Field	Purpose
`id`	Event ID
`device_id`	Device that sent the event
`event_type`	Type of event
`event_timestamp`	Device event time
`payload`	Event-specific JSONB data
`created_at`	Database insertion time
JSONB is used because audio, sensor and heartbeat events have different fields.
Flyway is used for database migrations.
Validation
Requests are validated before being published to Kafka.
Examples:
Device ID and timestamp are required.
Audio duration cannot be negative.
Sensor fields must be provided.
Heartbeat battery percentage must be valid.
Required event-specific fields must be present.
Load Test
The ingestion system was tested with 50,000 concurrent requests.
Metric	Result
Total requests	50,000
Successful `202` responses	50,000
Failed requests	0
Throughput	108.53 requests/sec
Execution time	460.71 seconds
Records persisted	50,000
The database was checked after the test and 50,000 records were persisted.
Load-test evidence is available in:
```text
load-test/screenshots/
```
---
Task 2 – Data Layer
What was built
Task 2 models the information needed to keep a user's conversation history and context.
The database stores:
Users
User sessions
Conversations
Emotional-state tags
Commitments
The main relationship is:
```text
User
  ↓
User Session
  ↓
Conversation
  ├── Emotional Tags
  └── Commitments
```
PostgreSQL was chosen because the data has clear relationships between users, sessions and conversations, and SQL makes it easy to retrieve a user's complete history.
Data Model
User
Stores the user who owns the sessions and conversations.
User Session
Represents a conversation session belonging to a user.
Conversation
Stores individual conversation messages inside a session.
Emotional State
Stores an emotional tag associated with conversation content.
Example tags used in the sample data include:
```text
anxious
stressed
confident
```
A confidence score is stored with the emotional tag.
Commitment
Stores an action or commitment identified from the conversation.
Example:
```text
Practice Java for two hours
```
The sample commitment has an `OPEN` status.
Sample Conversation
The sample data represents a user preparing for an interview:
```text
I have an interview next week.

I am really nervous about it.

Let us create a preparation plan for the interview.

I will practice Java for two hours tonight.

I finished my preparation today.

That is great. You are making good progress.
```
The sample data also contains emotional states and a commitment extracted from this conversation.
Full User Context Query
A working SQL query is included to retrieve the user's context history by joining the related user, session, conversation, emotional-state and commitment data.
The migration scripts and sample queries are included in the project.
---
Task 3 – RAG / Memory Prototype
What was built
A small RAG pipeline was implemented using five sample conversation snippets.
The pipeline is:
```text
Conversation Snippets
        ↓
Chunking
        ↓
Embedding
        ↓
PGVector
        ↓
Similarity Search
        ↓
Top 3 Results
```
Embeddings
A local `all-MiniLM-L6-v2` model is used to create embeddings.
The model is stored inside the project so that the application does not depend on downloading the model at runtime.
The generated embeddings have 384 dimensions.
Storage
PostgreSQL with the PGVector extension is used to store the embeddings.
The vector table stores:
Chunk content
Metadata
384-dimensional embedding
An HNSW index is used for vector similarity search.
Chunking
The five conversation snippets are split using sentences.
Sentences are combined until a chunk reaches approximately 15 words while keeping complete sentences together.
For the sample data, each snippet produced one chunk, giving:
```text
5 snippets
↓
5 chunks
```
Search
The API provides:
```text
POST /api/v1/rag/ingest
```
to index the sample conversations.
Search is performed using:
```text
POST /api/v1/rag/search
```
Example query:
```text
How should I prepare for my Java interview?
```
The system returns the top three relevant chunks using cosine similarity.
Example result order:
```text
1. Interview preparation plan and Java practice
2. Interview anxiety and preparation
3. Completed Java preparation and coding practice
```
This confirms that the stored conversation chunks can be retrieved based on the meaning of the query rather than only matching exact words.
---
Task 4 – Security
Task 4 contains a short security write-up focused on the technologies used in this project.
The three main areas identified are:
1. Unauthorized Access to User Data
YUNO stores user sessions, conversations, emotional-state information and commitments.
The proposed protection is Spring Security with JWT authentication.
The authenticated user ID should be used to decide which sessions and conversations the user can access.
Client-provided user IDs should not be trusted for authorization.
2. Ingestion API Abuse
The device ingestion APIs can receive a large number of requests.
Protection includes:
Request validation
Request-size limits
Rate limiting
Per-device and IP limits
HTTP `429 Too Many Requests`
Kafka protection and retention settings
Kafka continues to separate the API from direct database writes.
3. Direct Access to Kafka and PostgreSQL
Kafka and PostgreSQL should not be directly exposed to the public internet.
Production deployment should use:
Private networking
Dedicated PostgreSQL application user
Limited database permissions
Kafka authentication and ACLs
TLS where required
Environment variables or a secrets manager for credentials
The complete security write-up is available in:
```text
task4security.md
```
---
Technology Stack
Technology	Use
Java 21	Backend application
Spring Boot	REST backend
Spring Kafka	Kafka integration
Apache Kafka	Event queue
PostgreSQL	Main database
JPA / Hibernate	Database access
Flyway	Database migrations
Spring AI	RAG implementation
PGVector	Vector storage
all-MiniLM-L6-v2	Local text embeddings
Docker Compose	Local infrastructure
Maven	Build and dependency management
---
Project Structure
```text
yuno-backend/
│
├── src/
│   ├── main/
│   │   ├── java/com/yuno/backend/
│   │   │   ├── controller/
│   │   │   ├── dto/
│   │   │   ├── entity/
│   │   │   ├── messaging/
│   │   │   ├── repository/
│   │   │   ├── service/
│   │   │   └── rag/
│   │   │
│   │   └── resources/
│   │       ├── db/migration/
│   │       ├── onnx/
│   │       └── application.properties
│   │
│   └── test/
│
├── load-test/
│   └── screenshots/
│
├── task3shortexplanation.md
├── task4security.md
├── docker-compose.yml
├── pom.xml
├── mvnw
├── mvnw.cmd
└── README.md
```
---
Running the Project
Start the infrastructure
```powershell
docker compose up -d
```
Start the Spring Boot application
```powershell
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.jvmArguments=-Duser.timezone=Asia/Kolkata"
```
The application runs at:
```text
http://localhost:8080
```
Flyway applies the database migrations when the application starts.
---
Task Completion
Task	Status
Task 1 – Ingestion API	Complete
Task 2 – Data Layer	Complete
Task 3 – RAG Prototype	Complete
Task 4 – Security Write-up	Complete
---
Repository
GitHub:
https://github.com/Anvith433/YUNO-Backend-Task
