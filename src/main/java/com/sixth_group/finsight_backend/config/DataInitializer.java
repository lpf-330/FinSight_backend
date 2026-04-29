package com.sixth_group.finsight_backend.config;

import com.sixth_group.finsight_backend.entity.User;
import com.sixth_group.finsight_backend.entity.Role;
import com.sixth_group.finsight_backend.mapper.UserMapper;
import com.sixth_group.finsight_backend.mapper.RoleMapper;
import com.sixth_group.finsight_backend.utils.PasswordUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 数据初始化器
 * 在应用启动时自动创建测试用户和角色数据
 */
@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private RoleMapper roleMapper;

    /**
     * 应用启动后执行数据初始化
     * 
     * @param args 命令行参数
     * @throws Exception 初始化异常
     */
    @Override
    public void run(String... args) throws Exception {
        initRoles();
        initUsers();
    }

    /**
     * 初始化角色数据
     */
    private void initRoles() {
        // 检查是否已存在角色数据
        if (roleMapper.selectByCode("ADMIN") == null) {
            Role adminRole = new Role();
            adminRole.setName("系统管理员");
            adminRole.setCode("ADMIN");
            adminRole.setDescription("拥有所有功能权限");
            adminRole.setCreatedAt(LocalDateTime.now());
            roleMapper.insert(adminRole);
            System.out.println("已创建管理员角色");
        }
    }

    /**
     * 初始化用户数据
     */
    private void initUsers() {
        // 获取管理员角色
        Role adminRole = roleMapper.selectByCode("ADMIN");
        if (adminRole == null) {
            System.out.println("警告: 未找到管理员角色，跳过用户初始化");
            return;
        }

        // 检查是否已存在admin用户
        if (userMapper.selectByUsername("admin") == null) {
            // 创建admin用户
            User admin = new User();
            admin.setUsername("admin");
            admin.setPassword(PasswordUtil.hashPassword("123456"));
            admin.setName("系统管理员");
            admin.setDepartment("信息部");
            admin.setRoleId(adminRole.getId());
            admin.setStatus("active");
            admin.setCreatedAt(LocalDateTime.now());
            userMapper.insert(admin);
            System.out.println("已创建admin用户，密码: 123456");
        }

        // 创建测试用户
        if (userMapper.selectByUsername("testuser") == null) {
            User testUser = new User();
            testUser.setUsername("testuser");
            testUser.setPassword(PasswordUtil.hashPassword("123456"));
            testUser.setName("测试用户");
            testUser.setDepartment("测试部");
            testUser.setRoleId(adminRole.getId());
            testUser.setStatus("active");
            testUser.setCreatedAt(LocalDateTime.now());
            userMapper.insert(testUser);
            System.out.println("已创建testuser用户，密码: 123456");
        }
    }
}
