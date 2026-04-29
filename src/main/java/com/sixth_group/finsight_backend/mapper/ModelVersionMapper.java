package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.ModelVersion;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Options;
import java.util.List;

/**
 * 模型版本Mapper接口
 * 负责模型版本数据的数据库操作
 */
@Mapper
public interface ModelVersionMapper {

    /**
     * 根据ID查询模型版本
     * @param id 模型版本ID
     * @return 模型版本对象
     */
    @Select("SELECT id, model_type AS modelType, version, description, creator, " +
            "is_active AS isActive, created_at AS createdAt " +
            "FROM config_model_version WHERE id = #{id}")
    ModelVersion selectById(@Param("id") Long id);

    /**
     * 查询所有模型版本
     * @return 模型版本列表
     */
    @Select("SELECT id, model_type AS modelType, version, description, creator, " +
            "is_active AS isActive, created_at AS createdAt " +
            "FROM config_model_version ORDER BY model_type, created_at DESC")
    List<ModelVersion> selectAll();

    /**
     * 根据模型类型查询模型版本
     * @param modelType 模型类型
     * @return 模型版本列表
     */
    @Select("SELECT id, model_type AS modelType, version, description, creator, " +
            "is_active AS isActive, created_at AS createdAt " +
            "FROM config_model_version WHERE model_type = #{modelType} ORDER BY created_at DESC")
    List<ModelVersion> selectByModelType(@Param("modelType") String modelType);

    /**
     * 插入模型版本
     * @param version 模型版本对象
     * @return 影响行数
     */
    @Options(useGeneratedKeys = true, keyProperty = "id")
    @Insert("INSERT INTO config_model_version (model_type, version, description, creator, is_active, created_at) " +
            "VALUES (#{modelType}, #{version}, #{description}, #{creator}, #{isActive}, NOW())")
    int insert(ModelVersion version);

    /**
     * 更新模型版本
     * @param version 模型版本对象
     * @return 影响行数
     */
    @Update("UPDATE config_model_version SET model_type = #{modelType}, version = #{version}, " +
            "description = #{description}, creator = #{creator}, is_active = #{isActive} " +
            "WHERE id = #{id}")
    int update(ModelVersion version);

    /**
     * 根据ID删除模型版本
     * @param id 模型版本ID
     * @return 影响行数
     */
    @Delete("DELETE FROM config_model_version WHERE id = #{id}")
    int deleteById(@Param("id") Long id);

    /**
     * 设置指定类型的所有版本为非激活状态
     * @param modelType 模型类型
     * @return 影响行数
     */
    @Update("UPDATE config_model_version SET is_active = 0 WHERE model_type = #{modelType}")
    int deactivateByModelType(@Param("modelType") String modelType);

    /**
     * 设置指定版本为激活状态
     * @param id 模型版本ID
     * @return 影响行数
     */
    @Update("UPDATE config_model_version SET is_active = 1 WHERE id = #{id}")
    int activateById(@Param("id") Long id);
}
