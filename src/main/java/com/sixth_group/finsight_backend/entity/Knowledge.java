package com.sixth_group.finsight_backend.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 知识库实体类
 * 用于存储财务指标相关知识的介绍内容
 */
@Data
public class Knowledge {
    private Long id;
    private String indicator;
    private String level;
    private String content;
    private String version;
    private Integer usefulCount;
    private Integer uselessCount;
    private LocalDateTime updateTime;
}
