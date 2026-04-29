package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.ValidationRule;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Delete;
import java.util.List;

/**
 * 验证规则Mapper接口
 * 负责验证规则数据的数据库操作
 */
@Mapper
public interface ValidationRuleMapper {

    /**
     * 根据ID查询验证规则
     * @param id 验证规则ID
     * @return 验证规则对象
     */
    @Select("SELECT id, name, expression, level, message, enabled, created_at AS createdAt " +
            "FROM data_validation_rule WHERE id = #{id}")
    ValidationRule selectById(@Param("id") Long id);

    /**
     * 查询所有验证规则
     * @return 验证规则列表
     */
    @Select("SELECT id, name, expression, level, message, enabled, created_at AS createdAt " +
            "FROM data_validation_rule ORDER BY id")
    List<ValidationRule> selectAll();

    /**
     * 插入验证规则
     * @param rule 验证规则对象
     * @return 影响行数
     */
    @Insert("INSERT INTO data_validation_rule (name, expression, level, message, enabled, created_at, updated_at) " +
            "VALUES (#{name}, #{expression}, #{level}, #{message}, #{enabled}, NOW(), NOW())")
    int insert(ValidationRule rule);

    /**
     * 更新验证规则
     * @param rule 验证规则对象
     * @return 影响行数
     */
    @Update("UPDATE data_validation_rule SET name = #{name}, expression = #{expression}, " +
            "level = #{level}, message = #{message}, enabled = #{enabled}, updated_at = NOW() " +
            "WHERE id = #{id}")
    int update(ValidationRule rule);

    /**
     * 根据ID删除验证规则
     * @param id 验证规则ID
     * @return 影响行数
     */
    @Delete("DELETE FROM data_validation_rule WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
