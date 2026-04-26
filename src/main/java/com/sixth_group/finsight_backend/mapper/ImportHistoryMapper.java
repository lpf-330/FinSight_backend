package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.ImportHistory;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 导入历史Mapper接口
 * 负责导入历史数据的数据库操作
 */
@Mapper
public interface ImportHistoryMapper {
    ImportHistory selectById(@Param("id") Long id);
    List<ImportHistory> selectAll(@Param("page") Integer page, @Param("pageSize") Integer pageSize);
    List<ImportHistory> search(@Param("type") String type, @Param("status") String status, @Param("page") Integer page, @Param("pageSize") Integer pageSize);
    int count();
    int countByCondition(@Param("type") String type, @Param("status") String status);
    int insert(ImportHistory history);
    int deleteById(@Param("id") Long id);
}
