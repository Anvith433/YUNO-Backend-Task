package com.yuno.backend.rag.controller;

import com.yuno.backend.rag.dto.RagSearchRequest;
import com.yuno.backend.rag.dto.RagSearchResponse;
import com.yuno.backend.rag.service.RagService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/rag")
public class RagController {

    private final RagService ragService;

    public RagController(RagService ragService) {
        this.ragService = ragService;
    }

    @PostMapping("/ingest")
    public Map<String, Object> ingest() {

        int chunksIndexed = ragService.indexSampleConversations();

        return Map.of(
                "message", "Sample conversations indexed successfully",
                "chunksIndexed", chunksIndexed
        );
    }

    @PostMapping("/search")
    public RagSearchResponse search(
            @Valid @RequestBody RagSearchRequest request) {

        return ragService.search(request.query());
    }
}