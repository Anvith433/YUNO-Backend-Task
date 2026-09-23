package com.yuno.backend.messaging;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.yuno.backend.config.KafkaConfig;
import com.yuno.backend.entity.DeviceEvent;
import com.yuno.backend.repository.DeviceEventRepository;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class DeviceEventConsumer {

    private final DeviceEventRepository deviceEventRepository;
    private final ObjectMapper objectMapper;

    public DeviceEventConsumer(
            DeviceEventRepository deviceEventRepository,
            ObjectMapper objectMapper
    ) {
        this.deviceEventRepository = deviceEventRepository;
        this.objectMapper = objectMapper;
    }

    @KafkaListener(
            topics = KafkaConfig.DEVICE_EVENTS_TOPIC,
            groupId = "yuno-device-event-consumers"
    )
    public void consume(String message) {

        try {
            DeviceEventMessage eventMessage =
                    objectMapper.readValue(message, DeviceEventMessage.class);

            DeviceEvent event = new DeviceEvent(
                    eventMessage.deviceId(),
                    eventMessage.eventType(),
                    eventMessage.eventTimestamp(),
                    eventMessage.payload()
            );

            deviceEventRepository.save(event);

        } catch (Exception e) {
            throw new IllegalArgumentException(
                    "Failed to process Kafka device event: " + message,
                    e
            );
        }
    }
}