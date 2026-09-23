-- Task 2 sample data
-- Safe to run multiple times.

-- ------------------------------------------------------------
-- User
-- ------------------------------------------------------------

INSERT INTO users (external_user_id)
VALUES ('user-001')
ON CONFLICT (external_user_id) DO NOTHING;


-- ------------------------------------------------------------
-- Session 1
-- ------------------------------------------------------------

INSERT INTO user_sessions (
    user_id,
    started_at,
    ended_at
)
SELECT
    id,
    '2026-09-20T09:00:00Z',
    '2026-09-20T09:20:00Z'
FROM users
WHERE external_user_id = 'user-001'
  AND NOT EXISTS (
      SELECT 1
      FROM user_sessions s
      WHERE s.user_id = users.id
        AND s.started_at = '2026-09-20T09:00:00Z'
  );


-- ------------------------------------------------------------
-- Session 1 conversations
-- ------------------------------------------------------------

INSERT INTO conversations (
    session_id,
    role,
    content,
    occurred_at,
    message_id,
    message_sequence
)
SELECT
    s.id,
    'USER',
    'I have an interview next week.',
    '2026-09-20T09:02:00Z',
    '10000000-0000-0000-0000-000000000001',
    1
FROM user_sessions s
JOIN users u ON u.id = s.user_id
WHERE u.external_user_id = 'user-001'
  AND s.started_at = '2026-09-20T09:00:00Z'
ON CONFLICT DO NOTHING;


INSERT INTO conversations (
    session_id,
    role,
    content,
    occurred_at,
    message_id,
    message_sequence
)
SELECT
    s.id,
    'USER',
    'I am really nervous about it.',
    '2026-09-20T09:04:00Z',
    '10000000-0000-0000-0000-000000000002',
    2
FROM user_sessions s
JOIN users u ON u.id = s.user_id
WHERE u.external_user_id = 'user-001'
  AND s.started_at = '2026-09-20T09:00:00Z'
ON CONFLICT DO NOTHING;


INSERT INTO conversations (
    session_id,
    role,
    content,
    occurred_at,
    message_id,
    message_sequence
)
SELECT
    s.id,
    'ASSISTANT',
    'Let us create a preparation plan for the interview.',
    '2026-09-20T09:05:00Z',
    '10000000-0000-0000-0000-000000000003',
    3
FROM user_sessions s
JOIN users u ON u.id = s.user_id
WHERE u.external_user_id = 'user-001'
  AND s.started_at = '2026-09-20T09:00:00Z'
ON CONFLICT DO NOTHING;


INSERT INTO conversations (
    session_id,
    role,
    content,
    occurred_at,
    message_id,
    message_sequence
)
SELECT
    s.id,
    'USER',
    'I will practice Java for two hours tonight.',
    '2026-09-20T09:07:00Z',
    '10000000-0000-0000-0000-000000000004',
    4
FROM user_sessions s
JOIN users u ON u.id = s.user_id
WHERE u.external_user_id = 'user-001'
  AND s.started_at = '2026-09-20T09:00:00Z'
ON CONFLICT DO NOTHING;


-- ------------------------------------------------------------
-- Session 1 emotional state tags
-- ------------------------------------------------------------

INSERT INTO emotional_state_tags (
    conversation_id,
    tag,
    confidence
)
SELECT
    c.id,
    'anxious',
    0.94
FROM conversations c
WHERE c.message_id = '10000000-0000-0000-0000-000000000002'
  AND NOT EXISTS (
      SELECT 1
      FROM emotional_state_tags est
      WHERE est.conversation_id = c.id
        AND est.tag = 'anxious'
  );


INSERT INTO emotional_state_tags (
    conversation_id,
    tag,
    confidence
)
SELECT
    c.id,
    'stressed',
    0.82
FROM conversations c
WHERE c.message_id = '10000000-0000-0000-0000-000000000002'
  AND NOT EXISTS (
      SELECT 1
      FROM emotional_state_tags est
      WHERE est.conversation_id = c.id
        AND est.tag = 'stressed'
  );


-- ------------------------------------------------------------
-- Session 1 commitment
-- ------------------------------------------------------------

INSERT INTO commitments (
    conversation_id,
    description,
    status,
    due_at
)
SELECT
    c.id,
    'Practice Java for two hours.',
    'OPEN',
    '2026-09-20T20:00:00Z'
FROM conversations c
WHERE c.message_id = '10000000-0000-0000-0000-000000000004'
  AND NOT EXISTS (
      SELECT 1
      FROM commitments cm
      WHERE cm.conversation_id = c.id
        AND cm.description = 'Practice Java for two hours.'
  );


-- ------------------------------------------------------------
-- Session 2
-- ------------------------------------------------------------

INSERT INTO user_sessions (
    user_id,
    started_at,
    ended_at
)
SELECT
    id,
    '2026-09-21T18:00:00Z',
    '2026-09-21T18:20:00Z'
FROM users
WHERE external_user_id = 'user-001'
  AND NOT EXISTS (
      SELECT 1
      FROM user_sessions s
      WHERE s.user_id = users.id
        AND s.started_at = '2026-09-21T18:00:00Z'
  );


-- ------------------------------------------------------------
-- Session 2 conversations
-- ------------------------------------------------------------

INSERT INTO conversations (
    session_id,
    role,
    content,
    occurred_at,
    message_id,
    message_sequence
)
SELECT
    s.id,
    'USER',
    'I finished my preparation today.',
    '2026-09-21T18:05:00Z',
    '20000000-0000-0000-0000-000000000001',
    1
FROM user_sessions s
JOIN users u ON u.id = s.user_id
WHERE u.external_user_id = 'user-001'
  AND s.started_at = '2026-09-21T18:00:00Z'
ON CONFLICT DO NOTHING;


INSERT INTO conversations (
    session_id,
    role,
    content,
    occurred_at,
    message_id,
    message_sequence
)
SELECT
    s.id,
    'ASSISTANT',
    'That is great. You are making good progress.',
    '2026-09-21T18:06:00Z',
    '20000000-0000-0000-0000-000000000002',
    2
FROM user_sessions s
JOIN users u ON u.id = s.user_id
WHERE u.external_user_id = 'user-001'
  AND s.started_at = '2026-09-21T18:00:00Z'
ON CONFLICT DO NOTHING;


-- ------------------------------------------------------------
-- Session 2 emotional state tag
-- ------------------------------------------------------------

INSERT INTO emotional_state_tags (
    conversation_id,
    tag,
    confidence
)
SELECT
    c.id,
    'confident',
    0.89
FROM conversations c
WHERE c.message_id = '20000000-0000-0000-0000-000000000001'
  AND NOT EXISTS (
      SELECT 1
      FROM emotional_state_tags est
      WHERE est.conversation_id = c.id
        AND est.tag = 'confident'
  );