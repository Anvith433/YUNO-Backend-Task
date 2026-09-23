package com.yuno.backend.messaging;

import com.yuno.backend.config.KafkaConfig;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class DeviceEventProducer {

    private final KafkaTemplate<String, DeviceEventMessage> kafkaTemplate;

    public DeviceEventProducer(
            KafkaTemplate<String, DeviceEventMessage> kafkaTemplate
    ) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void publish(DeviceEventMessage event) {
        kafkaTemplate.send(
                KafkaConfig.DEVICE_EVENTS_TOPIC,
                event.deviceId(),
                event
        );
    }
}