\# Task 3 - Chunking Strategy



The 5 conversation snippets are split into sentence-based chunks.

Sentences are combined until the chunk reaches approximately 15 words,

while keeping complete sentences intact.



Each chunk is embedded using the local `all-MiniLM-L6-v2` model and

stored in PostgreSQL using PGVector.



For the sample data, each snippet produced one chunk, resulting in

5 stored chunks. The system retrieves the top 3 relevant chunks using

cosine similarity.

