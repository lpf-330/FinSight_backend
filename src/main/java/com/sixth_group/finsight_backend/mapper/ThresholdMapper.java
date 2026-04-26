package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.Threshold;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 阈值Mapper接口
 * 负责阈值数据的数据库操作
 */
@Mapper
public interface ThresholdMapper {
    Threshold selectById(@Param("id") Long id);
    Threshold selectByIndicatorCode(@Param("indicatorCode") String indicatorCode);
    List<Threshold> selectAll();
    int insert(Threshold threshold);
    int update(Threshold threshold);
    int deleteById(@Param("id") Long id);
}
