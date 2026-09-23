\# Task 4 - Security Write-up



\## 1. Unauthorized Access to User and Conversation Data



YUNO stores user sessions, conversations, emotional-state tags, and commitments in PostgreSQL. Since this is user-specific data, one user should never be able to access another user's information.



I would add Spring Security with JWT authentication. Every protected request would validate the JWT signature, expiry, and claims, and the authenticated user ID would be used to determine data ownership.



The service and repository layers would verify that requested sessions and conversations belong to the authenticated user. `@PreAuthorize` can be used where endpoint-level authorization is needed. Client-supplied user IDs would never be trusted for authorization.



\## 2. Ingestion API Abuse and Resource Exhaustion



The audio-event, sensor-reading, and heartbeat APIs are designed to handle high-volume device traffic through Kafka. An attacker could abuse these endpoints with excessive requests or very large payloads and consume application, Kafka, or database resources.



I would enforce request-size limits and validate all incoming fields using Bean Validation. Invalid timestamps, event types, and device IDs would be rejected.



Rate limiting would be applied per device and IP, with HTTP `429 Too Many Requests` returned when limits are exceeded. Kafka limits and retention would also be configured appropriately. Database writes would continue to happen through Kafka so that the API is not directly exposed to unbounded database writes.



\## 3. Unauthorized Access to Kafka and PostgreSQL



Kafka and PostgreSQL contain the backend's event and application data. If these services are directly accessible, an attacker could potentially read, modify, or delete data without going through the application's security controls.



Kafka and PostgreSQL would remain on a private network, with only the Spring Boot API exposed externally.



PostgreSQL would use a dedicated application user instead of the `postgres` superuser, with only the permissions required by the application. TLS would be enabled when database traffic crosses an untrusted network.



For Kafka, production deployment would use authentication and ACLs so that producers and consumers can access only the topics they require. Database and Kafka credentials would be stored in environment variables or a secrets manager rather than in source control.

