package com.sixth_group.finsight_backend.dto;

import lombok.Data;

/**
 * ETL任务触发请求DTO
 * 用于指定需要触发的ETL任务ID
 */
@Data
public class EtlTriggerRequest {
    private Long taskId;
}
