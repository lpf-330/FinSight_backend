package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.InvestmentScheme;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 投资方案Mapper接口
 * 负责投资方案数据的数据库操作
 */
@Mapper
public interface InvestmentSchemeMapper {
    InvestmentScheme selectById(@Param("id") Long id);
    List<InvestmentScheme> selectAll();
    int insert(InvestmentScheme scheme);
    int update(InvestmentScheme scheme);
    int deleteById(@Param("id") Long id);
}
