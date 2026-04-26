package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.AccountMapping;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 科目映射Mapper接口
 * 负责科目映射数据的数据库操作
 */
@Mapper
public interface AccountMappingMapper {
    AccountMapping selectById(@Param("id") Long id);
    List<AccountMapping> selectAll();
    List<AccountMapping> selectByCategory(@Param("category") String category);
    int insert(AccountMapping mapping);
    int update(AccountMapping mapping);
    int deleteById(@Param("id") Long id);
}
