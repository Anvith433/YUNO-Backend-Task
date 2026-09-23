package com.yuno.backend.rag.service;

import com.yuno.backend.rag.dto.RagSearchResponse;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class RagService {

    private static final String SAMPLE_SOURCE = "task3-sample";

    private final VectorStore vectorStore;

    public RagService(VectorStore vectorStore) {
        this.vectorStore = vectorStore;
    }

    public int indexSampleConversations() {

        // Remove only the sample data created by this Task 3 pipeline.
        vectorStore.delete("source == '" + SAMPLE_SOURCE + "'");

        List<String> snippets = List.of(
                "I have an interview next week. I am really nervous about it. I want to prepare well.",
                "Let us create a preparation plan for the interview. I will practice Java for two hours tonight.",
                "I am worried about answering Spring Boot questions during the interview. I need to revise REST APIs and dependency injection.",
                "I finished my preparation today. I revised Java and practiced several coding problems.",
                "I feel more confident now. Before the interview, I want to revise SQL and practice a few database queries."
        );

        List<Document> chunks = new ArrayList<>();

        for (int i = 0; i < snippets.size(); i++) {

            List<String> snippetChunks = chunkText(snippets.get(i));

            for (int j = 0; j < snippetChunks.size(); j++) {

                String chunk = snippetChunks.get(j);

                Map<String, Object> metadata = Map.of(
                        "source", SAMPLE_SOURCE,
                        "snippet", i + 1,
                        "chunk", j + 1
                );

                chunks.add(new Document(chunk, metadata));
            }
        }

        vectorStore.add(chunks);

        return chunks.size();
    }

    public RagSearchResponse search(String query) {

        SearchRequest searchRequest = SearchRequest.builder()
                .query(query)
                .topK(3)
                .similarityThreshold(0.0)
                .build();

        List<Document> documents = vectorStore.similaritySearch(searchRequest);

        List<RagSearchResponse.RetrievedChunk> results = documents.stream()
                .map(document -> new RagSearchResponse.RetrievedChunk(
                        document.getText(),
                        document.getScore() == null ? 0.0 : document.getScore()
                ))
                .toList();

        return new RagSearchResponse(
                query,
                results
        );
    }

    private List<String> chunkText(String text) {

        String[] sentences = text.split("(?<=[.!?])\\s+");

        List<String> chunks = new ArrayList<>();

        StringBuilder currentChunk = new StringBuilder();

        for (String sentence : sentences) {

            if (currentChunk.length() == 0) {
                currentChunk.append(sentence);
            } else {
                currentChunk.append(" ").append(sentence);
            }

            // Keep chunks small and sentence-aligned.
            if (currentChunk.toString().split("\\s+").length >= 15) {
                chunks.add(currentChunk.toString().trim());
                currentChunk.setLength(0);
            }
        }

        if (currentChunk.length() > 0) {
            chunks.add(currentChunk.toString().trim());
        }

        return chunks;
    }
}