package com.yuno.backend.service;
import com.yuno.backend.entity.DeviceEvent;
import com.yuno.backend.messaging.DeviceEventMessage;
import com.yuno.backend.repository.DeviceEventRepository;
import org.springframework.stereotype.Service;
@Service
public class DeviceEventPersistenceService {

    private final DeviceEventRepository deviceEventRepository;

    public DeviceEventPersistenceService(
            DeviceEventRepository deviceEventRepository
    ) {
        this.deviceEventRepository = deviceEventRepository;
    }

    public void save(DeviceEventMessage message) {

        DeviceEvent event = new DeviceEvent(
                message.deviceId(),
                message.eventType(),
                message.eventTimestamp(),
                message.payload()
        );

        deviceEventRepository.save(event);
    }
}