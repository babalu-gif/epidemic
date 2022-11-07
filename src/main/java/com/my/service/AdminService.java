package com.my.service;

import com.my.entity.Admin;
import com.my.entity.ReturnObject;
import com.my.entity.Student;
import com.my.entity.Teacher;

import java.util.List;

public interface AdminService {

    Admin login(String userName, String password);

    boolean setPwd(Admin admin);

    List<Teacher> getTeachers(Teacher teacher);

    ReturnObject saveCreateTeacher(Teacher teacher);

    boolean deleteTeacherByIds(String[] ids);

    ReturnObject updateTeacher(Teacher teacher);

    List<Teacher> getAllTeachers();

    List<Teacher> getTeachersByIds(String[] ids);

    ReturnObject saveTeachers(List<Teacher> teacherList);


}
