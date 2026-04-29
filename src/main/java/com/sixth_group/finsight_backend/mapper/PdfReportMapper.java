package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.PdfReport;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Options;
import java.util.List;

/**
 * PDF报告Mapper接口
 * 负责PDF报告数据的数据库操作
 */
@Mapper
public interface PdfReportMapper {

    /**
     * 根据ID查询PDF报告
     * @param id PDF报告ID
     * @return PDF报告对象
     */
    @Select("SELECT id, name, type, period, status, created_at AS createTime, file_size AS fileSize, creator_name AS creatorName " +
            "FROM report_pdf_report WHERE id = #{id}")
    PdfReport selectById(@Param("id") Long id);

    /**
     * 查询所有PDF报告
     * @return PDF报告列表
     */
    @Select("SELECT id, name, type, period, status, created_at AS createTime, file_size AS fileSize, creator_name AS creatorName " +
            "FROM report_pdf_report ORDER BY created_at DESC")
    List<PdfReport> selectAll();

    /**
     * 插入PDF报告
     * @param report PDF报告对象
     * @return 影响行数
     */
    @Options(useGeneratedKeys = true, keyProperty = "id")
    @Insert("INSERT INTO report_pdf_report (name, type, period, status, file_size, creator_name, created_at) " +
            "VALUES (#{name}, #{type}, #{period}, #{status}, #{fileSize}, #{creatorName}, NOW())")
    int insert(PdfReport report);

    /**
     * 根据ID删除PDF报告
     * @param id PDF报告ID
     * @return 影响行数
     */
    @Delete("DELETE FROM report_pdf_report WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
