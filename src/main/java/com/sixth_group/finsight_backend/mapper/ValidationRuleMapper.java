package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.ValidationRule;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 验证规则Mapper接口
 * 负责验证规则数据的数据库操作
 */
@Mapper
public interface ValidationRuleMapper {
    ValidationRule selectById(@Param("id") Long id);
    List<ValidationRule> selectAll();
    int insert(ValidationRule rule);
    int update(ValidationRule rule);
    int deleteById(@Param("id") Long id);
}
