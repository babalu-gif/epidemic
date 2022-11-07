package com.my.service.impl;

import com.my.entity.*;
import com.my.entity.Class;
import com.my.mapper.ClassMapper;
import com.my.mapper.DicProMapper;
import com.my.mapper.StudentMapper;
import com.my.mapper.TeacherMapper;
import com.my.service.TeacherService;
import com.my.utils.DateUtils;
import com.my.utils.UUIDUtil;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Date;
import java.util.List;

@Service
public class TeacherServiceImpl implements TeacherService {

    @Resource
    private TeacherMapper teacherMapper;
    @Resource
    private StudentMapper studentMapper;

    @Override
    public boolean deleteTeacherById(String id) {
        boolean flag = false;
        int result = teacherMapper.deleteTeacherById(id);
        if (result >= 1){
            flag = true;
        }
        return flag;
    }

    @Override
    public Teacher queryTeacherById(String id) {
        return teacherMapper.queryTeacherById(id);
    }

    @Override
    public boolean resetPassword(Teacher teacher) {
        int result = teacherMapper.resetPassword(teacher);
        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public Teacher login(String userName, String password) {
        Teacher teacher = teacherMapper.login(userName, password);
        return teacher;
    }

    @Override
    public boolean setPwd(Teacher teacher) {
        boolean flag = false;
        int count = teacherMapper.setPwd(teacher);
        if (count > 0){
            flag = true;
        }
        return flag;
    }

    @Override
    public boolean setAvatar(String id, String avatar) {
        boolean flag = false;
        int count = teacherMapper.setAvatar(id, avatar);
        if (count > 0){
            flag = true;
        }
        return flag;
    }

    @Override
    public List<Student> getStudentByTeacherClassId(Student student, String classId) {
        return teacherMapper.getStudentByTeacherClassId(student, classId);
    }

    @Override
    public List<Student> getPunchByConditionAndClassId(Student student, String[] studentIds) {
        return studentMapper.getPunchByConditionAndClassId(student, studentIds);
    }
}
