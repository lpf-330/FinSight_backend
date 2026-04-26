package com.sixth_group.finsight_backend.utils;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 密码工具类
 * 使用 bcrypt 算法进行密码哈希处理和验证
 */
public class PasswordUtil {

    private static final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    /**
     * 将明文密码哈希化
     * @param rawPassword 明文密码
     * @return 哈希后的密码
     */
    public static String hashPassword(String rawPassword) {
        return encoder.encode(rawPassword);
    }

    /**
     * 验证密码是否正确
     * @param rawPassword 用户输入的明文密码
     * @param hashedPassword 数据库中存储的哈希密码
     * @return 密码是否匹配
     */
    public static boolean verifyPassword(String rawPassword, String hashedPassword) {
        return encoder.matches(rawPassword, hashedPassword);
    }
}
