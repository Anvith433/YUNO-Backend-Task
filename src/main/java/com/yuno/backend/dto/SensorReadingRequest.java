package com.yuno.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;

public record SensorReadingRequest(

        @NotBlank
        String deviceId,

        @NotNull
        Instant timestamp,

        @NotBlank
        String sensorType,

        @NotNull
        Double value,

        @NotBlank
        String unit

) {
}