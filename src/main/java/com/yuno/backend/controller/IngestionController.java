package com.yuno.backend.controller;
import com.yuno.backend.dto.AudioEventRequest;
import com.yuno.backend.dto.HeartbeatRequest;
import com.yuno.backend.dto.SensorReadingRequest;
import com.yuno.backend.service.IngestionService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/ingestion")
public class IngestionController {

    private final IngestionService ingestionService;

    public IngestionController(IngestionService ingestionService) {
        this.ingestionService = ingestionService;
    }

    @PostMapping("/audio-event")
    public ResponseEntity<Void> ingestAudioEvent(
            @Valid @RequestBody AudioEventRequest request
    ) {
        ingestionService.ingestAudioEvent(request);

        return ResponseEntity.accepted().build();
    }

    @PostMapping("/sensor-reading")
    public ResponseEntity<Void> ingestSensorReading(
            @Valid @RequestBody SensorReadingRequest request
    ) {
        ingestionService.ingestSensorReading(request);

        return ResponseEntity.accepted().build();
    }

    @PostMapping("/heartbeat")
    public ResponseEntity<Void> ingestHeartbeat(
            @Valid @RequestBody HeartbeatRequest request
    ) {
        ingestionService.ingestHeartbeat(request);

        return ResponseEntity.accepted().build();
    }
}