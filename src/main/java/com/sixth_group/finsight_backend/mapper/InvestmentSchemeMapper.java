package com.sixth_group.finsight_backend.mapper;

import com.sixth_group.finsight_backend.entity.InvestmentScheme;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Delete;
import java.util.List;

/**
 * 投资方案Mapper接口
 * 负责投资方案数据的数据库操作
 */
@Mapper
public interface InvestmentSchemeMapper {

    /**
     * 根据ID查询投资方案
     * @param id 投资方案ID
     * @return 投资方案对象
     */
    @Select("SELECT id, project_name AS projectName, initial_investment AS initialInvestment, " +
            "discount_rate AS discountRate, cash_flows AS cashFlows, npv, irr, " +
            "static_payback AS staticPayback, dynamic_payback AS dynamicPayback, created_at AS createdAt " +
            "FROM algo_investment_scheme WHERE id = #{id}")
    InvestmentScheme selectById(@Param("id") Long id);

    /**
     * 查询所有投资方案
     * @return 投资方案列表
     */
    @Select("SELECT id, project_name AS projectName, initial_investment AS initialInvestment, " +
            "discount_rate AS discountRate, cash_flows AS cashFlows, npv, irr, " +
            "static_payback AS staticPayback, dynamic_payback AS dynamicPayback, created_at AS createdAt " +
            "FROM algo_investment_scheme ORDER BY created_at DESC")
    List<InvestmentScheme> selectAll();

    /**
     * 插入投资方案
     * @param scheme 投资方案对象
     * @return 影响行数
     */
    @Insert("INSERT INTO algo_investment_scheme (project_name, initial_investment, discount_rate, " +
            "cash_flows, npv, irr, static_payback, dynamic_payback, created_at) " +
            "VALUES (#{projectName}, #{initialInvestment}, #{discountRate}, " +
            "#{cashFlows}, #{npv}, #{irr}, #{staticPayback}, #{dynamicPayback}, NOW())")
    int insert(InvestmentScheme scheme);

    /**
     * 更新投资方案
     * @param scheme 投资方案对象
     * @return 影响行数
     */
    @Update("UPDATE algo_investment_scheme SET project_name = #{projectName}, " +
            "initial_investment = #{initialInvestment}, discount_rate = #{discountRate}, " +
            "cash_flows = #{cashFlows}, npv = #{npv}, irr = #{irr}, " +
            "static_payback = #{staticPayback}, dynamic_payback = #{dynamicPayback} " +
            "WHERE id = #{id}")
    int update(InvestmentScheme scheme);

    /**
     * 根据ID删除投资方案
     * @param id 投资方案ID
     * @return 影响行数
     */
    @Delete("DELETE FROM algo_investment_scheme WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
