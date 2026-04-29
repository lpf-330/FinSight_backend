package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.Role;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Delete;
import java.util.List;

/**
 * 角色Mapper接口
 * 负责角色数据的数据库操作
 */
@Mapper
public interface RoleMapper {

    /**
     * 根据ID查询角色
     * @param id 角色ID
     * @return 角色对象
     */
    @Select("SELECT id, name, code, description, created_at AS createdAt " +
            "FROM sys_role WHERE id = #{id}")
    Role selectById(@Param("id") Long id);

    /**
     * 根据角色编码查询角色
     * @param code 角色编码
     * @return 角色对象
     */
    @Select("SELECT id, name, code, description, created_at AS createdAt " +
            "FROM sys_role WHERE code = #{code}")
    Role selectByCode(@Param("code") String code);

    /**
     * 查询所有角色
     * @return 角色列表
     */
    @Select("SELECT id, name, code, description, created_at AS createdAt FROM sys_role")
    List<Role> selectAll();

    /**
     * 插入角色
     * @param role 角色对象
     * @return 影响行数
     */
    @Insert("INSERT INTO sys_role (name, code, description, created_at, updated_at) " +
            "VALUES (#{name}, #{code}, #{description}, NOW(), NOW())")
    int insert(Role role);

    /**
     * 更新角色
     * @param role 角色对象
     * @return 影响行数
     */
    @Update("UPDATE sys_role SET name = #{name}, code = #{code}, description = #{description}, " +
            "updated_at = NOW() WHERE id = #{id}")
    int update(Role role);

    /**
     * 根据ID删除角色
     * @param id 角色ID
     * @return 影响行数
     */
    @Delete("DELETE FROM sys_role WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
