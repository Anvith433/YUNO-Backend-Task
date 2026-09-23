

ALTER TABLE conversations
    ADD COLUMN message_id UUID;

ALTER TABLE conversations
    ADD COLUMN message_sequence BIGINT;

ALTER TABLE commitments
    ADD COLUMN completed_at TIMESTAMPTZ;

ALTER TABLE commitments
    ADD COLUMN cancelled_at TIMESTAMPTZ;


-- Existing rows receive deterministic values.
-- message_sequence is unique within a session.
WITH ordered_messages AS (
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY session_id
            ORDER BY occurred_at, id
        ) AS sequence_number
    FROM conversations
)
UPDATE conversations c
SET message_sequence = om.sequence_number
FROM ordered_messages om
WHERE c.id = om.id;



UPDATE conversations
SET message_id = gen_random_uuid()
WHERE message_id IS NULL;


ALTER TABLE conversations
    ALTER COLUMN message_id SET NOT NULL;

ALTER TABLE conversations
    ALTER COLUMN message_sequence SET NOT NULL;


ALTER TABLE conversations
    ADD CONSTRAINT uq_conversations_message_id
    UNIQUE (message_id);

ALTER TABLE conversations
    ADD CONSTRAINT uq_conversations_session_sequence
    UNIQUE (session_id, message_sequence);


ALTER TABLE conversations
    ADD CONSTRAINT chk_conversation_sequence
    CHECK (message_sequence > 0);


ALTER TABLE commitments
    ADD CONSTRAINT chk_commitment_lifecycle
    CHECK (
        (status = 'OPEN'
            AND completed_at IS NULL
            AND cancelled_at IS NULL)

        OR

        (status = 'COMPLETED'
            AND completed_at IS NOT NULL
            AND cancelled_at IS NULL)

        OR

        (status = 'CANCELLED'
            AND cancelled_at IS NOT NULL
            AND completed_at IS NULL)
    );


CREATE INDEX idx_conversations_session_sequence
    ON conversations(session_id, message_sequence);

CREATE INDEX idx_conversations_message_id
    ON conversations(message_id);

CREATE INDEX idx_commitments_open_due
    ON commitments(due_at)
    WHERE status = 'OPEN';