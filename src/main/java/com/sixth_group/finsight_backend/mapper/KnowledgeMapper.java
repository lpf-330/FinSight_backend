package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.Knowledge;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 知识库Mapper接口
 * 负责知识库数据的数据库操作
 */
@Mapper
public interface KnowledgeMapper {
    Knowledge selectById(@Param("id") Long id);
    List<Knowledge> selectAll();
    List<Knowledge> search(@Param("indicator") String indicator, @Param("level") String level);
    int insert(Knowledge knowledge);
    int update(Knowledge knowledge);
    int deleteById(@Param("id") Long id);
}
