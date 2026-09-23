package com.yuno.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

import java.time.Instant;

public record AudioEventRequest(

        @NotBlank
        String deviceId,

        @NotNull
        Instant timestamp,

        @NotBlank
        String event,

        @PositiveOrZero
        Long durationMs

) {
}