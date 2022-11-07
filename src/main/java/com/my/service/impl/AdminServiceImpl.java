package com.my.service.impl;

import com.my.entity.*;
import com.my.entity.Class;
import com.my.mapper.*;
import com.my.service.AdminService;
import com.my.utils.DateUtils;
import com.my.utils.MD5Util;
import com.my.utils.UUIDUtil;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Date;
import java.util.List;

@Service
public class AdminServiceImpl implements AdminService {

    @Resource
    private AdminMapper adminMapper;
    @Resource
    private TeacherMapper teacherMapper;
    @Resource
    private StudentMapper studentMapper;
    @Resource
    private ClassMapper classMapper;
    @Resource
    private DicProMapper dicProMapper;

    @Override
    public boolean setPwd(Admin admin) {
        boolean flag = false;
        int count = adminMapper.setPwd(admin);
        if (count > 0){
            flag = true;
        }
        return flag;
    }

    @Override
    public Admin login(String userName, String password) {
        return adminMapper.login(userName, password);
    }

    @Override
    public List<Teacher> getTeachers(Teacher teacher) {
        return adminMapper.getTeachers(teacher);
    }

    @Override
    public ReturnObject saveCreateTeacher(Teacher teacher) {
        String className = teacher.getClass_id();
        ReturnObject returnObject = new ReturnObject();

        List<String> phoneList = teacherMapper.getAllTeachersPhone();
        if (phoneList.contains(teacher.getPhone())){
            returnObject.setCode("316");
            returnObject.setMessage("手机号已存在");
            return returnObject;
        }

        if (className != ""){
            Class c = classMapper.selectClassByName(className);
            // 如果班级不存在，则创建
            if (null == c){
                DicPro dicPro = dicProMapper.queryDicProByShortName(className.substring(0, 2));
                if (null == dicPro){
                    returnObject.setCode("305");
                    returnObject.setMessage("教师添加失败,专业不存在！");
                    return returnObject;
                }
                c = new Class();
                c.setId(UUIDUtil.getUUID());
                c.setName(teacher.getClass_id());
                c.setPro_code(dicPro.getCode());
                classMapper.insertClass(c);
            }

            Class c2 = classMapper.selectClassByName(className);
            teacher.setClass_id(c2.getId());
        }

        teacher.setId(UUIDUtil.getUUID());
        teacher.setTeacherId("960"+teacher.getPhone());
        teacher.setCreateBy(teacher.getCreateBy());
        teacher.setCreateTime(DateUtils.formateDateTime(new Date()));
        teacher.setLockState("1");
        if ("未选择文件...".equals(teacher.getAvatar())){
            teacher.setAvatar("teacher.png");
        }

        int result = teacherMapper.saveCreateTeacher(teacher);
        if (result == 0){
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请销后重试...");
            return returnObject;
        }
        returnObject.setCode("200");
        returnObject.setMessage("教师添加成功");
        return returnObject;
    }

    @Override
    public boolean deleteTeacherByIds(String[] ids) {
        int result = teacherMapper.deleteTeacherByIds(ids);
        if (result >= 1){
            return true;
        }
        return false;
    }


    @Override
    public ReturnObject updateTeacher(Teacher teacher) {
        String className = teacher.getClass_id();
        ReturnObject returnObject = new ReturnObject();

        List<String> phoneList = teacherMapper.getAllTeachersPhone();
        if (phoneList.contains(teacher.getPhone())){
            returnObject.setCode("316");
            returnObject.setMessage("手机号已存在");
            return returnObject;
        }

        if (className != ""){
            Class c = classMapper.selectClassByName(className);
            // 如果班级不存在，则创建
            if (null == c){
                DicPro dicPro = dicProMapper.queryDicProByShortName(className.substring(0, 2));
                if (null == dicPro){
                    returnObject.setCode("307");
                    returnObject.setMessage("教师添加失败,专业不存在！");
                    return returnObject;
                }
                c = new Class();
                c.setId(UUIDUtil.getUUID());
                c.setName(teacher.getClass_id());
                c.setPro_code(dicPro.getCode());
                c.setNumber("0");
                c.setDep_code(dicPro.getCode().substring(0, 2));
                classMapper.insertClass(c);
            }

            Class c2 = classMapper.selectClassByName(className);
            teacher.setClass_id(c2.getId());
        }

        teacher.setTeacherId("960"+teacher.getPhone());
        teacher.setEditBy(teacher.getEditBy());
        teacher.setEditTime(DateUtils.formateDateTime(new Date()));

        int result = teacherMapper.updateTeacher(teacher);
        if (result == 0){
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请销后重试...");
            return returnObject;
        }
        returnObject.setCode("200");
        returnObject.setMessage("教师修改成功");
        return returnObject;
    }

    @Override
    public List<Teacher> getAllTeachers() {
        return teacherMapper.getAllTeachers();
    }

    @Override
    public List<Teacher> getTeachersByIds(String[] ids) {
        return teacherMapper.getTeachersByIds(ids);
    }


    @Override
    public ReturnObject saveTeachers(List<Teacher> teacherList) {
        Date date = new Date();
        ReturnObject returnObject = new ReturnObject();

        List<String> phoneList = teacherMapper.getAllTeachersPhone();
        for (Teacher t : teacherList){
            if (phoneList.contains(t.getPhone())){
                returnObject.setCode("316");
                returnObject.setMessage("手机号已存在");
                return returnObject;
            }
        }


        for (Teacher teacher : teacherList){
            String className = teacher.getClass_id();

            if (className != ""){
                Class c = classMapper.selectClassByName(className);
                // 如果班级不存在，则创建
                if (null == c){
                    DicPro dicPro = dicProMapper.queryDicProByShortName(className.substring(0, 2));
                    if (null == dicPro){
                        returnObject.setCode("307");
                        returnObject.setMessage("教师添加失败,专业不存在！");
                        return returnObject;
                    }
                    c = new Class();
                    c.setId(UUIDUtil.getUUID());
                    c.setName(teacher.getClass_id());
                    c.setPro_code(dicPro.getCode());
                    c.setDep_code(dicPro.getCode().substring(0, 2));
                    c.setNumber("0");
                    classMapper.insertClass(c);
                }

                Class c2 = classMapper.selectClassByName(className);
                teacher.setClass_id(c2.getId());
            }

            teacher.setId(UUIDUtil.getUUID());
            teacher.setAvatar("teacher.png");
            teacher.setTeacherId("960"+teacher.getPhone());
            teacher.setCreateBy(teacher.getCreateBy());
            teacher.setLockState("1");
            teacher.setCreateTime(DateUtils.formateDateTime(date));

        }

        int result = teacherMapper.saveTeachers(teacherList);
        if (result >= 1){
            returnObject.setCode("200");
            returnObject.setMessage("成功导入"+result+"条数据");
        } else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请销后重试...");
        }
        return returnObject;
    }


}
