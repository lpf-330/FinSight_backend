package com.sixth_group.finsight_backend.dto;

import lombok.Data;

/**
 * Excel导入请求DTO
 * 用于指定导入类型和导入模式
 */
@Data
public class ExcelImportRequest {
    private String type;
    private String mode;
}
