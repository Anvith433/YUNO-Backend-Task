package com.yuno.backend.dto;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;

public record HeartbeatRequest(

        @NotBlank
        String deviceId,

        @NotNull
        Instant timestamp,

        @NotNull
        @Min(0)
        @Max(100)
        Integer batteryPercentage,

        @NotBlank
        String firmwareVersion

) {
}