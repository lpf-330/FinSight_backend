package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.Role;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 角色Mapper接口
 * 负责角色数据的数据库操作
 */
@Mapper
public interface RoleMapper {
    Role selectById(@Param("id") Long id);
    Role selectByCode(@Param("code") String code);
    List<Role> selectAll();
    int insert(Role role);
    int update(Role role);
    int deleteById(@Param("id") Long id);
}
