package com.yuno.backend.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.yuno.backend.dto.AudioEventRequest;
import com.yuno.backend.dto.HeartbeatRequest;
import com.yuno.backend.dto.SensorReadingRequest;
import com.yuno.backend.messaging.DeviceEventMessage;
import com.yuno.backend.messaging.DeviceEventProducer;
import org.springframework.stereotype.Service;

@Service
public class IngestionService {

    private final DeviceEventProducer deviceEventProducer;
    private final ObjectMapper objectMapper;

    public IngestionService(
            DeviceEventProducer deviceEventProducer,
            ObjectMapper objectMapper
    ) {
        this.deviceEventProducer = deviceEventProducer;
        this.objectMapper = objectMapper;
    }

    public void ingestAudioEvent(AudioEventRequest request) {
        publish(
                request.deviceId(),
                "AUDIO_EVENT",
                request.timestamp(),
                request
        );
    }

    public void ingestSensorReading(SensorReadingRequest request) {
        publish(
                request.deviceId(),
                "SENSOR_READING",
                request.timestamp(),
                request
        );
    }

    public void ingestHeartbeat(HeartbeatRequest request) {
        publish(
                request.deviceId(),
                "HEARTBEAT",
                request.timestamp(),
                request
        );
    }

    private void publish(
            String deviceId,
            String eventType,
            java.time.Instant timestamp,
            Object payload
    ) {
        try {
            String payloadJson = objectMapper.writeValueAsString(payload);

            DeviceEventMessage message = new DeviceEventMessage(
                    deviceId,
                    eventType,
                    timestamp,
                    payloadJson
            );

            deviceEventProducer.publish(message);

        } catch (JsonProcessingException e) {
            throw new IllegalArgumentException(
                    "Failed to serialize device event payload",
                    e
            );
        }
    }
}