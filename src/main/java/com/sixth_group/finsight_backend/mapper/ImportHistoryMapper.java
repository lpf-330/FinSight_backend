package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.ImportHistory;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Delete;
import java.util.List;

/**
 * 导入历史Mapper接口
 * 负责导入历史数据的数据库操作
 */
@Mapper
public interface ImportHistoryMapper {

    /**
     * 根据ID查询导入历史
     * @param id 导入历史ID
     * @return 导入历史对象
     */
    @Select("SELECT id, file_name AS fileName, type, mode, records, status, " +
            "operator_name AS operatorName, created_at AS createdAt " +
            "FROM data_import_record WHERE id = #{id}")
    ImportHistory selectById(@Param("id") Long id);

    /**
     * 分页查询所有导入历史
     * @param page 页码
     * @param pageSize 每页大小
     * @return 导入历史列表
     */
    @Select("SELECT id, file_name AS fileName, type, mode, records, status, " +
            "operator_name AS operatorName, created_at AS createdAt " +
            "FROM data_import_record ORDER BY created_at DESC " +
            "LIMIT #{pageSize} OFFSET #{page}")
    List<ImportHistory> selectAll(@Param("page") Integer page, @Param("pageSize") Integer pageSize);

    /**
     * 根据类型和状态搜索导入历史
     * @param type 报表类型
     * @param status 状态
     * @param page 页码
     * @param pageSize 每页大小
     * @return 导入历史列表
     */
    @Select("<script>" +
            "SELECT id, file_name AS fileName, type, mode, records, status, " +
            "operator_name AS operatorName, created_at AS createdAt " +
            "FROM data_import_record " +
            "WHERE 1=1 " +
            "<if test='type != null and type != \"\"'>" +
            "AND type = #{type} " +
            "</if>" +
            "<if test='status != null and status != \"\"'>" +
            "AND status = #{status} " +
            "</if>" +
            "ORDER BY created_at DESC " +
            "LIMIT #{pageSize} OFFSET #{page}" +
            "</script>")
    List<ImportHistory> search(@Param("type") String type, @Param("status") String status, 
                               @Param("page") Integer page, @Param("pageSize") Integer pageSize);

    /**
     * 统计导入历史总数
     * @return 导入历史总数
     */
    @Select("SELECT COUNT(*) FROM data_import_record")
    int count();

    /**
     * 根据条件统计导入历史数量
     * @param type 报表类型
     * @param status 状态
     * @return 导入历史数量
     */
    @Select("<script>" +
            "SELECT COUNT(*) FROM data_import_record " +
            "WHERE 1=1 " +
            "<if test='type != null and type != \"\"'>" +
            "AND type = #{type} " +
            "</if>" +
            "<if test='status != null and status != \"\"'>" +
            "AND status = #{status} " +
            "</if>" +
            "</script>")
    int countByCondition(@Param("type") String type, @Param("status") String status);

    /**
     * 插入导入历史
     * @param history 导入历史对象
     * @return 影响行数
     */
    @Insert("INSERT INTO data_import_record (file_name, type, mode, records, status, operator_name, created_at) " +
            "VALUES (#{fileName}, #{type}, #{mode}, #{records}, #{status}, #{operatorName}, NOW())")
    int insert(ImportHistory history);

    /**
     * 根据ID删除导入历史
     * @param id 导入历史ID
     * @return 影响行数
     */
    @Delete("DELETE FROM data_import_record WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
