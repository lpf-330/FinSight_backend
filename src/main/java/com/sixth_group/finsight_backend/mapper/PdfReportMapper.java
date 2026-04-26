package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.PdfReport;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * PDF报告Mapper接口
 * 负责PDF报告数据的数据库操作
 */
@Mapper
public interface PdfReportMapper {
    PdfReport selectById(@Param("id") Long id);
    List<PdfReport> selectAll();
    int insert(PdfReport report);
    int deleteById(@Param("id") Long id);
}
