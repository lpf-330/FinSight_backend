package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.AccountMapping;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Delete;
import java.util.List;

/**
 * 科目映射Mapper接口
 * 负责科目映射数据的数据库操作
 */
@Mapper
public interface AccountMappingMapper {

    /**
     * 根据ID查询科目映射
     * @param id 科目映射ID
     * @return 科目映射对象
     */
    @Select("SELECT id, k8_code AS k8Code, k8_name AS k8Name, target_code AS targetCode, " +
            "target_name AS targetName, category, enabled " +
            "FROM data_subject_mapping WHERE id = #{id}")
    AccountMapping selectById(@Param("id") Long id);

    /**
     * 查询所有科目映射
     * @return 科目映射列表
     */
    @Select("SELECT id, k8_code AS k8Code, k8_name AS k8Name, target_code AS targetCode, " +
            "target_name AS targetName, category, enabled " +
            "FROM data_subject_mapping ORDER BY category, k8_code")
    List<AccountMapping> selectAll();

    /**
     * 根据分类查询科目映射
     * @param category 科目类别
     * @return 科目映射列表
     */
    @Select("SELECT id, k8_code AS k8Code, k8_name AS k8Name, target_code AS targetCode, " +
            "target_name AS targetName, category, enabled " +
            "FROM data_subject_mapping WHERE category = #{category} ORDER BY k8_code")
    List<AccountMapping> selectByCategory(@Param("category") String category);

    /**
     * 插入科目映射
     * @param mapping 科目映射对象
     * @return 影响行数
     */
    @Insert("INSERT INTO data_subject_mapping (k8_code, k8_name, target_code, target_name, category, enabled, created_at, updated_at) " +
            "VALUES (#{k8Code}, #{k8Name}, #{targetCode}, #{targetName}, #{category}, #{enabled}, NOW(), NOW())")
    int insert(AccountMapping mapping);

    /**
     * 更新科目映射
     * @param mapping 科目映射对象
     * @return 影响行数
     */
    @Update("UPDATE data_subject_mapping SET k8_code = #{k8Code}, k8_name = #{k8Name}, " +
            "target_code = #{targetCode}, target_name = #{targetName}, category = #{category}, " +
            "enabled = #{enabled}, updated_at = NOW() WHERE id = #{id}")
    int update(AccountMapping mapping);

    /**
     * 根据ID删除科目映射
     * @param id 科目映射ID
     * @return 影响行数
     */
    @Delete("DELETE FROM data_subject_mapping WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
