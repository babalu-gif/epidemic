package com.my.service.impl;

import com.my.entity.Leave;
import com.my.mapper.LeaveMapper;
import com.my.service.LeaveService;
import com.my.utils.DateUtils;
import com.my.utils.UUIDUtil;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Date;
import java.util.List;
@Service
public class LeaveServiceImpl implements LeaveService {

    @Resource
    private LeaveMapper leaveMapper;

    @Override
    public List<Leave> getLeavesByCondition(Leave leave) {
        return leaveMapper.getLeavesByCondition(leave);
    }

    @Override
    public List<Leave> getLeavesByConditionAndClassId(Leave leave, String[] studentIds) {
        return leaveMapper.getLeavesByConditionAndClassId(leave, studentIds);
    }

    @Override
    public List<Leave> getLeavesByConditionAndStudentId(Leave leave) {
        return leaveMapper.getLeavesByConditionAndStudentId(leave);
    }

    @Override
    public boolean deleteLeaveById(String id) {
        int result = leaveMapper.deleteLeaveById(id);
        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public boolean deleteLeaveByIds(String[] ids) {
        int result = leaveMapper.deleteLeaveByIds(ids);
        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public boolean approval(String id, String approver) {
        int result = leaveMapper.approval(id, approver);
        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public boolean saveLeave(Leave leave) {
        leave.setId(UUIDUtil.getUUID());
        leave.setIsApproval("0");
        leave.setCreateTime(DateUtils.formateDateTime(new Date()));
        int result = leaveMapper.saveLeave(leave);
        if (result >= 1){
            return true;
        }
        return false;
    }
}
