package com.my.service;

import com.my.entity.Leave;

import java.util.List;

public interface LeaveService {
    List<Leave> getLeavesByCondition(Leave leave);

    List<Leave> getLeavesByConditionAndClassId(Leave leave, String[] studentId);

    List<Leave> getLeavesByConditionAndStudentId(Leave leave);

    boolean deleteLeaveById(String id);

    boolean deleteLeaveByIds(String[] ids);

    boolean approval(String id, String approver);

    boolean saveLeave(Leave leave);
}
