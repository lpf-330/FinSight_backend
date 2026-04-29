package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.EtlTask;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Delete;
import java.util.List;

/**
 * ETL任务Mapper接口
 * 负责ETL任务数据的数据库操作
 */
@Mapper
public interface EtlTaskMapper {

    /**
     * 根据ID查询ETL任务
     * @param id ETL任务ID
     * @return ETL任务对象
     */
    @Select("SELECT id, name, source, target, cron, status, " +
            "last_run AS lastRun, next_run AS nextRun, last_records AS records, last_duration AS duration " +
            "FROM data_etl_task WHERE id = #{id}")
    EtlTask selectById(@Param("id") Long id);

    /**
     * 查询所有ETL任务
     * @return ETL任务列表
     */
    @Select("SELECT id, name, source, target, cron, status, " +
            "last_run AS lastRun, next_run AS nextRun, last_records AS records, last_duration AS duration " +
            "FROM data_etl_task ORDER BY id")
    List<EtlTask> selectAll();

    /**
     * 根据状态查询ETL任务
     * @param status 任务状态
     * @return ETL任务列表
     */
    @Select("SELECT id, name, source, target, cron, status, " +
            "last_run AS lastRun, next_run AS nextRun, last_records AS records, last_duration AS duration " +
            "FROM data_etl_task WHERE status = #{status} ORDER BY id")
    List<EtlTask> selectByStatus(@Param("status") String status);

    /**
     * 插入ETL任务
     * @param task ETL任务对象
     * @return 影响行数
     */
    @Insert("INSERT INTO data_etl_task (name, source, target, cron, status, last_run, next_run, last_records, last_duration, created_at, updated_at) " +
            "VALUES (#{name}, #{source}, #{target}, #{cron}, #{status}, #{lastRun}, #{nextRun}, #{records}, #{duration}, NOW(), NOW())")
    int insert(EtlTask task);

    /**
     * 更新ETL任务
     * @param task ETL任务对象
     * @return 影响行数
     */
    @Update("UPDATE data_etl_task SET name = #{name}, source = #{source}, target = #{target}, " +
            "cron = #{cron}, status = #{status}, last_run = #{lastRun}, next_run = #{nextRun}, " +
            "last_records = #{records}, last_duration = #{duration}, updated_at = NOW() WHERE id = #{id}")
    int update(EtlTask task);

    /**
     * 根据ID删除ETL任务
     * @param id ETL任务ID
     * @return 影响行数
     */
    @Delete("DELETE FROM data_etl_task WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
