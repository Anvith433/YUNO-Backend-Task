CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    external_user_id VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_sessions_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_session_times
        CHECK (
            ended_at IS NULL
            OR ended_at >= started_at
        )
);

CREATE TABLE conversations (
    id BIGSERIAL PRIMARY KEY,
    session_id BIGINT NOT NULL,
    role VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_conversations_session
        FOREIGN KEY (session_id)
        REFERENCES user_sessions(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_conversation_role
        CHECK (role IN ('USER', 'ASSISTANT'))
);

CREATE TABLE emotional_state_tags (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL,
    tag VARCHAR(100) NOT NULL,
    confidence NUMERIC(4,3),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_emotional_tags_conversation
        FOREIGN KEY (conversation_id)
        REFERENCES conversations(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_emotional_confidence
        CHECK (
            confidence IS NULL
            OR (
                confidence >= 0.000
                AND confidence <= 1.000
            )
        )
);

CREATE TABLE commitments (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    due_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_commitments_conversation
        FOREIGN KEY (conversation_id)
        REFERENCES conversations(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_commitment_status
        CHECK (
            status IN ('OPEN', 'COMPLETED', 'CANCELLED')
        )
);

CREATE INDEX idx_user_sessions_user_started
    ON user_sessions(user_id, started_at);

CREATE INDEX idx_conversations_session_occurred
    ON conversations(session_id, occurred_at);

CREATE INDEX idx_emotional_tags_conversation
    ON emotional_state_tags(conversation_id);

CREATE INDEX idx_commitments_conversation
    ON commitments(conversation_id);

CREATE INDEX idx_commitments_status
    ON commitments(status);