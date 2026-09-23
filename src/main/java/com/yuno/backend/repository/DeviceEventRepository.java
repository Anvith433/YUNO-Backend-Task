package com.yuno.backend.repository;

import com.yuno.backend.entity.DeviceEvent;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DeviceEventRepository extends JpaRepository<DeviceEvent, Long> {
}