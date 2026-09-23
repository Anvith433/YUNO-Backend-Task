package com.yuno.backend.messaging;

import java.time.Instant;

public record DeviceEventMessage(
        String deviceId,
        String eventType,
        Instant eventTimestamp,
        String payload
) {
}