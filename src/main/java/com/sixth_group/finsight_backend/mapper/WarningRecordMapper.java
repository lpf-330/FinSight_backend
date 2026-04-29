package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.WarningRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Delete;
import java.util.List;

/**
 * 预警记录Mapper接口
 * 负责预警记录数据的数据库操作
 */
@Mapper
public interface WarningRecordMapper {

    /**
     * 根据ID查询预警记录
     * @param id 预警记录ID
     * @return 预警记录对象
     */
    @Select("SELECT id, indicator, indicator_code AS indicatorCode, level, current_value AS currentValue, " +
            "yellow_threshold AS yellowThreshold, orange_threshold AS orangeThreshold, red_threshold AS redThreshold, " +
            "trend, suggestion, status, fiscal_period AS fiscalPeriod, triggered_at AS triggeredAt " +
            "FROM algo_warning_record WHERE id = #{id}")
    WarningRecord selectById(@Param("id") Long id);

    /**
     * 查询所有预警记录
     * @return 预警记录列表
     */
    @Select("SELECT id, indicator, indicator_code AS indicatorCode, level, current_value AS currentValue, " +
            "yellow_threshold AS yellowThreshold, orange_threshold AS orangeThreshold, red_threshold AS redThreshold, " +
            "trend, suggestion, status, period, triggered_at AS triggeredAt " +
            "FROM algo_warning_record ORDER BY triggered_at DESC")
    List<WarningRecord> selectAll();

    /**
     * 根据级别和状态搜索预警记录
     * @param level 预警级别
     * @param status 状态
     * @return 预警记录列表
     */
    @Select("<script>" +
            "SELECT id, indicator, indicator_code AS indicatorCode, level, current_value AS currentValue, " +
            "yellow_threshold AS yellowThreshold, orange_threshold AS orangeThreshold, red_threshold AS redThreshold, " +
            "trend, suggestion, status, fiscal_period AS fiscalPeriod, triggered_at AS triggeredAt " +
            "FROM algo_warning_record " +
            "WHERE 1=1 " +
            "<if test='level != null and level != \"\"'>" +
            "AND level = #{level} " +
            "</if>" +
            "<if test='status != null and status != \"\"'>" +
            "AND status = #{status} " +
            "</if>" +
            "ORDER BY triggered_at DESC" +
            "</script>")
    List<WarningRecord> search(@Param("level") String level, @Param("status") String status);

    /**
     * 根据级别统计预警记录数量
     * @param level 预警级别
     * @return 预警记录数量
     */
    @Select("SELECT COUNT(*) FROM algo_warning_record WHERE level = #{level}")
    int countByLevel(@Param("level") String level);

    /**
     * 插入预警记录
     * @param record 预警记录对象
     * @return 影响行数
     */
    @Insert("INSERT INTO algo_warning_record (indicator, indicator_code, level, current_value, " +
            "yellow_threshold, orange_threshold, red_threshold, trend, suggestion, status, fiscal_period, triggered_at) " +
            "VALUES (#{indicator}, #{indicatorCode}, #{level}, #{currentValue}, " +
            "#{yellowThreshold}, #{orangeThreshold}, #{redThreshold}, #{trend}, #{suggestion}, #{status}, #{fiscalPeriod}, NOW())")
    int insert(WarningRecord record);

    /**
     * 更新预警记录
     * @param record 预警记录对象
     * @return 影响行数
     */
    @Update("UPDATE algo_warning_record SET indicator = #{indicator}, indicator_code = #{indicatorCode}, " +
            "level = #{level}, current_value = #{currentValue}, " +
            "yellow_threshold = #{yellowThreshold}, orange_threshold = #{orangeThreshold}, red_threshold = #{redThreshold}, " +
            "trend = #{trend}, suggestion = #{suggestion}, status = #{status}, period = #{period} " +
            "WHERE id = #{id}")
    int update(WarningRecord record);

    /**
     * 根据ID删除预警记录
     * @param id 预警记录ID
     * @return 影响行数
     */
    @Delete("DELETE FROM algo_warning_record WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
