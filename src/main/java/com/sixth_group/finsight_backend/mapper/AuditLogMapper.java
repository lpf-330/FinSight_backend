package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.AuditLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 审计日志Mapper接口
 * 负责审计日志数据的数据库操作
 */
@Mapper
public interface AuditLogMapper {

    /**
     * 根据ID查询审计日志
     * @param id 审计日志ID
     * @return 审计日志对象
     */
    @Select("SELECT id, user_id AS userId, username, operation, module, detail, ip, created_at AS createdAt " +
            "FROM sys_audit_log WHERE id = #{id}")
    AuditLog selectById(@Param("id") Long id);

    /**
     * 分页查询所有审计日志
     * @param page 页码
     * @param pageSize 每页大小
     * @return 审计日志列表
     */
    @Select("SELECT id, user_id AS userId, username, operation, module, detail, ip, created_at AS createdAt " +
            "FROM sys_audit_log ORDER BY created_at DESC " +
            "LIMIT #{pageSize} OFFSET #{page}")
    List<AuditLog> selectAll(@Param("page") Integer page, @Param("pageSize") Integer pageSize);

    /**
     * 根据条件搜索审计日志
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @param username 用户名
     * @param operation 操作类型
     * @param page 页码
     * @param pageSize 每页大小
     * @return 审计日志列表
     */
    @Select("<script>" +
            "SELECT id, user_id AS userId, username, operation, module, detail, ip, created_at AS createdAt " +
            "FROM sys_audit_log " +
            "WHERE 1=1 " +
            "<if test='startDate != null'>" +
            "AND created_at &gt;= #{startDate} " +
            "</if>" +
            "<if test='endDate != null'>" +
            "AND created_at &lt;= #{endDate} " +
            "</if>" +
            "<if test='username != null and username != \"\"'>" +
            "AND username LIKE CONCAT('%', #{username}, '%') " +
            "</if>" +
            "<if test='operation != null and operation != \"\"'>" +
            "AND operation = #{operation} " +
            "</if>" +
            "ORDER BY created_at DESC " +
            "LIMIT #{pageSize} OFFSET #{page}" +
            "</script>")
    List<AuditLog> search(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate,
                          @Param("username") String username, @Param("operation") String operation,
                          @Param("page") Integer page, @Param("pageSize") Integer pageSize);

    /**
     * 统计审计日志总数
     * @return 审计日志总数
     */
    @Select("SELECT COUNT(*) FROM sys_audit_log")
    int count();

    /**
     * 根据条件统计审计日志数量
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @param username 用户名
     * @param operation 操作类型
     * @return 审计日志数量
     */
    @Select("<script>" +
            "SELECT COUNT(*) FROM sys_audit_log " +
            "WHERE 1=1 " +
            "<if test='startDate != null'>" +
            "AND created_at &gt;= #{startDate} " +
            "</if>" +
            "<if test='endDate != null'>" +
            "AND created_at &lt;= #{endDate} " +
            "</if>" +
            "<if test='username != null and username != \"\"'>" +
            "AND username LIKE CONCAT('%', #{username}, '%') " +
            "</if>" +
            "<if test='operation != null and operation != \"\"'>" +
            "AND operation = #{operation} " +
            "</if>" +
            "</script>")
    int countByCondition(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate,
                         @Param("username") String username, @Param("operation") String operation);

    /**
     * 插入审计日志
     * @param log 审计日志对象
     * @return 影响行数
     */
    @Insert("INSERT INTO sys_audit_log (user_id, username, operation, module, detail, ip, created_at) " +
            "VALUES (#{userId}, #{username}, #{operation}, #{module}, #{detail}, #{ip}, NOW())")
    int insert(AuditLog log);
}
