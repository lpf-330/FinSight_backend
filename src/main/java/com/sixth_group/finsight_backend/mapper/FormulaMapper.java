package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.Formula;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 公式Mapper接口
 * 负责公式数据的数据库操作
 */
@Mapper
public interface FormulaMapper {
    Formula selectById(@Param("id") Long id);
    List<Formula> selectAll();
    List<Formula> search(@Param("category") String category, @Param("keyword") String keyword);
    int insert(Formula formula);
    int update(Formula formula);
    int deleteById(@Param("id") Long id);
}
