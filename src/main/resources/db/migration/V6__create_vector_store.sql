CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS vector_store (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    content TEXT NOT NULL,
    metadata JSON,
    embedding VECTOR(384) NOT NULL
);

CREATE INDEX IF NOT EXISTS vector_store_embedding_hnsw_idx
    ON vector_store
    USING HNSW (embedding vector_cosine_ops);