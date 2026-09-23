package com.yuno.backend.rag.dto;

import jakarta.validation.constraints.NotBlank;

public record RagSearchRequest(
        @NotBlank(message = "Query must not be blank")
        String query
) {
}