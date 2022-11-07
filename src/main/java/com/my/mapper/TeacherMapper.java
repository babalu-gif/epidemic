package com.my.mapper;

import com.my.entity.Admin;
import com.my.entity.Student;
import com.my.entity.Teacher;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface TeacherMapper {
    int saveCreateTeacher(Teacher teacher);

    int deleteTeacherById(String id);

    int deleteTeacherByIds(String[] ids);

    Teacher queryTeacherById(String id);

    int updateTeacher(Teacher teacher);

    List<Teacher> getAllTeachers();

    List<Teacher> getTeachersByIds(String[] ids);

    int saveTeachers(List<Teacher> teacherList);

    List<String> getAllTeachersPhone();

    int resetPassword(Teacher teacher);

    Teacher login(@Param("userName") String teacherId, @Param("password") String password);

    int setPwd(Teacher teacher);

    int setAvatar(@Param("id") String id, @Param("avatar") String avatar);

    List<Student> getStudentByTeacherClassId(@Param("student") Student student, @Param("ci") String ci);

}
