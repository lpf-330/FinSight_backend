package com.sixth_group.finsight_backend.dto;

import lombok.Data;

/**
 * 比率计算请求DTO
 * 用于指定需要计算财务比率的会计期间
 */
@Data
public class RatioCalculateRequest {
    private String period;
}
