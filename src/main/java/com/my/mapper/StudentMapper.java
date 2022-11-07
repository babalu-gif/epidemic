package com.my.mapper;

import com.my.entity.Student;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface StudentMapper {
    List<Student> getStudents(Student student);

    int saveStudent(Student student);

    int getClassPersonNumber(String class_id);

    Student queryStudentById(String id);

    int deleteStudentByIds(String[] ids);

    int deleteStudentById(String id);

    int updateStudent(Student student);

    List<Student> getAllStudents();

    List<Student> getStudentByIds(String[] ids);

    List<Student> getNotClockStudents();

    List<Student> getNotClockStudentsByStudentIds(String[] studentIds);

    List<Student> getNotTourStudents();

    List<Student> getNotTourStudentsByStudentIds(String[] studentIds);

    List<Student> getNotHealthStudents();

    List<Student> getNotHealthStudentsByStudentIds(String[] studentIds);

    int saveStudents(List<Student> studentList);

    int resetPassword(Student student);

    int resetHealthAndTourCode(Student student);

    int resetPunch(Student student);

    int updateHealthCode(@Param("id") String id,@Param("healthCode") String healthCode);

    int updateTourCode(@Param("id") String id,@Param("tourCode") String tourCode);

    List<Student> queryAllStudentsByClassId(String ci);

    List<Student> getStudentByIdsAndClassId(String[] ids);

    String[] queryStudentsByClassId(String ci);

    List<Student> getPunchByConditionAndClassId(@Param("student") Student student, @Param("studentIds") String[] studentIds);

    Student login(@Param("id_number") String id_number, @Param("password") String password);

    int setStudentPwd(@Param("id") String id, @Param("password") String password);

    int setAvatar(@Param("id") String id, @Param("avatar") String avatar);

    int punch(String id);
}
