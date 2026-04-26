package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.ModelVersion;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 模型版本Mapper接口
 * 负责模型版本数据的数据库操作
 */
@Mapper
public interface ModelVersionMapper {
    ModelVersion selectById(@Param("id") Long id);
    List<ModelVersion> selectAll();
    List<ModelVersion> selectByModelType(@Param("modelType") String modelType);
    int insert(ModelVersion version);
    int update(ModelVersion version);
    int deleteById(@Param("id") Long id);
    int setActive(@Param("id") Long id);
}
