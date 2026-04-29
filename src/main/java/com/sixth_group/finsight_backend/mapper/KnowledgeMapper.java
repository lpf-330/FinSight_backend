package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.Knowledge;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Update;
import java.util.List;

/**
 * 知识库Mapper接口
 * 负责知识库数据的数据库操作
 */
@Mapper
public interface KnowledgeMapper {

        /**
         * 根据ID查询知识
         * 
         * @param id 知识ID
         * @return 知识对象
         */
        @Select("SELECT id, indicator, level, content, version, " +
                        "useful_count AS usefulCount, useless_count AS uselessCount, updated_at AS updateTime " +
                        "FROM config_knowledge WHERE id = #{id}")
        Knowledge selectById(@Param("id") Long id);

        /**
         * 查询所有知识
         * 
         * @return 知识列表
         */
        @Select("SELECT id, indicator, level, content, version, " +
                        "useful_count AS usefulCount, useless_count AS uselessCount, updated_at AS updateTime " +
                        "FROM config_knowledge ORDER BY indicator, level")
        List<Knowledge> selectAll();

        /**
         * 根据指标和级别搜索知识
         * 
         * @param indicator 指标名称
         * @param level     预警级别
         * @return 知识列表
         */
        @Select("<script>" +
                        "SELECT id, indicator, level, content, version, " +
                        "useful_count AS usefulCount, useless_count AS uselessCount, updated_at AS updateTime " +
                        "FROM config_knowledge " +
                        "WHERE 1=1 " +
                        "<if test='indicator != null and indicator != \"\"'>" +
                        "AND indicator LIKE CONCAT('%', #{indicator}, '%') " +
                        "</if>" +
                        "<if test='level != null and level != \"\"'>" +
                        "AND level = #{level} " +
                        "</if>" +
                        "ORDER BY indicator, level" +
                        "</script>")
        List<Knowledge> search(@Param("indicator") String indicator, @Param("level") String level);

        /**
         * 插入知识
         * 
         * @param knowledge 知识对象
         * @return 影响行数
         */
        @Options(useGeneratedKeys = true, keyProperty = "id")
        @Insert("INSERT INTO config_knowledge (indicator, level, content, version, useful_count, useless_count, created_at, updated_at) "
                        +
                        "VALUES (#{indicator}, #{level}, #{content}, #{version}, #{usefulCount}, #{uselessCount}, NOW(), NOW())")
        int insert(Knowledge knowledge);

        /**
         * 根据ID删除知识库
         * 
         * @param id 知识库ID
         * @return 影响行数
         */
        @Delete("DELETE FROM config_knowledge WHERE id = #{id}")
        int deleteById(@Param("id") Long id);

        /**
         * 更新知识库
         * 
         * @param knowledge 知识库对象
         * @return 影响行数
         */
        @Update("UPDATE config_knowledge SET content = #{content}, version = #{version}, useful_count = #{usefulCount}, useless_count = #{uselessCount}, updated_at = NOW() "
                        +
                        "WHERE id = #{id}")
        int update(Knowledge knowledge);
}
