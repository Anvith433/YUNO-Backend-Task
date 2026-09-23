CREATE TABLE device_events (
    id BIGSERIAL PRIMARY KEY,
    device_id VARCHAR(100) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_timestamp TIMESTAMPTZ NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_device_events_device_id
    ON device_events(device_id);

CREATE INDEX idx_device_events_event_timestamp
    ON device_events(event_timestamp);

CREATE INDEX idx_device_events_event_type
    ON device_events(event_type);