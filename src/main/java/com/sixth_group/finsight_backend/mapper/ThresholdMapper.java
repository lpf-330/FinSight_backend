package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.Threshold;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Delete;
import java.util.List;

/**
 * 阈值Mapper接口
 * 负责阈值数据的数据库操作
 */
@Mapper
public interface ThresholdMapper {

        /**
         * 根据ID查询阈值
         * 
         * @param id 阈值ID
         * @return 阈值对象
         */
        @Select("SELECT id, indicator, indicator_code AS indicatorCode, direction, " +
                        "yellow_value AS yellowValue, orange_value AS orangeValue, red_value AS redValue, " +
                        "dynamic_base AS dynamicBase, updated_at AS updateTime " +
                        "FROM config_threshold WHERE id = #{id}")
        Threshold selectById(@Param("id") Long id);

        /**
         * 根据指标编码查询阈值
         * 
         * @param indicatorCode 指标编码
         * @return 阈值对象
         */
        @Select("SELECT id, indicator, indicator_code AS indicatorCode, direction, " +
                        "yellow_value AS yellowValue, orange_value AS orangeValue, red_value AS redValue, " +
                        "dynamic_base AS dynamicBase, updated_at AS updateTime " +
                        "FROM config_threshold WHERE indicator_code = #{indicatorCode}")
        Threshold selectByIndicatorCode(@Param("indicatorCode") String indicatorCode);

        /**
         * 查询所有阈值
         * 
         * @return 阈值列表
         */
        @Select("SELECT id, indicator, indicator_code AS indicatorCode, direction, " +
                        "yellow_value AS yellowValue, orange_value AS orangeValue, red_value AS redValue, " +
                        "dynamic_base AS dynamicBase, updated_at AS updateTime " +
                        "FROM config_threshold ORDER BY indicator_code")
        List<Threshold> selectAll();

        /**
         * 插入阈值
         * 
         * @param threshold 阈值对象
         * @return 影响行数
         */
        @Options(useGeneratedKeys = true, keyProperty = "id")
        @Insert("INSERT INTO config_threshold (indicator, indicator_code, direction, " +
                        "yellow_value, orange_value, red_value, dynamic_base, created_at, updated_at) " +
                        "VALUES (#{indicator}, #{indicatorCode}, #{direction}, " +
                        "#{yellowValue}, #{orangeValue}, #{redValue}, #{dynamicBase}, NOW(), NOW())")
        int insert(Threshold threshold);

        /**
         * 更新阈值
         * 
         * @param threshold 阈值对象
         * @return 影响行数
         */
        @Update("UPDATE config_threshold SET indicator = #{indicator}, indicator_code = #{indicatorCode}, " +
                        "direction = #{direction}, yellow_value = #{yellowValue}, orange_value = #{orangeValue}, " +
                        "red_value = #{redValue}, dynamic_base = #{dynamicBase}, updated_at = NOW() " +
                        "WHERE id = #{id}")
        int update(Threshold threshold);

        /**
         * 根据ID删除阈值
         * 
         * @param id 阈值ID
         * @return 影响行数
         */
        @Delete("DELETE FROM config_threshold WHERE id = #{id}")
        int deleteById(@Param("id") Long id);
}
