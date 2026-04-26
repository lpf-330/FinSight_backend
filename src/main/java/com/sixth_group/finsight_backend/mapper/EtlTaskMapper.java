package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.EtlTask;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * ETL任务Mapper接口
 * 负责ETL任务数据的数据库操作
 */
@Mapper
public interface EtlTaskMapper {
    EtlTask selectById(@Param("id") Long id);
    List<EtlTask> selectAll();
    List<EtlTask> selectByStatus(@Param("status") String status);
    int insert(EtlTask task);
    int update(EtlTask task);
    int deleteById(@Param("id") Long id);
}
