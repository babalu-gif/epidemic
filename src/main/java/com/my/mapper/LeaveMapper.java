package com.my.mapper;

import com.my.entity.Leave;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface LeaveMapper {
    List<Leave> getLeavesByCondition(Leave leave);

    List<Leave> getLeavesByConditionAndClassId(@Param("leave") Leave leave, @Param("studentIds") String[] studentIds);

    List<Leave> getLeavesByConditionAndStudentId(Leave leave);

    int deleteLeaveById(String id);

    int deleteLeaveByIds(String[] ids);

    int approval(@Param("id") String id, @Param("approver") String approver);

    int saveLeave(Leave leave);
}
