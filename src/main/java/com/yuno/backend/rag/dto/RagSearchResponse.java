package com.yuno.backend.rag.dto;

import java.util.List;

public record RagSearchResponse(
        String query,
        List<RetrievedChunk> results
) {

    public record RetrievedChunk(
            String content,
            double score
    ) {
    }
}