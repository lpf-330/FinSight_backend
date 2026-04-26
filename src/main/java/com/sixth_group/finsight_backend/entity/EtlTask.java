package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * ETL任务实体类
 * 用于存储数据抽取、转换、加载任务的配置信息
 */
@Data
public class EtlTask {
    private Long id;
    private String name;
    private String source;
    private String target;
    private String cron;
    private String status;
    private LocalDateTime lastRun;
    private LocalDateTime nextRun;
    private Integer records;
    private String duration;
}
