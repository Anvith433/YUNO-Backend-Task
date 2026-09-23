-- Task 2: Sample Queries


-- 1. Retrieve a user's complete context history.
-- Includes sessions, conversations, emotional-state tags and commitments.

SELECT
    u.external_user_id,
    s.id AS session_id,
    s.started_at,
    s.ended_at,
    c.id AS conversation_id,
    c.role,
    c.content,
    c.occurred_at,

    COALESCE(
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'tag', est.tag,
                    'confidence', est.confidence
                )
                ORDER BY est.id
            )
            FROM emotional_state_tags est
            WHERE est.conversation_id = c.id
        ),
        '[]'::jsonb
    ) AS emotional_tags,

    COALESCE(
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', cm.id,
                    'description', cm.description,
                    'status', cm.status,
                    'dueAt', cm.due_at
                )
                ORDER BY cm.id
            )
            FROM commitments cm
            WHERE cm.conversation_id = c.id
        ),
        '[]'::jsonb
    ) AS commitments

FROM users u
JOIN user_sessions s
    ON s.user_id = u.id
JOIN conversations c
    ON c.session_id = s.id

WHERE u.external_user_id = 'user-001'

ORDER BY
    s.started_at,
    c.message_sequence;


-- 2. Retrieve all open commitments for a user.

SELECT
    u.external_user_id,
    c.content AS source_conversation,
    cm.description,
    cm.status,
    cm.due_at

FROM users u
JOIN user_sessions s
    ON s.user_id = u.id
JOIN conversations c
    ON c.session_id = s.id
JOIN commitments cm
    ON cm.conversation_id = c.id

WHERE u.external_user_id = 'user-001'
  AND cm.status = 'OPEN'

ORDER BY
    cm.due_at;


-- 3. Retrieve emotional history for a user.

SELECT
    u.external_user_id,
    c.occurred_at,
    est.tag,
    est.confidence,
    c.content AS source_conversation

FROM users u
JOIN user_sessions s
    ON s.user_id = u.id
JOIN conversations c
    ON c.session_id = s.id
JOIN emotional_state_tags est
    ON est.conversation_id = c.id

WHERE u.external_user_id = 'user-001'

ORDER BY
    c.occurred_at;