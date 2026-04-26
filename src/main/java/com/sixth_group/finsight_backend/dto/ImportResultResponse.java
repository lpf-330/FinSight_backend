package com.sixth_group.finsight_backend.dto;

import lombok.Data;

/**
 * 导入结果响应DTO
 * 用于返回Excel导入操作的结果信息
 */
@Data
public class ImportResultResponse {
    private Integer records;
    private String fileName;

    public ImportResultResponse(Integer records, String fileName) {
        this.records = records;
        this.fileName = fileName;
    }
}
