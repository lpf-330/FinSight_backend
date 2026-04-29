package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Options;
import java.util.List;

/**
 * 用户Mapper接口
 * 负责用户数据的数据库操作
 */
@Mapper
public interface UserMapper {

    /**
     * 根据ID查询用户
     */
    @Select("SELECT id, username, password_hash AS password, name, department, role_id AS roleId, " +
            "status, last_login AS lastLogin, created_at AS createdAt, updated_at AS updatedAt " +
            "FROM sys_user WHERE id = #{id}")
    User selectById(@Param("id") Long id);

    /**
     * 根据用户名查询用户
     */
    @Select("SELECT id, username, password_hash AS password, name, department, role_id AS roleId, " +
            "status, last_login AS lastLogin, created_at AS createdAt, updated_at AS updatedAt " +
            "FROM sys_user WHERE username = #{username}")
    User selectByUsername(@Param("username") String username);

    /**
     * 查询所有用户
     */
    @Select("SELECT id, username, password_hash AS password, name, department, role_id AS roleId, " +
            "status, last_login AS lastLogin, created_at AS createdAt, updated_at AS updatedAt " +
            "FROM sys_user")
    List<User> selectAll();

    /**
     * 搜索用户（支持关键字、角色ID、状态过滤）
     */
    @Select("<script>" +
            "SELECT id, username, password_hash AS password, name, department, role_id AS roleId, " +
            "status, last_login AS lastLogin, created_at AS createdAt, updated_at AS updatedAt " +
            "FROM sys_user " +
            "WHERE 1=1 " +
            "<if test='keyword != null and keyword != \"\"'>" +
            "AND (username LIKE CONCAT('%', #{keyword}, '%') OR name LIKE CONCAT('%', #{keyword}, '%') OR department LIKE CONCAT('%', #{keyword}, '%')) "
            +
            "</if>" +
            "<if test='roleId != null'>" +
            "AND role_id = #{roleId} " +
            "</if>" +
            "<if test='status != null and status != \"\"'>" +
            "AND status = #{status} " +
            "</if>" +
            "</script>")
    List<User> search(@Param("keyword") String keyword, @Param("roleId") Long roleId, @Param("status") String status);

    /**
     * 插入用户
     */
    @Options(useGeneratedKeys = true, keyProperty = "id")
    @Insert("INSERT INTO sys_user (username, password_hash, name, department, role_id, status, last_login, created_at, updated_at) "
            +
            "VALUES (#{username}, #{password}, #{name}, #{department}, #{roleId}, #{status}, #{lastLogin}, NOW(), NOW())")
    int insert(User user);

    /**
     * 更新用户
     */
    @Update("UPDATE sys_user SET username = #{username}, name = #{name}, department = #{department}, " +
            "role_id = #{roleId}, status = #{status}, updated_at = NOW() WHERE id = #{id}")
    int update(User user);

    /**
     * 根据ID删除用户
     */
    @Delete("DELETE FROM sys_user WHERE id = #{id}")
    int deleteById(@Param("id") Long id);

    /**
     * 更新用户密码
     */
    @Update("UPDATE sys_user SET password_hash = #{password}, updated_at = NOW() WHERE id = #{id}")
    int updatePassword(@Param("id") Long id, @Param("password") String password);
}
