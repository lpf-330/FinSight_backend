package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.WarningRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 预警记录Mapper接口
 * 负责预警记录数据的数据库操作
 */
@Mapper
public interface WarningRecordMapper {
    WarningRecord selectById(@Param("id") Long id);
    List<WarningRecord> selectAll();
    List<WarningRecord> search(@Param("level") String level, @Param("status") String status);
    int countByLevel(@Param("level") String level);
    int insert(WarningRecord record);
    int update(WarningRecord record);
    int deleteById(@Param("id") Long id);
}
