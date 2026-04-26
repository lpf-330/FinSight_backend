package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * ETL日志实体类
 * 用于记录ETL任务执行过程中的日志信息
 */
@Data
public class EtlLog {
    private Long id;
    private Long taskId;
    private LocalDateTime time;
    private String level;
    private String message;
}
