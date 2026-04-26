package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.AuditLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 审计日志Mapper接口
 * 负责审计日志数据的数据库操作
 */
@Mapper
public interface AuditLogMapper {
    AuditLog selectById(@Param("id") Long id);
    List<AuditLog> selectAll(@Param("page") Integer page, @Param("pageSize") Integer pageSize);
    List<AuditLog> search(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate,
                          @Param("username") String username, @Param("operation") String operation,
                          @Param("page") Integer page, @Param("pageSize") Integer pageSize);
    int count();
    int countByCondition(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate,
                         @Param("username") String username, @Param("operation") String operation);
    int insert(AuditLog log);
}
