package com.my.service;

import com.my.entity.Admin;
import com.my.entity.Student;
import com.my.entity.Teacher;

import java.util.List;

public interface TeacherService {
    boolean deleteTeacherById(String id);

    Teacher queryTeacherById(String id);

    boolean resetPassword(Teacher teacher);

    Teacher login(String userName, String password);

    boolean setPwd(Teacher teacher);

    boolean setAvatar(String id,  String avatar);

    List<Student> getStudentByTeacherClassId(Student student, String classId);

    List<Student> getPunchByConditionAndClassId(Student student, String[] studentIds);
}
