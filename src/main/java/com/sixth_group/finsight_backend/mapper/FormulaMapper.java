package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.Formula;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Delete;
import java.util.List;

/**
 * 公式Mapper接口
 * 负责公式数据的数据库操作
 */
@Mapper
public interface FormulaMapper {

    /**
     * 根据ID查询公式
     * @param id 公式ID
     * @return 公式对象
     */
    @Select("SELECT id, name, expression, category, enabled, version, updated_at AS updateTime " +
            "FROM config_formula WHERE id = #{id}")
    Formula selectById(@Param("id") Long id);

    /**
     * 查询所有公式
     * @return 公式列表
     */
    @Select("SELECT id, name, expression, category, enabled, version, updated_at AS updateTime " +
            "FROM config_formula ORDER BY category, id")
    List<Formula> selectAll();

    /**
     * 根据分类和关键字搜索公式
     * @param category 分类
     * @param keyword 关键字
     * @return 公式列表
     */
    @Select("<script>" +
            "SELECT id, name, expression, category, enabled, version, updated_at AS updateTime " +
            "FROM config_formula " +
            "WHERE 1=1 " +
            "<if test='category != null and category != \"\"'>" +
            "AND category = #{category} " +
            "</if>" +
            "<if test='keyword != null and keyword != \"\"'>" +
            "AND (name LIKE CONCAT('%', #{keyword}, '%') OR expression LIKE CONCAT('%', #{keyword}, '%')) " +
            "</if>" +
            "ORDER BY category, id" +
            "</script>")
    List<Formula> search(@Param("category") String category, @Param("keyword") String keyword);

    /**
     * 插入公式
     * @param formula 公式对象
     * @return 影响行数
     */
    @Options(useGeneratedKeys = true, keyProperty = "id")
    @Insert("INSERT INTO config_formula (name, expression, category, enabled, version, created_at, updated_at) " +
            "VALUES (#{name}, #{expression}, #{category}, #{enabled}, #{version}, NOW(), NOW())")
    int insert(Formula formula);

    /**
     * 更新公式
     * @param formula 公式对象
     * @return 影响行数
     */
    @Update("UPDATE config_formula SET name = #{name}, expression = #{expression}, " +
            "category = #{category}, enabled = #{enabled}, version = #{version}, updated_at = NOW() " +
            "WHERE id = #{id}")
    int update(Formula formula);

    /**
     * 根据ID删除公式
     * @param id 公式ID
     * @return 影响行数
     */
    @Delete("DELETE FROM config_formula WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
